extends Control

## EasyMultiplayer-GD 测试场景
## 测试房间创建、搜索、加入、准备状态同步

@onready var log_text: TextEdit = $VBoxContainer/LogText
@onready var room_name_input: LineEdit = $VBoxContainer/HostPanel/RoomNameInput
@onready var create_room_btn: Button = $VBoxContainer/HostPanel/CreateRoomBtn
@onready var close_room_btn: Button = $VBoxContainer/HostPanel/CloseRoomBtn
@onready var host_ready_btn: Button = $VBoxContainer/HostPanel/HostReadyBtn

@onready var search_btn: Button = $VBoxContainer/ClientPanel/SearchBtn
@onready var stop_search_btn: Button = $VBoxContainer/ClientPanel/StopSearchBtn
@onready var rooms_list: ItemList = $VBoxContainer/ClientPanel/RoomsList
@onready var join_btn: Button = $VBoxContainer/ClientPanel/JoinBtn
@onready var leave_btn: Button = $VBoxContainer/ClientPanel/LeaveBtn
@onready var client_ready_btn: Button = $VBoxContainer/ClientPanel/ClientReadyBtn

@onready var status_label: Label = $VBoxContainer/StatusLabel

var discovered_rooms: Dictionary = {}


func _ready() -> void:
	# 绑定 UI 事件
	create_room_btn.pressed.connect(_on_create_room_pressed)
	close_room_btn.pressed.connect(_on_close_room_pressed)
	host_ready_btn.pressed.connect(_on_host_ready_pressed)

	search_btn.pressed.connect(_on_search_pressed)
	stop_search_btn.pressed.connect(_on_stop_search_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	leave_btn.pressed.connect(_on_leave_pressed)
	client_ready_btn.pressed.connect(_on_client_ready_pressed)

	# 绑定 EasyMultiplayer 信号
	EasyMultiplayer.state_changed.connect(_on_state_changed)
	EasyMultiplayer.peer_joined.connect(_on_peer_joined)
	EasyMultiplayer.peer_left.connect(_on_peer_left)
	EasyMultiplayer.connection_succeeded.connect(_on_connection_succeeded)
	EasyMultiplayer.connection_failed.connect(_on_connection_failed)
	EasyMultiplayer.version_verified.connect(_on_version_verified)
	EasyMultiplayer.version_mismatch.connect(_on_version_mismatch)

	EasyMultiplayer.room_host.guest_joined.connect(_on_guest_joined)
	EasyMultiplayer.room_host.guest_left.connect(_on_guest_left)
	EasyMultiplayer.room_host.guest_ready_changed.connect(_on_guest_ready_changed)
	EasyMultiplayer.room_host.all_ready.connect(_on_all_ready)
	EasyMultiplayer.room_host.game_starting.connect(_on_game_starting)

	EasyMultiplayer.room_client.join_succeeded.connect(_on_join_succeeded)
	EasyMultiplayer.room_client.join_failed.connect(_on_join_failed)
	EasyMultiplayer.room_client.host_ready_changed.connect(_on_host_ready_changed)
	EasyMultiplayer.room_client.game_starting.connect(_on_game_starting_client)

	EasyMultiplayer.discovery.room_found.connect(_on_room_found)
	EasyMultiplayer.discovery.room_lost.connect(_on_room_lost)

	EasyMultiplayer.heartbeat.net_quality_changed.connect(_on_net_quality_changed)

	_log("测试场景已就绪")
	_update_ui()


func _process(_delta: float) -> void:
	status_label.text = "状态: %s | 对端: %d | RTT: %.0fms" % [
		_state_to_string(EasyMultiplayer.state),
		EasyMultiplayer.connected_peers.size(),
		EasyMultiplayer.heartbeat.rtt_ms
	]


# ── Host 操作 ──

func _on_create_room_pressed() -> void:
	var room_name = room_name_input.text
	if room_name.is_empty():
		room_name = "测试房间"

	var error = EasyMultiplayer.create_room(room_name, "TestGame")
	if error == OK:
		_log("创建房间: " + room_name)
	else:
		_log("创建房间失败: " + str(error))
	_update_ui()


func _on_close_room_pressed() -> void:
	EasyMultiplayer.room_host.close_room()
	_log("关闭房间")
	_update_ui()


func _on_host_ready_pressed() -> void:
	var ready = not EasyMultiplayer.room_host.host_ready
	EasyMultiplayer.room_host.set_host_ready(ready)
	_log("房主准备状态: " + str(ready))
	_update_ui()


# ── Client 操作 ──

func _on_search_pressed() -> void:
	EasyMultiplayer.room_client.start_searching()
	_log("开始搜索房间")
	_update_ui()


func _on_stop_search_pressed() -> void:
	EasyMultiplayer.room_client.stop_searching()
	_log("停止搜索")
	_update_ui()


func _on_join_pressed() -> void:
	var selected = rooms_list.get_selected_items()
	if selected.is_empty():
		_log("请先选择一个房间")
		return

	var room_key = rooms_list.get_item_text(selected[0])
	if not discovered_rooms.has(room_key):
		_log("房间不存在")
		return

	var room = discovered_rooms[room_key]
	var error = EasyMultiplayer.join_room(room.ip, room.info.port)
	if error == OK:
		_log("正在加入房间: " + room.info.host_name)
	else:
		_log("加入房间失败: " + str(error))
	_update_ui()


func _on_leave_pressed() -> void:
	EasyMultiplayer.room_client.leave_room()
	_log("离开房间")
	_update_ui()


func _on_client_ready_pressed() -> void:
	var ready = not EasyMultiplayer.room_client.is_ready
	EasyMultiplayer.room_client.set_ready(ready)
	_log("客户端准备状态: " + str(ready))
	_update_ui()


# ── Net 信号处理 ──

func _on_state_changed(old_state: ConnectionState.State, new_state: ConnectionState.State) -> void:
	_log("连接状态: %s → %s" % [_state_to_string(old_state), _state_to_string(new_state)])
	_update_ui()


func _on_peer_joined(peer_id: int) -> void:
	_log("对端加入: " + str(peer_id))


func _on_peer_left(peer_id: int) -> void:
	_log("对端离开: " + str(peer_id))


func _on_connection_succeeded() -> void:
	_log("连接成功")


func _on_connection_failed() -> void:
	_log("连接失败")


func _on_version_verified(remote_version: String) -> void:
	_log("版本校验通过: " + remote_version)


func _on_version_mismatch(local_version: String, remote_version: String) -> void:
	_log("版本不匹配！本地=%s, 对端=%s" % [local_version, remote_version])


func _on_guest_joined(peer_id: int) -> void:
	_log("客人加入: " + str(peer_id))


func _on_guest_left(peer_id: int) -> void:
	_log("客人离开: " + str(peer_id))


func _on_guest_ready_changed(peer_id: int, ready: bool) -> void:
	_log("客人 %d 准备状态: %s" % [peer_id, ready])


func _on_all_ready() -> void:
	_log("所有人已就绪！")


func _on_game_starting(game_type: String) -> void:
	_log("游戏开始: " + game_type)


func _on_join_succeeded(room_name: String, game_type: String) -> void:
	_log("成功加入房间: %s (%s)" % [room_name, game_type])


func _on_join_failed(reason: String) -> void:
	_log("加入房间失败: " + reason)


func _on_host_ready_changed(ready: bool) -> void:
	_log("房主准备状态: " + str(ready))


func _on_game_starting_client(game_type: String) -> void:
	_log("游戏即将开始: " + game_type)


func _on_room_found(ip: String, room_info) -> void:
	var key = ip + ":" + str(room_info.port)
	discovered_rooms[key] = {"ip": ip, "info": room_info}
	_update_rooms_list()
	_log("发现房间: %s (%s:%d) [%d/%d]" % [
		room_info.host_name,
		ip,
		room_info.port,
		room_info.player_count,
		room_info.max_players
	])


func _on_room_lost(ip: String, port: int) -> void:
	var key = ip + ":" + str(port)
	discovered_rooms.erase(key)
	_update_rooms_list()
	_log("房间丢失: " + key)


func _on_net_quality_changed(quality: ConnectionState.NetQuality, rtt_ms: float) -> void:
	_log("网络质量: %s (RTT=%.0fms)" % [_quality_to_string(quality), rtt_ms])


# ── UI 更新 ──

func _update_ui() -> void:
	var is_host = EasyMultiplayer.room_host.state != RoomState.State.IDLE and EasyMultiplayer.room_host.state != RoomState.State.CLOSED
	var is_client = EasyMultiplayer.room_client.state != ConnectionState.ClientState.IDLE

	# Host 面板
	create_room_btn.disabled = is_host or is_client
	close_room_btn.disabled = not is_host
	host_ready_btn.disabled = EasyMultiplayer.room_host.state != RoomState.State.READY
	host_ready_btn.text = "取消准备" if EasyMultiplayer.room_host.host_ready else "准备就绪"

	# Client 面板
	search_btn.disabled = is_host or is_client
	stop_search_btn.disabled = EasyMultiplayer.room_client.state != ConnectionState.ClientState.SEARCHING
	join_btn.disabled = EasyMultiplayer.room_client.state != ConnectionState.ClientState.SEARCHING or rooms_list.get_selected_items().is_empty()
	leave_btn.disabled = EasyMultiplayer.room_client.state != ConnectionState.ClientState.IN_ROOM
	client_ready_btn.disabled = EasyMultiplayer.room_client.state != ConnectionState.ClientState.IN_ROOM
	client_ready_btn.text = "取消准备" if EasyMultiplayer.room_client.is_ready else "准备就绪"


func _update_rooms_list() -> void:
	rooms_list.clear()
	for key in discovered_rooms.keys():
		var room = discovered_rooms[key]
		var text = "%s [%d/%d]" % [
			room.info.host_name,
			room.info.player_count,
			room.info.max_players
		]
		rooms_list.add_item(text)
		rooms_list.set_item_metadata(rooms_list.item_count - 1, key)


func _log(message: String) -> void:
	var time = Time.get_time_string_from_system()
	log_text.text += "[%s] %s\n" % [time, message]
	log_text.scroll_vertical = INF


func _state_to_string(state: ConnectionState.State) -> String:
	match state:
		ConnectionState.State.DISCONNECTED: return "未连接"
		ConnectionState.State.HOSTING: return "主机中"
		ConnectionState.State.JOINING: return "连接中"
		ConnectionState.State.CONNECTED: return "已连接"
		ConnectionState.State.RECONNECTING: return "重连中"
		_: return "未知"


func _quality_to_string(quality: ConnectionState.NetQuality) -> String:
	match quality:
		ConnectionState.NetQuality.GOOD: return "良好"
		ConnectionState.NetQuality.WARNING: return "一般"
		ConnectionState.NetQuality.BAD: return "较差"
		_: return "未知"
