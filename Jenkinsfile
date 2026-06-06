pipeline {
    // This tells Jenkins to run this job specifically on your private EC2 slave
    agent any
        
    
    stages {
        stage('Pull Code') {
            steps {
              
                checkout scm
            }
        }

        
        stage('Build multiple Docker images') {
           steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    dir('app') {
                        sh '''

                            echo "Building Docker image version ${BUILD_NUMBER}..."
                            docker build -t ${USERNAME}/backend-app:${BUILD_NUMBER} .
                            
                        '''
                    }
                    dir('frontend') {
                        sh '''

                            echo "Building Docker image version ${BUILD_NUMBER}..."
                            docker build -t ${USERNAME}/frontend-app:${BUILD_NUMBER} .
                            
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

                    dir('frontend') {
                        sh '''
                            docker login -u ${USERNAME} --password ${PASSWORD}
                            docker push ${USERNAME}/frontend-app:${BUILD_NUMBER}
                        '''
                    }
                }
            }
          
              
              
        }

        
      stage ('Deploy') {
            steps {

              dir('k8s') {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                sh '''

                    kubectl apply -f backend_configmap.yml
                    kubectl apply -f backend_secret.yml

                    echo "Deploying version ${BUILD_NUMBER} to Kubernetes..."
                    sed -i "s/latest/$BUILD_NUMBER/g"   backend_deployment.yml
                    sed -i "s/latest/$BUILD_NUMBER/g"   frontend_deployment.yml

                    kubectl apply -f backend_deployment.yml
                    kubectl apply -f backend_service.yml
                    kubectl apply -f frontend_deployment.yml
                    kubectl apply -f frontend_service.yml

                   
                '''
              }
              }
    
    }
    }
}
}