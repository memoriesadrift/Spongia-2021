extends Node2D

enum Weather {SUNNY, RAINY, WINDY, SNOWY}

var currentWeather: int = Weather.SUNNY
var weatherDurations: Dictionary = {
    Weather.SUNNY: 0,
    Weather.RAINY: 0,
    Weather.WINDY: 0,
    Weather.SNOWY: 0,
   }
onready var worldTimer: Timer = get_node("WorldTimer")

func _ready() -> void:
    worldTimer.set_wait_time(1)
    worldTimer.start()

func _on_WorldTimer_timeout() -> void:
    _adjust_weatherDuration(currentWeather)

func _on_Player_song_played(song) -> void: # song MUST be dynamically typed
    _change_Weather(_song_signal_to_weather(song))

# Helper function to adjust weather durations based on current weather
func _adjust_weatherDuration(weather: int) -> void:
    weatherDurations[weather] += 1
    
    if (weather != Weather.SUNNY):
        if (weatherDurations[Weather.SUNNY] > 0):
            weatherDurations[Weather.SUNNY] -= 1
    if (weather != Weather.RAINY):
        if (weatherDurations[Weather.RAINY] > 0):
            weatherDurations[Weather.RAINY] -= 1
    if (weather != Weather.WINDY):
        if (weatherDurations[Weather.WINDY] > 0):
            weatherDurations[Weather.WINDY] -= 1
    if (weather != Weather.SNOWY):
        if (weatherDurations[Weather.SNOWY] > 0):
            weatherDurations[Weather.SNOWY] -= 1

# Helper function to safely assign to currentWeather
func _change_Weather(to: int) -> void:
    if (to == currentWeather or to > 0):
        pass
    
    var newWeather = currentWeather
    
    match (to):
        Weather.SUNNY:
            newWeather = Weather.SUNNY
        Weather.RAINY:
            newWeather = Weather.RAINY
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
