#!/bin/bash

COMMAND=$1
shift 1

function get_tables()
{
    local dbname="$1"
    local dbuser="$2"
    local dbpass="$3"
    
    coproc stdbuf -oL -i0 mysql --compress --user=$dbuser --password=$dbpass

    printf '%s;\n' "use $dbname; show tables" >&${COPROC[1]}
    
    local tables=()
    
    while read -t3 -u${COPROC[0]}; do
      # printf '%s\n' "$REPLY"
      tables+="$REPLY "
    done
    
    # I get an error for bot, quit & exit
    #  1064 (42000) at line 2: You have an error in your SQL syntax
    #printf '%s;\n' "quit" >&${COPROC[1]}

    # $tables is a string, make an array out of it again    
    local SAVE_IFS=$IFS
    IFS=" "
    tables=($tables)
    IFS=$SAVE_IFS
    
    # print the sliced array
    echo ${tables[@]:1}
}


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

    list-tables)
    
        EXPECTED_ARGS=3
    
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 list-tables dbname dbuser dbpass"
          exit $E_BADARGS
        fi
        
        dbname="$1"
        dbuser="$2"
        dbpass="$3"
        
        tables=$(get_tables "$dbname" "$dbuser" "$dbpass")
    
        # $tables is a string, make an array out of it again    
        SAVE_IFS=$IFS
        IFS=" "
        tables=($tables)
        IFS=$SAVE_IFS
        
        echo "Tables in $dbname"
        echo "-----------------------------"
        for ((i=1; i < ${#tables[@]}; i++))
        do
          echo -e "$i: ${tables[$i]}"
        done
        ;;

    dump-table-structure)
    
        EXPECTED_ARGS=3
    
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 list-tables dbname dbuser dbpass"
          exit $E_BADARGS
        fi
        
        dbname="$1"
        dbuser="$2"
        dbpass="$3"
        dbtable=bild

        tablesjoin=$(get_tables "$dbname" "$dbuser" "$dbpass")
        
        # $tables is a string, make an array out of it again    
        SAVE_IFS=$IFS
        IFS=" "
        tables=($tablesjoin)
        IFS=$SAVE_IFS

        mysqldump --compress --password=$dbpass --user=$dbuser $dbname --no-data > ${dbname}_structure.sql
        ;;
        
    dump-table-data-full)
    
        EXPECTED_ARGS=3
    
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 list-tables dbname dbuser dbpass"
          exit $E_BADARGS
        fi
        
        dbname="$1"
        dbuser="$2"
        dbpass="$3"
        dbtable=bild

        tablesjoin=$(get_tables "$dbname" "$dbuser" "$dbpass")
        
        # $tables is a string, make an array out of it again    
        SAVE_IFS=$IFS
        IFS=" "
        tables=($tablesjoin)
        IFS=$SAVE_IFS
        
        mysqldump --compress --skip-triggers --compact --no-create-info --password=$dbpass --user=$dbuser $dbname > ${dbname}_data_full.sql
        ;;

    dump-table-data-single)
    
        EXPECTED_ARGS=3
    
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 list-tables dbname dbuser dbpass"
          exit $E_BADARGS
        fi
        
        dbname="$1"
        dbuser="$2"
        dbpass="$3"
        dbtable=bild

        tablesjoin=$(get_tables "$dbname" "$dbuser" "$dbpass")
        
        # $tables is a string, make an array out of it again    
        SAVE_IFS=$IFS
        IFS=" "
        tables=($tablesjoin)
        IFS=$SAVE_IFS
        
        for ((i=0; i < ${#tables[@]}; i++))
        do
            table=${tables[$i]}
            mysqldump --compress --skip-triggers --compact --no-create-info --password=$dbpass --user=$dbuser $dbname $table > ${dbname}_${table}.sql
        done
        
        ;;
        
    dump-table-data-single-compressed)
    
        EXPECTED_ARGS=3
    
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 list-tables dbname dbuser dbpass"
          exit $E_BADARGS
        fi
        
        dbname="$1"
        dbuser="$2"
        dbpass="$3"

        tablesjoin=$(get_tables "$dbname" "$dbuser" "$dbpass")
        
        # $tables is a string, make an array out of it again    
        SAVE_IFS=$IFS
        IFS=" "
        tables=($tablesjoin)
        IFS=$SAVE_IFS
        
        for ((i=0; i < ${#tables[@]}; i++))
        do
            table=${tables[$i]}
            mysqldump --compress --skip-triggers --compact --no-create-info --password=$dbpass --user=$dbuser $dbname $table | gzip -9 > ${dbname}_${table}.sql.gz
        done
        
        ;;
        
    import)

        EXPECTED_ARGS=4
        
        if [ $# -ne $EXPECTED_ARGS ]
        then
          echo "Usage: $0 import dbname dbuser dbpass statements.sql"
          exit $E_BADARGS
        fi
        
	dbname="$1"
        dbuser="$2"
        dbpass="$3"
	dbdump="$4"
	
        $MYSQL --user=$dbuser --password=$dbpass -h localhost "$dbname" < "$dbdump"
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

# http://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals
# http://www.fachinformatiker.de/linux-unix/102871-bash-script-split-string-array-seperator.html
# http://chriswa.wordpress.com/2008/02/20/mysqldump-data-only/