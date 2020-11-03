tool
extends Camera
class_name OrbitalCamera

export var target : NodePath

var zoom_value : float = 0.50
var zoom_min : float = 0.25
var zoom_max : float = 1.00
var zoom_step : float = 100

var longitude_value : float = 0
var longitude_min : float = -180
var longitude_max : float = 180
var longitude_step : float = 100
var longitude_unrestricted : bool = true

var latitude_value : float = 0
var latitude_min : float = 0
var latitude_max : float = 90
var latitude_step : float = 100

var input_button_input : bool = true
var input_drag_input: bool = true
var input_drag_speed : float = 100
var input_action_left = "ui_left"
var input_action_right = "ui_right"
var input_action_up = "ui_up"
var input_action_down = "ui_down"
var input_action_drag = "ui_drag"
var input_action_zoom_in = "ui_zoom_in"
var input_action_zoom_out = "ui_zoom_out"

func _get_property_list():

	var properties = []

	#
	# ZOOM
	#

	properties.append(
	{
		name = "zoom",
		type = TYPE_NIL,
		hint_string = "zoom_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})

	properties.append(
	{
		name = "zoom_min",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1"
	})

	properties.append(
	{
		name = "zoom_max",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1"
	})

	properties.append(
	{
		name = "zoom_value",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,1"
	})

	properties.append(
	{
		name = "zoom_step",
		type = TYPE_REAL
	})

	#
	# longitude_value
	#

	properties.append(
	{
		name = "longitude",
		type = TYPE_NIL,
		hint_string = "longitude_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})

	properties.append(
	{
		name = "longitude_min",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-180,180"
	})

	properties.append(
	{
		name = "longitude_max",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-180,180"
	})

	properties.append(
	{
		name = "longitude_value",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-180,180"
	})

	properties.append({ name = "longitude_step", type = TYPE_REAL })
	properties.append({ name = "longitude_unrestricted", type = TYPE_BOOL })

	#
	# latitude_value
	#

	properties.append(
	{
		name = "latitude",
		type = TYPE_NIL,
		hint_string = "latitude_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})

	properties.append({
		name = "latitude_min",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-90,90"
	})

	properties.append({
		name = "latitude_max",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-90,90"
	})

	properties.append({
		name = "latitude_value",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-90,90"
	})

	properties.append(
	{
		name = "latitude_step",
		type = TYPE_REAL
	})

	#
	# Input
	#

	properties.append(
	{
		name = "input",
		type = TYPE_NIL,
		hint_string = "input_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})

	properties.append({ name = "input_button_input", type = TYPE_BOOL })
	properties.append({ name = "input_drag_input", type = TYPE_BOOL })
	properties.append({ name = "input_drag_speed", type = TYPE_REAL })
	properties.append({ name = "input_action_left", type = TYPE_STRING })
	properties.append({ name = "input_action_right", type = TYPE_STRING })
	properties.append({ name = "input_action_up", type = TYPE_STRING })
	properties.append({ name = "input_action_down", type = TYPE_STRING })
	properties.append({ name = "input_action_drag", type = TYPE_STRING })
	properties.append({ name = "input_action_zoom_in", type = TYPE_STRING })
	properties.append({ name = "input_action_zoom_out", type = TYPE_STRING })

	return properties

func _update() -> void:

	if not has_node(target): return

	var target_pos : Vector3 = get_node(target).global_transform.origin

	if longitude_unrestricted:

		longitude_value = fmod(longitude_value, 360)

	else:

		longitude_value = clamp(longitude_value, longitude_min, longitude_max)

	latitude_value = clamp(latitude_value, latitude_min, latitude_max)
	zoom_value = clamp(zoom_value, zoom_min, zoom_max)

	translation = target_pos

	var lng : float = deg2rad((longitude_value))
	var lat : float = deg2rad((90-latitude_value))

	translation += Vector3(
		sin(lat) * cos(lng),
		cos(lat),
		sin(lat) * sin(lng)
	) * zoom_value

	var dir : Vector3 = (target_pos-translation).normalized()

	if (abs(dir.dot(Vector3.UP)) == 1):

		translation += Vector3.RIGHT*1e-10

	look_at(target_pos, Vector3.UP)

func _ready() -> void:

	if input_drag_input:

		var drag_handler := DragHandler.new()

		drag_handler.target = self.get_path()
		drag_handler.x_property = "longitude_value"
		drag_handler.y_property = "latitude_value"
		drag_handler.scale = Vector2(1,1) * input_drag_speed
		drag_handler.action = input_action_drag

		add_child(drag_handler)

	_update()

func _process(delta) -> void:

	if not input_button_input: return

	var d : float = delta

	if Input.is_action_pressed(input_action_left):

		longitude_value += d * longitude_step

	elif Input.is_action_pressed(input_action_right):

		longitude_value -= d * longitude_step

	if Input.is_action_pressed(input_action_up):

		latitude_value += d * latitude_step

	elif Input.is_action_pressed(input_action_down):

		latitude_value -= d * latitude_step

	if Input.is_action_just_released(input_action_zoom_in):

		zoom_value -= d * zoom_step

	elif Input.is_action_just_released(input_action_zoom_out):

		zoom_value += d * zoom_step

	_update()
