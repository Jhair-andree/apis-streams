FROM carlosfeufernandez/base-jenkins-agents

RUN apt-get update

RUN apt-get install curl -y && apt-get install unzip -y
RUN wget https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip && \
    unzip terraform_1.3.3_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    terraform --version

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip -u awscliv2.zip && \
    ./aws/install

EXPOSE 22