extends Node
var voices := {}
var closing := false
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
		var voice := AudioStreamPlayer.new()
		voice.stream = sound
		voice.max_polyphony = 4
		add_child(voice)
		voices[kinds[i]] = voice
func play(kind: String) -> void:
	if closing or not voices.has(kind): return
	voices[kind].play()

func shutdown() -> void:
	if closing: return
	closing = true
	for voice in voices.values():
		voice.stop()
		voice.stream = null
	voices.clear()

func _exit_tree() -> void:
	shutdown()
