extends Control

onready var scoreLabel: RichTextLabel = get_node("ScoreLabel")

func _ready() -> void:
    $Button.grab_focus()
    scoreLabel.bbcode_enabled = true
    scoreLabel.bbcode_text = "[center]" + str(global.score) + "[/center]"


func _on_Button_pressed() -> void:
    get_tree().change_scene("res://src/scenes/menus/MainMenu.tscn")
