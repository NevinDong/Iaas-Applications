#! /bin/bash
export ZOOKEEPERADDRESS=`awk '/hbase.zookeeper.quorum/{getline; print}' /etc/hbase/*/0/hbase-site.xml | grep -oP '<value>\K.*(?=</value>)'`
export KYLINPROPERTIESFILE=`ls /usr/local/kap/kap-*-GA-hbase1.x/conf/kylin.properties`

# Setting kylin.server.mode=query
sed -i 's/kylin.server.mode=.*/kylin.server.mode=query/' $KYLINPROPERTIESFILE
# Setting kylin.enable.scheduler=1
sed -i 's/kylin.enable.scheduler=.*/kylin.enable.scheduler=1/' $KYLINPROPERTIESFILE
# Setting kap.job.helix.zookeeper-address
sed -i "s/kap.job.helix.zookeeper-address=.*/kap.job.helix.zookeeper-address=$ZOOKEEPERADDRESS/" $KYLINPROPERTIESFILE
