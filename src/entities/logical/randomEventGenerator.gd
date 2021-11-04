extends Node2D

signal random_event(event)

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var bias: int = 0 # "Bad Luck Protection" to increase chance of generating event with time

func _process(delta: float) -> void:
    var eventGenerated: int = rng.randi_range(0, 100 - bias)
    if (!eventGenerated):
        emit_signal("random_event", "event")
