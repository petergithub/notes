# Spark Notes

`docker attach spark`  

## Shell
open Spark shell: `$SPARK_HOME/sbin/spark-shell`  

[Submitting Applications](https://spark.apache.org/docs/latest/submitting-applications.html)
To launch a Spark application in cluster mode:  
`./bin/spark-submit --class path.to.your.Class --master yarn --deploy-mode cluster [options] <app jar> [app options]`

```
example:  
./bin/run-example SparkPi 10

./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory 4g \
    --executor-memory 2g \
    --executor-cores 1 \
    --queue default \
    examples/jars/spark-examples_2.11-2.1.0.jar \
    10

adding other jars:  
$ ./bin/spark-submit --class my.main.Class \
    --master yarn \
    --deploy-mode cluster \
    --jars my-other-jar.jar,my-other-other-jar.jar \
    my-main-jar.jar \
    app_arg1 app_arg2

```

To launch a Spark application in client mode:  
`./bin/spark-shell --master yarn --deploy-mode client`

## Spark Programming Guide
[Link](https://spark.apache.org/docs/latest/rdd-programming-guide.html#printing-elements-of-an-rdd)
### Quick Start
In the RDD API, there are two types of operations: transformations, which define a new dataset based on previous ones, and actions, which kick off a job to execute on a cluster.   
After Spark 2.0, RDDs are replaced by Dataset, which is strongly-typed like an RDD, but with richer optimizations under the hood.
Spark supports two types of shared variables: `broadcast` variables, which can be used to cache a value in memory on all nodes, and `accumulators`, which are variables that are only “added” to, such as counters and sums.

### Resilient Distributed Datasets (RDDs)
#### Parallelized Collections
One important parameter for parallel collections is the number of partitions to cut the dataset into. Spark will run one task for each partition of the cluster. Typically you want 2-4 partitions for each CPU in your cluster.

#### Understanding closures
In general, closures - constructs like loops or locally defined methods, should not be used to mutate some global state. Spark does not define or guarantee the behavior of mutations to objects referenced from outside of closures.

#### Printing elements of an RDD
To print all elements on the driver, one can use the `collect()` method to first bring the RDD to the driver node thus: `rdd.collect().foreach(println)`. This can cause the driver to run out of memory, though, because `collect()` fetches the entire RDD to a single machine; if you only need to print a few elements of the RDD, a safer approach is to use the `take()`: `rdd.take(100).foreach(println)`.  
`rdd.sortByKey().take(100).foreach(println)`  

#### RDD Persistence
[Which Storage Level to Choose?](https://spark.apache.org/docs/latest/rdd-programming-guide.html#which-storage-level-to-choose)

### Shared Variables
#### Broadcast Variables
After the broadcast variable is created, it should be used instead of the value v in any functions run on the cluster so that v is not shipped to the nodes more than once.   
`val broadcastVar = sc.broadcast(Array(1, 2, 3))`  
`broadcastVar.value`  
#### Accumulators
Accumulators are variables that are only “added” to through an associative and commutative operation and can therefore be efficiently supported in parallel.  
A numeric accumulator can be created by calling `SparkContext.longAccumulator()` or `SparkContext.doubleAccumulator()` to accumulate values of type Long or Double, respectively.
