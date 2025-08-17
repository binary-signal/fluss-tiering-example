# How to run

```shell
git clone https://github.com/binary-signal/fluss-tiering-example.git fluss-tiering-example
```

```shell
cd fluss-tiering-paimon 
```

```
make some-magic-happen
```

The first setup will take a few minutes. It involves downloading the required JAR files, and binary distribution for
Fluss and Flink, applying configurations, placing downloaded jars in the correct locations, starting MinIO, and finally
submitting the tiering job. Once everything is running, all services will be up and ready.

Then, start the Flink SQL client and run the SQL snippets from the blog post: Hands-on Fluss
Lakehouse. https://fluss.apache.org/blog/hands-on-fluss-lakehouse/

```shell
make sql-client
```

**Makefile Commands**

```shell
make help
```

```text
Available targets:
  setup               - Download and install Flink and Fluss with custom configuration
  clean-setup         - Remove installed Flink and Fluss directories
  clean-logs          - Clean log files from Flink and Fluss
  clean-bin-dist      - Remove binary distributions
  clean-jars          - Remove all JAR files from jar/ directories
  clean-all           - Remove everything (installations, logs, and JARs)
  start-all           - Setup (if needed), start MinIO, Fluss, and Flink clusters
  stop-all            - Stop all clusters and MinIO
  start-fluss         - Start Fluss local cluster
  stop-fluss          - Stop Fluss local cluster
  start-flink         - Start Flink local cluster
  stop-flink          - Stop Flink local cluster
  start-mino          - Start MinIO (Docker)
  stop-mino           - Stop MinIO (Docker)
  some-magic-happen   - Setup, start MinIO, Fluss, and Flink in sequence
  show-jars           - Show JAR files that will be copied during setup
  show-setup          - Show Flink lib and Fluss lib and plugins directories
  download-jars       - Download JAR files from Maven repositories
  submit-tiering-job  - Submit tiering job to local flink cluster
```
