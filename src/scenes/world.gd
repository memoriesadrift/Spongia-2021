extends Node2D

signal random_event_complete()
signal weather_event_changed(weatherEvent)

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

const seasonalFloods: Array = [
    preload("res://assets/background/weather/rainy/flood/0_flood_spring.png"),
    preload("res://assets/background/weather/rainy/flood/1_flood_summer.png"),
    preload("res://assets/background/weather/rainy/flood/2_flood_fall.png"),
    preload("res://assets/background/weather/rainy/flood/3_flood_winter.png"),
   ]

const sunnyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/sunny/sunny/0_sunny_atmosphere.png"),
    preload("res://assets/background/weather/sunny/drought/1_drought_atmosphere.png"),
]

const droughtGroundTexture: = preload("res://assets/background/weather/sunny/drought/0_drought_ground.png")

const rainyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/rainy/rainy/0_rainy_01.png"),
    preload("res://assets/background/weather/rainy/rainy/1_rainy_01.png"),
    preload("res://assets/background/weather/rainy/rainy/2_rainy_01.png"),
]

const windyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/sprites/wind/0_wind_01.png"),
    preload("res://assets/background/weather/sprites/wind/1_wind_02.png"),
    preload("res://assets/background/weather/sprites/wind/2_wind_03.png"),
]

const snowyAtmosphereTextures: Array = [
    preload("res://assets/background/weather/rainy/snowy/0_snowy_01.png"),
    preload("res://assets/background/weather/rainy/snowy/1_snowy_01.png"),
    preload("res://assets/background/weather/rainy/snowy/2_snowy_01.png"),
]

const hailAtmosphereTextures: Array = [
    preload("res://assets/background/weather/rainy/hail/0_hail_01.png"),
    preload("res://assets/background/weather/rainy/hail/1_hail_01.png"),
    preload("res://assets/background/weather/rainy/hail/2_hail_01.png"),
]

var atmosphereTextureAnimationFrame: int = 0

var isHailing: bool = false

const sunBrightnessSunny: Color = Color("50ffffff")
const sunBrightnessDrought: Color = Color("a0ffffff")
const sunBrightnessOff: Color = Color("00ffffff")

enum Weather {SUNNY, RAINY, WINDY, SNOWY}
enum Seasons {SPRING, SUMMER, AUTUMN, WINTER}

var gameTime: int = 0

var extremeWeatherThreshold: int = 10

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

onready var bgTexture: TextureRect = get_node("Background/BackgroundTexture")
onready var riverTexture: TextureRect = get_node("River/RiverTexture")
onready var frillTexture: TextureRect = get_node("Frills/FrillTexture")
onready var groundTexture: TextureRect = get_node("Ground/GroundTexture")
onready var atmosphereTexture: TextureRect = get_node("Atmosphere/AtmosphereTexture")
onready var sunAtmosphereTexture: TextureRect = get_node("SunAtmosphere/SunAtmosphereTexture")
onready var sunBrightness: = get_node("Sun/SunBrightness")

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
        if (weatherEffectAccumulators[key] >= extremeWeatherThreshold):
            match key:
                Weather.SUNNY:
                    sunBrightness.modulate = sunBrightnessDrought
                    sunAtmosphereTexture.set_texture(sunnyAtmosphereTextures[1])
                    groundTexture.set_texture(droughtGroundTexture)
                    emit_signal("weather_event_changed", "drought")
                Weather.RAINY:
                    riverTexture.set_texture(seasonalFloods[currentSeason])
                    emit_signal("weather_event_changed", "flood")
                Weather.WINDY:
                    emit_signal("weather_event_changed", "hurricane")
                Weather.SNOWY:
                    emit_signal("weather_event_changed", "snow-in")

func _on_Crops_special_event_over() -> void:
    _random_event_done()

func _on_Trees_special_event_over() -> void:
    _random_event_done()

func _random_event_done():
    if (isHailing):
        isHailing = false
    emit_signal("random_event_complete")

func _process_random_event(event: String) -> void:
    match event:
        "fire_trees":
            emit_signal("weather_event_changed", "fire_crops")
        "fire_crops":
            emit_signal("weather_event_changed", "fire_trees")
        "hail":
            isHailing = true
            emit_signal("weather_event_changed", "hail")

# Helper function to adjust weather durations based on current weather
func _adjust_weatherDuration(weather: int) -> void:
    weatherEffectAccumulators[weather] += 1

    for key in weatherEffectAccumulators:
        if(weather != key and weatherEffectAccumulators[key] > 0):
            if (weatherEffectAccumulators[key] == extremeWeatherThreshold):
                emit_signal("weather_event_changed", "extreme_weather_over")
                if (key == Weather.SUNNY):
                    groundTexture.texture = null # supposedly this is how you delete textures...
                    sunBrightness.modulate = sunBrightnessSunny
                    sunAtmosphereTexture.set_texture(sunnyAtmosphereTextures[0])
                if (key == Weather.RAINY):
                    riverTexture.set_texture(seasonalRivers[currentSeason])
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
            sunAtmosphereTexture.set_texture(sunnyAtmosphereTextures[0])
            sunBrightness.modulate = sunBrightnessSunny
            emit_signal("weather_event_changed", "sunny")
        Weather.RAINY:
            newWeather = Weather.RAINY
            _toggle_AnimationTimer(0.1, true)
            if (weatherEffectAccumulators[Weather.SUNNY] < extremeWeatherThreshold):
                sunBrightness.modulate = sunBrightnessOff
            emit_signal("weather_event_changed", "rainy")
        Weather.WINDY:
            newWeather = Weather.WINDY
            _toggle_AnimationTimer(0.3, true)
            if (weatherEffectAccumulators[Weather.SUNNY] < extremeWeatherThreshold):
                sunBrightness.modulate = sunBrightnessOff
            emit_signal("weather_event_changed", "windy")
        Weather.SNOWY:
            newWeather = Weather.SNOWY
            _toggle_AnimationTimer(0.1, true)
            if (weatherEffectAccumulators[Weather.SUNNY] < extremeWeatherThreshold):
                sunBrightness.modulate = sunBrightnessOff
            emit_signal("weather_event_changed", "snowy")
        _:
            pass 
    currentWeather = newWeather

# Helper function to convert the signal from player to our enum safely.
func _song_signal_to_weather(song: String) -> int:
    match song:
        "sunny":
            return Weather.SUNNY
        "rainy":
            if (currentSeason == Seasons.WINTER):
                return Weather.SNOWY
            return Weather.RAINY
        "windy":
            return Weather.WINDY
        _:
            assert(false, "Error: Unhandled song in _song_signal_to_weather, song: " + song)
            return -1 # Return an error value

# Advances to the next season if applicable
func _advance_season() -> void:
    if (gameTime % 20 == 0):
        if (currentSeason == Seasons.WINTER):
            # TODO: end the game here
            currentSeason = Seasons.SPRING
            return
        currentSeason += 1
        if (currentSeason != Seasons.SPRING):
            frillTexture.hide()
        bgTexture.set_texture(seasonalBackgrounds[currentSeason])
        if (weatherEffectAccumulators[Weather.RAINY] >= extremeWeatherThreshold):
            riverTexture.set_texture(seasonalFloods[currentSeason])
        else:
            riverTexture.set_texture(seasonalRivers[currentSeason])

# Performs actions that happen every second of the game
func _advance_game_time() -> void:
    gameTime += 1
    _adjust_weatherDuration(currentWeather)
    _check_weather_too_long()
    _advance_season()
    print(weatherEffectAccumulators)

func _toggle_AnimationTimer(timeout: float, enabled: bool):
    if (!animationTimer.is_stopped() or !enabled):
        animationTimer.stop()
        return
    animationTimer.set_wait_time(timeout)
    animationTimer.start()

func _on_AnimationTimer_timeout() -> void:
    atmosphereTextureAnimationFrame = atmosphereTextureAnimationFrame + 1 if atmosphereTextureAnimationFrame < 2 else 0
    if (currentWeather == Weather.RAINY):
        if (isHailing):
            atmosphereTexture.set_texture(hailAtmosphereTextures[atmosphereTextureAnimationFrame])
        else:
            atmosphereTexture.set_texture(rainyAtmosphereTextures[atmosphereTextureAnimationFrame])
    if (currentWeather == Weather.WINDY):
        atmosphereTexture.set_texture(windyAtmosphereTextures[atmosphereTextureAnimationFrame])
    if (currentWeather == Weather.SNOWY):
        if (isHailing):
            atmosphereTexture.set_texture(hailAtmosphereTextures[atmosphereTextureAnimationFrame])
        else:
            atmosphereTexture.set_texture(snowyAtmosphereTextures[atmosphereTextureAnimationFrame])

func _on_BGMPlayer_finished() -> void:
    bgmPlayer.play()
