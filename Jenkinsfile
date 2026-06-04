
pipeline {
	agent any

	environment {
		APP_NAME = 'spring-petclinic'
		NEXUS_DOCKER_MR_REGISTRY = 'localhost:8081/repository/mr'
		NEXUS_DOCKER_MAIN_REGISTRY = 'localhost:8081/repository/main'
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
					withEnv(["NEXUS_DOCKER_REGISTRY=${env.NEXUS_DOCKER_MR_REGISTRY}"] ) {
					sh '''
						set -eu
						SHORT_COMMIT=$(git rev-parse --short=7 HEAD)
						docker build -t "${APP_NAME}:${SHORT_COMMIT}" .
						docker login "$NEXUS_DOCKER_REGISTRY" -u "$NEXUS_USER" -p "$NEXUS_PASSWORD"
						docker tag "${APP_NAME}:${SHORT_COMMIT}" "$NEXUS_DOCKER_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
						docker push "$NEXUS_DOCKER_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
					'''
					}
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
					withEnv(["NEXUS_DOCKER_REGISTRY=${env.NEXUS_DOCKER_MAIN_REGISTRY}"] ) {
					sh '''
						set -eu
						SHORT_COMMIT=$(git rev-parse --short=7 HEAD)
						docker build -t "${APP_NAME}:${SHORT_COMMIT}" .
						docker login "$NEXUS_DOCKER_REGISTRY" -u "$NEXUS_USER" -p "$NEXUS_PASSWORD"
						docker tag "${APP_NAME}:${SHORT_COMMIT}" "$NEXUS_DOCKER_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
						docker push "$NEXUS_DOCKER_REGISTRY/${APP_NAME}:${SHORT_COMMIT}"
					'''
					}
				}
			}
		}
	}
}
