# TDengine Note

TDengine 核心是一款高性能、集群开源、云原生的时序数据库（Time Series Database，TSDB），专为物联网IoT平台、工业互联网、电力、IT 运维等场景设计并优化，具有极强的弹性伸缩能力。同时它还带有内建的缓存、流式计算、数据订阅等系统功能，能大幅减少系统设计的复杂度，降低研发和运营成本，是一个高性能、分布式的物联网IoT、工业大数据平台。

产品简介：https://docs.taosdata.com/intro/
数据模型：https://docs.taosdata.com/basic/model/
产品组件：https://docs.taosdata.com/reference/components/
技术内幕：https://docs.taosdata.com/tdinternal/

kepware IoT 网关

SCADA系统，全称为监控与数据采集系统（Supervisory Control And Data Acquisition），是一种集成了软件和硬件的系统，用于实现对工业流程的远程监控、数据采集、设备控制和管理
。SCADA系统通过计算机网络技术将现场的各种设备连接起来，形成一个统一的监控平台，使得操作人员可以实时掌握工业流程的运行状态，并进行远程控制和管理

MQTT broker  EMQX 基于 Erlang/OTP 开发，支持 MQTT 5.0、MQTT-SN 和 MQTT over QUIC 等协议和其他先进功能。采用无主集群架构，实现了高可用性和水平扩展性。

问题：

刘涛

1. 多列模式，单列模式：最大4096列，超过后 需要分表
[TDengine 数据模型 | TDengine 文档 | 涛思数据](https://docs.taosdata.com/basic/model/)

超级表 普通表

[超级表 | TDengine 文档 | 涛思数据](https://docs.taosdata.com/reference/taos-sql/stable/)

数据不能修改，只能追加，通过compact 整理数据

LEFT ASOF JOIN是一种特殊的连接查询，用于处理时间序列数据。它允许基于最接近的主键时间戳进行近似匹配，而不是要求精确匹配。

## 运维

### 部署服务器容量规划

[容量规划 | TDengine 文档 | 涛思数据](https://docs.taosdata.com/operation/planning/)

写入相关条件：

表数量
字段数量
写入频率

查询条件

### 部署

[集群部署 | TDengine 文档 | 涛思数据](https://docs.taosdata.com/operation/deployment/#kubernetes-%E9%83%A8%E7%BD%B2)
