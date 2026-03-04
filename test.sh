#!/bin/bash

# EasyMultiplayer-GD 快速测试脚本

PROJECT_DIR="/Users/void/Documents/EasyMultiplayer-GD"
GODOT_BIN="/usr/local/bin/godot"

echo "=== EasyMultiplayer-GD 测试工具 ==="
echo ""
echo "选择操作："
echo "1. 在编辑器中打开项目"
echo "2. 运行测试场景（Host 实例）"
echo "3. 运行测试场景（Client 实例）"
echo "4. 导出项目"
echo "5. 退出"
echo ""

read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo "正在打开 Godot 编辑器..."
        cd "$PROJECT_DIR"
        "$GODOT_BIN" project.godot &
        ;;
    2)
        echo "正在运行 Host 实例..."
        cd "$PROJECT_DIR"
        "$GODOT_BIN" --path . test_scene.tscn &
        ;;
    3)
        echo "正在运行 Client 实例..."
        cd "$PROJECT_DIR"
        "$GODOT_BIN" --path . test_scene.tscn &
        ;;
    4)
        echo "导出功能需要在 Godot 编辑器中配置导出预设"
        echo "请使用选项 1 打开编辑器，然后在 项目 → 导出 中配置"
        ;;
    5)
        echo "退出"
        exit 0
        ;;
    *)
        echo "无效选项"
        exit 1
        ;;
esac

echo ""
echo "操作已启动"
