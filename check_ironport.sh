#!/bin/bash
# Parametros de entrada
HOSTNAME=$1
USER=$2
PASSWORD=$3
ARGS=$4
#PAR_WARN=$5
#PAR_CRIT=$6

#echo $HOSTNAME >> /tmp/log_ironport
#echo $USER >> /tmp/log_ironport
#echo $PASSWORD >> /tmp/log_ironport
#echo $ARGS >> /tmp/log_ironport
#echo $PAR_WARN >> /tmp/log_ironport
#echo $PAR_CRIT >> /tmp/log_ironport



STATUSFILE=/tmp/status.`echo $RANDOM$RANDOM|cut -c1-4`

# Nagios return codes
#STATE_OK=0
#STATE_WARNING=1
#STATE_CRITICAL=2
#STATE_UNKNOWN=3
#STATE_DEPENDENT=4

PROGNAME=`basename $0`

print_usage() {
   echo ""
        echo "Usage: $PROGNAME <hostname> <user> <password> <parameter> <warning_nro> <critical_nro>"
        echo ""
        echo "Notes:"
        echo " hostname  - Can be a hostname or IP address"
   echo " parameter - Can be cpu, ram, msgxhour, conn_in, queue or workqueue"
        echo ""
}

# Check arguments for validity
if [ -z ${HOSTNAME} ]; then
        echo "Debe especificar un hostname!"
        print_usage
        #exitstatus=$STATE_UNKNOWN
        #exit $exitstatus
fi

wget --http-user=$USER --http-password=$PASSWORD --no-check-certificate --secure-protocol=TLSv1 --no-proxy https://$HOSTNAME/xml/status --output-document=$STATUSFILE  >> /dev/null 2>&1

if [ $? -ne 0 ]; then
   exitstatus=${STATE_UNKNOWN}
   echo ""
   echo "Error en solicitud de datos a appliance Ironport. Verifique hostname, usuario y password!"
   rm -rf $STATUSFILE
   #exit $exitstatus
   #exitstatus=${STATE_OK}
fi

case "$ARGS" in
   cpu)
                IPORTPAR=`grep total_utilization $STATUSFILE | cut -d\" -f 4`
                echo "$IPORTPAR"
                ;;
   ram)
    IPORTPAR=`grep ram_utilization $STATUSFILE | cut -d\" -f 4`
                        echo "$IPORTPAR"
                ;;
   msgxhour)
    IPORTPAR=`grep -A 3 "rate name=\"inj_msgs" $STATUSFILE | grep last_15_min | cut -d\" -f 2  `
                        echo "$IPORTPAR"
                ;;
        conn_in)
                IPORTPAR=`grep conn_in  $STATUSFILE | cut -d\" -f 4`
                        echo "$IPORTPAR"
                ;;
   queue)
    IPORTPAR1=`grep \"attempted_recips $STATUSFILE | cut -d\" -f 4`
    IPORTPAR2=`grep unattempted_recips $STATUSFILE | cut -d\" -f 4`
    IPORTPAR=`expr $IPORTPAR1 + $IPORTPAR2`
                        echo "$IPORTPAR"
                ;;
   workqueue)
    IPORTPAR=`grep msgs_in_work_queue $STATUSFILE | cut -d\" -f 4`
                        echo "$IPORTPAR"
                ;;
   *)
    print_help
esac

rm -rf $STATUSFILE

#exit $exitstatus

