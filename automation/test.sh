#!/usr/bin/env sh

# Copyright (C) 2015 Balena Ltd.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -eu
cleanup() {
	exit_code=$?
	test -n "${test_id}" && docker rm -f "${test_id}" >/dev/null
	exit $exit_code
}
trap cleanup EXIT

WORKDIR="$(dirname "$0")/.."
cd "${WORKDIR}"

test_id=$(docker run --privileged -d \
	--tmpfs /run \
	--tmpfs /sys/fs/cgroup \
	-e BALENA_VPN_PRODUCTION=false \
	-e BALENA_API_HOST=api.balena.test \
	-e BALENA_VPN_PORT=443 \
	-e VPN_BASE_SUBNET=100.64.0.0/10 \
	-e VPN_INSTANCE_SUBNET_BITMASK=20 \
	-e VPN_BASE_PORT=10000 \
	-e VPN_BASE_MANAGEMENT_PORT=20000 \
	-e VPN_API_PORT=30000 \
	-e VPN_HOST=127.0.0.1 \
	-e VPN_CONNECT_INSTANCE_COUNT=1 \
	-e VPN_CONNECT_PROXY_PORT=3128 \
	-e API_SERVICE_API_KEY=test_api_key \
	-e PROXY_SERVICE_API_KEY=test_proxy_key \
	-e VPN_SERVICE_API_KEY=test_vpn_key \
	-e BALENA_ROOT_CA=LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPekNDQWlPZ0F3SUJBZ0lKQUl2N05FNHRWMExmTUEwR0NTcUdTSWIzRFFFQkN3VUFNQmd4RmpBVUJnTlYKQkFNTURXTmhMbkpsYzJsdUxuUmxjM1F3SGhjTk1UZ3dPVEkzTVRZeE5UTTNXaGNOTWpnd09USTBNVFl4TlRNMwpXakFZTVJZd0ZBWURWUVFEREExallTNXlaWE5wYmk1MFpYTjBNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DCkFROEFNSUlCQ2dLQ0FRRUE4ZzAxOE1hRHJ1MjZYT0I4Z0hTLzNqR3JyRzdveWpsRHQ3S2pFbkUwb0NpRVVodXoKT0VvN0tuaUt0WHkwQVNud08yYkdRb3Z3Zm4xYW9oUE9oMjhCMCswSmk1VS9iN01mSW9iTGw2TjVDeHBycmRGdApwa3VsWWUrVDVUSDdqSEJ1cGtTNGhjT2ZRRGw0V1BzQ1dFZjVaRnRMWDRJZHVUMGh4ZHpQRnNlaHBSRjNVa1hUCk9kZG1kK0UwcWpxY1BtbFNPeW5JckhoNDJLcFNGRmF1WVBkOWtPcXpzVHg4blZzYVgwazVjRmJXb1BSRGV2NWoKOWw1eDdoVSs1UnptTTFYRDFlcENDT0xLYVVZZmRlRTlxenIrbmJRUEIveGlvdXA0aUpwSXV2d0U3TUVNNkNsdgp2TWxBMktFTnRZbVRKbU1NeU1YT3VkYldvOFJXSUFYQm5wTmRsd0lEQVFBQm80R0hNSUdFTUIwR0ExVWREZ1FXCkJCUUlSK3JMYUMyelZ2cXJQRzlFUGVId1pSdC9sakJJQmdOVkhTTUVRVEEvZ0JRSVIrckxhQzJ6VnZxclBHOUUKUGVId1pSdC9scUVjcEJvd0dERVdNQlFHQTFVRUF3d05ZMkV1Y21WemFXNHVkR1Z6ZElJSkFJdjdORTR0VjBMZgpNQXdHQTFVZEV3UUZNQU1CQWY4d0N3WURWUjBQQkFRREFnRUdNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUFtCllOeFliWkkxZ3R6cFlrMXVkWUR4MFZVMWlBby9xRE14RU1rdmVKS294Um5vYXhDakRWRzFWZmhMMlZIY0pxZnoKakZpcHUrYVdqT0pibkVHMzc4TWZCd24xTnFHVjVPbGlrN3lxWEY4cDhRRysrNXI0eWRMaGgzbkVrVGlyQmplcgo0ck1mUDZzMGIrcnJCbHpBOFpXTDNsdlFVMmg0cGVrZGNyWHR0aXZFblhiTmpBTy9XbVIrUHNhWW0wRnE2RW9OCmkydHpycVZsditJQ1lJZ0pTVDEyWnhVMWhZblB3NTg1S0xuT09mV2V4WUVZVlNIQ1RwQ0c3cmhUbEZQNEQ4b2YKUElqbGJKNlpMd0Q3RDltZng4ejBEQ1ZOeWFvZkFvaHFibXUzNmhxNjRUMnRhYXQwbjZkZHNhWmdSYW9xcFJ6Zwo0YkNYK2hWNko3Q1B3K0VQODNjRQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg== \
	-e VPN_OPENVPN_CA_CRT=Q2VydGlmaWNhdGU6CiAgICBEYXRhOgogICAgICAgIFZlcnNpb246IDMgKDB4MikKICAgICAgICBTZXJpYWwgTnVtYmVyOgogICAgICAgICAgICAzMDowZjo4MjphNzo0YToyYzoxMjplYjo0Nzo5YTplOTpmZDo2YTo5MDphMTphZQogICAgU2lnbmF0dXJlIEFsZ29yaXRobTogc2hhMjU2V2l0aFJTQUVuY3J5cHRpb24KICAgICAgICBJc3N1ZXI6IENOPWNhLnJlc2luLnRlc3QKICAgICAgICBWYWxpZGl0eQogICAgICAgICAgICBOb3QgQmVmb3JlOiBTZXAgMjcgMTY6MTU6MzggMjAxOCBHTVQKICAgICAgICAgICAgTm90IEFmdGVyIDogU2VwIDExIDE2OjE1OjM4IDIwMjEgR01UCiAgICAgICAgU3ViamVjdDogQ049dnBuLWNhLnJlc2luLnRlc3QKICAgICAgICBTdWJqZWN0IFB1YmxpYyBLZXkgSW5mbzoKICAgICAgICAgICAgUHVibGljIEtleSBBbGdvcml0aG06IHJzYUVuY3J5cHRpb24KICAgICAgICAgICAgICAgIFB1YmxpYy1LZXk6ICgyMDQ4IGJpdCkKICAgICAgICAgICAgICAgIE1vZHVsdXM6CiAgICAgICAgICAgICAgICAgICAgMDA6ZTI6OWM6ZGM6ZjU6ZDI6NTY6NDA6Yjc6NDg6ZTM6ZWI6YjI6ZDQ6NWM6CiAgICAgICAgICAgICAgICAgICAgNTQ6ZWI6MzA6ZTg6MzY6ZmY6ZTI6MmE6OTk6OTE6NGY6ZGM6YTE6M2E6YjI6CiAgICAgICAgICAgICAgICAgICAgYjU6NmU6NGE6ZWQ6YTM6NGE6MjQ6NmI6ZmM6MDY6ZTE6ZGE6MjE6NGU6ZDg6CiAgICAgICAgICAgICAgICAgICAgMzI6YmE6NDc6MGE6ZWE6NTM6Njc6YzY6MDM6MzU6MTY6NTk6YjU6OTA6Mjg6CiAgICAgICAgICAgICAgICAgICAgMDg6MjY6NmU6OWE6NTM6ZDg6ZWY6YjY6NWQ6OGU6MzQ6MDI6Zjc6YzY6NTU6CiAgICAgICAgICAgICAgICAgICAgODg6M2Y6NDk6MzE6NzA6ZTI6OTg6ZTE6NWM6OGU6Mjg6NTQ6ZDE6NjY6MjI6CiAgICAgICAgICAgICAgICAgICAgZTQ6ODI6YTY6NzY6MDU6Y2E6ODU6OWY6ODE6OTg6YTY6NDE6NzU6YWU6ZGY6CiAgICAgICAgICAgICAgICAgICAgZjU6YmE6MTY6NjY6OTE6M2E6ZjU6MTI6ZmM6NGQ6ZmM6NDM6YzY6NTY6MTI6CiAgICAgICAgICAgICAgICAgICAgYTM6YzA6OGM6OGQ6MmQ6NDc6NGE6MzU6MmE6YTE6OGM6NGU6ZjY6ZjA6Y2M6CiAgICAgICAgICAgICAgICAgICAgNmU6MGM6M2E6MTA6ZGQ6NzY6Mzk6ZWU6OWY6NTU6OWY6NzE6ZGI6Zjc6MTI6CiAgICAgICAgICAgICAgICAgICAgNDY6OTc6NWY6NWE6ZDM6NzA6ZjU6YjQ6Y2E6M2I6MTQ6MTE6ZDU6MjY6MGE6CiAgICAgICAgICAgICAgICAgICAgYzM6YTg6MzM6NGU6YWE6Y2M6YzI6YTg6M2M6YWY6YWU6OWE6YjY6Mjk6YzY6CiAgICAgICAgICAgICAgICAgICAgZTk6YmI6YjU6YWY6NTg6ZTk6OTk6ZTU6YTQ6NmQ6NmI6YzA6ZTY6ZGQ6NTc6CiAgICAgICAgICAgICAgICAgICAgMmU6ZWQ6ZTM6Y2U6YzE6YzQ6NGI6ZWU6Y2I6ZDE6NzA6NGE6OGY6ODc6ZWQ6CiAgICAgICAgICAgICAgICAgICAgYzA6NWQ6Mzk6ZGQ6ODM6Njc6YWQ6Mzc6MGU6ZDM6ZWE6ZWU6OWY6YjA6ZTA6CiAgICAgICAgICAgICAgICAgICAgY2I6YjQ6NDY6OTU6NTA6OGI6NGU6YzE6OGI6ODU6NWE6NDA6NmY6NmE6NjU6CiAgICAgICAgICAgICAgICAgICAgNjg6ZWY6ZjI6ZWM6ZjM6MmI6Zjk6Y2M6Y2Y6MGE6NGY6YTQ6NGQ6ODM6NDA6CiAgICAgICAgICAgICAgICAgICAgZDI6MDkKICAgICAgICAgICAgICAgIEV4cG9uZW50OiA2NTUzNyAoMHgxMDAwMSkKICAgICAgICBYNTA5djMgZXh0ZW5zaW9uczoKICAgICAgICAgICAgWDUwOXYzIEJhc2ljIENvbnN0cmFpbnRzOiAKICAgICAgICAgICAgICAgIENBOlRSVUUKICAgICAgICAgICAgWDUwOXYzIFN1YmplY3QgS2V5IElkZW50aWZpZXI6IAogICAgICAgICAgICAgICAgQkY6OTA6NzQ6Mjg6N0Q6NzI6MDk6MDU6Q0E6Q0I6NEE6ODY6NTQ6MTg6RTE6REQ6REY6RDc6MDM6MEUKICAgICAgICAgICAgWDUwOXYzIEF1dGhvcml0eSBLZXkgSWRlbnRpZmllcjogCiAgICAgICAgICAgICAgICBrZXlpZDowODo0NzpFQTpDQjo2ODoyRDpCMzo1NjpGQTpBQjozQzo2Rjo0NDozRDpFMTpGMDo2NToxQjo3Rjo5NgogICAgICAgICAgICAgICAgRGlyTmFtZTovQ049Y2EucmVzaW4udGVzdAogICAgICAgICAgICAgICAgc2VyaWFsOjhCOkZCOjM0OjRFOjJEOjU3OjQyOkRGCgogICAgICAgICAgICBYNTA5djMgS2V5IFVzYWdlOiAKICAgICAgICAgICAgICAgIENlcnRpZmljYXRlIFNpZ24sIENSTCBTaWduCiAgICBTaWduYXR1cmUgQWxnb3JpdGhtOiBzaGEyNTZXaXRoUlNBRW5jcnlwdGlvbgogICAgICAgICBkZDo0NDo2NDpmZjpiODo5YzpiYjo1MTo2MjoxNToxZjo1NDoyMDowNzphZjpmMzpkNzpiNDoKICAgICAgICAgNTg6Y2I6YTU6ZDQ6ZTY6ODQ6NGE6ODI6NmI6YjE6MDA6NGE6NGM6ODE6NDI6Y2I6NmE6YTQ6CiAgICAgICAgIDc3OjBlOjliOmJmOjNlOmNjOjg3OjNkOjJjOmZlOmE1OjQ3OmQyOjBlOjQ4OmRlOjdhOjA2OgogICAgICAgICA2MDpiNjpkYzoxMDo5MDoxNjpkMTo2MDphMjoyNTpmNDpiNDo1NTo2MzowZTplNzo5NTo4NzoKICAgICAgICAgN2Q6ZmQ6ZmE6YTY6Zjg6Mjg6M2U6ZDI6M2I6NTQ6NjU6NWY6NTM6ZTQ6NGM6Y2M6Nzc6MTE6CiAgICAgICAgIDc3OmUzOmEwOjQ4OjU1OjYyOmVmOjU0OmRjOmI4OjI0OmMyOjZlOjQxOmFkOjJmOmQxOjk4OgogICAgICAgICA4ZjpiZTpjMzplMTpkYjoxNzowMDpjYTo0Zjo1Mjo1ODplMTpiMjoyYjozYjo5YTpjMjpkOToKICAgICAgICAgMDg6MjY6M2I6YzY6M2Y6ZDQ6ZmM6ZTM6M2U6OGE6N2Y6YWQ6OTE6ZGI6ZDM6NzI6Zjg6MmI6CiAgICAgICAgIDM3OmFjOjhlOjMzOmJjOmFjOmU5OmFhOjlkOjJmOmQ1OjUwOmUwOmNkOjRlOjIzOjNiOjEzOgogICAgICAgICBjMzoxYTpmNjplNzo4Yjo4MjozMzozNzpiMzozMToxMDo4ZDpjNDoyMDowNDozODozMTpmNToKICAgICAgICAgYTg6OTg6OTM6ZmQ6N2Q6MjM6MGY6OGU6NWQ6ZWE6N2U6ODk6ZmQ6Y2U6MmY6MDE6MWI6OTI6CiAgICAgICAgIDVhOjc1OmUwOjA5OjZlOjE0OjUwOjU5OmFmOjIyOjQ1OmQxOjg2OmNlOjFlOmYyOmEyOmEwOgogICAgICAgICA1MToyMTo0Nzo5Njo3MTpmMTo3ZjplNjozMDpmODphOTpmYzozZjpjNTo0NDpkODoxYjpjZDoKICAgICAgICAgZmU6MmU6OTQ6MDA6YTU6MGU6MTU6NDc6Mjk6NzA6NjI6NjE6MWE6MTg6MzM6YzQ6MTM6NDE6CiAgICAgICAgIDIzOjI0Ojg0Ojk3Ci0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEUmpDQ0FpNmdBd0lCQWdJUU1BK0NwMG9zRXV0SG11bjlhcENocmpBTkJna3Foa2lHOXcwQkFRc0ZBREFZCk1SWXdGQVlEVlFRRERBMWpZUzV5WlhOcGJpNTBaWE4wTUI0WERURTRNRGt5TnpFMk1UVXpPRm9YRFRJeE1Ea3gKTVRFMk1UVXpPRm93SERFYU1CZ0dBMVVFQXd3UmRuQnVMV05oTG5KbGMybHVMblJsYzNRd2dnRWlNQTBHQ1NxRwpTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEaW5OejEwbFpBdDBqajY3TFVYRlRyTU9nMi8rSXFtWkZQCjNLRTZzclZ1U3UyalNpUnIvQWJoMmlGTzJESzZSd3JxVTJmR0F6VVdXYldRS0FnbWJwcFQyTysyWFk0MEF2ZkcKVllnL1NURnc0cGpoWEk0b1ZORm1JdVNDcG5ZRnlvV2ZnWmltUVhXdTMvVzZGbWFST3ZVUy9FMzhROFpXRXFQQQpqSTB0UjBvMUtxR01UdmJ3ekc0TU9oRGRkam51bjFXZmNkdjNFa2FYWDFyVGNQVzB5anNVRWRVbUNzT29NMDZxCnpNS29QSyt1bXJZcHh1bTd0YTlZNlpubHBHMXJ3T2JkVnk3dDQ4N0J4RXZ1eTlGd1NvK0g3Y0JkT2QyRFo2MDMKRHRQcTdwK3c0TXUwUnBWUWkwN0JpNFZhUUc5cVpXanY4dXp6Sy9uTXp3cFBwRTJEUU5JSkFnTUJBQUdqZ1ljdwpnWVF3REFZRFZSMFRCQVV3QXdFQi96QWRCZ05WSFE0RUZnUVV2NUIwS0gxeUNRWEt5MHFHVkJqaDNkL1hBdzR3ClNBWURWUjBqQkVFd1A0QVVDRWZxeTJndHMxYjZxenh2UkQzaDhHVWJmNWFoSEtRYU1CZ3hGakFVQmdOVkJBTU0KRFdOaExuSmxjMmx1TG5SbGMzU0NDUUNMK3pST0xWZEMzekFMQmdOVkhROEVCQU1DQVFZd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBTjFFWlArNG5MdFJZaFVmVkNBSHIvUFh0RmpMcGRUbWhFcUNhN0VBU2t5QlFzdHFwSGNPCm03OCt6SWM5TFA2bFI5SU9TTjU2Qm1DMjNCQ1FGdEZnb2lYMHRGVmpEdWVWaDMzOStxYjRLRDdTTzFSbFgxUGsKVE14M0VYZmpvRWhWWXU5VTNMZ2t3bTVCclMvUm1JKyt3K0hiRndES1QxSlk0YklyTzVyQzJRZ21POFkvMVB6agpQb3AvclpIYjAzTDRLemVzampPOHJPbXFuUy9WVU9ETlRpTTdFOE1hOXVlTGdqTTNzekVRamNRZ0JEZ3g5YWlZCmsvMTlJdytPWGVwK2lmM09Md0Via2xwMTRBbHVGRkJacnlKRjBZYk9Idktpb0ZFaFI1Wng4WC9tTVBpcC9EL0YKUk5nYnpmNHVsQUNsRGhWSEtYQmlZUm9ZTThRVFFTTWtoSmM9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K \
	-e VPN_OPENVPN_SERVER_CRT=Q2VydGlmaWNhdGU6CiAgICBEYXRhOgogICAgICAgIFZlcnNpb246IDMgKDB4MikKICAgICAgICBTZXJpYWwgTnVtYmVyOgogICAgICAgICAgICA3OTpmNTplNzpkYjo4YTo2MjpmMTphMzphMTpiZDpjNDo4NzplNzpiNzo3Mjo2OAogICAgU2lnbmF0dXJlIEFsZ29yaXRobTogc2hhMjU2V2l0aFJTQUVuY3J5cHRpb24KICAgICAgICBJc3N1ZXI6IENOPXZwbi1jYS5yZXNpbi50ZXN0CiAgICAgICAgVmFsaWRpdHkKICAgICAgICAgICAgTm90IEJlZm9yZTogU2VwIDI3IDE2OjE1OjM4IDIwMTggR01UCiAgICAgICAgICAgIE5vdCBBZnRlciA6IFNlcCAyNiAxNjoxNTozOCAyMDIwIEdNVAogICAgICAgIFN1YmplY3Q6IENOPXZwbi5yZXNpbi50ZXN0CiAgICAgICAgU3ViamVjdCBQdWJsaWMgS2V5IEluZm86CiAgICAgICAgICAgIFB1YmxpYyBLZXkgQWxnb3JpdGhtOiByc2FFbmNyeXB0aW9uCiAgICAgICAgICAgICAgICBQdWJsaWMtS2V5OiAoMjA0OCBiaXQpCiAgICAgICAgICAgICAgICBNb2R1bHVzOgogICAgICAgICAgICAgICAgICAgIDAwOmFmOjBjOjlmOmYyOjg0OjAwOjMwOjBjOmI3OjI5OjVlOjk3OjgwOjc1OgogICAgICAgICAgICAgICAgICAgIGQ1OjA1OjkyOjBjOjAzOjhhOjIzOjg0Ojk3OmY0OmMwOmM4OmNhOmQ4OjM2OgogICAgICAgICAgICAgICAgICAgIGZmOjg1OjM1OmQ5Ojk4OjA5OjYxOjA2OjkzOjA5OmJlOjljOjNiOmY3OjVkOgogICAgICAgICAgICAgICAgICAgIDljOjg5OmIzOmMyOjBiOjE4OjM4OmY3OjkzOmY2OjhiOmRmOmU2OjI1Ojc5OgogICAgICAgICAgICAgICAgICAgIDljOmE1OmYwOjhiOjk1Ojg3OmExOjU2OjYxOmM2OjZiOmIzOjQ4OjhhOmQ1OgogICAgICAgICAgICAgICAgICAgIGMwOmM3OjJjOjI4OjY5OjgwOjY5OmRkOmI4OjZmOmEzOjE3OjhmOjg4OjYyOgogICAgICAgICAgICAgICAgICAgIGZiOmUxOjI5OjQ1Ojk5OjQwOjk5OjQyOmNhOjkzOjE2OjI0OjZjOmQzOjljOgogICAgICAgICAgICAgICAgICAgIDE1OjhmOmRjOjJkOjUyOmE1OjVhOjU1OjBlOjM2OmMwOmQ4OmQ0OjM1OmVjOgogICAgICAgICAgICAgICAgICAgIDczOjg1OjhkOmFhOjk5OjEyOmM3OmJmOjJhOjk0OmE4OjY0OjliOjU2OmY3OgogICAgICAgICAgICAgICAgICAgIGM0OjQyOjIyOjY2OjQ5OmRkOmRmOmQ3OjI0OjhhOmVhOmFiOjM3OmUzOmI4OgogICAgICAgICAgICAgICAgICAgIGJhOjEzOmY5OjM4OmNmOmY0OjExOmIyOmQ5OjA1OjQ1OmMwOmJkOjQ2OjBlOgogICAgICAgICAgICAgICAgICAgIDVmOmU5OjRjOmE2OmEzOjkwOmIzOjgzOmI1OjAyOmVjOjY2OjcwOmMxOjQyOgogICAgICAgICAgICAgICAgICAgIGZiOmI2OjQ4OmNiOjdjOjgwOmJlOjRkOjVhOjRlOmYxOjUzOmEyOjk4OmE0OgogICAgICAgICAgICAgICAgICAgIGYyOjgwOmQ2OjUxOjM0OmVjOjk0OjZiOjZmOjU0OmE0OjVhOmNjOjZlOmMwOgogICAgICAgICAgICAgICAgICAgIDZlOmUyOjhiOjc5OjBmOmIzOjcxOjhmOjE3OjFkOjZhOjEyOjRmOjRkOmQzOgogICAgICAgICAgICAgICAgICAgIDA2OmJkOmQ2OjI3OmY0OmMwOjYzOmNlOjA5Ojc0OmRlOjI5OjA0OmI5OjAwOgogICAgICAgICAgICAgICAgICAgIGQ4OjZlOmI5OmVkOjJjOmJlOjkyOjRhOjVlOjc5Ojg5Ojk3OmI5OjVhOjg5OgogICAgICAgICAgICAgICAgICAgIDE2OmUxCiAgICAgICAgICAgICAgICBFeHBvbmVudDogNjU1MzcgKDB4MTAwMDEpCiAgICAgICAgWDUwOXYzIGV4dGVuc2lvbnM6CiAgICAgICAgICAgIFg1MDl2MyBCYXNpYyBDb25zdHJhaW50czogCiAgICAgICAgICAgICAgICBDQTpGQUxTRQogICAgICAgICAgICBYNTA5djMgU3ViamVjdCBLZXkgSWRlbnRpZmllcjogCiAgICAgICAgICAgICAgICA0NTozQzpCRjo5RjpDQTo5RToxNDozMzo2MzpEOTo1Qzo2NjowNDoyRTpEQjpGMDo4RDo4NDo4Rjo5MQogICAgICAgICAgICBYNTA5djMgQXV0aG9yaXR5IEtleSBJZGVudGlmaWVyOiAKICAgICAgICAgICAgICAgIGtleWlkOkJGOjkwOjc0OjI4OjdEOjcyOjA5OjA1OkNBOkNCOjRBOjg2OjU0OjE4OkUxOkREOkRGOkQ3OjAzOjBFCiAgICAgICAgICAgICAgICBEaXJOYW1lOi9DTj1jYS5yZXNpbi50ZXN0CiAgICAgICAgICAgICAgICBzZXJpYWw6MzA6MEY6ODI6QTc6NEE6MkM6MTI6RUI6NDc6OUE6RTk6RkQ6NkE6OTA6QTE6QUUKCiAgICAgICAgICAgIFg1MDl2MyBFeHRlbmRlZCBLZXkgVXNhZ2U6IAogICAgICAgICAgICAgICAgVExTIFdlYiBTZXJ2ZXIgQXV0aGVudGljYXRpb24KICAgICAgICAgICAgWDUwOXYzIEtleSBVc2FnZTogCiAgICAgICAgICAgICAgICBEaWdpdGFsIFNpZ25hdHVyZSwgS2V5IEVuY2lwaGVybWVudAogICAgICAgICAgICBYNTA5djMgU3ViamVjdCBBbHRlcm5hdGl2ZSBOYW1lOiAKICAgICAgICAgICAgICAgIEROUzp2cG4ucmVzaW4udGVzdAogICAgU2lnbmF0dXJlIEFsZ29yaXRobTogc2hhMjU2V2l0aFJTQUVuY3J5cHRpb24KICAgICAgICAgZTE6YjA6YWE6OWE6ZmU6MTU6MDQ6ZjM6ZGY6NjU6Mzc6YTM6Mzc6ZWQ6NGM6Njk6Njc6YWU6CiAgICAgICAgIDczOjIzOjkxOjZhOjliOjQzOmI3OmY3OjUxOmNlOjBlOmIzOjVhOjFiOmJjOmJhOjMzOjk3OgogICAgICAgICBiYTo4NjoyZjowZTo0MzphMDpkNjplZjo0YTo2NTpmMDoxMDpiMjo0MTowYTo5Mjo2YTozODoKICAgICAgICAgZDU6MTE6Zjg6YWI6ZDQ6MzU6MDI6YTA6ODA6ZTU6MWM6N2E6NmQ6YzY6ZDU6Zjk6YjQ6NWY6CiAgICAgICAgIDBjOmFhOmEwOjllOjc3OjY3OmMzOmQyOmEzOmY4OjZmOjdkOjRiOmE4OjUzOjNkOmZmOjllOgogICAgICAgICA5Mzo3NDoxOTpkMzowZDpmMDozNzozOTo0ODo5OTphNTplMzphMzo2MjpmNDpkOTphOTpiYToKICAgICAgICAgNzQ6ODA6ZmY6MWI6MTQ6YWQ6ZDE6NmY6MTI6NDU6MDE6MTI6YTQ6NTk6Mzg6Zjg6ZDQ6ODY6CiAgICAgICAgIDIwOmI1OmQwOjBhOmM3Ojg3Ojg5OmEzOjA5OjcyOjhkOmFiOmIzOjJhOjhiOjg0OjkxOmMxOgogICAgICAgICA4MzoxMzpmZjowZjowNToyMjo4NjozYjpjMjpkZDpmYzoyNTpkNjpkOTo5NTplYjo5Zjo4YjoKICAgICAgICAgOGY6ZGI6NjY6YTA6YWM6Zjc6NGY6YmU6YzY6ZDM6OGQ6Zjg6N2Q6ZmY6M2I6ZjA6NDc6MGM6CiAgICAgICAgIDc0OmYxOjQzOjU2OjMxOjVjOjVhOmFkOjFhOjFiOjJiOjBiOmM1OjhjOjMzOmI5OmQ4OmRiOgogICAgICAgICBlMzpmNToyMzo2Yzo2YToxZDo1OTpmODozZDplZTozMTo5Nzo0ZToxMTpiZDo1Mjo0ZjoxMDoKICAgICAgICAgZDE6OTE6NTA6MjI6Mzc6ZGM6NTE6Y2E6OWI6ODU6NTU6ZWM6OWM6YmE6MDc6OWU6MDA6NjA6CiAgICAgICAgIDJmOjA0OjE4OjU4OjIwOmY0OmVkOjAxOmJiOjAxOmEzOjkwOjNjOmQxOjE0OmU4OjYyOjFmOgogICAgICAgICA2ZjpjYzpiNToxNQotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRGV6Q0NBbU9nQXdJQkFnSVFlZlhuMjRwaThhT2h2Y1NINTdkeWFEQU5CZ2txaGtpRzl3MEJBUXNGQURBYwpNUm93R0FZRFZRUUREQkYyY0c0dFkyRXVjbVZ6YVc0dWRHVnpkREFlRncweE9EQTVNamN4TmpFMU16aGFGdzB5Ck1EQTVNall4TmpFMU16aGFNQmt4RnpBVkJnTlZCQU1NRG5ad2JpNXlaWE5wYmk1MFpYTjBNSUlCSWpBTkJna3EKaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFyd3lmOG9RQU1BeTNLVjZYZ0hYVkJaSU1BNG9qaEpmMAp3TWpLMkRiL2hUWFptQWxoQnBNSnZwdzc5MTJjaWJQQ0N4ZzQ5NVAyaTkvbUpYbWNwZkNMbFllaFZtSEdhN05JCml0WEF4eXdvYVlCcDNiaHZveGVQaUdMNzRTbEZtVUNaUXNxVEZpUnMwNXdWajl3dFVxVmFWUTQyd05qVU5leHoKaFkycW1STEh2eXFVcUdTYlZ2ZkVRaUptU2QzZjF5U0s2cXMzNDdpNkUvazR6L1FSc3RrRlJjQzlSZzVmNlV5bQpvNUN6ZzdVQzdHWnd3VUw3dGtqTGZJQytUVnBPOFZPaW1LVHlnTlpSTk95VWEyOVVwRnJNYnNCdTRvdDVEN054Cmp4Y2RhaEpQVGRNR3ZkWW45TUJqemdsMDNpa0V1UURZYnJudExMNlNTbDU1aVplNVdva1c0UUlEQVFBQm80RzcKTUlHNE1Ba0dBMVVkRXdRQ01BQXdIUVlEVlIwT0JCWUVGRVU4djUvS25oUXpZOWxjWmdRdTIvQ05oSStSTUU4RwpBMVVkSXdSSU1FYUFGTCtRZENoOWNna0Z5c3RLaGxRWTRkM2Yxd01Pb1J5a0dqQVlNUll3RkFZRFZRUUREQTFqCllTNXlaWE5wYmk1MFpYTjBnaEF3RDRLblNpd1M2MGVhNmYxcWtLR3VNQk1HQTFVZEpRUU1NQW9HQ0NzR0FRVUYKQndNQk1Bc0dBMVVkRHdRRUF3SUZvREFaQmdOVkhSRUVFakFRZ2c1MmNHNHVjbVZ6YVc0dWRHVnpkREFOQmdrcQpoa2lHOXcwQkFRc0ZBQU9DQVFFQTRiQ3FtdjRWQlBQZlpUZWpOKzFNYVdldWN5T1JhcHREdC9kUnpnNnpXaHU4CnVqT1h1b1l2RGtPZzF1OUtaZkFRc2tFS2ttbzQxUkg0cTlRMUFxQ0E1Ung2YmNiVitiUmZES3Fnbm5kbnc5S2oKK0c5OVM2aFRQZitlazNRWjB3M3dOemxJbWFYam8yTDAyYW02ZElEL0d4U3QwVzhTUlFFU3BGazQrTlNHSUxYUQpDc2VIaWFNSmNvMnJzeXFMaEpIQmd4UC9Ed1VpaGp2QzNmd2wxdG1WNjUrTGo5dG1vS3ozVDc3RzA0MzRmZjg3CjhFY01kUEZEVmpGY1dxMGFHeXNMeFl3enVkamI0L1VqYkdvZFdmZzk3akdYVGhHOVVrOFEwWkZRSWpmY1VjcWIKaFZYc25Mb0huZ0JnTHdRWVdDRDA3UUc3QWFPUVBORVU2R0lmYjh5MUZRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo= \
	-e VPN_OPENVPN_SERVER_KEY=LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2QUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktZd2dnU2lBZ0VBQW9JQkFRQ3ZESi95aEFBd0RMY3AKWHBlQWRkVUZrZ3dEaWlPRWwvVEF5TXJZTnYrRk5kbVlDV0VHa3dtK25EdjNYWnlKczhJTEdEajNrL2FMMytZbAplWnlsOEl1Vmg2RldZY1pyczBpSzFjREhMQ2hwZ0duZHVHK2pGNCtJWXZ2aEtVV1pRSmxDeXBNV0pHelRuQldQCjNDMVNwVnBWRGpiQTJOUTE3SE9GamFxWkVzZS9LcFNvWkp0Vzk4UkNJbVpKM2QvWEpJcnFxemZqdUxvVCtUalAKOUJHeTJRVkZ3TDFHRGwvcFRLYWprTE9EdFFMc1puREJRdnUyU010OGdMNU5Xazd4VTZLWXBQS0ExbEUwN0pScgpiMVNrV3N4dXdHN2lpM2tQczNHUEZ4MXFFazlOMHdhOTFpZjB3R1BPQ1hUZUtRUzVBTmh1dWUwc3ZwSktYbm1KCmw3bGFpUmJoQWdNQkFBRUNnZ0VCQUt4eDhYZ0YxZkYvOVVpSjZSSWlBcE1VUjBXTlptUVBGb3g4d21leDlwTVMKYzZPMVNhSWlaQzBrMkdaZUVBSVAxZzc3ODlMaUxyV3BBcDdVYVIrSUV0cGgzT3l1TWJ5VHg5a05ybllINkYvVwpvM1JMWjU3eGJQTGRJR20yTU54Q3FUa0ZPMVZLMlBLMkJ2L0wxZEpmRnRoSHdtVEV0bm5RMEJVM2RHS0wvNzh2CjM2alNjQThGRURxbXZRWkZDWXB4ZXYyZmNlUmpONXJaNjZVWGVVUE1aQjBkclRXN1l0Nk5IZ24vVnlrT2pvNlcKSmIvZ1BOT0krdGswenJoZ2NFbXJNWGEzd1UxZVRMUS93UStJMytiWEIvWXBNM3dOZmlRbmRIN0lzWXNOd1hzZApza0YvK25sNVUxMXQ0KzM1S1hOcVJGQVBXUHpkUkpMUjRjSUlzSkhvKytrQ2dZRUE0SG4vUVZSMmRDY0k5ZHIvCnB5OHZyMzF1SE9tNDJtTU9DaWs2WnF4dmt0dXhHV1pkSnJ5UHdGdGNhSFFJMklQYjNCRUR4MDZHNEJkaitSYVIKRVgyZUJlWThCWWFTZTZvcFA2WFY0R2RyZW5sbGswbjdpc1VaUTNyTGtJSFlzYlNSd0szKzlYaUI2MFVvTVRUQgpTclhJUS9qVFVmeEZYUmlpeGZaOTNLb3kzM01DZ1lFQXg2R3o5amRkVGRyUjZKc1VYdDNhNXo4YkprVWlvZkhzCi9RYm9mdFQveW9PL2xQT0NCUG8wcDFHSVorMFk1bjhEWCsrRDd6S3NKQ2JlUzViYm1xZzM2VS8vUnYra3NmNzUKQTdYbHh6RFVWSGUxcDJhNVZhQWI2UU5IbjZPL3lZdVdGMlVYVUhUU2JxUjlEUVdubmFyTWNVM1FiY051RTJjVQpOYjV3VFBUaGMxc0NnWUVBdkU1N0M1SFFJSllTVlRRV25HZmdCOFlmMWc5V3E1VEcxVTFLbVpEenMrMnB2aFg1CjlLSGZzVXl5MDBqcmxyM2VkTml0SThmREt6OVQ5VU95QkVzdGdlTm0zSGZNY0FNSndVUGJpL2tWMTFMNUc3ckgKVWQwUDJXU3NXWmdqY01kNk1YbUUxT1QzajZhZkZkQWNpaEMrWkE3Ykx2NkNMWnVhQ0psRGNoWXd3UE1DZjBpRgpkZHI4UWVrR2xUcnJHM3RiSFNya3dmZ2xKVyt2YzJoNEdmMzVZdk11NldvekRBakMzRjNzUUtHQWdJczdtUDVCCkJLemd1NmhtZGxyL2NzZThWSk50ZkU5T2o0WWFHbHcrdURxa2duNHMvdERSZ0lLYXA0aitxQVpXZGxYQlg4VWYKOUZoR0dDd1psVlFsdWI2TlRiZmJqTnhUSXFucHlHMjl3UTR6NTdNQ2dZQlVWWXE5N1lIVFRPRnRpUTgwYTErcgovZGdUYzdob2o0VTgxMTIwQ2NiWXBNUitVdXBMOUZqSHhsUUpQbXovYlY2OHRUT1NUN2QwLzdScnpZWlM3RGt6CjFpYjBwdXJPOEZUaWIrOGFTZkFCYXM3d0k0cXRFdjN1dVlkc2V4VXAzaDdlTHJMLzdRcHJncU1wY05NNloyckUKUHlkUEhzNGpyVzVqZzQ1NXBHMzdQdz09Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K \
	-e VPN_OPENVPN_SERVER_DH=LS0tLS1CRUdJTiBESCBQQVJBTUVURVJTLS0tLS0KTUlJQkNBS0NBUUVBckJsWVVvZmkwbmZ4WFNmYXBseFQ1a00yYlJ0L1NrN0JCbTBwMGxYTFkxb05GdzhWeUlFTAo2c1U1eGpoencrRVhFSnNoYlhrWno5dGdvZFdIMmIvdUs4dHZDR21PTkwrOEZYdkRtR3F5YlBIcmU4ZlBHRWFSCkt1WXJUbGhGT25LZjBzcUlwd0tPWnUrTktaNTNyRnhES3Y4eTM1ci82UnpydHFwYTBscEZYYjcwNlNYWGRacGUKbG50NXdJU20wQityUGFFRG1yZzFBU05vWDZTcktMOHp1RjhkdysyOVQrNjlDRGY3Si9NcUU2bWlZMkxDWklCegoxV1k3WGR1NWNaY1FmR3BJTlIwLy80ZHIwUjJBbVJTWnYyWEloUWJyVzZTMmR5ZEkwMnc4ZFd4a3EzcWl3UmYvCkpKaDJPU0N5ZncxdVlsU2dKVUIyK2Z5cFpkRG8zWjZ0aXdJQkFnPT0KLS0tLS1FTkQgREggUEFSQU1FVEVSUy0tLS0tCg== \
	-e BLUEBIRD_DEBUG=1 \
	-e TS_NODE_FILES=true \
	"${IMAGE_NAME-test-open-balena-vpn}")

docker cp "./src" "${test_id}:/usr/src/app/src"
docker cp "./test" "${test_id}:/usr/src/app/test"
docker cp "./typings" "${test_id}:/usr/src/app/typings"
docker cp "./tsconfig.json" "${test_id}:/usr/src/app/"
docker exec "${test_id}" /bin/sh -ec '
	echo -n "Waiting for systemd... "
	while ! systemctl status basic.target >/dev/null 2>&1; do sleep 1; done
	echo "ok"
	systemctl stop confd.service
	echo "[Service]\nType=oneshot\nExecStart=\nExecStart=-/usr/local/bin/confd -onetime -confdir=/usr/src/app/config/confd_env_backend -backend env -log-level debug\nRemainAfterExit=yes" > /etc/systemd/system/confd.service.d/env-backend.conf
	ln -fs /etc/docker.env /usr/src/app/config/env
	echo "127.0.0.1 deadbeef.vpn" >> /etc/hosts
	systemctl daemon-reload
	systemctl start haproxy.service
	npm install
	npm run test-unit
	npx mocha test/app.ts'
