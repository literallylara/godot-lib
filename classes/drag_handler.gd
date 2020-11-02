extends Node
class_name DragHandler

enum Trigger { HOLD, TOGGLE }
enum State { IDLE, DRAGGING }

export var enabled : bool = true
export var target : NodePath
export var x_property : String
export var y_property : String
export var scale : Vector2 = Vector2(1,1)
export var action : String = "game_drag"
export(Trigger) var action_trigger = Trigger.HOLD

signal dragged
signal grabbed
signal dropped


var _state : int = State.IDLE

var _pos_start : Vector2
var _pos_current : Vector2
var _pos_diff : Vector2

var _prop_x_start : float
var _prop_y_start : float

func _input(event : InputEvent) -> void:

	if not enabled: return
	if not target: return
	if not has_node(target): return
	if not (x_property or y_property): return

	var node = get_node(target)

	_pos_current = Vector2(event.position) / get_viewport().size

	match(_state):

		State.IDLE:

			if action_trigger == Trigger.HOLD and event.is_action_pressed("game_drag")\
			or action_trigger == Trigger.TOGGLE and event.is_action_released("game_drag"):

				_state = State.DRAGGING
				_pos_start = _pos_current

				if x_property: _prop_x_start = node.get(x_property)
				if y_property: _prop_y_start = node.get(y_property)

				emit_signal("grabbed", _pos_start)

		State.DRAGGING:

			if event.is_action_released("game_drag"):

				emit_signal("dropped", _pos_current)

				_state = State.IDLE

			elif event is InputEventMouseMotion:

				_pos_diff = _pos_start - _pos_current

				node.set(x_property, _prop_x_start + _pos_diff.x * scale.x)
				node.set(y_property, _prop_y_start + _pos_diff.y * scale.y)

				emit_signal("dragged", _pos_diff)
