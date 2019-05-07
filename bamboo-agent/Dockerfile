FROM atlassian/bamboo-agent-base:latest

USER root
RUN apt-get update && apt-get install curl apt-transport-https ca-certificates curl gnupg-agent software-properties-common unzip -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y
RUN wget https://releases.hashicorp.com/envconsul/0.7.3/envconsul_0.7.3_linux_amd64.zip \
    && unzip envconsul_0.7.3_linux_amd64.zip -d /usr/bin \
    && chmod +x /usr/bin/envconsul \
    && wget https://releases.hashicorp.com/vault/1.1.2/vault_1.1.2_linux_amd64.zip \
    && unzip vault_1.1.2_linux_amd64.zip -d /usr/bin \
    && chmod +x /usr/bin/vault \
    && wget https://releases.hashicorp.com/consul-template/0.20.0/consul-template_0.20.0_linux_amd64.zip \
    && unzip consul-template_0.20.0_linux_amd64.zip -d /usr/bin \
    && chmod +x /usr/bin/consul-template
