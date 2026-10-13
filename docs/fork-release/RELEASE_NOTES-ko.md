## MeshCentral {{VERSION}} — fcmatch121 빌드

[Ylianst/MeshCentral](https://github.com/Ylianst/MeshCentral) {{VERSION}} 소스를 수정 없이 빌드한 배포본입니다.

### 첨부 파일

| 파일 | 설명 |
|------|------|
| `meshcentral-{{VERSION}}.tar.gz` | Linux/macOS용 실행 번들 (소스 + 운영용 `node_modules` 포함, Node.js 20 이상 필요) |
| `meshcentral-{{VERSION}}.zip` | Windows용 실행 번들 (내용은 tar.gz와 동일) |
| `meshcentral-{{VERSION}}-docker-image.tar.gz` | Docker 이미지 (`docker load`로 불러오기, 이미지 이름 `meshcentral:{{VERSION}}`) |
| `MeshCentral-{{VERSION}}-Manual-ko.md` | 한국어 설치·사용 설명서 |
| `SHA256SUMS.txt` | 파일 무결성 확인용 체크섬 |

### 빠른 시작

```bash
# 일반 설치 (Linux)
tar -xzf meshcentral-{{VERSION}}.tar.gz
cd meshcentral-{{VERSION}}
node meshcentral/meshcentral.js

# Docker
gunzip -c meshcentral-{{VERSION}}-docker-image.tar.gz | docker load
docker run -d --name meshcentral -p 443:443 -p 80:80 \
  -e HOSTNAME=localhost -e DYNAMIC_CONFIG=true \
  -v meshcentral-data:/opt/meshcentral/meshcentral-data \
  meshcentral:{{VERSION}}
```

브라우저에서 `https://<서버주소>`에 접속해 **처음 만드는 계정이 관리자**가 됩니다. 자세한 내용은 첨부된 설명서를 참고하세요.
