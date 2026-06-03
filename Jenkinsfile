
pipeline {
	agent any

	stages {
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
				script {
					def shortCommit = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
					def registry = env.NEXUS_DOCKER_MR_REGISTRY

					if (!registry) {
						error('Set NEXUS_DOCKER_MR_REGISTRY in the Jenkins job or agent environment.')
					}

					docker.withRegistry("https://${registry}", 'nexus-docker') {
						def image = docker.build("spring-petclinic:${shortCommit}", '.')
						image.push(shortCommit)
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
				script {
					def shortCommit = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
					def registry = env.NEXUS_DOCKER_MAIN_REGISTRY

					if (!registry) {
						error('Set NEXUS_DOCKER_MAIN_REGISTRY in the Jenkins job or agent environment.')
					}

					docker.withRegistry("https://${registry}", 'nexus-docker') {
						def image = docker.build("spring-petclinic:${shortCommit}", '.')
						image.push(shortCommit)
					}
				}
			}
		}
	}
}
