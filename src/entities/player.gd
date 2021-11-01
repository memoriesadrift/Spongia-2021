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

var currentNote: int = -1

var _noteFilePathPrefix: String = "res://assets/audio/sfx/handpan/"

var noteToSoundFilePath: Dictionary = {
    Notes.A3: _noteFilePathPrefix + "A3_hard.wav",
    Notes.A4_SHARP: _noteFilePathPrefix + "A#4_hard.wav",
    Notes.C4_SHARP: _noteFilePathPrefix + "C#4_hard.wav",
    Notes.D3: _noteFilePathPrefix + "D3_hard.wav",
    Notes.D3_SHARP: _noteFilePathPrefix + "D#3_hard.wav",
    Notes.G3: _noteFilePathPrefix + "G3_hard.wav",
   }
    
var isNotePlaying: bool = false

onready var notePlayer: AudioStreamPlayer2D = get_node("NotePlayer")
onready var noteTimer: Timer = get_node("NoteTimer")

func _physics_process(delta: float) -> void:
    var pressedKey: int = _get_played_note()
    _change_song(pressedKey)
    _play_note(currentNote)

func _play_note(note: int):
    if (isNotePlaying or note < 0):
        currentNote = -1
        return
    noteTimer.set_wait_time(1)
    noteTimer.start()
    notePlayer.stream = load(noteToSoundFilePath[note])
    notePlayer.play()
    isNotePlaying = true
    currentNote = -1


# TODO: In the future, refactor to be like world.gd/_change_weather and emit the local var
func _change_song(song: int) -> void:
    # TODO: Introduce Song enum and change here too!
    match song:
        Notes.A3:
            currentNote = Notes.A3
            emit_signal("song_played", "sunny")
        Notes.D3:
            currentNote = Notes.D3
            emit_signal("song_played", "windy")
        Notes.G3:
            currentNote = Notes.G3
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


func _on_NoteTimer_timeout() -> void:
    isNotePlaying = false
    noteTimer.stop()
