
pipeline {
	agent any

	environment {
		APP_NAME = 'spring-petclinic'
	}
	stages {
		stage('Checkout') {
			steps {
				checkout scm
			}
		}

		stage('Checkstyle') {
			when {
				changeRequest()
			}
			steps {
				sh './mvnw -B checkstyle:checkstyle'
				archiveArtifacts artifacts: 'target/site/checkstyle.html,target/checkstyle-result.xml'
			}
		}

		stage('Test') {
			when {
				changeRequest()
			}
			steps {
				sh './mvnw -B test'
			}
		}

		stage('Build without tests') {
			when {
				changeRequest()
			}
			steps {
				sh './mvnw -B -DskipTests package'
			}
		}

		stage('Create docker image for merge request') {
			when {
				changeRequest()
			}
			steps {
				sh './mvnw -B -DskipTests package'
				withCredentials([usernamePassword(credentialsId: 'nexus-docker', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
					sh '''
						set -eu
						SHORT_COMMIT=$(git rev-parse --short=7 HEAD)
						docker login "$NEXUS_DOCKER_MR_REGISTRY" -u "$NEXUS_USER" -p "$NEXUS_PASSWORD"
						docker build -t "${APP_NAME}:${SHORT_COMMIT}" .
						docker tag "${APP_NAME}:${SHORT_COMMIT}" "$NEXUS_DOCKER_MR_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
						docker push "$NEXUS_DOCKER_MR_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
					'''
				}
			}
		}

		stage('Create docker image for main') {
			when {
				branch 'main'
			}
			steps {
				sh './mvnw -B -DskipTests package'
				withCredentials([usernamePassword(credentialsId: 'nexus-docker', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
					sh '''
						set -eu
						SHORT_COMMIT=$(git rev-parse --short=7 HEAD)
						docker login "$NEXUS_DOCKER_MAIN_REGISTRY" -u "$NEXUS_USER" -p "$NEXUS_PASSWORD"
						docker build -t "${APP_NAME}:${SHORT_COMMIT}" .
						docker tag "${APP_NAME}:${SHORT_COMMIT}" "$NEXUS_DOCKER_MAIN_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
						docker push "$NEXUS_DOCKER_MAIN_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
					'''
				}
			}
		}
	}
}
