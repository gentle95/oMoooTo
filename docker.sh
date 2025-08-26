#!/bin/bash
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt remove $pkg; done
apt install ca-certificates curl gnupg -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee -a /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin -y
mkdir /{docker,docker_root}
chmod -R 777 {docker,docker_root}
tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://hub.ddxm.pp.ua"
  ]
}
EOF
sed -i 's|ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock|ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock --containerd=/run/containerd/containerd.sock|' /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker