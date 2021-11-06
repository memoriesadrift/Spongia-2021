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

enum Songs {
    SUNNY,
    WINDY,
    RAINY,
}

const idleAnimations: Array = [
    preload("res://assets/sprites/player/character/0_weathergod_idle.png"),
    preload("res://assets/sprites/player/character/1_weathergod_idle.png"),
    preload("res://assets/sprites/player/character/2_weathergod_idle.png"),
]

const panPlayingAnimations: Array = [
    preload("res://assets/sprites/player/character/0_weathergod_play.png"),
    preload("res://assets/sprites/player/character/1_weathergod_play.png"),
    preload("res://assets/sprites/player/character/2_weathergod_play.png"),
    preload("res://assets/sprites/player/character/3_weathergod_play.png"),
    preload("res://assets/sprites/player/character/4_weathergod_play.png"),
    preload("res://assets/sprites/player/character/5_weathergod_play.png"),
]

var animationFrame: int = 0
var skipScheduledSpriteChange: bool = false
var queuedPanPlayingAnimation: int = 0

var currentNote: int = -1
var currentSong: int = 0

# RegEx patterns set later, because it is not possible here
var sunSongRegEx: RegEx = RegEx.new()
var windSongRegEx: RegEx = RegEx.new()
var rainSongRegEx: RegEx = RegEx.new()

var noteBuffer: Array = [] 

var _noteFilePathPrefix: String = "res://assets/audio/sfx/handpan/"

var noteToSoundFilePath: Dictionary = {
    Notes.A3: _noteFilePathPrefix + "A3_light.wav",
    Notes.A4_SHARP: _noteFilePathPrefix + "A#4_light.wav",
    Notes.C4_SHARP: _noteFilePathPrefix + "C#4_light.wav",
    Notes.D3: _noteFilePathPrefix + "D3_light.wav",
    Notes.D3_SHARP: _noteFilePathPrefix + "D#3_light.wav",
    Notes.G3: _noteFilePathPrefix + "G3_light.wav",
   }
    
var isNotePlaying: bool = false

onready var notePlayer: AudioStreamPlayer2D = get_node("NotePlayer")
onready var noteTimer: Timer = get_node("NoteTimer")
onready var silenceTimer: Timer = get_node("SilenceTimer")
onready var animationTimer: Timer = get_node("AnimationTimer")
onready var playerSprite: Sprite = get_node("PlayerSprite")

func _ready() -> void:
    animationTimer.set_wait_time(0.6)
    animationTimer.start()

func _process(delta: float) -> void:
    var pressedKey: int = _get_played_note()
    _change_note(pressedKey)
    _play_note(currentNote)
    _check_noteBuffer_length()
    _change_song(noteBuffer)

func _on_NoteTimer_timeout() -> void:
    isNotePlaying = false
    noteTimer.stop()

func _on_SilenceTimer_timeout() -> void:
    noteBuffer.push_front(currentNote)
    silenceTimer.stop()

func _play_note(note: int):
    if (isNotePlaying):
        currentNote = -1
        return

    # If no key is pressed, add "no note played" to noteBuffer
    if (currentNote < 0 and !isNotePlaying):
        if (silenceTimer.is_stopped()):
            silenceTimer.start()
        return

    playerSprite.set_texture(panPlayingAnimations[queuedPanPlayingAnimation])
    queuedPanPlayingAnimation = queuedPanPlayingAnimation + 1 if queuedPanPlayingAnimation < panPlayingAnimations.size() - 1 else 0
    skipScheduledSpriteChange = true

    silenceTimer.stop()
    noteTimer.set_wait_time(0.7)
    noteTimer.start()
    notePlayer.stream = load(noteToSoundFilePath[note])
    notePlayer.play()
    isNotePlaying = true
    noteBuffer.push_front(currentNote)
    currentNote = -1

func _change_song(notesPlayed: Array) -> void:
    # need to set regex patterns here, because it is not possible when calling RegEx.new()
    sunSongRegEx.compile("1100")
    windSongRegEx.compile("1111")
    rainSongRegEx.compile("1010")

    var notesString: String = ""

    # TODO: Remove this conversion if unnecessary
    for note in notesPlayed: 
        if (note < 0):
            notesString += '0'
        else:
            notesString += '1'
    
    print(notesString)
    if (notesString.length() <= 0):
        print("exiting!")
        return
    
    var isSunSong: bool = sunSongRegEx.search(notesString) != null
    var isWindSong: bool = windSongRegEx.search(notesString) != null
    var isRainSong: bool = rainSongRegEx.search(notesString) != null

    # FIXME: Check if two can't be present at the same time

    if (isSunSong):
        currentSong = Songs.SUNNY
        emit_signal("song_played", "sunny")
        return
    if (isWindSong):
        currentSong = Songs.WINDY
        emit_signal("song_played", "windy")
        return
    if (isRainSong):
        currentSong = Songs.RAINY
        emit_signal("song_played", "rainy")
        return

# Helper function to safely assign to currentNote
func _change_note(to: int) -> void:
    if (to == currentNote or to < 0):
        return
    
    var newNote = currentNote
    
    match (to):
        Notes.A3:
            newNote = Notes.A3
        Notes.A4_SHARP:
            newNote = Notes.A4_SHARP
        Notes.C4_SHARP:
            newNote = Notes.C4_SHARP
        Notes.D3:
            newNote = Notes.D3
        Notes.D3_SHARP:
            newNote = Notes.D3_SHARP
        Notes.G3:
            newNote = Notes.G3
        _:
            pass
    currentNote = newNote

func _get_played_note() -> int:
    if Input.get_action_strength("a3"):
        return Notes.A3
    elif Input.get_action_strength("a4_sharp"):
        return Notes.A4_SHARP
    elif Input.get_action_strength("c4_sharp"):
        return Notes.C4_SHARP
    elif Input.get_action_strength("d3"):
        return Notes.D3
    elif Input.get_action_strength("d3_sharp"):
        return Notes.D3_SHARP
    elif Input.get_action_strength("g3"):
        return Notes.G3
    return Notes.NONE

func _check_noteBuffer_length() -> void:
    if (noteBuffer.size() > 5):
        noteBuffer.pop_back()

# func to play animation
func _on_AnimationTimer_timeout() -> void:
    if (skipScheduledSpriteChange):
        skipScheduledSpriteChange = false
        return
    animationFrame = animationFrame + 1 if animationFrame < idleAnimations.size() - 1 else 0
    playerSprite.set_texture(idleAnimations[animationFrame])
