extends Node

@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var asp: AudioStreamPlayer = $"../AudioStreamPlayer"
@export var speaker: Node3D

var scale_on: Vector3
var scale_off: Vector3
var target_scale: Vector3

func _ready():
	midi_player.loop = true
	midi_player.note.connect(my_note_callback)

	 # link the AudioStreamPlayer in your scene
	 # that contains the music associated with the midi
	 # NOTE: this must be an array, you can link multiple ASPs or one as 
	 # shown below and they will all sync with playback of the MIDI
	midi_player.link_audio_stream_player([asp])
	# this will also start the audio stream player (music)
	midi_player.play()
	
	scale_off = speaker.scale
	scale_on = speaker.scale * 1.5
	target_scale = scale_off
	
func _process(delta: float) -> void:
	speaker.scale = speaker.scale.lerp(target_scale, 0.1)

func my_note_callback(event, track):
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON):
		target_scale = scale_on
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF):
		target_scale = scale_off
	print(event)
	print("[Track: " + str(track) + "] Note played: " + str(event['note']))
