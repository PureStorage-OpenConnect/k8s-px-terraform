export AWS_ACCESS_KEY_ID=$(aws --profile rg configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws --profile rg configure get aws_secret_access_key)

docker build -t purestorage_terraform_image .

#docker run -it --rm \
#   -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
#   -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
#   purestorage_terraform_image  bash

