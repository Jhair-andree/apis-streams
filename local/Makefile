all: clean build version init plan apply dockerize push integration-test

clean:
	find terraform-app-local -type d -name '*.terraform*' -exec rm -rf {} +
	find -type f -name '*.zip*' -delete
	docker rmi carlosfeufernandez/terraform-app-carlosfeu:latest --force

build:
	apt-get install curl -y && apt-get install unzip -y && \
    wget https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip && \
    unzip terraform_1.3.3_linux_amd64.zip && \
    mv terraform /usr/local/bin/

version:
	terraform --version

init:
	cd terraform-app-local && terraform init
	
plan:
	cd terraform-app-local && terraform plan

apply:
	cd terraform-app-local && terraform apply -auto-approve

destroy:
	cd terraform-app-local && terraform destroy -auto-approve

dockerize:
	cd ../agents && docker build -f tf.Dockerfile -t carlosfeufernandez/terraform-app-carlosfeu:latest .

docker-login:
	cat dockerHubPassword | docker login --username carlosfeufernandez --password-stdin

push:
	docker push carlosfeufernandez/terraform-app-carlosfeu:latest

integration-test:
	docker run -d carlosfeufernandez/terraform-app-carlosfeu:latest