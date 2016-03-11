#Location of JAVA_HOME (bin files)
export JAVA_HOME=/usr/java/latest
 
#Add Java binary files to PATH
export PATH=$JAVA_HOME/bin:$PATH
 
#CATALINA_HOME is the location of the bin files of Tomcat  
export CATALINA_HOME=/Application/tomcat  
 
#CATALINA_BASE is the location of the configuration files of this instance of Tomcat
export CATALINA_BASE=/Application/tomcat-node-1
 
#TOMCAT_USER is the default user of tomcat
export TOMCAT_USER=tomcat
 
#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {start|stop|kill|status|restart}"
 
#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=10
 
tomcat_pid() {
        echo `ps -fe | grep $CATALINA_BASE | grep -v grep | tr -s " "|cut -d" " -f2`
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
                echo -e "Tomcat user $TOMCAT_USER does not exists. Starting with $(id)"
                sh $CATALINA_HOME/bin/startup.sh
        fi
        status
  fi
  return 0
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
	echo -e "Terminating Tomcat"
	kill -9 $(tomcat_pid)
}

stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "Stoping Tomcat"
    #/bin/su -p -s /bin/sh $TOMCAT_USER
        sh $CATALINA_HOME/bin/shutdown.sh
 
    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\nwaiting for processes to exit";
      sleep 1
      let count=$count+1;
    done
 
    if [ $count -gt $kwait ]; then
      echo -n -e "\nkilling processes didn't stop after $SHUTDOWN_WAIT seconds"
      terminate
    fi
  else
    echo -e "Tomcat is not running"
  fi
 
  return 0
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
