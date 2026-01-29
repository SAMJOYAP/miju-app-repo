<<<<<<< HEAD
FROM nginx:1.27-alpine

# nginx 설정 교체
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 정적 파일
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css

COPY buildinfo.json /usr/share/nginx/html/buildinfo.json

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz >/dev/null 2>&1 || exit 1
=======
# syntax=docker/dockerfile:1

# Use imutable image tags rather than mutable tags (like ubuntu:22.04)
FROM ubuntu:22.04@sha256:149d67e29f765f4db62aa52161009e99e389544e25a8f43c8c89d4a445a7ca37

# Some tools like yamllint need this
# Pip needs this as well at the moment to install ansible
# (and potentially other packages)
# See: https://github.com/pypa/pip/issues/10219
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /kubespray

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -q \
    && apt-get install -yq --no-install-recommends \
    curl \
    python3 \
    python3-pip \
    sshpass \
    vim \
    rsync \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/log/*

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    --mount=type=cache,sharing=locked,id=pipcache,mode=0777,target=/root/.cache/pip \
    pip install --no-compile --no-cache-dir -r requirements.txt \
    && find /usr -type d -name '*__pycache__' -prune -exec rm -rf {} \;

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN --mount=type=bind,source=roles/kubespray-defaults/defaults/main/main.yml,target=roles/kubespray-defaults/defaults/main/main.yml \
    KUBE_VERSION=$(sed -n 's/^kube_version: //p' roles/kubespray-defaults/defaults/main/main.yml) \
    OS_ARCHITECTURE=$(dpkg --print-architecture) \
    && curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${OS_ARCHITECTURE}/kubectl" -o /usr/local/bin/kubectl \
    && echo "$(curl -L "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${OS_ARCHITECTURE}/kubectl.sha256")" /usr/local/bin/kubectl | sha256sum --check \
    && chmod a+x /usr/local/bin/kubectl

COPY *.yml ./
COPY *.cfg ./
COPY roles ./roles
COPY contrib ./contrib
COPY inventory ./inventory
COPY library ./library
COPY extra_playbooks ./extra_playbooks
COPY playbooks ./playbooks
COPY plugins ./plugins
>>>>>>> 0190203 (init: nginx app with health endpoint)
