extends Node
var streams := {}
func _ready() -> void:
	var kinds := ["jump","land","red","blue","invalid","teleport","death","checkpoint","stomp","win"]
	for i in kinds.size():
		var sound := AudioStreamWAV.new()
		sound.format = AudioStreamWAV.FORMAT_16_BITS
		sound.mix_rate = 22050
		var data := PackedByteArray()
		var duration := 0.22 if kinds[i] in ["death","win","teleport"] else 0.09
		var count := int(22050 * duration)
		data.resize(count * 2)
		for sample in count:
			var t := float(sample) / 22050
			var hz := 180 + i * 65
			var amplitude := sin(TAU * (hz * t + (350 if kinds[i] == "win" else -80) * t * t)) * 0.16 * pow(1.0 - float(sample) / count, 2)
			data.encode_s16(sample * 2, int(amplitude * 32767))
		sound.data = data
		streams[kinds[i]] = sound
func play(kind: String) -> void:
	if not streams.has(kind): return
	var voice := AudioStreamPlayer.new()
	voice.stream = streams[kind]
	add_child(voice)
	voice.finished.connect(voice.queue_free)
	voice.play()

func _exit_tree() -> void:
	for voice in get_children():
		if voice is AudioStreamPlayer:
			voice.stop()
