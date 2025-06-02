pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_PRIVATE_REGISTRY = '699475927716.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY_URL = "${ECR_PRIVATE_REGISTRY}/pawan-carvilla"
        IMAGE_TAG = 'latest'
    }
    stages{
        stage('Clean WS'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from GIT'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'git_credential', url: 'https://github.com/pawanhb/DevOpsWithAWS.git']])
            }
        }
        stage('DOCKER Build and Push to ECR'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ECR_PRIVATE_REGISTRY}"
                        sh "docker build -t ${ECR_REPOSITORY_URL}:${IMAGE_TAG} ."
                        sh "docker tag ${ECR_REPOSITORY_URL}:${IMAGE_TAG} ${ECR_REPOSITORY_URL}:${IMAGE_TAG}"
                        sh "docker push ${ECR_REPOSITORY_URL}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('initialize terrform'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "terraform init"
                    }
                }
            }
        }
        stage('format terrform code'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "terraform fmt"
                    }
                }
            }
        }
        stage('validate terrform code'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "terraform validate"
                    }
                }
            }
        }
        stage('preview terrform infrastructure with plan'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "terraform plan"
                    }
                    input(message: "Are you sure to proceed?", ok: "Proceed")
                }
            }
        }
        stage('Create ECS cluster and Deploy Carvilla application container'){
            steps{
                script{
                    dir('carvilla-v1.0'){
                        sh "terraform $action --auto-approve"
                    }
                }
            }
        }
    }
}
