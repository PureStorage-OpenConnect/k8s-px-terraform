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

installGoogleSDK() {
  echo 'checking gcloud sdk version'
  if ! gcloud version; then
  #if [[ "$?" -ne 0 ]]; then
    //The following call applies to MacOS and Linux per documentation
    echo 'Installing Cloud SDK'
    curl https://sdk.cloud.google.com > install.sh
    bash install.sh --disable-prompts
    echo 'Google Cloud SDK Installation completed'
  else
    echo "Gcloud SDK found.. no updates are made.."
  fi
}

installAWSCli() {
  echo 'Checking AWS version...'
  if ! aws --version; then
  #if [[ "$?" -ne 0 ]]; then
    if [[ "$(uname -s)" == Darwin ]]; then 
      echo 'Installing AWSCli - on Darwin (MacOS) -->'
      /usr/bin/ruby -e “$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)”
      brew install awscli
    elif [[ "$(uname -s)" == Linux ]]; then
      echo "Installing AWS -- on Linux OS --> "
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
    fi
    echo 'AWSCli Installation completed'
  else
    echo "AWScli found.. no updates are made"
  fi
}

installTerraform() {
  if ! terraform -version; then
  #if [[ "$?" -ne 0 ]]; then
    echo "Terraform not found.. installing now.."
    if [[ "$(uname -s)" == Darwin ]]; then 
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_darwin_amd64.zip
    elif [[ "$(uname -s)" == Linux ]]; then
      wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip 
    fi
    unzip -q -d /usr/local/bin /tmp/terraform.zip 
    rm /tmp/terraform.zip
    echo 'Terrafrom installation completed'
  else
    echo 'Terrform found, no updates are made..'
  fi
}

installAzureCLI() {
  echo 'Checking Azure version...'
  if ! az version; then
  #if [[ "$?" -ne 0 ]]; then
    if [[ "$(uname -s)" == Linux ]]; then
      echo 'Installing AzureCLI - on Linux (OS)'
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
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
      export DEBIAN_FRONTEND=noninteractive
      sudo apt-get update -qy
      sudo apt-get install apt-transport-https ca-certificates curl software-properties-common gnupg -qy
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
      sudo apt-get update -qy
      DOCKER_VERSION=$(sudo apt-cache madison docker-ce | grep '19.03.13' | awk '{print $3}')
      sudo apt-get install docker-ce="$DOCKER_VERSION" -qy
      sudo usermod -aG docker "$USER"
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
#  git -version
#  if [[ "$?" -ne 0 ]]; then
  if ! git --version; then
    if [[ "$(uname -s)" == Linux ]]; then
      echo "GIT not found.. installing now.."
      sudo apt-get install git
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install git
    fi
    echo 'GIT Installation is completed...'
  else
    echo 'GIT found.. no updates are made'
  fi
}

installKubeCTL() {
  echo 'Checking KubeCTL version'
  
  if ! kubectl version --client=true; then
    if [[ "$(uname -s)" == Linux ]]; then
      echo "KubeCTL not found.. installing now.."
        brew install kubectl   
      echo 'KubeCTL Installation is completed...'
    elif [[ "$(uname -s)" == Darwin ]]; then 
      brew install git
    fi
    echo 'GIT Installation is completed...'
  else
    echo 'KubeCTL found.. no updates are made'
  fi
}

checkRqdAppsAndVars() {
  #Check required Apps - 
  if ! kubectl version --client=true > /dev/null 2>&1; then
     echo "KubeCTL Missing"
  else
     echo "KubeCTL found"
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

  #Check variables that are required to set
  if [[ -z $vHOSTS ]]; then echo "Env Variable Missing: the vHOSTS environment variable not set. Please set it by assigning all host IPs separated by white space"; fi
  if [[ -z $vSSH_USER ]]; then echo "Env Variable Missing: the vSSH_USER environment variable not set. Please set with the ssh user name";  fi
  if [[ -z $AWS_PROFILE ]]; then echo "AWS Profile not set (Missing)";  fi
  exit 0;
}

ARG1=$1

if [[ $ARG1 = "help"  ]];
then
    display_help
elif [[ $ARG1 = "check" ]];
then
  checkRqdAppsAndVars
  exit 0;
fi


echo "$(date) - Cloud Environment chosen is : ${CLOUD_ENV}"
echo ''
installTerraform
echo ''
installDocker
echo ''
installGIT
echo ''
installAWSCli
echo ''
installGoogleSDK
echo ''
installAzureCLI
echo ''
installKubeCTL

echo "$(date) - Script completed successfully"