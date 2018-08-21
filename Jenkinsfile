#! /usr/bin/env groovy
pipeline {
  agent { label 'docker' }

  environment {
    COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}".replaceAll("/", "-")
    COMPOSE_FILE = "docker-compose.yml:docker-compose.test.yml"
    RAILS_ENV = "test"
  }

  stages {
    stage('Build') {
      steps {
        sh 'docker-compose build --pull'
        sh 'docker-compose up -d db'
      }
    }
    stage('Prepare') {
      steps {
        sh 'docker-compose run --rm -T web bundle exec rake db:setup'
      }
    }
    stage('Test') {
      parallel {
        stage('RSpec') {
          steps {
            sh 'docker-compose run --rm -T --name=\$COMPOSE_PROJECT_NAME-rspec web bundle exec rake spec'
          }
        }
        stage('Jasmine') {
          steps {
            sh 'docker-compose run --rm -T --name=\$COMPOSE_PROJECT_NAME-jasmine web bundle exec rake spec:javascript'
          }
        }
        stage('Cucumber') {
          steps {
            sh 'docker-compose run --rm -T --name=\$COMPOSE_PROJECT_NAME-cucumber web bash bin/cucumber'
          }
        }
        stage('Brakeman') {
          steps {
            sh 'docker-compose run --rm -T --name=\$COMPOSE_PROJECT_NAME-brakeman web bundle exec brakeman'
          }
        }
      }
    }
  }

  post {
    cleanup {
      sh 'docker-compose down --remove-orphans --rmi all'
    }
  }
}
