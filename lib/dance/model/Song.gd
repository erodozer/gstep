extends Reference

var title
var artist
var author
var parts = []
var bpm
var songfile
var bgfile
var offset

func get_stream():
	var ogg_file = File.new()
	ogg_file.open(songfile, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	ogg_file.close()
	return stream

func get_background():
	var image = ImageTexture.new()
	image.load(bgfile)
	return image
