export HADOOP_PREFIX=/usr/lib/hadoop
export HADOOP_LIBEXEC_DIR=/usr/lib/hadoop/libexec
export PATH=$HADOOP_PREFIX/bin:/usr/local/bin:/usr/lib/zookeeper:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
#export HADOOP_NAMENODE_OPTS=-Xms100 -Xmx1024 -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:+CMSParallelRemarkEnabled -XX:+PrintTenuringDistribution -XX:OnOutOfMemoryError={{AGENT_COMMON_DIR}}/killparent.sh
