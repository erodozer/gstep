extends Node

const Note = preload("../../model/Note.gd")
const NoteSprite = preload("./Note.tscn")

const SKIN = {
	4: preload("res://assets/noteskins/dance/default/4.tres"),
	8: preload("res://assets/noteskins/dance/default/8.tres"),
	12: preload("res://assets/noteskins/dance/default/12.tres"),
	16: preload("res://assets/noteskins/dance/default/16.tres"),
	24: preload("res://assets/noteskins/dance/default/24.tres"),
	32: preload("res://assets/noteskins/dance/default/32.tres"),
	48: preload("res://assets/noteskins/dance/default/48.tres"),
	64: preload("res://assets/noteskins/dance/default/64.tres"),
}

onready var lanes = {
	Note.LANES.DANCE_LEFT: get_node("Board/Left"),
	Note.LANES.DANCE_DOWN: get_node("Board/Down"),
	Note.LANES.DANCE_UP: get_node("Board/Up"),
	Note.LANES.DANCE_RIGHT: get_node("Board/Right")
}

onready var receptors = {
	Note.LANES.DANCE_LEFT: get_node("Camera2D/Input/Left"),
	Note.LANES.DANCE_DOWN: get_node("Camera2D/Input/Down"),
	Note.LANES.DANCE_UP: get_node("Camera2D/Input/Up"),
	Note.LANES.DANCE_RIGHT: get_node("Camera2D/Input/Right")
}

const ROTATIONS = {
	Note.LANES.DANCE_LEFT: 90,
	Note.LANES.DANCE_DOWN: 0,
	Note.LANES.DANCE_UP: 180,
	Note.LANES.DANCE_RIGHT: -90
}

const PIXEL_SCALE = 192.0

onready var camera = get_node("Camera2D")

onready var game = get_tree().get_nodes_in_group("game")[0]

var speed_scale = 3.0

func add_note(data, beat):
	var n = NoteSprite.instance()
	n.position.y = data.start_window * PIXEL_SCALE * speed_scale
	if data.end_window > data.start_window:
		n.get_node("Tail").rect_size.y = data.duration * PIXEL_SCALE * speed_scale
	else:
		n.get_node("Tail").queue_free()
	n.get_node("Note").rect_rotation = ROTATIONS[data.lane]
	n.get_node("Note").texture = SKIN.get(beat, SKIN[4])
	n.set_meta("note", data)
	
	lanes[data.lane].add_child(n)

func song_loaded():
	for direction in lanes.keys():
		var note = lanes[direction].get_child(0)
		receptors[direction].note = note

func _process(delta):
	camera.position.y = game.playback_position * PIXEL_SCALE * speed_scale
	
func score_update(score, combo, accuracy):
	pass # Replace with function body.
