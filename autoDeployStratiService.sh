#!/bin/bash

#CATALINA_HOME is the location of the bin files of Tomcat  
export CATALINA_HOME=/Applications/serverdozer165

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {start | stop | kill | status | restart}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=10

#TOMCAT_USER is the default user of tomcat
export TOMCAT_USER=tomcat

#source war file to copy from
export SOURCE_WAR=/strati-service/strati-service-registry/target/strati-service-registry-1.0.0-SNAPSHOT.war

tomcat_pid() {
        echo `ps -ef | grep $TOMCAT_USER | grep -v grep | tr -s " "|cut -d " " -f2`
}

start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "Tomcat is already running (pid: $pid)"
  else
    # Start tomcat
    echo -e "Starting tomcat"
    #ulimit -n 100000
    #umask 007
    #/bin/su -p -s /bin/sh $TOMCAT_USER
        if [ `user_exists $TOMCAT_USER` = "1" ]
        then
                /bin/su $TOMCAT_USER -c $CATALINA_HOME/bin/startup.sh
        else
                echo -e "\e[00;31mTomcat user $TOMCAT_USER does not exists. Starting with $(id)\e[00m"
                sh $CATALINA_HOME/bin/startup.sh
        fi
        status
  fi
  return 0
}

stop() {
  pid=$(tomcat_pid)
  echo -e "Tomcat is running (pid: $pid)"
  if [ -n "$pid" ]
  then
    echo -e "Stoping Tomcat"
    #/bin/su -p -s /bin/sh $TOMCAT_USER
    	sh $CATALINA_HOME/bin/shutdown.sh
 
    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\nwaiting for processes to exit\n";
      sleep 1
      let count=$count+1;
    done
 
    if [ $count -gt $kwait ]; then
      echo -n -e "killing processes didn't stop after $SHUTDOWN_WAIT seconds"
      terminate
    fi
  else
    echo -e "Tomcat is not running"
  fi
 
  return 0
}

clean(){
	echo -e "cleaning up log files and webapps"
	rm -rf $CATALINA_HOME/logs/*
	rm -rf $CATALINA_HOME/webapps/strati-service-registry-1.0.0-SNAPSHOT*
}

copy(){
	cp ~/Documents/workspace_mars/$SOURCE_WAR $CATALINA_HOME/webapps/
	echo -e "War file was copied to webapps"
}

status(){
          pid=$(tomcat_pid)
          if [ -n "$pid" ]
            then echo -e "Tomcat is running with pid: $pid"
          else
            echo -e "Tomcat is not running"
            return 3
          fi
}

terminate() {
	echo -e "Terminating Tomcat $(tomcat_pid)"
	kill -9 $(tomcat_pid)
}

user_exists(){
        if id -u $1 >/dev/null 2>&1; then
        echo "1"
        else
                echo "0"
        fi
}

case $1 in
	start)
	  start
	;;
	stop)  
	  stop
	;;
	restart)
	  stop
	  start
	;;
	redeploy)
	  # stop tomcat(AS@P)
  	  stop
	  # remove servie application in webapps and log files
	  clean
	  # cp service application war to webapps
	  copy
	  # start tomcat
	  start
	;;	
	status)
		status
		exit $?  
	;;
	kill)
		terminate
	;;		
	*)
		echo -e $TOMCAT_USAGE
	;;
esac    
exit 0