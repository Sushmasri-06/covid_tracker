pipeline {
  agent any

  environment {
    IMAGE = "sushmasri06/covid-tracker"
    TAG = "${env.BUILD_NUMBER ?: 'local'}"
    FULL_IMAGE = "${env.IMAGE}:${env.TAG}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Flutter Web') {
      steps {
        // Use a Flutter Docker image to build the web artifacts
        script {
          docker.image('cirrusci/flutter:stable').inside('-u root:root') {
            sh '''
              flutter --version
              flutter pub get
              flutter build web --release
            '''
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build final image using Docker on agent
          sh "docker build -t ${FULL_IMAGE} ."
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // dockerhub-creds must be a Jenkins username/password credential
          docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
            sh "docker push ${FULL_IMAGE}"
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          // kubeconfig is a Jenkins "Secret file" credential id
          withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
            sh '''
              export KUBECONFIG=${KUBECONFIG_FILE}
              # update image and rollout
              kubectl set image deployment/covid-tracker-deployment covid-tracker=${FULL_IMAGE} --namespace=default || true
              kubectl rollout status deployment/covid-tracker-deployment --timeout=120s || true
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded: ${FULL_IMAGE}"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
