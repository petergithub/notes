# StarRocks

[Deploy StarRocks with Docker | StarRocks](https://docs.starrocks.io/docs/3.5/quick_start/shared-nothing/)
[hub.docker.com](https://hub.docker.com/r/starrocks/allin1-ubuntu)

```sh
docker pull starrocks/artifacts-ubuntu:3.5.10
docker pull starrocks/allin1-ubuntu:3.5.10

docker run -p 9030:9030 -p 8030:8030 -p 8040:8040 -itd \
--name quickstart starrocks/allin1-ubuntu:3.5.10

docker exec -it quickstart \
mysql -P 9030 -h 127.0.0.1 -u root --prompt="StarRocks > "
```
