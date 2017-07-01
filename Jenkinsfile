pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'docker build -t openjobs:latest .'
        sh 'docker-compose build'
        sh 'docker-compose run web bundle install'
        sh 'docker-compose run web yarn'
        sh 'docker-compose run -e RAILS_ENV=test --rm web bundle exec rake db:drop db:create db:migrate'
      }
    }
    stage('Tests') {
      steps {
        parallel(
          "Unit Tests": {
            sh 'docker-compose run --name unit --rm web rspec --exclude-pattern "**/features/*_spec.rb"'
            
          },
          "Feature tests": {
            sh 'docker-compose run --name feature --rm web rspec spec/features/'
          }
        )
      }
    }

    stage('Deploy to Staging') {
      when {
        expression { env.BRANCH_NAME == 'master' }
      }
      steps {
        echo 'deploy to staging'
      }
    }

    stage('Create feature environment') {
      when {
        expression { env.BRANCH_NAME != 'master' }
      }

      steps {
        echo 'create custom environment'
      }
    }
  }
}
