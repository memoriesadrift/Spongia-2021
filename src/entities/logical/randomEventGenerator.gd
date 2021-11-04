extends Node2D

signal random_event(event)

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var bias: int = 0 # "Bad Luck Protection" to increase chance of generating event with time
var accumulatedDelta: float = 0
const events = ["fire", "invaders", "hail"]

func _process(delta: float) -> void:
    accumulatedDelta += delta
    if (accumulatedDelta < 1):
        return
    var eventGenerated: int = rng.randi_range(0, 100 - bias)
    if (!eventGenerated):
        var event: String = events[rng.randi_range(0, events.size() -1)]
        emit_signal("random_event", event)
