extends KinematicBody2D

# The signal param must be dynamically typed
signal song_played(song)

enum Notes {
    A3,
    A4_SHARP,
    C4_SHARP,
    D3,
    D3_SHARP,
    G3,
    NONE,
    }

func _physics_process(delta: float) -> void:
    var pressedKey: int = _get_played_note()
    _change_song(pressedKey)

# TODO: In the future, refactor to be like world.gd/_change_weather and emit the local var
func _change_song(song: int) -> void:
    # TODO: Introduce Song enum and change here too!
    match song:
        Notes.A3:
            emit_signal("song_played", "sunny")
        Notes.D3:
            emit_signal("song_played", "windy")
        Notes.G3:
            emit_signal("song_played", "rainy")
        _:
            pass

# TODO: Condense the inputs to needed inputs only in future commit.
func _get_played_note() -> int:
    if Input.get_action_strength("a3_hard"):
        return Notes.A3
    elif Input.get_action_strength("a3_light"):
        return Notes.A3
    elif Input.get_action_strength("a4_sharp_hard"):
        return Notes.A4_SHARP
    elif Input.get_action_strength("a4_sharp_light"):
        return Notes.A4_SHARP
    elif Input.get_action_strength("c4_sharp_hard"):
        return Notes.C4_SHARP
    elif Input.get_action_strength("c4_sharp_light"):
        return Notes.C4_SHARP
    elif Input.get_action_strength("d3_hard"):
        return Notes.D3
    elif Input.get_action_strength("d3_light"):
        return Notes.D3
    elif Input.get_action_strength("d3_sharp_hard"):
        return Notes.D3_SHARP
    elif Input.get_action_strength("d3_sharp_light"):
        return Notes.D3_SHARP
    elif Input.get_action_strength("g3_hard"):
        return Notes.G3
    elif Input.get_action_strength("g3_light"):
        return Notes.G3
    return Notes.NONE
