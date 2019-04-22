/*
	Copyright (C) 2019 Balena Ltd.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published
	by the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import * as Bluebird from 'bluebird';
import { ChildProcess, spawn } from 'child_process';
import { EventEmitter } from 'eventemitter3';
import * as net from 'net';
import VpnConnector = require('telnet-openvpn');

import { Netmask } from './netmask';

const parsePossibleInt = (s: string): number | string => {
	if (/^[1-9]\d*$/.test(s)) {
		return parseInt(s, 10);
	}
	return s;
};

export interface VpnClientUntrustedData {
	username: string;
}
export interface VpnClientTrustedData {
	common_name: string;
	ifconfig_pool_remote_ip: string;
	trusted_ip: string;
	trusted_port: number;
}
export interface VpnClientBytecountData {
	bytes_received: number;
	bytes_sent: number;
}
// CLIENT:CONNECT
export interface VpnClientConnectData extends VpnClientUntrustedData {
	password: string;
}
// CLIENT:ESTABLISHED
export interface VpnClientEstablishedData
	extends VpnClientUntrustedData,
		VpnClientTrustedData {}
// CLIENT:DISCONNECT
export interface VpnClientDisconnectData
	extends VpnClientUntrustedData,
		Partial<VpnClientTrustedData>,
		Partial<VpnClientBytecountData> {
	time_duration: number;
}

export const isTrusted = (data: any): data is VpnClientTrustedData =>
	data.common_name != null;
export const hasBytecountData = (data: any): data is VpnClientBytecountData =>
	data.bytes_received != null && data.bytes_sent != null;

const VpnLogLevels = {
	D: 'debug',
	I: 'info',
	n: 'notice',
	W: 'warning',
	N: 'error',
	F: 'emerg',
} as const;
type ValueOf<T> = T[keyof T];

export declare interface VpnManager {
	on(event: 'process:error', callback?: (err: Error) => void): this;
	on(
		event: 'process:exit',
		callback?: (code?: number, signal?: string) => void,
	): this;
	on(event: 'manager:connect', callback?: () => void): this;
	on(event: 'manager:data', callback?: (data: string) => void): this;
	on(
		event: 'log',
		callback?: (level: ValueOf<typeof VpnLogLevels>, message: string) => void,
	): this;
	on(
		event: 'client:connect',
		callback?: (
			clientId: number,
			keyId: number,
			data: VpnClientConnectData,
		) => void,
	): this;
	on(
		event: 'client:address',
		callback?: (clientId: number, address: string, primary: boolean) => void,
	): this;
	on(
		event: 'client:established',
		callback?: (clientId: number, data: VpnClientEstablishedData) => void,
	): this;
	on(
		event: 'client:bytecount',
		callback?: (clientId: number, data: VpnClientBytecountData) => void,
	): this;
	on(
		event: 'client:disconnect',
		callback?: (clientId: number, data: VpnClientDisconnectData) => void,
	): this;
}

export class VpnManager extends EventEmitter {
	private process?: ChildProcess;
	private readonly connector = new VpnConnector();
	private buf?: string;

	constructor(
		private instanceId: number,
		private vpnPort: number,
		private mgtPort: number,
		private subnet: Netmask,
		private gateway?: string,
	) {
		super();
		// proxy `data` events from connector, splitting at newlines
		this.connector.connection.on('data', data => {
			const lines = ((this.buf || '') + data.toString()).split(/\r?\n/);
			this.buf = lines.pop();
			for (const line of lines) {
				this.emit('manager:data', line.trim());
			}
		});
		// subscribe to our own raw data events in order to generate structured events
		this.on('manager:data', this.dataHandler);
	}

	private args() {
		const gateway = this.gateway || this.subnet.first;
		return [
			'--status',
			`/run/openvpn/server-${this.instanceId}.status`,
			'10',
			'--cd',
			'/etc/openvpn',
			'--config',
			'/etc/openvpn/server.conf',
			'--verb',
			'3',
			'--dev',
			`tun${this.instanceId}`,
			'--port',
			`${this.vpnPort}`,
			'--management',
			'127.0.0.1',
			`${this.mgtPort}`,
			'--management-hold',
			'--ifconfig',
			gateway,
			this.subnet.second,
			'--ifconfig-pool',
			this.subnet.third,
			this.subnet.last,
			'--route',
			this.subnet.base,
			this.subnet.mask,
			'--push',
			`route ${gateway}`,
			'--management-client-auth',
		];
	}

	private dataHandler = (data: string) => {
		if (data.startsWith('>LOG:')) {
			// >LOG:{timestamp},{level},{message}
			const logData = data.substr(5);
			const [, level, ...message] = logData.split(',');
			this.emit(
				'log',
				VpnLogLevels[(level as keyof typeof VpnLogLevels) || 'n'],
				message.join(','),
			);
		} else if (data.startsWith('>CLIENT:')) {
			// >CLIENT:{event},{clientId},{...args}
			// >CLIENT:ENV,{key}={value}
			// >CLIENT:END
			const eventData = data.substr('>CLIENT:'.length);
			for (const eventType of [
				'connect',
				'address',
				'established',
				'disconnect',
			]) {
				if (eventData.startsWith(eventType.toUpperCase())) {
					const [clientId, ...eventArgs] = eventData
						.substr(eventType.length + 1)
						.split(',');
					this.off('manager:data', this.dataHandler);
					this.on(
						'manager:data',
						this.clientEventEmitterFactory(
							eventType,
							parseInt(clientId, 10),
							eventArgs,
						),
					);
				}
			}
		} else if (data.startsWith('>BYTECOUNT_CLI:')) {
			// >BYTECOUNT_CLI:{clientId},{bytesRx},{bytesTx}
			const [clientId, bytesReceived, bytesSent] = data
				.substr('>BYTECOUNT_CLI:'.length)
				.split(',');
			this.emit('client:bytecount', parseInt(clientId, 10), {
				bytes_received: parseInt(bytesReceived, 10),
				bytes_sent: parseInt(bytesSent, 10),
			});
		}
	};

	private clientEventEmitterFactory = (
		eventName: string,
		clientId: number,
		eventArgs: string[] = [],
	) => {
		const env: { [key: string]: number | string } = {};
		const emitter = (data: string) => {
			if (data.startsWith('>CLIENT:ENV') && data !== '>CLIENT:ENV,END') {
				// >CLIENT:ENV,key=val
				const envData = data.substr('>CLIENT:ENV'.length + 1);
				const [key, val] = envData.split('=');
				env[key] = parsePossibleInt(val);
			} else {
				this.off('manager:data', emitter);
				this.on('manager:data', this.dataHandler);
				this.emit(
					`client:${eventName}`,
					clientId,
					...eventArgs.map(parsePossibleInt),
					env,
				);
				// re-emit the last message if it was not `CLIENT:ENV,END`
				if (data !== '>CLIENT:ENV,END') {
					this.emit('manager:data', data);
				}
			}
		};
		return emitter;
	};

	public start(): Bluebird<true> {
		this.process = spawn('/usr/sbin/openvpn', this.args(), { stdio: 'ignore' });
		// proxy error events from the child process
		this.process.on('error', err => {
			this.emit('process:error', err);
		});
		this.process.on('exit', (code, signal) => {
			this.emit('process:exit', code, signal);
		});

		return this.waitForStart();
	}

	private waitForStart(since: number = Date.now()): Bluebird<true> {
		return new Bluebird((resolve, reject) => {
			const socket = new net.Socket();
			const errorHandler = () => {
				socket.destroy();
				reject(new Error('socket not ready'));
			};
			const readyHandler = () => {
				socket.end();
				resolve(true);
			};
			socket.on('ready', readyHandler);
			socket.on('error', errorHandler);
			socket.on('timeout', errorHandler);
			socket.connect(this.mgtPort);
		})
			.timeout(5000 - (Date.now() - since))
			.catch(err => {
				if (err instanceof Bluebird.TimeoutError) {
					throw err;
				}
				return this.waitForStart(since);
			})
			.return(true);
	}

	public connect(): Bluebird<true> {
		return Bluebird.try(() =>
			this.connector
				.connect({
					port: this.mgtPort,
					shellPrompt: '',
				})
				.then(() => {
					this.emit('manager:connect');
				}),
		).return(true);
	}

	public exec(command: string): Bluebird<true> {
		return Bluebird.try(() => this.connector.exec(command)).return(true);
	}

	public enableLogging() {
		return this.exec('log on all');
	}

	public enableBytecountReporting(interval: number) {
		return this.exec(`bytecount ${interval}`);
	}

	public releaseHold() {
		return this.exec('hold release');
	}
}
