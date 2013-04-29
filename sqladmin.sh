#!/bin/bash

COMMAND=$1
shift 1

MYSQL=$(which mysql)
BTICK='`'
E_BADARGS=65

case $COMMAND in

    create-db)
    
        EXPECTED_ARGS=3
        
        Q1="CREATE DATABASE IF NOT EXISTS $1;"
        Q2="GRANT ALL ON ${BTICK}$1${BTICK}.* TO '$2'@'localhost' IDENTIFIED BY '$3';"
        Q3="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}${Q3}"
     
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 create-db dbname dbuser dbpass"
          exit $E_BADARGS
        fi
     
        $MYSQL -u root -p -e "$SQL"
        ;;
        
    import)

        EXPECTED_ARGS=2
        
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 import dbname statements.sql"
          exit $E_BADARGS
        fi
        
        $MYSQL -u root -p -h localhost "$1" < "$2"
        ;;
    
    delete-user)
    
        EXPECTED_ARGS=1
        SQL="DROP USER '$1'@'localhost';"
        
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 delete-user dbuser"
          exit $E_BADARGS
        fi
        
        $MYSQL -u root -p -e "$SQL"
        ;;
        
    *) echo "Unknown command"
    
esac