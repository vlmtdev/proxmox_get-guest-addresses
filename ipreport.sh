#!/bin/bash

# ===========VM PART===========
VMINFO=$(qm list 2>/dev/null | awk 'NR>1' )
VMCOUNT=$(echo "$VMINFO" | awk 'END {print NR}')
touch addrtable.temp
>addrtable.temp

#echo "Found $VMCOUNT VMs"

CURRENTVM=0
while [ $CURRENTVM -lt $VMCOUNT ]
do
  CURRENTLINE=$(($CURRENTVM+1))
  CURRENTVMID=$(echo "$VMINFO" | awk "NR == $CURRENTLINE" | awk '{print $1}')
  CURRENTVMNAME=$(echo "$VMINFO" | awk "NR == $CURRENTLINE" | awk '{print $2}')
#  CURRENTVMRESULTRAW=$(echo "$(qm guest exec $CURRENTVMID -- 'hostname' '-I' 2>&1)")
  CURRENTVMRESULTRAW=$(echo "$(qm guest cmd $CURRENTVMID network-get-interfaces 2>&1)")
  if echo "$CURRENTVMRESULTRAW" | grep hardware-address > /dev/null 2>&1;
  then
    CURRENTINTERFACE=0
    CURRENTVMRESULTPARSED=""
    ADDRCOUNT=$(echo "$CURRENTVMRESULTRAW" | grep "hardware-address" | awk 'END {print NR}')
    while [ $CURRENTINTERFACE -lt $ADDRCOUNT ]
    do
      CURRENTADDR=$(echo "$CURRENTVMRESULTRAW" | jq --arg CURRENTINTERFACE $CURRENTINTERFACE '.[$CURRENTINTERFACE|tonumber]."ip-addresses"[0]."ip-address"')
      CURRENTVMRESULTPARSED=$(echo " $CURRENTVMRESULTPARSED $CURRENTADDR")
    (( CURRENTINTERFACE++ ))
    done
    CURRENTVMRESULTPARSED=$(echo "$CURRENTVMRESULTPARSED" | tr -d \" | tr -d '\\n')
  elif echo "$CURRENTVMRESULTRAW" | grep "No QEMU guest agent configured" > /dev/null 2>&1;
  then
    CURRENTVMRESULTPARSED="agentnotfound"
  elif echo "$CURRENTVMRESULTRAW" | grep "is not running" > /dev/null 2>&1;
  then
    CURRENTVMRESULTPARSED="notrunning"
  else
    CURRENTVMRESULTPARSED="noguestpermission"
  fi
  
  echo "vm $CURRENTVMID $CURRENTVMNAME $CURRENTVMRESULTPARSED" >> addrtable.temp
  (( CURRENTVM++ ))
done

# =============LXC PART=============
LXCINFO=$(pct list 2>/dev/null | awk 'NR>1' )
LXCCOUNT=$(echo "$LXCINFO" | awk 'END {print NR}')

#echo "Found $LXCCOUNT LXC containers"

CURRENTLXC=0
while [ $CURRENTLXC -lt $LXCCOUNT ]
do
  CURRENTLINE=$(($CURRENTLXC+1))
  CURRENTLXCID=$(echo "$LXCINFO" | awk "NR == $CURRENTLINE" | awk '{print $1}')
  CURRENTLXCNAME=$(echo "$LXCINFO" | awk "NR == $CURRENTLINE" | awk '{print $NF}')
  CURRENTLXCRESULT=$(echo "$(pct exec $CURRENTLXCID -- hostname -I 2>&1)")
  echo "lxc $CURRENTLXCID $CURRENTLXCNAME $CURRENTLXCRESULT" >> addrtable.temp
  (( CURRENTLXC++ ))
done

cat addrtable.temp
rm addrtable.temp