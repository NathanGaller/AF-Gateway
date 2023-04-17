@Library('ng-lib')
def gv

pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials("nathan-access-awsaccountid")
        AWS_REGION = credentials("AWS_REGION")
    }
    
    parameters {
        booleanParam(name: 'deployToECS', defaultValue: false, description: 'Set to true to deploy to ECS')
        booleanParam(name: 'deployToEKS', defaultValue: false, description: 'Set to true to deploy to EKS')
        string(name: 'commitToRevertTo', defaultValue: '', description: 'Specify the commit SHA or branch name to revert to')
    }
    
    stages {
        stage('Revert to Previous Commit') {
            when {
                expression {
                    return params.commitToRevertTo != ''
                }
            }
            steps {
                script {
                    git "reset --hard ${params.commitToRevertTo}"
                }
            }
        }

        stage('Loading Environment Variables') {
            steps {
                script {
                    def envMap = readYaml(file: 'env.yaml')
                    envMap.each { k, v ->
                        env[k] = "${v}"
                    }
                }
            }
        }
        
        stage('Git Submodule Update.') {
            steps {
                script {
                    submodule.submodule()
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    build.sonarqubeMaven()
                }
            }
        }
        
        stage('Build and Package') {
            steps {
                script {
                    build.buildMaven()
                    build.dockerImage()
                    build.dockerPush()
                }
            }
        }
                
        stage('Deploy to ECS') {
            when {
                expression { 
                    return params.deployToECS
                }
            }
            steps {
                script {
                    ecs.toECS()
                }
            }
        }
        
        stage('Deploy to EKS') {
            when {
                expression { 
                    return params.deployToEKS
                }
            }
            steps {
                script {
                    eks.deployToEKSBackend()
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
            sh 'docker system prune -af --volumes'
        }
    }
}


