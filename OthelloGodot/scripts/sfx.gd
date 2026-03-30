class_name SFX
extends RefCounted

static func create_piece_place_sound() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.12
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)  # 16-bit = 2 bytes per sample

	for i in range(num_samples):
		var t := float(i) / sample_rate
		var envelope := exp(-t * 35.0)  # Fast decay

		# Low thud: mix of low frequencies
		var thud := sin(t * TAU * 180.0) * 0.6
		thud += sin(t * TAU * 90.0) * 0.3

		# Soft noise component for felt texture
		var noise := (randf() * 2.0 - 1.0) * 0.15
		# Filter noise by applying extra decay
		var noise_envelope := exp(-t * 50.0)

		var sample := (thud * envelope + noise * noise_envelope) * 0.7
		sample = clampf(sample, -1.0, 1.0)

		# Convert to 16-bit signed integer
		var value := int(sample * 32767.0)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
