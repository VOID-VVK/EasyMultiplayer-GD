# EasyMultiplayer-GD 测试指南

## 环境准备

### 1. 在 Godot 编辑器中打开项目
```bash
cd /Users/void/Documents/EasyMultiplayer-GD
godot project.godot
```

### 2. 启用插件
1. 打开 **项目 → 项目设置 → 插件**
2. 找到 **EasyMultiplayer-GD** 插件
3. 勾选启用

### 3. 验证自动加载
1. 打开 **项目 → 项目设置 → 自动加载**
2. 确认 `EasyMultiplayer` 已注册（路径：`res://addons/easy_multiplayer_gd/easy_multiplayer.gd`）

---

## 测试场景使用

### 打开测试场景
在 Godot 编辑器中打开 `test_scene.tscn`

### 测试流程

#### 单机测试（Host + Client 同一实例）

**步骤 1：创建房间**
1. 在"房主面板"输入房间名称（可选）
2. 点击"创建房间"
3. 观察日志输出：
   - `创建房间: xxx`
   - `连接状态: 未连接 → 主机中`
   - `房间状态: Idle → Waiting`

**步骤 2：搜索房间**
1. 在"客户端面板"点击"搜索房间"
2. 等待 1-2 秒，房间列表应显示刚创建的房间
3. 观察日志：`发现房间: xxx (127.0.0.1:xxxx) [1/4]`

**步骤 3：加入房间**
1. 选择房间列表中的房间
2. 点击"加入房间"
3. 观察日志：
   - `正在加入房间: xxx`
   - `连接成功`
   - `版本校验通过: 1.0.0`
   - `成功加入房间: xxx (TestGame)`
   - `对端加入: 1`（Host 视角）
   - `客人加入: 1`（Host 视角）

**步骤 4：准备状态同步**
1. 点击"客户端面板"的"准备就绪"
2. 观察日志：
   - `客户端准备状态: true`
   - `客人 1 准备状态: true`（Host 视角）

3. 点击"房主面板"的"准备就绪"
4. 观察日志：
   - `房主准备状态: true`
   - `所有人已就绪！`
   - `房主准备状态: true`（Client 视角）

**步骤 5：离开房间**
1. 点击"客户端面板"的"离开房间"
2. 观察日志：
   - `离开房间`
   - `对端离开: 1`（Host 视角）
   - `客人离开: 1`（Host 视角）

**步骤 6：关闭房间**
1. 点击"房主面板"的"关闭房间"
2. 观察日志：
   - `关闭房间`
   - `连接状态: 主机中 → 未连接`

---

#### 多实例测试（真实局域网）

**准备工作**
1. 在 Godot 编辑器中导出项目为可执行文件
2. 或使用 Godot 的"远程调试"功能运行多个实例

**Host 实例**
1. 运行第一个实例
2. 创建房间

**Client 实例**
1. 运行第二个实例
2. 搜索房间
3. 加入房间
4. 测试准备状态同步

**测试重连功能**
1. 在 Client 实例中，模拟网络中断（关闭网络或强制退出）
2. 观察 Host 日志：
   - `对端超时: 1`
   - `等待对端重连...`
3. 恢复 Client 网络连接
4. 观察日志：
   - `对端重连成功: 1`（Host 视角）
   - `重连成功`（Client 视角）

---

## 关键测试点

### 1. 连接状态机
- [ ] Disconnected → Hosting（创建房间）
- [ ] Disconnected → Joining → Connected（加入房间）
- [ ] Connected → Reconnecting → Connected（重连）
- [ ] Connected → Disconnected（主动退出）

### 2. 房间状态机（Host）
- [ ] Idle → Waiting（创建房间）
- [ ] Waiting → Ready（有客人加入）
- [ ] Ready → Playing（所有人准备就绪）
- [ ] Playing → Closed（关闭房间）

### 3. 客户端状态机
- [ ] Idle → Searching（搜索房间）
- [ ] Searching → Joining → InRoom（加入房间）
- [ ] InRoom → GameStarting（游戏开始）
- [ ] InRoom → Idle（离开房间）

### 4. UDP 广播发现
- [ ] 房间创建后自动广播
- [ ] 客户端能搜索到房间
- [ ] 房间满员后停止广播
- [ ] 房间关闭后停止广播

### 5. 心跳检测
- [ ] RTT 计算正确（显示在状态栏）
- [ ] 网络质量分级（Good/Warning/Bad）
- [ ] 超时检测（10 秒无响应）
- [ ] 重连机制（Client 主动重连，最多 5 次）

### 6. 版本校验
- [ ] 连接时自动交换版本号
- [ ] 版本匹配时通过
- [ ] 版本不匹配时断开连接

### 7. 准备状态同步
- [ ] Host 准备状态同步到 Client
- [ ] Client 准备状态同步到 Host
- [ ] 所有人准备就绪时触发 `all_ready` 信号

### 8. 主动退出通知
- [ ] 主动离开房间时发送退出通知
- [ ] 对端能区分主动退出与意外断线

---

## 常见问题

### Q1: 搜索不到房间
**可能原因：**
- 防火墙阻止 UDP 广播（端口 47777）
- 不在同一局域网
- 房间已满员（停止广播）

**解决方法：**
- 检查防火墙设置
- 确认在同一局域网
- 检查房间最大人数配置

### Q2: 连接失败
**可能原因：**
- 防火墙阻止 TCP 连接（端口 47778）
- IP 地址错误
- 版本不匹配

**解决方法：**
- 检查防火墙设置
- 确认 IP 地址正确
- 确认双方版本号一致

### Q3: 频繁断线重连
**可能原因：**
- 网络不稳定
- 心跳间隔配置过短
- 超时阈值配置过小

**解决方法：**
- 检查网络质量
- 调整 `config.heartbeat_interval_ms`（默认 3000ms）
- 调整 `config.heartbeat_timeout_ms`（默认 10000ms）

---

## 配置参数

可在 `EasyMultiplayer.config` 中修改：

```gdscript
# 在测试场景的 _ready() 中添加：
EasyMultiplayer.config.default_port = 47778
EasyMultiplayer.config.max_clients = 4
EasyMultiplayer.config.heartbeat_interval_ms = 3000
EasyMultiplayer.config.heartbeat_timeout_ms = 10000
EasyMultiplayer.config.reconnect_max_attempts = 5
EasyMultiplayer.config.reconnect_interval_ms = 3000
```

---

## 日志输出示例

### 正常流程
```
[15:30:00] 测试场景已就绪
[15:30:05] 创建房间: 测试房间
[15:30:05] 连接状态: 未连接 → 主机中
[15:30:10] 开始搜索房间
[15:30:11] 发现房间: 测试房间 (192.168.1.100:47778) [1/4]
[15:30:15] 正在加入房间: 测试房间
[15:30:16] 连接成功
[15:30:16] 版本校验通过: 1.0.0
[15:30:16] 成功加入房间: 测试房间 (TestGame)
[15:30:16] 对端加入: 1
[15:30:16] 客人加入: 1
[15:30:20] 客户端准备状态: true
[15:30:20] 客人 1 准备状态: true
[15:30:25] 房主准备状态: true
[15:30:25] 所有人已就绪！
```

### 重连流程
```
[15:35:00] 对端超时: 1
[15:35:00] 等待对端重连...
[15:35:10] 对端重连成功: 1
[15:35:10] 网络质量: 良好 (RTT=50ms)
```

---

## 下一步

测试通过后，可以：
1. 集成到实际游戏项目
2. 自定义消息通道（使用 `EasyMultiplayer.message_channel`）
3. 实现游戏逻辑（在 `game_starting` 信号中切换场景）
4. 调整配置参数以适应游戏需求
