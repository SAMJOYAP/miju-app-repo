FROM nginx:1.27-alpine

# nginx 설정 교체
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 정적 파일
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css

#COPY buildinfo.json /usr/share/nginx/html/buildinfo.json

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz >/dev/null 2>&1 || exit 1
