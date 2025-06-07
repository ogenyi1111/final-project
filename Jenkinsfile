pipeline {
    agent any

    environment {
        // Define environment variables
        DOCKER_IMAGE = 'final-project'
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
                        echo "No package.json found. Running basic build steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic build steps..."'
                            sh 'ls -la'
                        } else {
                            bat 'echo "Running basic build steps..."'
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
                            sh "${env.NPM_CMD} run test"
                        } else {
                            bat "${env.NPM_CMD} run test"
                        }
                    } else {
                        echo "No package.json found. Running basic test steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic test steps..."'
                            sh 'ls -la templates/'
                            sh 'ls -la static/'
                        } else {
                            bat 'echo "Running basic test steps..."'
                            bat 'dir templates'
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
                            sh "${env.NPM_CMD} run lint"
                        } else {
                            bat "${env.NPM_CMD} run lint"
                        }
                    } else {
                        echo "No package.json found. Running basic lint steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic lint steps..."'
                            sh 'find . -type f -name "*.html" -o -name "*.css" -o -name "*.js"'
                        } else {
                            bat 'echo "Running basic lint steps..."'
                            bat 'dir /s /b *.html *.css *.js'
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def dockerAvailable = isUnix() ? 
                        sh(script: 'which docker', returnStatus: true) == 0 :
                        bat(script: 'where docker', returnStatus: true) == 0

                    if (dockerAvailable) {
                        // Check if Dockerfile exists
                        def dockerfileExists = fileExists 'Dockerfile'
                        if (!dockerfileExists) {
                            error 'Dockerfile not found. Cannot build Docker image.'
                        }

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
                    if (isUnix()) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    } else {
                        bat 'docker login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%'
                        bat "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
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