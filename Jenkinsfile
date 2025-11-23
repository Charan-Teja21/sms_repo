pipeline {
    agent any
    
    environment {
        // Docker configuration
        DOCKER_IMAGE = "smsimg"
        DOCKER_TAG = "latest"
        JAR_FILE = "studentmarkservice.jar"
        
        // Kubernetes configuration
        KUBE_NAMESPACE = "sms-namespace"
        DEPLOYMENT_NAME = "sms-deployment"
        SERVICE_NAME = "sms-service"
        
        // Application configuration
        APP_PORT = "8100"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo "========== Checking out source code =========="
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo "========== Building Java application =========="
                sh '''
                    # Build the Java application (Maven/Gradle command based on project setup)
                    # Assuming Maven is used - modify if using Gradle
                    mvn clean package -DskipTests
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo "========== Running tests =========="
                sh '''
                    mvn test
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "========== Building Docker image =========="
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                '''
            }
        }
        
        stage('Verify Docker Image') {
            steps {
                echo "========== Verifying Docker image =========="
                sh '''
                    docker images | grep ${DOCKER_IMAGE}
                '''
            }
        }
        
        stage('Clean Previous Container') {
            steps {
                echo "========== Cleaning up old containers =========="
                sh '''
                    # Remove old container if it exists
                    docker rm -f sms_cont 2>/dev/null || true
                '''
            }
        }
        
        stage('Create Kubernetes Namespace') {
            steps {
                echo "========== Creating Kubernetes namespace =========="
                sh '''
                    kubectl apply -f namespace.yaml
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo "========== Deploying to Kubernetes =========="
                sh '''
                    # Apply all Kubernetes manifests
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo "========== Verifying deployment status =========="
                sh '''
                    # Wait for deployment to be ready
                    kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${KUBE_NAMESPACE} --timeout=5m
                    
                    # Display pod status
                    echo "Pod Status:"
                    kubectl get pods -n ${KUBE_NAMESPACE}
                    
                    # Display service status
                    echo "Service Status:"
                    kubectl get svc -n ${KUBE_NAMESPACE}
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo "========== Performing health check =========="
                sh '''
                    # Wait for service to be accessible
                    sleep 10
                    
                    # Get service info
                    SERVICE_IP=$(kubectl get service ${SERVICE_NAME} -n ${KUBE_NAMESPACE} -o jsonpath='{.spec.clusterIP}')
                    echo "Service IP: $SERVICE_IP"
                    
                    # Try to access the application
                    for i in {1..10}; do
                        if curl -f http://localhost:30100/actuator/health 2>/dev/null; then
                            echo "Application is healthy"
                            exit 0
                        fi
                        echo "Attempt $i: Waiting for application to be ready..."
                        sleep 2
                    done
                    
                    echo "Warning: Could not verify application health"
                '''
            }
        }
    }
    
    post {
        always {
            echo "========== Cleaning up workspace =========="
            cleanWs()
        }
        
        success {
            echo "========== DEPLOYMENT SUCCESSFUL =========="
            // Add notification (email, Slack, etc.)
        }
        
        failure {
            echo "========== DEPLOYMENT FAILED =========="
            sh '''
                echo "Failed deployment details:"
                kubectl describe deployment ${DEPLOYMENT_NAME} -n ${KUBE_NAMESPACE} || true
                kubectl logs -n ${KUBE_NAMESPACE} -l app=sms --tail=50 || true
            '''
            // Add notification (email, Slack, etc.)
        }
        
        unstable {
            echo "========== BUILD UNSTABLE =========="
        }
    }
}
