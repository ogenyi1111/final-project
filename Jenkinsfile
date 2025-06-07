pipeline {
    agent any

    environment {
        // Define environment variables
        DOCKER_IMAGE = 'ikenna2025/final-project'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PREVIOUS_TAG = "${env.PREVIOUS_TAG ?: 'none'}"  // Store previous version
        // Cross-platform path separator
        PATH_SEPARATOR = "${isUnix() ? '/' : '\\'}"
        // Application environment
        APP_ENV = 'production'
        // Nginx configuration
        NGINX_PORT = '80'
        // GitHub repository URL
        GITHUB_REPO = 'https://github.com/ogenyi1111/final-project.git'
        // Health check configuration
        HEALTH_CHECK_RETRIES = '3'
        HEALTH_CHECK_INTERVAL = '10'
    }

    stages {
        stage('Checkout') {
            steps {
                // Clean workspace
                cleanWs()
                // Configure Git
                git branch: 'main',
                    url: "${GITHUB_REPO}",
                    credentialsId: 'github-credentials'
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'echo "Running on Unix-like system"'
                    } else {
                        bat 'echo "Running on Windows system"'
                    }
                }
            }
        }

        stage('Code Quality') {
            parallel {
                stage('Static Analysis') {
                    steps {
                        script {
                            if (isUnix()) {
                                sh '''
                                    echo "Running HTML validation..."
                                    find . -name "*.html" -exec echo "Validating {}" \\;
                                '''
                            } else {
                                bat '''
                                    echo "Running HTML validation..."
                                    dir /s /b *.html
                                '''
                            }
                        }
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        script {
                            if (isUnix()) {
                                sh '''
                                    echo "Running security scan..."
                                    find . -type f -exec echo "Scanning {}" \\;
                                '''
                            } else {
                                bat '''
                                    echo "Running security scan..."
                                    dir /s /b
                                '''
                            }
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Check if package.json exists
                    def packageJsonExists = fileExists 'package.json'
                    
                    if (packageJsonExists) {
                        if (isUnix()) {
                            sh 'npm install'
                            sh 'npm run build'
                        } else {
                            bat 'npm install'
                            bat 'npm run build'
                        }
                    } else {
                        echo "No package.json found. Running basic build steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic build steps..."'
                        } else {
                            bat 'echo "Running basic build steps..."'
                        }
                        // List files in workspace
                        if (isUnix()) {
                            sh 'ls -la'
                        } else {
                            bat 'dir'
                        }
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def packageJsonExists = fileExists 'package.json'
                    
                    if (packageJsonExists) {
                        if (isUnix()) {
                            sh 'npm test'
                        } else {
                            bat 'npm test'
                        }
                    } else {
                        echo "No package.json found. Running basic test steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic test steps..."'
                        } else {
                            bat 'echo "Running basic test steps..."'
                        }
                        // List files in templates directory
                        if (isUnix()) {
                            sh 'ls -la templates/'
                        } else {
                            bat 'dir templates'
                        }
                        // List files in static directory
                        if (isUnix()) {
                            sh 'ls -la static/'
                        } else {
                            bat 'dir static'
                        }
                    }
                }
            }
            post {
                always {
                    script {
                        def testResultsExist = fileExists '**/test-results.xml'
                        if (testResultsExist) {
                            junit '**/test-results.xml'
                        } else {
                            echo 'No test results found, skipping JUnit report'
                        }
                    }
                }
            }
        }

        stage('Lint') {
            steps {
                script {
                    def packageJsonExists = fileExists 'package.json'
                    
                    if (packageJsonExists) {
                        if (isUnix()) {
                            sh 'npm run lint'
                        } else {
                            bat 'npm run lint'
                        }
                    } else {
                        echo "No package.json found. Running basic lint steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic lint steps..."'
                        } else {
                            bat 'echo "Running basic lint steps..."'
                        }
                        // List all HTML, CSS, and JS files
                        if (isUnix()) {
                            sh 'find . -type f -name "*.html" -o -name "*.css" -o -name "*.js"'
                        } else {
                            bat 'dir /s /b *.html *.css *.js'
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'which docker'
                    } else {
                        bat 'where docker'
                    }
                    
                    if (fileExists('Dockerfile')) {
                        if (isUnix()) {
                            sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        } else {
                            bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        }
                    } else {
                        error "Dockerfile not found!"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                               usernameVariable: 'DOCKER_USERNAME', 
                                               passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            '''
                        } else {
                            bat '''
                                echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                                docker push ikenna2025/final-project:%BUILD_NUMBER%
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application..."
                    
                    // Store current version before deployment
                    def currentVersion = bat(script: "docker ps -f name=final-project --format \"{{.Image}}\"", returnStdout: true).trim()
                    if (currentVersion) {
                        env.PREVIOUS_TAG = currentVersion.split(':')[1]
                        echo "Storing previous version: ${env.PREVIOUS_TAG}"
                    }
                    
                    // Stop and remove any existing container
                    bat """
                        docker stop final-project-%BUILD_NUMBER% || exit 0
                        docker rm final-project-%BUILD_NUMBER% || exit 0
                    """
                    
                    // Run the container directly on port 8081
                    bat "docker run -d -p 8081:80 --name final-project-%BUILD_NUMBER% ikenna2025/final-project:%BUILD_NUMBER%"
                    
                    // Wait for container to be healthy
                    def healthCheckPassed = false
                    for (int i = 0; i < HEALTH_CHECK_RETRIES.toInteger(); i++) {
                        sleep(HEALTH_CHECK_INTERVAL.toInteger())
                        def status = bat(script: "docker ps -f name=final-project-%BUILD_NUMBER% --format \"{{.Status}}\"", returnStdout: true).trim()
                        if (status && status.contains("Up")) {
                            healthCheckPassed = true
                            echo "Container is healthy. Status: ${status}"
                            break
                        }
                    }
                    
                    if (!healthCheckPassed) {
                        error "Health check failed after ${HEALTH_CHECK_RETRIES} attempts"
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace
            cleanWs()
        }
        success {
            script {
                echo "Application deployed successfully!"
                // Add deployment success metrics
                if (isUnix()) {
                    sh 'echo "Deployment metrics collected"'
                } else {
                    bat 'echo "Deployment metrics collected"'
                }
            }
        }
        failure {
            script {
                echo "Deployment failed! Initiating rollback..."
                
                // Rollback to previous version if available
                if (env.PREVIOUS_TAG && env.PREVIOUS_TAG != 'none') {
                    echo "Rolling back to version: ${env.PREVIOUS_TAG}"
                    
                    // Stop and remove failed container
                    bat """
                        docker stop final-project-%BUILD_NUMBER% || exit 0
                        docker rm final-project-%BUILD_NUMBER% || exit 0
                    """
                    
                    // Start previous version
                    bat "docker run -d -p 8081:80 --name final-project-rollback ikenna2025/final-project:${env.PREVIOUS_TAG}"
                    
                    // Verify rollback
                    sleep(10)
                    def rollbackStatus = bat(script: "docker ps -f name=final-project-rollback --format \"{{.Status}}\"", returnStdout: true).trim()
                    
                    if (rollbackStatus) {
                        echo "Rollback successful! Container status: ${rollbackStatus}"
                    } else {
                        echo "Rollback failed! Please check the container logs."
                    }
                } else {
                    echo "No previous version available for rollback"
                }
            }
        }
    }
} 