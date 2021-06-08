extends Reference

const LANES = preload("./Note.gd").LANES

var lanes = {
	LANES.DANCE_DOWN: 0,
	LANES.DANCE_LEFT: 0,
	LANES.DANCE_UP: 0,
	LANES.DANCE_RIGHT: 0
}

# precise time of when note appears in the song
var time = 0
# the beat position in the song
var beat = 0
# the bpm at the time this note is played
var bpm = 0
