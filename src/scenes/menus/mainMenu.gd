extends Control

func _ready() -> void:
    $MenuContainer/StartButton.grab_focus()

func _on_StartButton_pressed() -> void:
    get_tree().change_scene("res://src/scenes/World.tscn")

func _on_OptionsButton_pressed() -> void:
    pass # Replace with function body.

func _on_QuitButton_pressed() -> void:
    get_tree().quit()
