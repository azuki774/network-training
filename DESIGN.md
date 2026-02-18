# Demo - ネットワーク構成図

## トポロジー

```mermaid
graph LR
    srvA1["srvA1<br/>192.168.1.10/24<br/>gw: 192.168.1.1"]
    rtA["rtA<br/>FRRouting<br/>eth2: 192.168.1.1/24<br/>eth1: 10.0.0.1/30"]
    rtB["rtB<br/>FRRouting<br/>eth1: 10.0.0.2/30<br/>eth2: 192.168.2.1/24"]
    srvB1["srvB1<br/>192.168.2.10/24<br/>gw: 192.168.2.1"]

    srvA1 -- "Network A<br/>192.168.1.0/24" --- rtA
    rtA -- "Internal Network<br/>10.0.0.0/30" --- rtB
    rtB -- "Network B<br/>192.168.2.0/24" --- srvB1
```

## ネットワーク一覧

| ネットワーク | アドレス | 用途 |
|---|---|---|
| Network A | 192.168.1.0/24 | srvA1 と rtA を接続 |
| Internal Network | 10.0.0.0/30 | rtA と rtB を接続 (ルータ間リンク) |
| Network B | 192.168.2.0/24 | rtB と srvB1 を接続 |

## ノード一覧

| ノード | イメージ | インターフェース | IPアドレス |
|---|---|---|---|
| rtA | frrouting/frr | eth1 | 10.0.0.1/30 |
|     |               | eth2 | 192.168.1.1/24 |
| rtB | frrouting/frr | eth1 | 10.0.0.2/30 |
|     |               | eth2 | 192.168.2.1/24 |
| srvA1 | alpine | eth1 | 192.168.1.10/24 |
| srvB1 | alpine | eth1 | 192.168.2.10/24 |
