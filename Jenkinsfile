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
        //createEnvironment('staging')
      }
    }

    stage('Create feature environment') {
      when {
        expression { env.BRANCH_NAME != 'master' }
      }

      steps {
        echo 'create custom environment'
        //createEnvironment(env.BRANCH_NAME)
      }
    }
  }
}

def createEnvironment(name) {
  sh "docker-compose down"
  sh "docker service rm ${name} || :"
  sh "docker service rm ${name}-pg || :"
  sh "docker service rm ${name}-redis || :"
  sh script: """\
    docker service create \
    --name ${name}-pg \
    --network traefik-net \
    postgres \
  """
  sh script: """\
    docker service create \
    --name ${name}-redis \
    --network traefik-net \
    redis \
  """
  sh script: """\
    docker service create \
    --name ${name} \
    -e REDIS_URL='redis://${name}-redis:6379' \
    -e DATABASE_URL='postgresql://postgres@${name}-pg/openjobs' \
    -e RAILS_ENV='production' \
    -e SECRET_KEY_BASE='5062c5efb655ca4e40512dc46b5167d7cea579a84160134813583ec1c339c3e390cbcfcf6ae7e31332e6fef9b4654d5068a1fd0a352beff2b1e8f0270908a3bd' \
    -e RAILS_SERVE_STATIC_FILES=true \
    --label 'traefik.port=3000' \
    --network traefik-net \
    openjobs:latest \
  """

  sh "sleep 60"

  sh "docker run -e RAILS_ENV=production -e DATABASE_URL=postgresql://postgres@${name}-pg/openjobs --network traefik-net --rm openjobs:latest rake db:create db:migrate assets:precompile"
}
