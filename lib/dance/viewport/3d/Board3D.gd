extends Node

const Note = preload("../../model/Note.gd")
const Note3D = preload("./Note3D.tscn")

onready var lanes = {
	Note.LANES.DANCE_LEFT: get_node("Board/Left"),
	Note.LANES.DANCE_DOWN: get_node("Board/Down"),
	Note.LANES.DANCE_UP: get_node("Board/Up"),
	Note.LANES.DANCE_RIGHT: get_node("Board/Right")
}

onready var receptors = {
	Note.LANES.DANCE_LEFT: get_node("Camera/Input/Left"),
	Note.LANES.DANCE_DOWN: get_node("Camera/Input/Down"),
	Note.LANES.DANCE_UP: get_node("Camera/Input/Up"),
	Note.LANES.DANCE_RIGHT: get_node("Camera/Input/Right")
}

const ROTATIONS = {
	Note.LANES.DANCE_LEFT: -90,
	Note.LANES.DANCE_DOWN: 0,
	Note.LANES.DANCE_UP: 180,
	Note.LANES.DANCE_RIGHT: 90
}

const UV_SKIN = {
	4: 0.0,
	8: 1.0,
	12: 2.0,
	16: 3.0,
	24: 4.0,
	32: 5.0,
	48: 6.0,
	64: 7.0,
}

const UNIT_SCALE = 4.0

var speed_scale = 1.0

onready var camera = get_node("Camera")

onready var game = get_tree().get_nodes_in_group("game")[0]
onready var accuracy_display = get_node("Viewport/Control/Accuracy")
onready var combo_display = get_node("Viewport/Control/Combo")

func add_note(data, beat):
	var n = Note3D.instance()
	n.translation.y = -data.start_window * UNIT_SCALE * speed_scale
	if data.end_window > data.start_window:
		n.get_node("Tail/Body").scale.y = data.duration * speed_scale * UNIT_SCALE / 2.0
		n.get_node("Tail/Body").translation.y = n.get_node("Tail/Body").scale.y / -2.0
		n.get_node("Tail/End").translation.y = -(n.get_node("Tail/Body").scale.y + 0.25)
		n.get_node("Tail").visible = true
	else:
		n.get_node("Tail").queue_free()
	n.get_node("Note").rotation_degrees.z = ROTATIONS[data.lane]
	var material = n.get_node("Note").get_active_material(0)
	material.set_shader_param("beat", UV_SKIN.get(beat, UV_SKIN[4]))
	n.set_meta("note", data)
	
	lanes[data.lane].add_child(n)
	
func song_loaded():
	for direction in lanes.keys():
		var note = lanes[direction].get_child(0)
		receptors[direction].note = note

func _process(delta):
	camera.translation.y = -game.playback_position * UNIT_SCALE * speed_scale

func score_update(score, combo, accuracy):
	accuracy_display.text = accuracy
	if combo > 0:
		combo_display.text = "%d COMBO" % combo
	else:
		combo_display.text = ""
