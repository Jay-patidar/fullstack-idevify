pipeline {
    agent any

    environment {
        REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        BACKEND_IMAGE = 'devops-assessment-backend'
        FRONTEND_IMAGE = 'devops-assessment-frontend'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend Quality Checks') {
            steps {
                dir('backend') {
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        python manage.py check
                        python manage.py test
                    '''
                }
            }
        }

        stage('Frontend Build Check') {
            steps {
                dir('frontend') {
                    sh '''
                        npm ci || npm install
                        npm run build
                    '''
                }
            }
        }

        stage('Docker Build & Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Building Backend & Frontend Multi-Stage Docker Images..."
                    sh 'docker compose build'
                    
                    // If Docker Hub registry credentials are provided in Jenkins:
                    /*
                    withCredentials([usernamePassword(credentialsId: "${env.DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo \${DOCKER_PASS} | docker login -u \${DOCKER_USER} --password-stdin"
                        sh "docker tag fullstackapplication-backend:latest \${DOCKER_USER}/\${env.BACKEND_IMAGE}:latest"
                        sh "docker tag fullstackapplication-frontend:latest \${DOCKER_USER}/\${env.FRONTEND_IMAGE}:latest"
                        sh "docker push \${DOCKER_USER}/\${env.BACKEND_IMAGE}:latest"
                        sh "docker push \${DOCKER_USER}/\${env.FRONTEND_IMAGE}:latest"
                    }
                    */
                }
            }
        }

        stage('Deploy to Local / Host Environment') {
            when {
                branch 'main'
            }
            steps {
                echo "Triggering automated local deployment script..."
                sh 'chmod +x scripts/deploy.sh'
                sh './scripts/deploy.sh'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline succeeded! Application deployed and verified."
        }
        failure {
            echo "Pipeline failed. Review stage logs above."
        }
    }
}
