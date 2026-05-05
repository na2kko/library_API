pipeline {
  
  agent any

  environment {
    DB_CONNECTION = 'sqlite'
    DB_DATABASE = 'database/database.sqlite'
    APP_ENV = 'testing'
  }

  stages {

    stage("checkout") {
      steps {
        checkout scm
      }
    }

    stage("setup") {
      steps {
        sh 'cp .env.example .env'
        sh 'composer install --no-interaction --prefer-dist --optimize-autoloader'
        sh 'npm install'
        sh 'php artisan key:generate'
      }
      post {
        success {
          echo 'SetUp completado de manera correcta.'
        }
      }
    }

    stage("lint") {
      steps {
        sh './vendor/bin/pint --test'
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
        sh 'mkdir -p database'
        sh 'touch database/database.sqlite'
        sh 'php artisan migrate --force'
        sh 'npm run build'
        sh 'php artisan test'
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
        sh 'composer audit'
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
