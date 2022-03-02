FROM fedora:32
MAINTAINER \
[Bikash Roy Choudhury <broychoudhury@purestorage.com >]
LABEL repo=https://github.com/PureStorage-OpenConnect/k8s-px-terraform/
RUN dnf install -q -y jq unzip wget ruby awscli ShellCheck gettext git \
  && wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip \
  && unzip -q -d /usr/bin /tmp/terraform.zip \
  && rm /tmp/terraform.zip \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin \
  && gem install mustache \
  && curl -L https://aka.ms/InstallAzureCli | bash \
  && RUN terraform workspace new docker \
  && terraform init \
  && terraform validate \
  && rm -rf .terraform/environment terraform.tfstate.d terraform.tfstate


#ENV PATH $PATH:/root/google-cloud-sdk/bin

#ENTRYPOINT ["./scripts/entrypoint.sh"]
#CMD ["version"]
#  && RUN curl -sSL https://sdk.cloud.google.com | bash \
