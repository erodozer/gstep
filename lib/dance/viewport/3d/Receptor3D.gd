extends Node

onready var game = get_tree().get_nodes_in_group("game")[0]
onready var anim = get_node("AnimationPlayer")

export var key = "dance_down"
export(NodePath) var linked_lane

var note = null
var hold = false

onready var lane = get_node(linked_lane)

func _input(event):
	if event.is_action_pressed(key):
		anim.play("tap")
	
	if not self.note:
		return
	
	var note = self.note.get_meta("note")
	if event.is_action_pressed(key) and not note.played:
		if note.in_window(game.playback_position):
			if note.end_window > note.start_window:
				note.pressed = true
				hold = true
			else:
				note.played = game.playback_position
				game.add_score(note.played, note.start_window)
				self.note.visible = false
				anim.play("played")
	if event.is_action_released(key):
		hold = false
		if note.pressed:
			note.played = game.playback_position
			note.pressed = false

func _process(delta):
	if note == null:
		return
		
	var data = note.get_meta("note")
	
	if data.pressed and not data.played:
		game.score += 100 * delta
	
	if game.playback_position > data.start_window:
		if data.pressed == true:
			pass
		elif data.played <= 0:
			# note.modulate = Color(0.4, 0.4, 0.4, 0.6)
			game.add_score(data.played, data.start_window)
	
	if game.playback_position > data.end_window:
		if data.pressed == true:
			data.played = data.end_window
			game.score += 1000 # OK
		note = lane.get_child(note.get_index() + 1)
