extends Node2D

signal random_event(event)

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var bias: int = 0 # "Bad Luck Protection" to increase chance of generating event with time
var accumulatedDelta: float = 0
var isEventHappening: bool = false
const events = ["fire", "invaders", "hail"]

func _process(delta: float) -> void:
    accumulatedDelta += delta
    if (accumulatedDelta < 1 or isEventHappening):
        return
    accumulatedDelta = 0
    var eventGenerated: int = rng.randi_range(0, 100 - bias)
    if (!eventGenerated):
        var event: String = events[rng.randi_range(0, events.size() -1)]
        isEventHappening = true
        emit_signal("random_event", event)
        print("event fired!")
        print(event)


func _on_World_random_event_complete() -> void:
    isEventHappening = false
