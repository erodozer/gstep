extends Node

const Note = preload("./lib/dance/model/Note.gd")

export(String) var songfile

export var part = 0
var current_bpm = 0
var next_bpm = 0
var scroll_position = 0
var playback_position = 0
var offset = 0
var score = 0
var combo = 0
export var speed_scale = 3.0

onready var bgm = get_node("AudioStreamPlayer")

onready var time_display = get_node("UI/TIME")
onready var score_display = get_node("UI/Score")

signal add_note(note, beat)
signal song_loaded()
signal score_update(score, combo, accuracy)

# Called when the node enters the scene tree for the first time.
func _ready():
	var parser
	if songfile.ends_with('sm'):
		parser = load('./lib/dance/formats/sm.gd')
	else:
		return
		
	var song = parser.parse(songfile)

	# render notes
	part = song.parts[self.part]
	
	current_bpm = 0
	next_bpm = 1 if len(part.bpm) == 1 else 0
	
	# hold durations
	var hold = {}
	
	for measure in part.measures:
		# one measure of 1/4 notes should be readable with full note height spacing between each note
		# a single note is 48x48
		for row in measure.rows:
			var rot = 0
			for direction in [Note.LANES.DANCE_DOWN, Note.LANES.DANCE_LEFT, Note.LANES.DANCE_UP, Note.LANES.DANCE_RIGHT]:
				var note = row.lanes[direction]
				match note:
					Note.TYPES.REGULAR:
						var data = Note.new(
							direction,
							row.time,
							row.time
						)
						var skin = fmod(row.beat, 1.0)
						if skin == 0:
							skin = 4
						else:
							skin = int(4.0 / skin)
						emit_signal("add_note", data, skin)
						
					Note.TYPES.START_HOLD, Note.TYPES.START_ROLL:
						hold[direction] = {
							'time': row.time,
						}
						hold[direction] = {
							'time': row.time,
						}
					Note.TYPES.END_HOLD, Note.TYPES.END_ROLL:
						var data = Note.new(
							direction,
							hold[direction].time,
							row.time
						)
						
						var skin = fmod(row.beat, 1.0)
						if skin == 0:
							skin = 4
						else:
							skin = int(1.0 / skin)
							
						emit_signal("add_note", data, skin)
						
				rot += 90
	
	emit_signal("song_loaded")
	
	var bg = get_node("CanvasLayer/BG") as TextureRect
	bg.texture = song.get_background()
	
	# ready view
	$AnimationPlayer.play("Intro")
	yield($AnimationPlayer, "animation_finished")
	var stream = song.get_stream()
	bgm.stream = stream
	bgm.play()

func add_score(time, target):
	var dst = abs(target - time)
	var mult = 0
	var accuracy = "MISS"
	if dst > 0.225: # MISS
		combo = -1
	elif dst > 0.142: # BAD
		mult = 20
		combo = -1
		accuracy = "BAD"
	elif dst > 0.092: # GOOD
		mult = 80
		combo = -1
		accuracy = "GOOD"
	elif dst > 0.033: # GREAT
		mult = 150
		accuracy = "GREAT"
	elif dst > 0.0167: # PERFECT
		mult = 300
		accuracy = "PERFECT"
	else: #MARVELOUS
		mult = 500
		accuracy = "MARVELOUS"
	
	score += mult
	combo += 1
	
	emit_signal("score_update", score, combo, accuracy)
	
func _process(delta):
	var time = bgm.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	
	if time >= playback_position:
		playback_position = time
	
	time_display.text = "TIME %f - %f" % [playback_position, bgm.get_playback_position()]
	score_display.text = "%d" % score
