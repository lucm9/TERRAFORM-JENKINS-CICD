pipeline {
    agent any

    tools {
        jdk 'jdk17'
        terraform 'terraform'
    }

    environment {
        SONAR_SCANNER_HOME = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/lucm9/TERRAFORM-JENKINS-CICD.git'
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform --version'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=Terraform \
                        -Dsonar.projectName=Terraform \
                        -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-token'
                    }
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --format json --output trivyfs.json .'
            }
        }

        stage('Make Userdata Executable') {
            steps {
                sh 'chmod +x website.sh'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
