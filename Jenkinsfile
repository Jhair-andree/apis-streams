pipeline {
    agent {
        label('terraform')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-credentials')
    }

    options { 
        disableConcurrentBuilds()
        ansiColor('xterm')
        timeout(time: 10, unit: 'MINUTES')
        timestamps()
    }
    stages {
        stage('Version') {
            steps {
                dir('terraform-app') {
                    sh 'terraform --version'
                }
            }
        }
        stage('Init') {
            steps {
                dir('terraform-app') {
                    sh 'terraform init'
                }
            }
        }
        stage('Plan') {
            steps {
                dir('terraform-app') {
                    sh 'terraform plan'
                }
            }
        }
        stage('Apply') {
             input {
                 message "Do you want to continue"
                 ok "Yes, continue the pipeline"
             }
             when {
                branch 'main'
             }
            steps {
                dir('terraform-app') {
                    sh 'terraform apply --auto-approve'
                }
            }
        }
    }
        post {
        failure {
            echo "Your pipeline has failed, contact with your administrator"
        }
        success {
            echo "The deployment was done successfully"
        }
        always {
            echo "I hope you like Jenkins"
        }
    }
}
