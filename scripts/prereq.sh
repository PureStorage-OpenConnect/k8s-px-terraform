#!/bin/bash

#########################
# The command line help #
#########################
display_help() {
  echo "$(date) --> Usage: $0 [optional app] [aws|gcloud|azure] " >&2
  echo "$(date) -->        for example: ./prereq.sh [aws] "
  echo "$(date) -->        for example: ./prereq.sh [gcloud] "
  echo
  exit 1
}

source ~/.bashrc

if [[ "$(uname -s)" == Linux ]]; then
  vRETURN=$(grep "^NAME=" /etc/os-release| cut -f2 -d"=")
  if [[ ${vRETURN} == '"CentOS Linux"' ]]; then
    LINUX_DISRO="CENTOS"
  elif [[ ${vRETURN} == '"Ubuntu"' ]]; then
    LINUX_DISRO="UBUNTU"
  else
    echo -e "Unsupported Linux Distribution. Currenty CentOS and Ubuntu are supported. \nPlease install all the tools as per the documentation for your linux distribution"
    exit 1;
  fi
elif [[ "$(uname -s)" == Darwin ]]; then 
  echo 'Darwin (MacOS) Detected.'
else
  echo -e "Unsupported operating system. Currenty MAC and Linux (CentOS, Ubuntu) are supported."
  exit 1;
fi

installBasicUtils() {
  if [[ "$(uname -s)" == Linux ]]; then
    if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
      echo "Installing basic tools -- on Linux OS (CentOS)--> "
      sudo yum check-update
      sudo yum install unzip curl wget git -qy
    else
      echo "Installing basic tools -- on Linux OS (Ubuntu)--> "
      sudo apt-get update;
      sudo apt-get install unzip curl wget git -qy
    fi
  elif [[ "$(uname -s)" == Darwin ]]; then 
    echo 'Installing basic tools -- on Darwin (MacOS) -->'
    brew install unzip curl wget git
  fi
  echo 'Installing basic tools completed.'
}

installGoogleSDK() {
  echo 'checking gcloud sdk version'
  if ! gcloud version; then
    #The following call applies to MacOS and Linux per documentation
    echo 'Installing G-Cloud SDK'
    mv ~/google-cloud-sdk ~/google-cloud-sdk_old 2>/dev/null
    curl https://sdk.cloud.google.com > /tmp/install.sh
    bash /tmp/install.sh --disable-prompts --install-dir=~/google-cloud-sdk
    echo "source ~/google-cloud-sdk/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc
    echo "source ~/google-cloud-sdk/google-cloud-sdk/path.bash.inc" >> ~/.bashrc
    echo 'Google Cloud SDK Installation completed'
  else
    echo "Gcloud SDK found.. no updates are made.."
  fi
}

installAWSCli() {
  echo 'Checking AWS version...'
  if ! aws --version; then
    if [[ "$(uname -s)" == Darwin ]]; then 
      echo 'Installing AWSCli - on Darwin (MacOS) -->'
      /usr/bin/ruby -e “$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)”
      brew install awscli
    elif [[ "$(uname -s)" == Linux ]]; then
      echo "Installing AWS -- on Linux OS --> "
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
      unzip /tmp/awscliv2.zip -d /tmp/
      sudo /tmp/aws/install
    fi
    echo 'AWSCli Installation completed'
  else
    echo "AWScli found.. no updates are made"
  fi
}

installTerraform() {
  if ! terraform -version; then
    echo "Terraform not found.. installing now.."
    if [[ "$(uname -s)" == Darwin ]]; then 
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_darwin_amd64.zip
    elif [[ "$(uname -s)" == Linux ]]; then
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip 
    fi
    sudo unzip -q -d /usr/local/bin /tmp/terraform.zip 
    rm /tmp/terraform.zip
    echo 'Terrafrom installation completed'
  else
    echo 'Terrform found, no updates are made..'
  fi
}

installAzureCLI() {
  echo 'Checking Azure version...'
  if ! az version; then
    if [[ "$(uname -s)" == Linux ]]; then
      if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
        echo 'Installing AzureCLI - on Linux (CentOS)'
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
        sudo yum install azure-cli -qy
      else
        echo 'Installing AzureCLI - on Linux (Ubuntu)'
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      fi
    elif [[ "$(uname -s)" == Darwin ]]; then 
      echo 'Installing AzureCLI - on Darwin (MacOS)'
      brew update && brew install azure-cli
      echo 'AzureCli Installation completed'
    fi
  else
      echo "Azure CLI found, no updates are made.."
  fi
}

installDocker() {
  echo 'Checking Docker...'
  if ! docker -v; then
    if [[ "$(uname -s)" == Linux ]]; then
      # Install Docker
      if [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install -qy uidmap
      fi
      curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
      sudo sh /tmp/get-docker.sh
      echo "user.max_user_namespaces = 28633" | sudo tee -a /etc/sysctl.d/51-rootless.conf
      sudo sysctl --system
      dockerd-rootless-setuptool.sh install
      echo "export DOCKER_HOST=unix:///run/user/$(id -ru)/docker.sock" >> ~/.bashrc
    elif [[ "$(uname -s)" == Darwin ]]; then 
      echo "Docker not found.. installing now on Darwin (MacOS).."
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      echo 'Docker Installation is completed...'
    fi
  else
      echo 'Docker found.. no updates are made'
  fi
}

installGIT() {
  echo 'Checking GIT version'
  if ! git --version; then
    echo 'GIT not found.. installing now on Darwin (MacOS)...'
    if [[ "$(uname -s)" == Darwin ]]; then 
      brew install git
    fi
  else
    echo 'GIT found. no updates are made'
  fi
}

installKubeCTL() {
  echo 'Checking kubectl version'
    if ! kubectl version --client=true; then
    echo "kubectl not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
      sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install kubectl
    fi
    echo 'kubectl Installation is completed...'
  else
    echo 'kubectl found.. no updates are made'
  fi
}

installJQ() {
  echo 'Checking JQ version'
    if ! jq --version; then
    echo "JQ not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
        sudo yum install jq -qy
      elif [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install jq -qy
      fi
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install jq
    fi
    echo 'JQ Installation is completed...'
  else
    echo 'JQ found.. no updates are made'
  fi
}

install_pip3() {
  echo 'Checking pip3 version'
    if ! pip3 --version; then
    echo "pip3 not found.. installing now.."
    if [[ "$(uname -s)" == Linux ]]; then
      if [[ "${LINUX_DISRO}" == "CENTOS" ]]; then
        sudo yum install python3-pip -qy
      elif [[ "${LINUX_DISRO}" == "UBUNTU" ]]; then
        sudo apt-get install python3-pip -qy
      fi
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install python3
    fi
    echo 'pip3 Installation is completed...'
  else
    echo 'pip3 found.. no updates are made'
  fi
}

checkRqdAppsAndVars() {
  #Check required Apps - 
  if ! kubectl version --client > /dev/null 2>&1; then
     echo "KubeCTL Missing"
  else
     echo "KubeCTL found"
  fi

  if ! pip3 --version > /dev/null 2>&1; then
     echo "pip3 Missing"
  else
     echo "pip3 found"
  fi

  if ! git --version > /dev/null 2>&1; then
    echo "GIT Missing"
  else
     echo "GIT found"
  fi

  if ! docker -v > /dev/null 2>&1; then
    echo "Docker Missing" 
  else
     echo "Docker found"
  fi

  if ! terraform -version > /dev/null 2>&1; then
    echo "Terraform Missing"
  else
     echo "Terraform found"
  fi

  if ! az version > /dev/null 2>&1; then
    echo "Azure CLI missing"
  else
     echo "Azure CLI found"
  fi

  if ! aws --version > /dev/null 2>&1; then
    echo "AWScli missing"
  else
     echo "AWScli found"
  fi

  if ! gcloud version > /dev/null 2>&1; then
    echo "Google Cloud SDK missing"
  else
    echo "Google Cloud SDK found"
  fi

  source ~/.bashrc

  #Check variables that are required to set
  if [[ -z $vHOSTS ]]; then echo "Env Variable Missing: the vHOSTS environment variable not set. Please set it by assigning all host IPs separated by white space"; fi
  if [[ -z $vSSH_USER ]]; then echo "Env Variable Missing: the vSSH_USER environment variable not set. Please set with the ssh user name";  fi
  if [[ -z $AWS_PROFILE ]]; then echo "AWS Profile not set (Missing)";  fi
  exit 0;
}

ARG1=$1

if [[ $ARG1 = "help"  ]]; then
    display_help
elif [[ $ARG1 = "check" ]]; then
  checkRqdAppsAndVars
  exit 0;
fi

echo "$(date) - Cloud Environment chosen is : ${CLOUD_ENV}"
echo ''
installBasicUtils
echo ''
installGIT
echo ''
installKubeCTL
echo ''
installJQ
echo ''
install_pip3
echo ''
installTerraform
echo ''
installDocker
echo ''
installAWSCli
echo ''
installGoogleSDK
echo ''
installAzureCLI

echo "$(date) - Script completed successfully"

echo -e "\n\n\n$(date) - To make sure all the tools are available, run following command:\n\nsource ~/.bashrc"
