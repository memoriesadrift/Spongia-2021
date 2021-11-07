extends Control

func _ready() -> void:
    $MenuContainer/StartButton.grab_focus()

func _on_StartButton_pressed() -> void:
    global.isEndless = false
    get_tree().change_scene("res://src/scenes/World.tscn")

func _on_QuitButton_pressed() -> void:
    get_tree().quit()

func _on_HelpButton_pressed() -> void:
    get_tree().change_scene("res://src/scenes/menus/HelpMenu.tscn")


func _on_EndlessButton_pressed() -> void:
    get_tree().change_scene("res://src/scenes/World.tscn")
    global.isEndless = true
    pass # Replace with function body.
