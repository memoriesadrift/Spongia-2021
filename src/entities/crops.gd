extends Node2D

signal special_event_over()

var weatherDamageAccumulators: Dictionary = {
    "sun": 0,
    "rain": 0,
    "wind": 0,
    "snow": 0,
    "hail": 0,
    "fire": 0,
   }

var damageLevel: int = 0

var currentWeatherEvent: String = "sun"
var currentExtremeWeatherEvent: String = ""
var currentSpecialEvent: String = ""

var eventTimer: int = 0

onready var damageTimer: Timer = get_node("DamageTimer")

func _on_World_weather_event_changed(weatherEvent) -> void:
    _safe_assign_weather_event(weatherEvent)
    if(damageTimer.is_stopped()):
        _applyWeatherEffects(currentWeatherEvent)
        damageTimer.start()

func _on_DamageTimer_timeout() -> void:
    _applyWeatherEffects(currentWeatherEvent)
    _incur_damage()

func _applyWeatherEffects(weatherEvent: String) -> void:
    # Fire keeps on burning, until it's put out
    if (currentSpecialEvent == "fire"):
        weatherDamageAccumulators.fire += 3
    # Hail goes on for constant time
    if (currentSpecialEvent == "hail"):
        eventTimer -= 1

    match currentExtremeWeatherEvent:
        "drought":
            weatherDamageAccumulators.sun += 3
        "flood":
            weatherDamageAccumulators.rain += 3
        "hurricane":
            weatherDamageAccumulators.wind += 3
        "snow-in":
            weatherDamageAccumulators.snow += 3

    match weatherEvent:
        "sunny":
            if (weatherDamageAccumulators.fire > 1):
                weatherDamageAccumulators.fire += 2
            # Hail goes away faster in sun
            if (currentSpecialEvent == "hail"):
                eventTimer -= 1
            weatherDamageAccumulators.rain -= 1
            weatherDamageAccumulators.snow -= 1
        "rainy":
            # replace rain with hail
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
            else:
                weatherDamageAccumulators.sun -= 1
                weatherDamageAccumulators.fire -= 4
        "windy":
            # TODO: add fire spread signal to trees?
            if (weatherDamageAccumulators.fire > 1):
                weatherDamageAccumulators.fire += 2
            # hail + wind means more hail damage
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
        "snowy":
            # replace snow with hail
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
            else:
                weatherDamageAccumulators.sun -= 1
    
    # reset negative counters to 0
    for key in weatherDamageAccumulators:
        if (weatherDamageAccumulators[key] < 0):
            weatherDamageAccumulators[key] = 0

    if (currentSpecialEvent == "fire" and weatherDamageAccumulators.fire <= 0):
        currentSpecialEvent = ""
        emit_signal("special_event_over")
    if (currentSpecialEvent == "hail" and eventTimer <= 0):
        currentSpecialEvent = ""
        eventTimer = 0
        emit_signal("special_event_over")

# TODO: Tinker with numbers
func _incur_damage() -> void:
    for key in weatherDamageAccumulators:
        if (weatherDamageAccumulators[key] > 10):
            weatherDamageAccumulators[key] -= 10
            damageLevel += 1

# TODO: Apply damage graphically
func _apply_damage_effects():
    pass

# Helper function to safely assign the signal
func _safe_assign_weather_event(event: String) -> void:
    match event:
        "sunny":
            currentWeatherEvent = event
        "rainy":
            currentWeatherEvent = event
        "windy":
            currentWeatherEvent = event
        "snowy":
            currentWeatherEvent = event
        "drought":
            currentExtremeWeatherEvent = event
        "flood":
            currentExtremeWeatherEvent = event
        "hurricane":
            currentExtremeWeatherEvent = event
        "snow-in":
            currentExtremeWeatherEvent = event
        "extreme_weather_over":
            currentExtremeWeatherEvent = ""
        "fire_trees":
            pass
        "fire_crops":
            currentSpecialEvent = event
        "hail":
            currentSpecialEvent = event
            eventTimer = 10
