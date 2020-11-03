extends Node
class_name DragHandler

enum Trigger { HOLD, TOGGLE }
enum State { IDLE, DRAGGING }

export var enabled : bool = true
export var target : NodePath
export var x_property : String
export var y_property : String
export var scale : Vector2 = Vector2(1,1)
export var action : String = "ui_drag"
export(Trigger) var action_trigger = Trigger.HOLD

signal dragged
signal grabbed
signal dropped

var _state : int = State.IDLE

var _pos_start : Vector2

var _prop_x_start : float
var _prop_y_start : float

func _input(event : InputEvent) -> void:

	if not enabled: return
	if not target: return
	if not has_node(target): return
	if not (x_property or y_property): return

	match(_state):

		State.IDLE:

			if action_trigger == Trigger.HOLD and event.is_action_pressed(action)\
			or action_trigger == Trigger.TOGGLE and event.is_action_released(action):

				var node := get_node(target)

				_state = State.DRAGGING
				_pos_start = Vector2(event.position) / get_viewport().size

				if x_property: _prop_x_start = node.get(x_property)
				if y_property: _prop_y_start = node.get(y_property)

				emit_signal("grabbed", _pos_start)

		State.DRAGGING:

			if event.is_action_released(action):

				var pos := Vector2(event.position) / get_viewport().size

				emit_signal("dropped", pos)

				_state = State.IDLE

			elif event is InputEventMouseMotion:

				var pos := Vector2(event.position) / get_viewport().size
				var diff := Vector2(event.position) / get_viewport().size - _pos_start
				var node := get_node(target)

				node.set(x_property, _prop_x_start + diff.x * scale.x)
				node.set(y_property, _prop_y_start + diff.y * scale.y)

				emit_signal("dragged", diff)
