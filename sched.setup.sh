
export PATH=${JRUBYBIN:-/hcro/opt/jruby/bin}:$PATH
JRUBYDIR=$(dirname $(which jruby))/..
JAR=$(find "$JRUBYDIR" -name 'mysql-connector-java*.jar')
export CLASSPATH="$JAR:$CLASSPATH"

