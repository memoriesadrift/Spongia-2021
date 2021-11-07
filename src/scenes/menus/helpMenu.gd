extends Control

func _ready() -> void:
    $BackButton.grab_focus()

func _on_BackButton_pressed() -> void:
    get_tree().change_scene("res://src/scenes/menus/MainMenu.tscn")
