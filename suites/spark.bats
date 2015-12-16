@test "spark standalone with client model" {
  run /root/spark-1.5.2-bin-hadoop2.6/bin/spark-submit --master spark://xp-docker1.eng.platformlab.ibm.com:7077 --deploy-mode client --class org.apache.spark.examples.SparkPi /root/spark-1.5.2-bin-hadoop2.6/lib/spark-examples-1.5.2-hadoop2.6.0.jar
  #[[ "${lines[0]}" =~ "Pi is roughly" ]]
  run bash -c "echo $output | cut -d' ' -f1"
  [ "$output" = "Pi" ]
}