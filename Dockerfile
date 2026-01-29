FROM nginx:1.27-alpine

# nginx 설정과 정적 파일 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css

EXPOSE 80

# nginx foreground
CMD ["nginx", "-g", "daemon off;"]
