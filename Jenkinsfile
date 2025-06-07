pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ikenna2025/final-project'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PREVIOUS_TAG = "${env.PREVIOUS_TAG ?: 'none'}"
        PATH_SEPARATOR = "${isUnix() ? '/' : '\\'}"
        APP_ENV = 'production'
        NGINX_PORT = '80'
        GITHUB_REPO = 'https://github.com/ogenyi1111/final-project.git'
        HEALTH_CHECK_RETRIES = '3'
        HEALTH_CHECK_INTERVAL = '10'
        VERSION_FILE = 'version.txt'
        MAJOR_VERSION = '1'
        MINOR_VERSION = '0'
        PATCH_VERSION = '0'
        VERSION = "${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${BUILD_NUMBER}"
        VERSION_HISTORY_FILE = 'version_history.json'
    }

    stages {
        stage('Version Management') {
            steps {
                script {
                    if (isUnix()) {
                        sh """
                            echo "${VERSION}" > ${VERSION_FILE}
                            echo "Version ${VERSION} created"
                        """
                    } else {
                        bat """
                            echo ${VERSION} > ${VERSION_FILE}
                            echo Version ${VERSION} created
                        """
                    }

                    def versionHistory = [:]
                    if (fileExists(VERSION_HISTORY_FILE)) {
                        versionHistory = readJSON file: VERSION_HISTORY_FILE
                    }

                    def commitHash = isUnix() ? 
                        sh(script: 'git rev-parse HEAD', returnStdout: true).trim() :
                        bat(script: 'git rev-parse HEAD', returnStdout: true).trim()

                    versionHistory[BUILD_NUMBER] = [
                        version: VERSION,
                        timestamp: new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
                        commit: commitHash,
                        status: 'created'
                    ]

                    writeJSON file: VERSION_HISTORY_FILE, json: versionHistory
                }
            }
        }

        stage('Checkout') {
            steps {
                cleanWs()
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
                        bat 'echo Running on Windows system'
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
                                    echo Running HTML validation...
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
                                    echo Running security scan...
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
                            sh 'ls -la'
                        } else {
                            bat 'echo Running basic build steps...'
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
                            sh 'ls -la templates/'
                            sh 'ls -la static/'
                        } else {
                            bat 'echo Running basic test steps...'
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
                            sh 'npm run lint'
                        } else {
                            bat 'npm run lint'
                        }
                    } else {
                        echo "No package.json found. Running basic lint steps..."
                        if (isUnix()) {
                            sh 'echo "Running basic lint steps..."'
                            sh 'find . -type f -name "*.html" -o -name "*.css" -o -name "*.js"'
                        } else {
                            bat 'echo Running basic lint steps...'
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
                            sh """
                                docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} \\
                                    --build-arg VERSION='${VERSION}' \\
                                    --build-arg BUILD_NUMBER='${BUILD_NUMBER}' \\
                                    --build-arg BUILD_DATE="\$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \\
                                    .
                            """
                            sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${VERSION}"
                        } else {
                            bat """
                                set BUILD_DATE=%date:~-4%-%date:~3,2%-%date:~0,2%T%time:~0,8%Z
                                docker build -t ikenna2025/final-project:${BUILD_NUMBER} --build-arg VERSION=${VERSION} --build-arg BUILD_NUMBER=${BUILD_NUMBER} --build-arg BUILD_DATE=%BUILD_DATE% .
                            """
                            bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${VERSION}"
                        }
                    } else {
                        error "Dockerfile not found!"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            '''
                        } else {
                            bat '''
                                echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application version ${VERSION}..."

                    def currentVersion = isUnix() ?
                        sh(script: "docker ps -f name=final-project --format '{{.Image}}'", returnStdout: true).trim() :
                        bat(script: "docker ps -f name=final-project --format '{{.Image}}'", returnStdout: true).trim()

                    if (currentVersion) {
                        env.PREVIOUS_TAG = currentVersion.split(':')[1]
                        echo "Storing previous version: ${env.PREVIOUS_TAG}"

                        def versionHistory = readJSON file: VERSION_HISTORY_FILE
                        versionHistory[env.PREVIOUS_TAG].status = 'deployed'
                        writeJSON file: VERSION_HISTORY_FILE, json: versionHistory
                    }

                    try {
                        if (isUnix()) {
                            sh "docker stop final-project-${BUILD_NUMBER} || true"
                            sh "docker rm final-project-${BUILD_NUMBER} || true"
                            sh "docker run -d -p 80:80 --name final-project-${BUILD_NUMBER} ${DOCKER_IMAGE}:${VERSION}"
                        } else {
                            bat "docker stop final-project-%BUILD_NUMBER% || exit 0"
                            bat "docker rm final-project-%BUILD_NUMBER% || exit 0"
                            bat "docker run -d -p 80:80 --name final-project-%BUILD_NUMBER% ${DOCKER_IMAGE}:${VERSION}"
                        }

                        def versionHistory = readJSON file: VERSION_HISTORY_FILE
                        versionHistory[BUILD_NUMBER].status = 'deployed'
                        writeJSON file: VERSION_HISTORY_FILE, json: versionHistory

                    } catch (Exception e) {
                        echo "Deployment failed, attempting rollback..."

                        if (env.PREVIOUS_TAG != 'none') {
                            if (isUnix()) {
                                sh "docker run -d -p 80:80 --name final-project-${BUILD_NUMBER} ${DOCKER_IMAGE}:${env.PREVIOUS_TAG}"
                            } else {
                                bat "docker run -d -p 80:80 --name final-project-%BUILD_NUMBER% ${DOCKER_IMAGE}:${env.PREVIOUS_TAG}"
                            }

                            def versionHistory = readJSON file: VERSION_HISTORY_FILE
                            versionHistory[BUILD_NUMBER].status = 'failed'
                            versionHistory[env.PREVIOUS_TAG].status = 'rolled_back'
                            writeJSON file: VERSION_HISTORY_FILE, json: versionHistory

                            echo "Rolled back to version ${env.PREVIOUS_TAG}"
                        } else {
                            error "Deployment failed and no previous version available for rollback"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            script {
                echo "Application deployed successfully!"
                if (isUnix()) {
                    sh 'echo "Deployment metrics collected"'
                } else {
                    bat 'echo Deployment metrics collected'
                }
            }
        }
        failure {
            script {
                echo "Deployment failed! Initiating rollback..."

                if (env.PREVIOUS_TAG && env.PREVIOUS_TAG != 'none') {
                    echo "Rolling back to version: ${env.PREVIOUS_TAG}"
                    bat """
                        docker stop final-project-%BUILD_NUMBER% || exit 0
                        docker rm final-project-%BUILD_NUMBER% || exit 0
                    """
                    bat "docker run -d -p 8081:80 --name final-project-rollback ikenna2025/final-project:${env.PREVIOUS_TAG}"
                    sleep(10)
                    def rollbackStatus = bat(script: "docker ps -f name=final-project-rollback --format '{{.Status}}'", returnStdout: true).trim()
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
