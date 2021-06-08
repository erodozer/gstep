extends Object

const Part = preload("../model/Part.gd")
const Song = preload("../model/Song.gd")
const Measure = preload('../model/Measure.gd')
const Row = preload("../model/Row.gd")
const Note = preload("../model/Note.gd")

const note_mapping = {
	'L': Note.TYPES.LIFT,
	'M': Note.TYPES.MINE,
	'0': Note.TYPES.NONE,
	'1': Note.TYPES.REGULAR,
	'2': Note.TYPES.START_HOLD,
	'3': Note.TYPES.END_HOLD,
	'4': Note.TYPES.START_ROLL
}

static func parse(file):
	var song = Song.new()

	var f = File.new()
	f.open(file, File.READ)
	
	var buffer = ""
	var is_comment = false
	var bpms_set = []
	var stop_set = []
		
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var letter = char(f.get_8())
		
		if not is_comment and letter != ';':
			buffer += letter
		
			if "//" in buffer:
				is_comment = true
				buffer = ""
			
			continue
		
		if is_comment and letter in ['\n', '\r']:
			is_comment = false
			continue
		
		# end of line reached
		var parts = buffer.strip_escapes().split(":")
		
		match parts[0]:
			"#TITLE":
				song.title = parts[1]
			"#ARTIST":
				song.artist = parts[1]
			"#MUSIC":
				song.songfile = file.get_base_dir() + "\\" + parts[1]
			"#BACKGROUND":
				song.bgfile = file.get_base_dir() + "\\" + parts[1]
			"#OFFSET":
				song.offset = float(parts[1])
			"#BPMS":
				var bpms = parts[1].split(",")
				var time = 0
				for bpm in bpms:
					var rng = bpm.split("=")
					var start = float(rng[0])
					if len(bpms_set) > 0:
						var minutes = (start - bpms_set[-1].start) / bpms_set[-1].rate
						var duration = 60 * minutes
						time += duration
						
					var section = {
						"start": start, #beat
						"rate": float(rng[1]),
						"time": time # seconds
					}
					bpms_set.append(section)
					
					
			"#STOPS":
				var stops = parts[1].split(",")
				for stop in stops:
					var rng = stop.split("=")
					stop_set.append({
						"start": float(rng[0]),
						"duration": float(rng[1]),
					})
			"#NOTES":
				var part = Part.new()
				part.mode = parts[1].strip_edges()
				part.difficulty = parts[3].strip_edges()
				part.meter = parts[4].strip_edges()
				part.bpm = bpms_set
				
				var beat = 0
				var notes = parts[6].strip_edges()
				
				var measures = notes.split(",")
				
				for m in measures:
					var measure = Measure.new()
					for i in range(0, len(m), 4):
						var row = Row.new()
						row.lanes[Note.LANES.DANCE_LEFT] = note_mapping.get(m[i], Note.TYPES.NONE)
						row.lanes[Note.LANES.DANCE_DOWN] = note_mapping.get(m[i+1], Note.TYPES.NONE)
						row.lanes[Note.LANES.DANCE_UP] = note_mapping.get(m[i+2], Note.TYPES.NONE)
						row.lanes[Note.LANES.DANCE_RIGHT] = note_mapping.get(m[i+3], Note.TYPES.NONE)
						measure.rows.append(row)
					# stepmania format is always 4 beats per measure
					var step = 4.0 / len(measure.rows)
					for r in measure.rows:
						r.beat = beat
						beat += step
					part.measures.append(measure)
				part.beats = beat
				song.parts.append(part)
		buffer = ""
	f.close()

	for bpm in bpms_set:
		bpm.time += song.offset
	
	# calculate exact time of when notes appear (in seconds)
	for p in song.parts:
		for m in p.measures:
			for n in m.rows:
				var beat = n.beat
				var bpm = bpms_set[0]
				for b in bpms_set:
					if beat >= b.start:
						bpm = b
				var depth = beat - bpm.start
				var time = song.offset + bpm.time + ((1.0 / (bpm.rate / 60.0)) * depth)
				for s in stop_set:
					if beat >= s.start:
						time += s.duration
				n.time = time
				n.bpm = bpm
	return song
