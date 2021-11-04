extends Node2D

enum Weather {SUNNY, RAINY, WINDY, SNOWY}
enum Seasons {SPRING, SUMMER, AUTUMN, WINTER}

var currentSeason: int = Seasons.SPRING
var currentWeather: int = Weather.SUNNY
var gameTime: int = 0
var weatherEffectAccumulators: Dictionary = {
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
    _advance_game_time()

func _on_Player_song_played(song) -> void: # song MUST be dynamically typed
    _change_Weather(_song_signal_to_weather(song))

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


# Advances to the next season if applicable
func _advance_season() -> void:
    if (gameTime % 10 == 0):
        if (currentSeason == Seasons.WINTER):
            # TODO: end the game here
            currentSeason = Seasons.SPRING
            return
        currentSeason += 1

# Performs actions that happen every second of the game
func _advance_game_time() -> void:
    gameTime += 1
    _adjust_weatherDuration(currentWeather)
    _advance_season()
