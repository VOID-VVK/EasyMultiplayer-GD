@tool
extends EditorPlugin

## EasyMultiplayer 编辑器插件入口。
## 负责插件的启用和禁用生命周期管理。


## 插件启用时调用
func _enter_tree() -> void:
	print("[EasyMultiplayer] Plugin enabled.")


## 插件禁用时调用
func _exit_tree() -> void:
	print("[EasyMultiplayer] Plugin disabled.")
