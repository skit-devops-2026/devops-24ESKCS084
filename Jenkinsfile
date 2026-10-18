pipeline {
    agent any

    environment {
        NODE_ENV = 'production'
        IMAGE_NAME = 'craftcv:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'make install'
            }
        }

        stage('Lint & Tests') {
            steps {
                sh 'make test'
            }
        }

        stage('Build Production Bundle') {
            steps {
                sh 'make build'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'make docker-build'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        success {
            echo 'Build, lint tests, and container packaging passed successfully!'
        }
        failure {
            echo 'Build failed. Check the console output for debugging.'
        }
    }
}
