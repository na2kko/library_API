pipeline {
  
  agent any

  stages {

    stage("lint") {
      steps {
        sh '''
          docker compose -f docker-compose.ci.yml build app-test

          docker compose -f docker-compose.ci.yml run --rm app-test \
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
      }
    }

    stage("test") {
      steps {
        sh '''
          docker compose -f docker-compose.ci.yml run --rm app-test \
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
      }
    }

    stage("security") {
      steps {
        sh '''
          docker compose -f docker-compose.ci.yml run --rm app-test \
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
      }
    }

    stage("Deploy to Develop") {
      when {
        branch 'develop'
      }
      steps {
        script {
          sh '''
          docker compose up -d --build
        '''

        sh '''
          docker compose exec app php artisan migrate --force
        '''

        sh '''
          docker compose exec app php artisan config:cache
        '''

        sh '''
          docker compose exec app php artisan route:cache
        '''
        }
      }
      post {
        always {
          sh '''
            docker compose -f docker-compose.ci.yml down -v --remove-orphans || true
          '''
          sh 'docker compose -f docker-compose.ci.yml down -v || true'
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
