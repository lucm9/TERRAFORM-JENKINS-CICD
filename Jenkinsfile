pipeline {
    agent any
 
    tools {
        jdk 'jdk17'
        terraform 'terraform'
    }

    environment {
        SONAR_SCANNER = tool 'sonar-scanner'
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

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        ${SONAR_SCANNER}/bin/sonar-scanner \
                        -Dsonar.projectName=Terraform \
                        -Dsonar.projectKey=Terraform \
                        -Dsonar.sources=.
                    '''
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --format json --output trivyfs.json .'
            }
        }

        stage('Executable Permission to Userdata') {
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
                script {
                    def action = "apply"
                    sh "terraform ${action} --auto-approve"
                }
            }
        }
    }
}
