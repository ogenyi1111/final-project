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
                    def shellPrefix = isWindows ? 'cmd /c ' : ''
                    
                    // Store these in environment variables for use in other stages
                    env.NPM_CMD = npmCmd
                    env.SHELL_PREFIX = shellPrefix
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Use cross-platform commands
                    sh "${env.SHELL_PREFIX}${env.NPM_CMD} install"
                    sh "${env.SHELL_PREFIX}${env.NPM_CMD} run build"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run tests with cross-platform compatibility
                    sh "${env.SHELL_PREFIX}${env.NPM_CMD} run test"
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
                    // Run linting with cross-platform compatibility
                    sh "${env.SHELL_PREFIX}${env.NPM_CMD} run lint"
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
                        // Add Unix-specific deployment commands
                    } else {
                        bat 'echo "Deploying application on Windows..."'
                        // Add Windows-specific deployment commands
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