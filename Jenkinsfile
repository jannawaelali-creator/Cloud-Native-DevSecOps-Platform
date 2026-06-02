pipeline {
    // This tells Jenkins to run this job specifically on your private EC2 slave
    agent any
        
    
    stages {
        stage('Pull Code') {
            steps {
              
                checkout scm
            }
        }

        
        stage('Build') {
           steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    dir('app') {
                        sh '''

                            echo "Building Docker image version ${BUILD_NUMBER}..."
                            docker build -t ${USERNAME}/backend-app:${BUILD_NUMBER} .
                            docker login -u ${USERNAME} --password ${PASSWORD}
                            docker push ${USERNAME}/backend-app:${BUILD_NUMBER}
                        '''
                    }
                }
            }
        }

        stage('Push ') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    dir('app') {
                        sh '''
                            docker login -u ${USERNAME} --password ${PASSWORD}
                            docker push ${USERNAME}/backend-app:${BUILD_NUMBER}
                        '''
                    }
                }
            }
          
              
              
        }

        
      stage ('Deploy') {
            steps {
              dir('k8s') {
                sh '''
                    echo "Deploying version ${BUILD_NUMBER} to Kubernetes..."
                    sed -i "s/latest/$BUILD_NUMBER/g" deployment.yaml

                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '''
              }
    
    }
    }
}
}