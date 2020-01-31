pipeline {
    agent any 
    stages {
        stage('Build a car for Ariza') { 
            steps {
               sh  '''echo "Building a package"
                      echo "deploy my car"
                      pwd 
                      ls -ltrhsa
                   '''
            }
        }
        stage('Test') { 
            steps {
               sh 'echo "Testing a package"'
            }
        }
        stage('Deploy') { 
            steps {
               sh 'echo "Deploying a package"' 
            }
        }
    }
}
