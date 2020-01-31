pipeline {
    agent any 
    stages {
        stage('Build') { 
            steps {
               sh 'echo "Building a package"'
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
