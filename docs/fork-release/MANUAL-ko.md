# MeshCentral 설치 및 사용 설명서 (fcmatch121 빌드)

이 설명서는 `fcmatch121/MeshCentral` GitHub 릴리스에 첨부된 파일로 MeshCentral 서버를 설치하고 운영하는 방법을 설명합니다.
원본 프로젝트 문서: <https://ylianst.github.io/MeshCentral/>

---

## 1. 릴리스 파일

| 파일 | 용도 |
|------|------|
| `meshcentral-<버전>.tar.gz` | Linux/macOS용 실행 번들 |
| `meshcentral-<버전>.zip` | Windows용 실행 번들 (내용은 tar.gz와 동일) |
| `meshcentral-<버전>-docker-image.tar.gz` | Docker 이미지 (`meshcentral:<버전>`) |
| `MeshCentral-<버전>-Manual-ko.md` | 이 설명서 |
| `SHA256SUMS.txt` | 파일 체크섬 |

실행 번들 압축을 풀면 다음 구조가 됩니다.

```
meshcentral-<버전>/
├── meshcentral/          # 서버 프로그램 (운영용 node_modules 포함)
├── config.sample.json    # 설정 파일 예시
└── MANUAL-ko.md          # 이 설명서
```

서버를 처음 실행하면 `meshcentral/` 옆에 다음 폴더가 자동으로 생성됩니다.

- `meshcentral-data/` — 설정(`config.json`), 인증서, 데이터베이스 (**가장 중요, 반드시 백업**)
- `meshcentral-files/` — 사용자가 업로드한 파일
- `meshcentral-backups/` — 자동 백업

## 2. 다운로드 파일 확인 (선택)

```bash
sha256sum -c SHA256SUMS.txt --ignore-missing
```
Windows PowerShell: `Get-FileHash .\meshcentral-<버전>.zip -Algorithm SHA256` 결과를 `SHA256SUMS.txt`의 값과 비교합니다.

## 3. 시스템 요구사항

- **Node.js 20 이상** (번들 설치 시). Docker로 설치하면 Node.js가 필요 없습니다.
- 메모리 1GB 이상 권장
- 열어야 하는 포트
  - `443/TCP` — 웹 화면, 에이전트 연결 (HTTPS)
  - `80/TCP` — HTTP → HTTPS 리다이렉트, Let's Encrypt 인증
  - `4433/TCP` — Intel AMT를 사용할 때만 필요

---

## 4. 설치 방법 A — Linux 번들

```bash
# 1) Node.js 20 설치 (Ubuntu/Debian 예시)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2) 압축 해제
sudo mkdir -p /opt
sudo tar -xzf meshcentral-<버전>.tar.gz -C /opt
cd /opt/meshcentral-<버전>

# 3) 첫 실행 (인증서 생성 때문에 1~2분 정도 걸릴 수 있음)
sudo node meshcentral/meshcentral.js
```

콘솔에 `MeshCentral HTTPS server running on port 443.`이 나오면 정상입니다. `Ctrl+C`로 종료합니다.

> 1024 이하 포트(80, 443)를 사용하려면 root 권한이 필요합니다. root 없이 테스트하려면 다음처럼 실행합니다.
> `node meshcentral/meshcentral.js --port 4430 --redirport 8080`

### 백그라운드 서비스(systemd)로 등록

```bash
cd /opt/meshcentral-<버전>
sudo node meshcentral/meshcentral.js --install     # 서비스 등록 및 시작
sudo systemctl status meshcentral                  # 상태 확인
sudo node meshcentral/meshcentral.js --uninstall   # 서비스 제거
```

## 5. 설치 방법 B — Windows 번들

1. <https://nodejs.org>에서 Node.js 20 LTS 이상을 설치합니다.
2. `meshcentral-<버전>.zip`을 `C:\MeshCentral` 같은 폴더에 풉니다.
3. **관리자 권한** 명령 프롬프트에서 실행합니다.
   ```bat
   cd C:\MeshCentral\meshcentral-<버전>
   node meshcentral\meshcentral.js
   ```
4. Windows 서비스로 등록하려면 다음 명령을 실행합니다. 처음 등록할 때 `node-windows` 모듈을 내려받으므로 인터넷 연결이 필요합니다.
   ```bat
   node meshcentral\meshcentral.js --install
   node meshcentral\meshcentral.js --uninstall
   ```
5. Windows 방화벽에서 443, 80 포트를 허용합니다.

## 6. 설치 방법 C — Docker

```bash
# 1) 이미지 불러오기
gunzip -c meshcentral-<버전>-docker-image.tar.gz | docker load
docker images meshcentral

# 2) 실행
docker run -d --name meshcentral --restart unless-stopped \
  -p 443:443 -p 80:80 \
  -e HOSTNAME=mesh.example.com \
  -e DYNAMIC_CONFIG=true \
  -e ALLOW_NEW_ACCOUNTS=false \
  -v meshcentral-data:/opt/meshcentral/meshcentral-data \
  -v meshcentral-files:/opt/meshcentral/meshcentral-files \
  -v meshcentral-backups:/opt/meshcentral/meshcentral-backups \
  meshcentral:<버전>

# 3) 로그 확인
docker logs -f meshcentral
```

Windows에서는 `gunzip` 대신 `docker load -i meshcentral-<버전>-docker-image.tar.gz`를 사용해도 됩니다.

주요 환경 변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `HOSTNAME` | `localhost` | 서버 도메인 이름 (인증서 이름) |
| `PORT` / `REDIR_PORT` | `443` / `80` | HTTPS / HTTP 포트 |
| `DYNAMIC_CONFIG` | `false` | `true`이면 컨테이너가 시작할 때마다 환경 변수로 `config.json`을 다시 만듭니다. 직접 수정한 `config.json`을 유지하려면 `false`로 둡니다. |
| `ALLOW_NEW_ACCOUNTS` | `false` | 첫 관리자 계정 이후 누구나 계정을 만들 수 있게 할지 여부 |
| `REVERSE_PROXY`, `TRUSTED_PROXY`, `TLS_OFFLOAD` | — | 리버스 프록시(nginx 등) 뒤에서 운영할 때 사용 |
| `USE_MONGODB`, `USE_POSTGRESQL`, `USE_MARIADB` | `false` | 외부 데이터베이스 사용 |

전체 변수 목록은 저장소의 `docker/README.md`를 참고하세요.

---

## 7. 첫 접속과 관리자 계정

1. 브라우저에서 `https://<서버주소>`로 접속합니다.
2. 처음에는 자체 서명 인증서를 사용하므로 브라우저 경고가 나옵니다. "고급 → 계속 진행"을 선택합니다.
3. **"Create Account"로 처음 만드는 계정이 서버 관리자**가 됩니다. 서버를 띄우면 바로 관리자 계정을 만드세요.
4. 명령줄로 계정을 관리할 수도 있습니다. 서버를 멈춘 상태에서 실행합니다.
   ```bash
   node meshcentral/meshcentral.js --createaccount admin --pass '<비밀번호>' --email admin@example.com
   node meshcentral/meshcentral.js --adminaccount admin        # 관리자 권한 부여
   node meshcentral/meshcentral.js --resetaccount admin --pass '<새 비밀번호>'  # 비밀번호 초기화 및 2FA 해제
   ```
   Docker에서는 `docker exec -it meshcentral node /opt/meshcentral/meshcentral/meshcentral.js ...` 형태로 실행합니다.

## 8. 기본 설정 (`meshcentral-data/config.json`)

첫 실행 때 `config.json`이 없으면 기본값으로 동작합니다. `config.sample.json`을 `meshcentral-data/config.json`으로 복사해서 수정하세요. **키 이름 앞의 `_`는 주석 처리를 의미**하므로, 사용할 항목은 `_`를 지웁니다.

```json
{
  "settings": {
    "cert": "mesh.example.com",
    "port": 443,
    "redirPort": 80,
    "WANonly": true
  },
  "domains": {
    "": {
      "title": "우리 회사 원격지원",
      "newAccounts": false
    }
  },
  "letsencrypt": {
    "email": "admin@example.com",
    "names": "mesh.example.com",
    "production": true
  }
}
```

- `cert`: 서버의 도메인 이름입니다. 점(`.`)이 없는 이름이면 서버가 **LAN 전용 모드**로 동작합니다.
- `WANonly` / `LANonly`: 인터넷 전용 또는 내부망 전용 모드
- `letsencrypt`: 공인 도메인과 80 포트가 열려 있으면 정식 인증서를 자동으로 발급받습니다.
- 설정을 바꾼 뒤에는 서버를 재시작합니다(`systemctl restart meshcentral` 또는 `docker restart meshcentral`).

## 9. 에이전트 설치 (원격 관리할 PC 등록)

1. 웹 화면에서 **"My Devices → Add Device Group"**으로 장치 그룹을 만듭니다.
2. 그룹에서 **"Add Agent"**를 누르고 운영체제를 선택합니다.
3. Windows는 설치 파일(`.exe`)을 내려받아 실행하고, Linux/macOS는 화면에 나오는 설치 명령을 복사해 실행합니다.
4. 장치가 목록에 나타나면 원격 데스크톱, 터미널, 파일 관리 기능을 사용할 수 있습니다.

> 에이전트는 서버 인증서로 서버를 확인합니다. 에이전트를 배포한 뒤 `meshcentral-data`의 인증서를 지우거나 도메인을 바꾸면 에이전트를 다시 설치해야 합니다.

## 10. 백업과 업데이트

- **백업**: `meshcentral-data` 폴더(Docker는 `meshcentral-data` 볼륨) 전체를 복사합니다. 인증서와 DB가 모두 들어 있습니다. 자동 백업은 `meshcentral-backups`에 저장됩니다.
- **업데이트(번들)**: 서버를 멈추고 새 릴리스의 `meshcentral/` 폴더로만 교체한 뒤 다시 시작합니다. `meshcentral-data`는 그대로 둡니다.
- **업데이트(Docker)**: 새 이미지를 `docker load`로 불러온 뒤 기존 컨테이너를 지우고(`docker rm -f meshcentral`) 같은 볼륨으로 다시 `docker run` 합니다.
- 웹 화면의 자동 업데이트 기능은 npm 공식 패키지 기준으로 동작합니다. 이 빌드를 계속 쓰려면 위 방법으로 수동 업데이트하세요.

## 11. 문제 해결

| 증상 | 해결 방법 |
|------|-----------|
| `EACCES` / 포트 443 바인딩 실패 | root(관리자) 권한으로 실행하거나 `--port 4430 --redirport 8080`처럼 높은 포트를 사용합니다. |
| `EADDRINUSE` | 다른 프로그램(nginx, IIS 등)이 포트를 쓰고 있습니다. 해당 프로그램을 멈추거나 포트를 바꿉니다. |
| 첫 실행이 오래 걸림 | 인증서를 생성하는 중입니다. 1~2분 기다립니다. |
| "LAN mode"로 표시됨 | `cert`에 점(`.`)이 들어간 도메인 이름을 설정합니다. |
| 비밀번호 분실 | 서버를 멈추고 `--resetaccount <id> --pass <새 비밀번호>`를 실행합니다. |
| 로그 확인 | 번들: 실행 콘솔 / `journalctl -u meshcentral -f`, Docker: `docker logs -f meshcentral` |

## 12. 라이선스

MeshCentral은 Apache License 2.0으로 배포됩니다(`meshcentral/LICENSE`). 이 릴리스는 원본 소스를 수정하지 않고 빌드했습니다.
