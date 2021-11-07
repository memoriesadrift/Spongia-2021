extends Node2D

signal special_event_over()
 
const damagedTreeTextures: Array = [
    preload("res://assets/sprites/trees/evergreens/1_evergreen_01_dead.png"),
    preload("res://assets/sprites/trees/evergreens/1_evergreen_02_dead.png"),
    preload("res://assets/sprites/trees/evergreens/1_evergreen_03_dead.png"),
    preload("res://assets/sprites/trees/leafygreens/1_leafygreen_01_dead.png"),
    preload("res://assets/sprites/trees/leafygreens/1_leafygreen_02_dead.png"),
    preload("res://assets/sprites/trees/leafygreens/1_leafygreen_03_dead.png"),
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

onready var tree1: TextureRect = get_node("TreeLayer/1Evergreen")
onready var tree2: TextureRect = get_node("TreeLayer/1Evergreen2")
onready var tree3: TextureRect = get_node("TreeLayer/1Evergreen3")
onready var tree4: TextureRect = get_node("TreeLayer/1Evergreen4")

onready var tree5: TextureRect = get_node("TreeLayer/2Evergreen")
onready var tree6: TextureRect = get_node("TreeLayer/2Evergreen2")
onready var tree7: TextureRect = get_node("TreeLayer/2Evergreen3")

onready var tree8: TextureRect = get_node("TreeLayer/3Evergreen")
onready var tree9: TextureRect = get_node("TreeLayer/3Evergreen2")

onready var tree10: TextureRect = get_node("TreeLayer/1Leafygreen")
onready var tree11: TextureRect = get_node("TreeLayer/1Leafygreen2")
onready var tree12: TextureRect = get_node("TreeLayer/1Leafygreen3")

onready var tree13: TextureRect = get_node("TreeLayer/2Leafygreen")

onready var tree14: TextureRect = get_node("TreeLayer/3Leafygreen")
onready var tree15: TextureRect = get_node("TreeLayer/3Leafygreen2")

var trees: Array = []

onready var fire11: TextureRect = get_node("FireLayer/1Fire1")
onready var fire12: TextureRect = get_node("FireLayer/2Fire1")
onready var fire21: TextureRect = get_node("FireLayer/Fire2")

var treeFires: Array = []

func _ready() -> void:
    trees.append(tree1)
    trees.append(tree2)
    trees.append(tree3)
    trees.append(tree4)
    trees.append(tree5)
    trees.append(tree6)
    trees.append(tree7)
    trees.append(tree8)
    trees.append(tree9)
    trees.append(tree10)
    trees.append(tree11)
    trees.append(tree12)
    trees.append(tree13)
    trees.append(tree14)
    trees.append(tree15)

    treeFires.append(fire11)
    treeFires.append(fire12)
    treeFires.append(fire21)

    damageTimer.start()

func _on_DamageTimer_timeout() -> void:
    _applyWeatherEffects(currentWeatherEvent)
    _incur_damage()

func _on_World_weather_event_changed(weatherEvent) -> void:
    _safe_assign_weather_event(weatherEvent)

func _applyWeatherEffects(weatherEvent: String) -> void:
    # Fire keeps on burning, until it's put out
    if (currentSpecialEvent == "fire_trees"):
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

    match weatherEvent:
        "sunny":
            if (weatherDamageAccumulators.fire > 1 and currentSpecialEvent == "fire_trees"):
                weatherDamageAccumulators.fire += 1
            # Hail goes away faster in sun
            if (currentSpecialEvent == "hail"):
                eventTimer -= 1
            weatherDamageAccumulators.rain -= 1
        "rainy":
            # replace rain with hail
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
                weatherDamageAccumulators.fire -= 5
            else:
                weatherDamageAccumulators.sun -= 1
                weatherDamageAccumulators.fire -= 4
        "windy":
            if (weatherDamageAccumulators.fire > 1 and currentSpecialEvent == "fire_trees"):
                weatherDamageAccumulators.fire += 1
            # hail + wind means more hail damage
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
        "snowy":
            # replace snow with hail
            if (currentSpecialEvent == "hail"):
                weatherDamageAccumulators.hail += 1
                weatherDamageAccumulators.fire -= 5
            else:
                weatherDamageAccumulators.sun -= 1
                weatherDamageAccumulators.fire -= 5
    
    # reset negative counters to 0
    for key in weatherDamageAccumulators:
        if (weatherDamageAccumulators[key] < 0):
            weatherDamageAccumulators[key] = 0

    if (currentSpecialEvent == "fire_trees" and weatherDamageAccumulators.fire <= 0):
        currentSpecialEvent = ""
        stop_fire()
        emit_signal("special_event_over")
    if (currentSpecialEvent == "hail" and eventTimer <= 0):
        currentSpecialEvent = ""
        eventTimer = 0
        emit_signal("special_event_over")

func _incur_damage() -> void:
    for key in weatherDamageAccumulators:
        if (weatherDamageAccumulators[key] > 20):
            weatherDamageAccumulators[key] -= 20
            damageLevel += 1
            global.score -= 1
            _apply_damage_effects()

func _apply_damage_effects():
    var treeToDamage: int = damageLevel -1
    if (global.isEndurance):
        global.plantsDestroyed += 1
    if (treeToDamage > trees.size() - 1):
        return
    
    if (treeToDamage < 5):
        trees[treeToDamage].set_texture(damagedTreeTextures[0])
        return
    if (treeToDamage > 4 and treeToDamage < 7):
        trees[treeToDamage].set_texture(damagedTreeTextures[1])
        return
    if (treeToDamage > 6 and treeToDamage < 9):
        trees[treeToDamage].set_texture(damagedTreeTextures[2])
        return
    if (treeToDamage > 8 and treeToDamage < 12):
        trees[treeToDamage].set_texture(damagedTreeTextures[3])
        return
    if (treeToDamage == 12):
        trees[treeToDamage].set_texture(damagedTreeTextures[4])
        return
    if (treeToDamage > 12):
        trees[treeToDamage].set_texture(damagedTreeTextures[5])
        return

func start_fire() -> void:
    weatherDamageAccumulators.fire = 2
    animationTimer.set_wait_time(0.2)
    animationTimer.start()

func stop_fire() -> void:
    animationTimer.stop()
    for fire in treeFires:
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
        "extreme_weather_over":
            currentExtremeWeatherEvent = ""
        "fire_trees":
            currentSpecialEvent = event
            start_fire()
        "fire_crops":
            return
        "hail":
            currentSpecialEvent = event
            eventTimer = 10


func _on_AnimationTimer_timeout() -> void:
    fireTextureAnimationFrame = fireTextureAnimationFrame + 1 if fireTextureAnimationFrame < 2 else 0
    var pos = 0
    for fire in treeFires:
        # this is a strange approach but it works so it's ok for now
        if (pos < 2):
            fire.set_texture(fireTextures1[fireTextureAnimationFrame])
        else:
            fire.set_texture(fireTextures2[fireTextureAnimationFrame])
        pos += 1
    pos = 0
