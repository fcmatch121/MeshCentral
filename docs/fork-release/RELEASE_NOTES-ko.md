## StressMan {{VERSION}} — fcmatch121 빌드

StressMan은 [Ylianst/MeshCentral](https://github.com/Ylianst/MeshCentral) {{VERSION}}을 기반으로 한 fcmatch121 배포본입니다(StressMan 브랜딩, 새 로그인/대시보드 테마, TLS 1.2 이상 + HSTS). 기존 MeshCentral 에이전트와 `meshcentral-data`는 그대로 호환됩니다.

### 첨부 파일

| 파일 | 설명 |
|------|------|
| `stressman-{{VERSION}}.tar.gz` | Linux/macOS용 실행 번들 (소스 + 운영용 `node_modules` 포함, Node.js 20 이상 필요) |
| `stressman-{{VERSION}}.zip` | Windows용 실행 번들 (내용은 tar.gz와 동일) |
| `stressman-{{VERSION}}-docker-image.tar.gz` | Docker 이미지 (`docker load`로 불러오기, 이미지 이름 `stressman:{{VERSION}}`) |
| `StressMan-{{VERSION}}-Manual-ko.md` | 한국어 설치·사용 설명서 |
| `SHA256SUMS.txt` | 파일 무결성 확인용 체크섬 |

### 빠른 시작

```bash
# 일반 설치 (Linux)
tar -xzf stressman-{{VERSION}}.tar.gz
cd stressman-{{VERSION}}
node meshcentral/meshcentral.js

# Docker
gunzip -c stressman-{{VERSION}}-docker-image.tar.gz | docker load
docker run -d --name stressman -p 443:443 -p 80:80 \
  -e HOSTNAME=localhost -e DYNAMIC_CONFIG=true \
  -v meshcentral-data:/opt/meshcentral/meshcentral-data \
  stressman:{{VERSION}}
```

브라우저에서 `https://<서버주소>`에 접속해 **처음 만드는 계정이 관리자**가 됩니다. 자세한 내용은 첨부된 설명서를 참고하세요.
