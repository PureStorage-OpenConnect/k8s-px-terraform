
#!/usr/bin/env bash
set -e -u -x
set -o pipefail

rm -f regional/target.tf docker/*.tf target/*.sh


export TF_INPUT=0

./validate.sh
./clean.sh

cleanup() {
  set +e
  time terraform destroy -parallelism=512 -force -target=module.us_east_1 -target=module.us_west_2
  if terraform destroy -parallelism=512 -force; then
    terraform workspace select "${oldws}"
  else
    cat "terraform.tfstate.d/$rnd/terraform.tfstate"
    echo terraform destroy failed please review > /dev/stderr
    exit 1
  fi
}


oldws="$(cat .terraform/environment 2>/dev/null || true)"
# default is the name of the default terraform workspace
oldws="${oldws:-default}"
rnd=ws-$$-$RANDOM

shellcheck -x ./*.sh ./*/*.sh ./*/*.env

terraform workspace new "$rnd"

trap cleanup INT

trap cleanup EXIT

source resources/default.env

if time terraform apply -parallelism=100 -auto-approve=true; then
  time terraform apply -auto-approve=true -target data.null_data_source.anchor
  apply=apply
  if terraform plan -detailed-exitcode; then
    converge=converge
  else
    echo "Plan exit code: $?"
    converge=noconverge
  fi
else
  apply=noapply
fi

if [ "$apply" != apply ]; then
  exit 1
fi

if [ "$converge" != converge ]; then
 # exit 1 - data.null_data_source.anchor, 0 to add, 0 to change, 0 to destroy.
 # not working! - fix later
 echo state did not converge
fi
