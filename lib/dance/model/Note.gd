extends Reference

enum TYPES {
	NONE, 
	REGULAR, 
	START_HOLD, 
	END_HOLD, 
	START_ROLL, 
	END_ROLL, 
	LIFT, 
	MINE
}

enum LANES {
	DANCE_LEFT,
	DANCE_RIGHT,
	DANCE_UP,
	DANCE_DOWN,
}

const WINDOW = 0.25

export(LANES) var lane = LANES.DANCE_LEFT
export(float, 0.0) var start_window = 0
export(float, 0.0) var end_window = 0
var pressed = false
var played = 0
var duration setget ,get_duration

func _init(l, s, e):
	self.lane = l
	self.start_window = s
	self.end_window = e
	
func in_window(time):
	return start_window - WINDOW <= time and start_window + WINDOW >= time

func get_duration():
	return self.end_window - self.start_window
