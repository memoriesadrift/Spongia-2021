extends Node2D

signal random_event(event)

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var bias: int = 0 # "Bad Luck Protection" to increase chance of generating event with time
var accumulatedDelta: float = 0
var isEventHappening: bool = false
const events = ["fire", "hail"]

func _process(delta: float) -> void:
    rng.randomize()
    accumulatedDelta += delta
    if (accumulatedDelta < 1 or isEventHappening):
        return
    accumulatedDelta = 0
    var eventGenerated: int = rng.randi_range(0, max(0, 100 - bias))
    if (eventGenerated == 0):
        bias = 0
        rng.randomize()
        var event: String = events[rng.randi_range(0, events.size() -1)]
        if (event == "fire"):
            var whereFire = rng.randi_range(0, 1)
            if (!whereFire):
                event += "_trees"
            else:
                event += "_crops"

        isEventHappening = true
        emit_signal("random_event", event)
        print("event fired!")
        print(event)
    else:
        bias += 2


func _on_World_random_event_complete() -> void:
    isEventHappening = false
