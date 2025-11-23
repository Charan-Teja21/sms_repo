pipeline {
    agent any

    environment {
        APP_NAME        = "sms"
        APP_NAMESPACE   = "sms-namespace"
        IMAGE_NAME      = "smsimg"
        IMAGE_TAG       = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Charan-Teja21/sms_repo.git'
            }
        }

        stage('Cleanup Old Container (if exists)') {
            steps {
                sh '''
                    if [ "$(docker ps -aq -f name=${APP_NAME})" ]; then
                        echo "Container exists — stopping & removing..."
                        docker stop ${APP_NAME} || true
                        docker rm ${APP_NAME} || true
                    else
                        echo "No old container found."
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile ."
            }
        }

        stage('K8s Deployment') {
            steps {
                script {
                    withEnv(["KUBECONFIG=$HOME/.kube/config"]) {

                        echo "Applying Kubernetes manifests directly..."

                        sh "kubectl apply -f namespace.yaml --validate=false"
                        sh "kubectl apply -f deployment.yaml --validate=false"
                        sh "kubectl apply -f service.yaml --validate=false"

                        sh "kubectl rollout status deployment/sms-deployment -n sms-namespace"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✔ Completed: Build and Deploy"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}