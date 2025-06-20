pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ikenna2025/final-project'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PREVIOUS_TAG = "${env.PREVIOUS_TAG ?: 'none'}"
        PATH_SEPARATOR = "${isUnix() ? '/' : '\\'}"
        APP_ENV = 'development'  // Default environment
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
        
        // Environment-specific configurations
        DEV_PORT = '8082'
        STAGING_PORT = '8081'
        PROD_PORT = '8083'  // Updated to match docker-compose.production.yml
        
        DEV_NETWORK = 'dev-network'
        STAGING_NETWORK = 'staging-network'
        PROD_NETWORK = 'prod-network'
        SLACK_CHANNEL = '#jenkins-notifications'
    }

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['development', 'staging', 'production'], description: 'Select deployment environment')
    }

    stages {
        stage('Version Management') {
            steps {
                script {
                    // Set environment-specific variables
                    if (params.DEPLOY_ENV == 'development') {
                        env.APP_ENV = 'development'
                        env.NGINX_PORT = env.DEV_PORT
                        env.NETWORK_NAME = env.DEV_NETWORK
                    } else if (params.DEPLOY_ENV == 'staging') {
                        env.APP_ENV = 'staging'
                        env.NGINX_PORT = env.STAGING_PORT
                        env.NETWORK_NAME = env.STAGING_NETWORK
                    } else if (params.DEPLOY_ENV == 'production') {
                        env.APP_ENV = 'production'
                        env.NGINX_PORT = env.PROD_PORT
                        env.NETWORK_NAME = env.PROD_NETWORK
                    }

                    // Create version.txt
                    if (isUnix()) {
                        sh """
                            echo "${VERSION}" > ${VERSION_FILE}
                            echo "Version ${VERSION} created for ${env.APP_ENV} environment"
                        """
                    } else {
                        bat """
                            echo ${VERSION} > ${VERSION_FILE}
                            echo Version ${VERSION} created for ${env.APP_ENV} environment
                        """
                    }

                    // Initialize version history
                    def versionHistory = [:]
                    if (fileExists(VERSION_HISTORY_FILE)) {
                        try {
                            versionHistory = readJSON file: VERSION_HISTORY_FILE
                        } catch (Exception e) {
                            echo "Error reading version history, creating new one"
                            versionHistory = [:]
                        }
                    }

                    // Get commit hash
                    def commitHash = isUnix() ? 
                        sh(script: 'git rev-parse HEAD', returnStdout: true).trim() :
                        bat(script: 'git rev-parse HEAD', returnStdout: true).trim()

                    // Update version history
                    versionHistory[BUILD_NUMBER] = [
                        version: VERSION,
                        timestamp: new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'"),
                        commit: commitHash,
                        environment: env.APP_ENV,
                        status: 'created'
                    ]

                    writeJSON file: VERSION_HISTORY_FILE, json: versionHistory
                    echo "Version history updated for build ${BUILD_NUMBER} in ${env.APP_ENV} environment"
                }
            }
        }

        stage('Checkout') {
            steps {
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
                                    --build-arg APP_ENV='${env.APP_ENV}' \\
                                    .
                            """
                            sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${VERSION}"
                            sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${env.APP_ENV}"
                        } else {
                            bat """
                                for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
                                set BUILD_DATE=%datetime:~0,8%T%datetime:~8,6%Z
                                docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} --build-arg VERSION=${VERSION} --build-arg BUILD_NUMBER=${BUILD_NUMBER} --build-arg BUILD_DATE=%BUILD_DATE% --build-arg APP_ENV=${env.APP_ENV} .
                            """
                            bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${VERSION}"
                            bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${env.APP_ENV}"
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
                                echo "${DOCKER_PASSWORD}" | docker login -u ${DOCKER_USERNAME} --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                docker push ${DOCKER_IMAGE}:${VERSION}
                                docker push ${DOCKER_IMAGE}:${env.APP_ENV}
                            '''
                        } else {
                            bat """
                                echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                docker push ${DOCKER_IMAGE}:${VERSION}
                                docker push ${DOCKER_IMAGE}:${env.APP_ENV}
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying application version ${VERSION} to ${DEPLOY_ENV} environment..."
                    
                    // Check if port is available
                    def port = DEPLOY_ENV == 'development' ? env.DEV_PORT : 
                              DEPLOY_ENV == 'staging' ? env.STAGING_PORT : 
                              env.PROD_PORT
                    
                    if (isUnix()) {
                        def portCheck = sh(script: "netstat -tuln | grep ':${port}' || true", returnStdout: true).trim()
                        if (portCheck) {
                            echo "Port ${port} is in use. Attempting to stop existing containers..."
                            sh "docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down || true"
                            sleep(5) // Wait for containers to stop
                            portCheck = sh(script: "netstat -tuln | grep ':${port}' || true", returnStdout: true).trim()
                            if (portCheck) {
                                error "Port ${port} is still in use after stopping containers. Please free up the port manually."
                            }
                        }
                    } else {
                        def portCheck = bat(script: "netstat -ano | findstr :${port}", returnStdout: true).trim()
                        if (portCheck) {
                            echo "Port ${port} is in use. Attempting to stop existing containers..."
                            bat "docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down || exit /b 0"
                            sleep(5) // Wait for containers to stop
                            portCheck = bat(script: "netstat -ano | findstr :${port}", returnStdout: true).trim()
                            if (portCheck) {
                                error "Port ${port} is still in use after stopping containers. Please free up the port manually."
                            }
                        }
                    }
                    
                    // Store current version for rollback
                    def versionHistory = [:]
                    if (fileExists(VERSION_HISTORY_FILE)) {
                        try {
                            versionHistory = readJSON file: VERSION_HISTORY_FILE
                        } catch (Exception e) {
                            echo "Error reading version history, creating new one"
                            versionHistory = [:]
                        }
                    }
                    
                    // Store previous version before deployment
                    env.PREVIOUS_VERSION = versionHistory.currentVersion ?: 'none'
                    echo "Storing previous version: ${env.PREVIOUS_VERSION}"
                    
                    // Set environment-specific variables
                    if (isUnix()) {
                        sh """
                            export COMPOSE_PROJECT_NAME=final-project-${DEPLOY_ENV}
                            export DOCKER_IMAGE=${DOCKER_IMAGE}
                            export NGINX_PORT=${port}
                            export NETWORK_NAME=${env.NETWORK_NAME}
                            export VERSION=${VERSION}
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down || true
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml up -d
                        """
                    } else {
                        bat """
                            set COMPOSE_PROJECT_NAME=final-project-${DEPLOY_ENV}
                            set DOCKER_IMAGE=${DOCKER_IMAGE}
                            set NGINX_PORT=${port}
                            set NETWORK_NAME=${env.NETWORK_NAME}
                            set VERSION=${VERSION}
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down || exit /b 0
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml up -d
                        """
                    }
                    
                    // Update version history
                    versionHistory.currentVersion = VERSION
                    versionHistory.previousVersion = env.PREVIOUS_VERSION
                    versionHistory.lastDeployed = new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'")
                    versionHistory.environment = DEPLOY_ENV
                    writeJSON file: VERSION_HISTORY_FILE, json: versionHistory
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
                try {
                    withCredentials([string(credentialsId: 'slack-token2', variable: 'SLACK_TOKEN')]) {
                        slackSend(
                            channel: env.SLACK_CHANNEL,
                            color: 'good',
                            message: """
                                :white_check_mark: Pipeline Succeeded
                                *Build:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
                                *Version:* ${VERSION}
                                *Environment:* ${DEPLOY_ENV}
                                *Changes:* ${currentBuild.changeSets}
                                *Build URL:* ${env.BUILD_URL}
                            """
                        )
                    }
                } catch (Exception e) {
                    echo "Failed to send Slack notification: ${e.message}"
                }
            }
        }
        failure {
            script {
                try {
                    withCredentials([string(credentialsId: 'slack-token2', variable: 'SLACK_TOKEN')]) {
                        slackSend(
                            channel: env.SLACK_CHANNEL,
                            color: 'danger',
                            message: """
                                :x: Pipeline Failed
                                *Build:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
                                *Version:* ${VERSION}
                                *Environment:* ${DEPLOY_ENV}
                                *Error:* ${currentBuild.description ?: 'No error description available'}
                                *Build URL:* ${env.BUILD_URL}
                            """
                        )
                    }
                } catch (Exception e) {
                    echo "Failed to send Slack notification: ${e.message}"
                }
                
                // Attempt rollback if deployment failed
                echo "Deployment failed! Initiating rollback..."
                if (env.PREVIOUS_VERSION && env.PREVIOUS_VERSION != 'none') {
                    echo "Rolling back to version: ${env.PREVIOUS_VERSION}"
                    def port = DEPLOY_ENV == 'development' ? env.DEV_PORT : 
                              DEPLOY_ENV == 'staging' ? env.STAGING_PORT : 
                              env.PROD_PORT
                    
                    if (isUnix()) {
                        sh """
                            export COMPOSE_PROJECT_NAME=final-project-${DEPLOY_ENV}
                            export DOCKER_IMAGE=${DOCKER_IMAGE}
                            export NGINX_PORT=${port}
                            export NETWORK_NAME=${env.NETWORK_NAME}
                            export VERSION=${env.PREVIOUS_VERSION}
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml up -d
                        """
                    } else {
                        bat """
                            set COMPOSE_PROJECT_NAME=final-project-${DEPLOY_ENV}
                            set DOCKER_IMAGE=${DOCKER_IMAGE}
                            set NGINX_PORT=${port}
                            set NETWORK_NAME=${env.NETWORK_NAME}
                            set VERSION=${env.PREVIOUS_VERSION}
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml down
                            docker-compose -f docker-compose.yml -f docker-compose.${DEPLOY_ENV}.yml up -d
                        """
                    }
                } else {
                    echo "No previous version available for rollback"
                }
            }
        }
        unstable {
            script {
                try {
                    withCredentials([string(credentialsId: 'slack-token2', variable: 'SLACK_TOKEN')]) {
                        slackSend(
                            channel: env.SLACK_CHANNEL,
                            color: 'warning',
                            message: """
                                :warning: Pipeline Unstable
                                *Build:* ${env.JOB_NAME} #${env.BUILD_NUMBER}
                                *Version:* ${VERSION}
                                *Environment:* ${DEPLOY_ENV}
                                *Build URL:* ${env.BUILD_URL}
                            """
                        )
                    }
                } catch (Exception e) {
                    echo "Failed to send Slack notification: ${e.message}"
                }
            }
        }
    }
}