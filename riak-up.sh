#!/bin/bash

set -ex

PRESTART=$(find /etc/riak/prestart.d -name '*.sh' -print | sort)
POSTSTART=$(find /etc/riak/poststart.d -name '*.sh' -print | sort)
PRESTOP=$(find /etc/riak/prestop.d -name '*.sh' -print | sort)

for s in $PRESTART; do
  . $s
done

cat /etc/riak/riak.conf

if [ -r "/etc/riak/advanced.config" ]
then
  cat /etc/riak/advanced.config
fi

riak chkconfig

riak start

riak-admin wait-for-service riak_kv

riak ping

riak-admin test

for s in $POSTSTART; do
  . $s
done

tail -n 1024 -f /var/log/riak/console.log &
TAIL_PID=$!

function graceful_death {
  for s in $PRESTOP; do
    . $s
  done

  kill $TAIL_PID
}

trap graceful_death SIGTERM SIGINT

wait $TAIL_PID
