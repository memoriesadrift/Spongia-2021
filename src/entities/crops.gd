extends Node2D

signal special_event_over()

const damagedCropTextures: Array = [
    preload("res://assets/sprites/crops/wheat/1_wheat_01_dead.png"),
    preload("res://assets/sprites/crops/wheat/1_wheat_02_dead.png"),
    preload("res://assets/sprites/crops/wheat/1_wheat_03_dead.png"),
]

const fireTextures1: Array = [
    preload("res://assets/background/weather/sprites/fire/fire_01/0_fire_01.png"),
    preload("res://assets/background/weather/sprites/fire/fire_01/1_fire_01.png"),
    preload("res://assets/background/weather/sprites/fire/fire_01/2_fire_01.png"),
]

const fireTextures2: Array = [
    preload("res://assets/background/weather/sprites/fire/fire_02/0_fire_02.png"),
    preload("res://assets/background/weather/sprites/fire/fire_02/1_fire_02.png"),
    preload("res://assets/background/weather/sprites/fire/fire_02/2_fire_02.png"),
]

var fireTextureAnimationFrame: int = 0

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
onready var animationTimer: Timer = get_node("AnimationTimer")

onready var fire11: TextureRect = get_node("FireLayer/1Fire1")
onready var fire12: TextureRect = get_node("FireLayer/2Fire1")
onready var fire21: TextureRect = get_node("FireLayer/1Fire2")
onready var fire22: TextureRect = get_node("FireLayer/2Fire2")

var fires: Array = []

# no better way?
onready var crop1: TextureRect = get_node("CropLayer/0Wheat")
onready var crop2: TextureRect = get_node("CropLayer/0Wheat2")
onready var crop3: TextureRect = get_node("CropLayer/0Wheat3")
onready var crop4: TextureRect = get_node("CropLayer/0Wheat4")

onready var crop5: TextureRect = get_node("CropLayer/1Wheat")
onready var crop6: TextureRect = get_node("CropLayer/1Wheat2")
onready var crop7: TextureRect = get_node("CropLayer/1Wheat3")
onready var crop8: TextureRect = get_node("CropLayer/1Wheat4")
onready var crop9: TextureRect = get_node("CropLayer/1Wheat5")

onready var crop10: TextureRect = get_node("CropLayer/2Wheat")
onready var crop11: TextureRect = get_node("CropLayer/2Wheat2")
onready var crop12: TextureRect = get_node("CropLayer/2Wheat3")

var crops: Array = []

func _ready() -> void:
    fires.append(fire11)
    fires.append(fire12)
    fires.append(fire21)
    fires.append(fire22)

    crops.append(crop1)
    crops.append(crop2)
    crops.append(crop3)
    crops.append(crop4)
    crops.append(crop5)
    crops.append(crop6)
    crops.append(crop7)
    crops.append(crop8)
    crops.append(crop9)
    crops.append(crop10)
    crops.append(crop11)
    crops.append(crop12)
    
    damageTimer.start()

func _on_DamageTimer_timeout() -> void:
    _applyWeatherEffects(currentWeatherEvent)
    _incur_damage()

func _on_World_weather_event_changed(weatherEvent) -> void:
    _safe_assign_weather_event(weatherEvent)

func _applyWeatherEffects(weatherEvent: String) -> void:
    # Fire keeps on burning, until it's put out
    if (currentSpecialEvent == "fire_crops"):
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
            if (weatherDamageAccumulators.fire > 1 and currentSpecialEvent == "fire_crops"):
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
                weatherDamageAccumulators.fire -= 5
        "windy":
            if (weatherDamageAccumulators.fire > 1 and currentSpecialEvent == "fire_crops"):
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

    if (currentSpecialEvent == "fire_crops" and weatherDamageAccumulators.fire <= 0):
        currentSpecialEvent = ""
        stop_fire()
        emit_signal("special_event_over")
    if (currentSpecialEvent == "hail" and eventTimer <= 0):
        currentSpecialEvent = ""
        eventTimer = 0
        emit_signal("special_event_over")

func _incur_damage() -> void:
    for key in weatherDamageAccumulators:
        if (weatherDamageAccumulators[key] > 10):
            weatherDamageAccumulators[key] -= 10
            damageLevel += 1
            _apply_damage_effects()

func _apply_damage_effects():
    var cropToDamage: int = damageLevel -1
    if (cropToDamage > crops.size() - 1):
        return
    
    if (cropToDamage < 4):
        crops[cropToDamage].set_texture(damagedCropTextures[0])
        return
    if (cropToDamage > 3 and cropToDamage < 9):
        crops[cropToDamage].set_texture(damagedCropTextures[1])
        return
    if (cropToDamage > 8):
        crops[cropToDamage].set_texture(damagedCropTextures[2])
        return

func start_fire() -> void:
    animationTimer.set_wait_time(0.2)
    animationTimer.start()

func stop_fire() -> void:
    animationTimer.stop()
    for fire in fires:
        fire.texture = null # apparently this is how you remove textures

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
            return
        "fire_crops":
            currentSpecialEvent = event
            start_fire()
        "hail":
            currentSpecialEvent = event
            eventTimer = 10

func _on_AnimationTimer_timeout() -> void:
    fireTextureAnimationFrame = fireTextureAnimationFrame + 1 if fireTextureAnimationFrame < 2 else 0
    var pos = 0
    for fire in fires:
        # this is a strange approach but it works so it's ok for now
        if (pos < 2):
            fire.set_texture(fireTextures1[fireTextureAnimationFrame])
        else:
            fire.set_texture(fireTextures2[fireTextureAnimationFrame])
        pos += 1
    pos = 0
