#! /bin/sh

QPKG_NAME=QSickRage
QPKG_DIR=$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)
PID_FILE="$QPKG_DIR/config/sickrage.pid"

DAEMON_OPTS="SickBeard.py --datadir $QPKG_DIR/config --daemon --pidfile $PID_FILE --port 7073"

# Determine Arch
ver="none"
arch="$(/bin/uname -m)"
if echo $arch | grep "armv5tejl"; then
    ver="arm";
elif echo $arch | grep "armv5tel"; then
    ver="arm";
elif echo $arch | grep "i686"; then
    ver="x86";
elif echo $arch | grep "x86_64"; then
    ver="x86";
elif echo $arch | grep "armv7l"; then
    ver="x31";
else
    err_log "Could not determine architecture from $arch";
fi

export PATH=${QPKG_DIR}/${ver}/bin-utils:/Apps/bin:/usr/local/bin:$PATH

CheckQpkgEnabled() { # Is the QPKG enabled? if not exit the script
  if [ $($CMD_GETCFG ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf) = UNKNOWN ]; then
      $CMD_SETCFG ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
  elif [ $($CMD_GETCFG ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf) != TRUE ]; then
      /bin/echo "${QPKG_NAME} is disabled."
      exit 1
  fi
}

ConfigPython(){ # checks if the daemon exists and will link /usr/bin/python to it
  # python dependency checking
    VER=0
    DAEMON="None"
    for DAEMON2 in /usr/bin/python2.7 /usr/local/bin/python2.7 /opt/bin/python2.7 /Apps/opt/bin/python2.7 /opt/QPython2/bin/python2.7; do
        echo "Looking for $DAEMON2"
        [ ! -x $DAEMON2 ] && continue
        VER2=$(expr substr "$(${DAEMON2} -V 2>&1)" 8 8)
        if [ $VER2 > $VER ]; then
            DAEMON=$DAEMON2
            VER=$VER2
        fi
    done
    if [ ! -x $DAEMON ]; then
        log_error "Failed to start $QPKG_NAME, Python was not found. Please re-install the Python qpkg." 1
        exit 1
    else
        log "Found Python Version ${VER} at ${DAEMON}"
    fi
}

CheckQpkgRunning() { # Is the QPKG already running? if so, exit the script
  if [ -f $PID_FILE ]; then
    # grab pid from pid file
    Pid=$(/bin/cat $PID_FILE)
    if [ -d /proc/$Pid ]; then
      log "$QPKG_NAME is already running"
      exit 1
    fi
  fi
  # ok, we survived so the QPKG should not be running
}

StartQpkg(){
    log "Starting $QPKG_NAME"
    cd $QPKG_DIR/$QPKG_NAME
    PATH=${PATH} ${DAEMON} ${DAEMON_OPTS}
}

ShutdownQPKG() { # kills a proces based on a PID in a given PID file
    log "Shutting down ${QPKG_NAME}... "
    if [ -f $PID_FILE ]; then
        # grab pid from pid file
        Pid=$($CMD_CAT $PID_FILE)
        i=0
        /bin/kill $Pid
        log " Waiting for ${QPKG_NAME} to shut down: "
        while [ -d /proc/$Pid ]; do
            sleep 1
            let i+=1
            /bin/echo -n "$i, "
            if [ $i = 45 ]; then
                log " Tired of waiting, killing ${QPKG_NAME} now"
                /bin/kill -9 $Pid
                /bin/rm -f $PID_FILE
                exit 1
            fi
        done
        $CMD_RM -f $PID_FILE
        log "Done"
    else
        log "${QPKG_NAME} is not running?"
    fi
}

case "$1" in
    start)
        CheckQpkgEnabled # Check if the QPKG is enabled, else exit
        CheckQpkgRunning # Check if the QPKG is not running, else exit
        ConfigPython   # Check for Python, exit if not found
        StartQpkg    # Finally Start the qpkg
        ;;
  stop)
        ShutdownQPKG
        ;;
  restart)
        echo "Restarting $QPKG_NAME"
        $0 stop
        $0 start
        ;;
  *)
        N=/etc/init.d/$QPKG_NAME.sh
        $CMD_ECHO "Usage: $N {start|stop|restart}" >&2
        exit 1
        ;;
esac
