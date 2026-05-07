pipeline {
  
  agent any

  environment {
    CI_PROJECT = "library-ci"
    PROD_PROJECT = "library-prod"
  }

  stages {

    stage("lint") {
      steps {
        sh '''
          docker compose \
            -p $CI_PROJECT \
            -f docker-compose.ci.yml \
            build app-test

          docker compose \
            -p $CI_PROJECT \
            -f docker-compose.ci.yml \
            run --rm app-test \
            php ./vendor/bin/pint --test
        '''
      }
      post {
        failure {
          echo 'Estilo de de código incorrecto. Recuerda correr \'./vendor/bin/pint\' de manera local.'
        }
        success {
          echo 'La prueba de estilos del código fue completada de manera correcta.'
        }
        always {
          sh '''
            docker compose \
              -p $CI_PROJECT \
              -f docker-compose.ci.yml \
              down -v || true
          '''
        }
      }
    }

    stage("test") {
      steps {
        sh '''
          docker compose \
            -p $CI_PROJECT \
            -f docker-compose.ci.yml \
            run --rm app-test \
            sh -c "
              touch /tmp/testing.sqlite &&
              php artisan migrate:fresh --force &&
              php artisan test
            "
        '''
      }
      post {
        failure {
          echo 'Los tests fallaron. Recuerda correr \'php artisan test\' de manera local.'
        }
        success {
          echo 'Las pruebas de código fueron completadas de manera correcta.'
        }
        always {
          sh '''
            docker compose \
              -p $CI_PROJECT \
              -f docker-compose.ci.yml \
              down -v || true
          '''
        }
      }
    }

    stage("security") {
      steps {
        sh '''
          docker compose \
            -p $CI_PROJECT \
            -f docker-compose.ci.yml \
            run --rm app-test \
            composer audit
        '''
      }
      post {
        failure {
          echo 'Los test de seguridad fallaron. Recuerda correr \'composer audit\' de manera local.'
        }
        success {
          echo 'Las pruebas de seguridad fueron completadas de manera correcta.'
        }
        always {
          sh '''
            docker compose \
              -p $CI_PROJECT \
              -f docker-compose.ci.yml \
              down -v || true
          '''
        }
      }
    }

    stage("Deploy to Develop") {
      when {
        branch 'develop'
      }
      steps {
        script {
          sh '''
            docker compose \
              -p $PROD_PROJECT \
              up -d --build
          '''

          sh '''
            docker compose \
              -p $PROD_PROJECT \
              exec -T app \
              php artisan migrate --force
          '''

          sh '''
            docker compose \
              -p $PROD_PROJECT \
              exec -T app \
              php artisan config:cache
          '''

          sh '''
            docker compose \
              -p $PROD_PROJECT \
              exec -T app \
              php artisan route:cache
          '''
        }
      }
      post {
        always {
          sh 'docker image prune -f || true'
          sh 'docker builder prune -f || true'
        }
        success {
          echo 'Pipeline completada correctamente.'
        }

        failure {
          echo 'La pipeline falló.'
        }
      }
    }
  }
}
