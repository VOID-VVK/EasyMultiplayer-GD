# EasyMultiplayer-GD

Godot 4.x GDScript 局域网多人游戏插件。提供房间管理、UDP 广播发现、ENet 传输、断线重连、心跳检测、优雅退出等开箱即用的功能。

## 功能

- **房间管理** — Host 创建房间并广播，Client 自动发现并加入
- **UDP 广播发现** — 局域网内自动发现房间，无需手动输入 IP
- **ENet 传输层** — 基于 Godot 内置 ENet，可靠/不可靠消息均支持
- **心跳检测** — 定期 Ping/Pong，自动检测对端存活状态
- **断线重连** — 网络抖动时自动重连，Host 端保留重连窗口
- **优雅退出** — 主动退出前发送通知，对端可区分主动退出与意外断线
- **版本校验** — 连接时自动交换版本号，版本不匹配自动踢出
- **消息通道** — 逻辑通道隔离，支持发送速率限制

## 要求

- Godot 4.x（GDScript）

## 安装

1. 将 `addons/easy_multiplayer_gd/` 目录复制到你的项目 `addons/` 下
2. 在 Godot 编辑器中启用插件：**项目 → 项目设置 → 插件 → EasyMultiplayer-GD → 启用**
3. 插件会自动注册 `Net` 单例（Autoload）

## 快速开始

```gdscript
# 获取单例
var net = Net
net.game_version = "1.0.0"

# 监听信号
net.connection_succeeded.connect(func(): print("连接成功"))
net.peer_joined.connect(func(id): print("玩家加入: ", id))
net.peer_left.connect(func(id): print("玩家离开: ", id))

# 创建房间（Host）
net.create_room("我的房间", "MyGame")

# 发现并加入房间（Client）
net.discovery.room_found.connect(func(room):
    print("发现房间: ", room.info.host_name, " @ ", room.host_ip, ":", room.info.port)
    net.join_room(room.host_ip, room.info.port)
)
net.room_client.start_searching()

# 发送消息
net.send_message(peer_id, "chat", "Hello!")
net.broadcast_message("game_state", data)

# 优雅退出
net.graceful_disconnect("quit")
```

## API 概要

### EasyMultiplayer（主入口）

| 方法/属性 | 说明 |
|---|---|
| `host(port?, max_clients?)` | 作为主机开始监听 |
| `join(address, port?)` | 作为客户端连接主机 |
| `disconnect_all()` | 断开连接 |
| `graceful_disconnect(reason?)` | 优雅退出（先通知再断开） |
| `create_room(name, game_type, port?)` | 创建房间 |
| `join_room(host_ip, port?)` | 加入房间 |
| `send_message(peer_id, channel, data)` | 发送可靠消息 |
| `broadcast_message(channel, data, reliable?)` | 广播消息 |
| `state` | 当前连接状态（ConnectionState 枚举） |
| `is_server` | 是否为服务端 |
| `game_version` | 游戏版本号（连接时自动校验） |

### 信号

| 信号 | 说明 |
|---|---|
| `state_changed(old_state, new_state)` | 连接状态变化 |
| `peer_joined(peer_id)` | 对端连接 |
| `peer_left(peer_id)` | 对端断开 |
| `connection_succeeded()` | 客户端连接成功 |
| `connection_failed()` | 客户端连接失败 |
| `version_verified(remote_version)` | 版本校验通过 |
| `version_mismatch(local, remote)` | 版本不匹配 |
| `peer_graceful_quit(peer_id, reason)` | 对端主动退出 |
| `full_sync_requested(peer_id)` | 重连后需要全量同步 |

### EasyMultiplayerConfig（可配置参数）

| 参数 | 默认值 | 说明 |
|---|---|---|
| `port` | 27015 | ENet 端口 |
| `max_clients` | 1 | 最大客户端数 |
| `heartbeat_interval` | 3.0s | 心跳间隔 |
| `disconnect_timeout` | 10.0s | 断线超时 |
| `reconnect_timeout` | 30.0s | Host 重连等待上限 |
| `max_reconnect_attempts` | 20 | Client 最大重连次数 |
| `reconnect_retry_interval` | 3.0s | 重连重试间隔 |
| `broadcast_port` | 27016 | UDP 广播端口 |
| `broadcast_interval` | 1.0s | 广播发送间隔 |
| `rpc_min_interval_ms` | 100ms | 消息最小发送间隔 |

## 目录结构

```
addons/easy_multiplayer_gd/
├── core/
│   ├── easy_multiplayer.gd          # 主入口单例
│   ├── easy_multiplayer_config.gd   # 配置资源
│   ├── connection_state.gd          # 连接状态枚举
│   └── message_channel.gd           # 消息通道
├── discovery/
│   ├── discovery_base.gd            # 发现层抽象基类
│   ├── room_info.gd                 # 房间信息数据类
│   └── udp_broadcast_discovery.gd   # UDP 广播实现
├── heartbeat/
│   └── heartbeat_manager.gd         # 心跳管理器
├── room/
│   ├── room_state.gd                # 房间状态枚举
│   ├── room_host.gd                 # 房间主机
│   └── room_client.gd               # 房间客户端
├── transport/
│   ├── transport_base.gd            # 传输层抽象基类
│   └── enet_transport.gd            # ENet 传输实现
├── plugin.gd                        # 编辑器插件入口
└── plugin.cfg                       # 插件配置

## License

MIT License. See [LICENSE](LICENSE).
