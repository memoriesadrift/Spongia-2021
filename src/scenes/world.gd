extends Node2D

signal random_event_complete()

const seasonalBackgrounds: Array = [
    preload("res://assets/background/seasons/spring/0_spring_bg.png"),
    preload("res://assets/background/seasons/summer/0_summer_bg.png"),
    preload("res://assets/background/seasons/autumn/0_autumn_bg.png"),
    preload("res://assets/background/seasons/winter/0_winter_bg.png"),
   ]

const seasonalRivers: Array = [
    preload("res://assets/background/seasons/spring/2_spring_river.png"),
    preload("res://assets/background/seasons/summer/1_summer_river.png"),
    preload("res://assets/background/seasons/autumn/1_autumn_river.png"),
    preload("res://assets/background/seasons/winter/1_winter_river.png"),
   ]

# TODO: Add drought / burning ground here when incorporating repsective parts
const sunnyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/sunny/sunny/0_sunny_atmosphere.png"),
]

const rainyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/rainy/rainy/0_rainy_01.png"),
    preload("res://assets/background/weather/rainy/rainy/1_rainy_01.png"),
    preload("res://assets/background/weather/rainy/rainy/2_rainy_01.png"),
]
var rainyAtmosphereTextureAnimationFrame: int = 0

enum Weather {SUNNY, RAINY, WINDY, SNOWY}
enum Seasons {SPRING, SUMMER, AUTUMN, WINTER}

var gameTime: int = 0

var currentSeason: int = Seasons.SPRING
var currentWeather: int = Weather.SUNNY
var currentRandomEvent: String = ""
var randomEventTime: int = 0

var weatherEffectAccumulators: Dictionary = {
    Weather.SUNNY: 0,
    Weather.RAINY: 0,
    Weather.WINDY: 0,
    Weather.SNOWY: 0,
   }

onready var worldTimer: Timer = get_node("WorldTimer")
onready var animationTimer: Timer = get_node("AnimationTimer")

onready var bgmPlayer: AudioStreamPlayer = get_node("BGMPlayer")

onready var weatherLabel: RichTextLabel = get_node("DebugExtremeWeather")
onready var songLabel: RichTextLabel = get_node("DebugExtremeWeather")

onready var bgTexture: TextureRect = get_node("Background/BackgroundTexture")
onready var riverTexture: TextureRect = get_node("River/RiverTexture")
onready var frillTexture: TextureRect = get_node("Frills/FrillTexture")
onready var atmosphereTexture: TextureRect = get_node("Atmosphere/AtmosphereTexture")

func _ready() -> void:
    worldTimer.set_wait_time(1)
    worldTimer.start()
    bgmPlayer.play()

func _on_WorldTimer_timeout() -> void:
    _advance_game_time()

func _on_Player_song_played(song) -> void: # song MUST be dynamically typed
    _change_Weather(_song_signal_to_weather(song))

func _on_RandomEventGenerator_random_event(event) -> void:
    currentRandomEvent = event

func _check_weather_too_long() -> void:
    for key in weatherEffectAccumulators:
        if (weatherEffectAccumulators[key] > 50):
            weatherLabel.clear()
            weatherLabel.add_text("Extreme weather effect: ")
            match key:
                Weather.SUNNY:
                    weatherLabel.add_text("drought")
                Weather.RAINY:
                    weatherLabel.add_text("flood")
                Weather.WINDY:
                    weatherLabel.add_text("hurricane")
                Weather.SNOWY:
                    weatherLabel.add_text("snow-in")

func _random_event_done():
    randomEventTime = 0
    currentRandomEvent = ""
    emit_signal("random_event_complete")

func _process_random_event(event: String) -> void:
    match event:
        "fire":
            _process_fire_random_event()
        # TODO: Add in a later PR
        "hail":
            pass
        "invaders":
            pass

func _process_fire_random_event() -> void:
    if (currentWeather == Weather.RAINY):
        randomEventTime += 1
    if (randomEventTime > 10):
        _random_event_done()

# Helper function to adjust weather durations based on current weather
func _adjust_weatherDuration(weather: int) -> void:
    weatherEffectAccumulators[weather] += 1

    for key in weatherEffectAccumulators:
        if(weather != key and weatherEffectAccumulators[key] > 0):
            weatherEffectAccumulators[key] -= 1

# Helper function to safely assign to currentWeather
func _change_Weather(to: int) -> void:
    if (to == currentWeather or to < 0):
        return

    var newWeather = currentWeather
 
    match (to):
        Weather.SUNNY:
            newWeather = Weather.SUNNY
            _toggle_AnimationTimer(0, false)
            # TODO: Add custom setter function to detect drought
            atmosphereTexture.set_texture(sunnyAtmosphereTextures[0])
        Weather.RAINY:
            newWeather = Weather.RAINY
            _toggle_AnimationTimer(0.1, true)
        Weather.WINDY:
            newWeather = Weather.WINDY
        Weather.SNOWY:
            newWeather = Weather.SNOWY
        _:
            pass 
    currentWeather = newWeather

# Helper function to convert the signal from player to our enum safely.
func _song_signal_to_weather(song: String) -> int:
    match song:
        "sunny":
            return Weather.SUNNY
        "rainy":
            return Weather.RAINY
        "windy":
            return Weather.WINDY
        "snowy":
            return Weather.SNOWY
        _:
            assert(false, "Error: Unhandled song in _song_signal_to_weather, song: " + song)
            return -1 # Return an error value

# Advances to the next season if applicable
func _advance_season() -> void:
    if (gameTime % 10 == 0):
        if (currentSeason == Seasons.WINTER):
            # TODO: end the game here
            currentSeason = Seasons.SPRING
            return
        currentSeason += 1
        if (currentSeason != Seasons.SPRING):
            frillTexture.hide()
        bgTexture.set_texture(seasonalBackgrounds[currentSeason])
        riverTexture.set_texture(seasonalRivers[currentSeason])

# Performs actions that happen every second of the game
func _advance_game_time() -> void:
    gameTime += 1
    _adjust_weatherDuration(currentWeather)
    _advance_season()
    print(weatherEffectAccumulators)
    songLabel.clear()
    match currentWeather:
        Weather.SUNNY:
            songLabel.add_text("sun")
        Weather.RAINY:
            songLabel.add_text("rain")
        Weather.WINDY:
            songLabel.add_text("wind")
        Weather.SNOWY:
            songLabel.add_text("snow")

func _toggle_AnimationTimer(timeout: float, enabled: bool):
    if (!animationTimer.is_stopped() or !enabled):
        animationTimer.stop()
        return
    animationTimer.set_wait_time(timeout)
    animationTimer.start()

func _on_AnimationTimer_timeout() -> void:
    if (currentWeather == Weather.RAINY):
        rainyAtmosphereTextureAnimationFrame = rainyAtmosphereTextureAnimationFrame + 1 if rainyAtmosphereTextureAnimationFrame < rainyAtmosphereTextures.size() - 1 else 0
        atmosphereTexture.set_texture(rainyAtmosphereTextures[rainyAtmosphereTextureAnimationFrame])

func _on_BGMPlayer_finished() -> void:
    bgmPlayer.play()
