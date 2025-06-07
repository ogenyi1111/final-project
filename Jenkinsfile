pipeline {
    agent any

    environment {
        // Define environment variables
        DOCKER_IMAGE = 'your-app-name'
        DOCKER_TAG = "${BUILD_NUMBER}"
        // Cross-platform path separator
        PATH_SEPARATOR = "${isUnix() ? '/' : '\\'}"
        // GitHub repository URL
        GITHUB_REPO = 'https://github.com/ogenyi1111/final-project.git'
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
                    // Detect OS and set appropriate commands
                    def isWindows = isUnix() ? false : true
                    def npmCmd = isWindows ? 'npm.cmd' : 'npm'
                    
                    // Store these in environment variables for use in other stages
                    env.NPM_CMD = npmCmd
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
                            sh "${env.NPM_CMD} install"
                            sh "${env.NPM_CMD} run build"
                        } else {
                            bat "${env.NPM_CMD} install"
                            bat "${env.NPM_CMD} run build"
                        }
                    } else {
                        echo "No package.json found. Skipping npm build steps."
                        // Add your non-Node.js build steps here
                        if (isUnix()) {
                            sh 'echo "Running non-Node.js build steps..."'
                        } else {
                            bat 'echo "Running non-Node.js build steps..."'
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
                            sh "${env.NPM_CMD} run test"
                        } else {
                            bat "${env.NPM_CMD} run test"
                        }
                    } else {
                        echo "No package.json found. Skipping npm test steps."
                        // Add your non-Node.js test steps here
                        if (isUnix()) {
                            sh 'echo "Running non-Node.js test steps..."'
                        } else {
                            bat 'echo "Running non-Node.js test steps..."'
                        }
                    }
                }
            }
            post {
                always {
                    // Publish test results with cross-platform path handling
                    junit "**${env.PATH_SEPARATOR}test-results.xml"
                }
            }
        }

        stage('Lint') {
            steps {
                script {
                    def packageJsonExists = fileExists 'package.json'
                    
                    if (packageJsonExists) {
                        if (isUnix()) {
                            sh "${env.NPM_CMD} run lint"
                        } else {
                            bat "${env.NPM_CMD} run lint"
                        }
                    } else {
                        echo "No package.json found. Skipping npm lint steps."
                        // Add your non-Node.js lint steps here
                        if (isUnix()) {
                            sh 'echo "Running non-Node.js lint steps..."'
                        } else {
                            bat 'echo "Running non-Node.js lint steps..."'
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Check if Docker is available
                    def dockerAvailable = isUnix() ? 
                        sh(script: 'which docker', returnStatus: true) == 0 :
                        bat(script: 'where docker', returnStatus: true) == 0

                    if (dockerAvailable) {
                        // Build Docker image with cross-platform compatibility
                        if (isUnix()) {
                            sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        } else {
                            bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        }
                    } else {
                        echo "Docker not available, skipping Docker build stage"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Check if Docker is available
                    def dockerAvailable = isUnix() ? 
                        sh(script: 'which docker', returnStatus: true) == 0 :
                        bat(script: 'where docker', returnStatus: true) == 0

                    if (dockerAvailable) {
                        // Push Docker image with cross-platform compatibility
                        if (isUnix()) {
                            sh """
                                docker login your-registry.com -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            """
                        } else {
                            bat """
                                docker login your-registry.com -u %DOCKER_USER% -p %DOCKER_PASSWORD%
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            """
                        }
                    } else {
                        echo "Docker not available, skipping Docker push stage"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Cross-platform deployment commands
                    if (isUnix()) {
                        sh 'echo "Deploying application on Unix-based system..."'
                    } else {
                        bat 'echo "Deploying application on Windows..."'
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
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 