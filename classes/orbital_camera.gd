extends Camera
class_name OrbitalCamera

export var target : NodePath

export var distance : float = 0.50
export var min_distance : float = 0.25
export var max_distance : float = 1.00

export var longitude : float = 0
export var min_longitude : float = -180
export var max_longitude : float = 180
export var unrestricted_longitude : bool = true

export var latitude : float = 0
export var min_latitude : float = 0
export var max_latitude : float = 90

export var speed : float = 100

func _update() -> void:

	if not has_node(target): return

	var target_pos : Vector3 = get_node(target).global_transform.origin

	if unrestricted_longitude:

		longitude = fmod(longitude, 360)

	else:

		longitude = clamp(longitude, min_longitude, max_longitude)

	latitude = clamp(latitude, min_latitude, max_latitude)
	distance = clamp(distance, min_distance, max_distance)

	translation = target_pos

	var lng : float = deg2rad((longitude))
	var lat : float = deg2rad((90-latitude))

	translation += Vector3(
		sin(lat) * cos(lng),
		cos(lat),
		sin(lat) * sin(lng)
	) * distance

	var dir : Vector3 = (target_pos-translation).normalized()

	if (abs(dir.dot(Vector3.UP)) == 1):

		translation += Vector3.RIGHT*1e-10

	look_at(target_pos, Vector3.UP)

func _ready() -> void:

	_update()

func _process(delta) -> void:

	var d : float = delta * speed

	if Input.is_action_pressed("ui_left"):

		longitude += d

	elif Input.is_action_pressed("ui_right"):

		longitude -= d

	if Input.is_action_pressed("ui_up"):

		latitude += d

	elif Input.is_action_pressed("ui_down"):

		latitude -= d

	if Input.is_action_just_released("ui_zoom_in"):

		distance -= d

	elif Input.is_action_just_released("ui_zoom_out"):

		distance += d

	_update()
