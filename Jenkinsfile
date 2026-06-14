pipeline {
    // This tells Jenkins to run this job specifically on your private EC2 slave
    agent any
        
          environment {
        AWS_REGION = 'us-east-1'          
        CLUSTER_NAME = 'my-eks-cluster'
    }

    
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


        stage('Security Scan (Trivy)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    echo "🛡️ Scanning Backend Image for High/Critical Vulnerabilities..."
                    
                    sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${USERNAME}/backend-app:${BUILD_NUMBER}"
                    
                    echo "🛡️ Scanning Frontend Image for High/Critical Vulnerabilities..."
                    sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${USERNAME}/frontend-app:${BUILD_NUMBER}"
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

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials']]) {

              dir('k8s') {

               
                sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                 
                    kubectl apply -f backend_configmap.yml
                    kubectl apply -f backend_secret.yml
                    kubectl apply -f ingress.yml
                    kubectl apply -f headless_service.yml
                    kubectl apply -f stateful_db.yml

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