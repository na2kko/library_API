pipeline {
  
  agent any

  environment {
    DB_CONNECTION='mysql'
    DB_HOST='library-db'
    DB_PORT='3306'
    DB_DATABASE='laravel'
    DB_USERNAME='test-user'
    DB_PASSWORD='test-password'
    APP_ENV = 'testing'
  }

  stages {

    stage("setup") {
      steps {
        sh 'cp .env.example .env'
        sh 'docker compose up -d mysql'
        sh 'docker compose build --quiet app'
        sh 'docker compose run --rm app composer install --no-interaction --prefer-dist --optimize-autoloader'
        sh 'docker compose run --rm app npm install'
        sh 'docker compose run --rm app php artisan key:generate'
      }
      post {
        failure {
            echo 'El SetUp falló.'
        }
        success {
          echo 'SetUp completado de manera correcta.'
        }
      }
    }

    stage("lint") {
      steps {
        sh 'docker compose run --rm app php ./vendor/bin/pint --test'
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
        sh 'docker compose run --rm app php artisan migrate:fresh --force'
        sh 'docker compose run --rm app npm run build'
        sh 'docker compose run --rm app php ./vendor/bin/phpunit'
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
        sh 'docker compose run --rm app composer audit'
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
          echo 'Iniciando el despliegue automático...'
          sh 'docker compose up -d --build'

          sh 'docker exec library-app php artisan config:cache'
          sh 'docker exec library-app php artisan route:cache'
          sh 'docker exec library-app php artisan view:cache'
        }
      }
    }
  }

  post {
    always {
      sh 'rm -f database/database.sqlite'
    }
    success {
      echo 'La pipeline ha sido completada de manera correcta =)'
    }
  }
  
}
