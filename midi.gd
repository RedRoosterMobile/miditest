extends Node

@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var asp: AudioStreamPlayer = $"../AudioStreamPlayer"
@export var speaker: Node3D
@export var spawn_ball_scene:PackedScene

var scale_on: Vector3
var scale_off: Vector3
var target_scale: Vector3
var target_y_start: float
var target_y: float

# ball pool stuff
var ball_pool: Array[Node3D] = []
var active_balls: Array[Node3D] = []
@export var pool_size: int = 100
@export var spawn_distance: float = 3.5
@export var despawn_distance: float = 3.5
@export var move_speed: float = 5.5

func init_ball_pool():
	for i in pool_size:
		var ball: Node3D = spawn_ball_scene.instantiate()
		ball_pool.append(ball)
		# Add the ball to the scene but make it invisible initially
		add_child(ball)
		ball.visible = false

func spawn_ball(y:float = 0.0):
	if ball_pool.size() > 0:
		var ball = ball_pool.pop_back()
		ball.visible = true
		ball.position = Vector3(-spawn_distance, y, -spawn_distance)
		active_balls.append(ball)

func recycle_ball(ball: Node3D):
	ball.visible = false
	ball_pool.append(ball)
	active_balls.erase(ball)

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
	target_y_start = speaker.position.y
	target_y = speaker.position.y
	
	# create ball pool
	init_ball_pool()
	
func _process(delta: float) -> void:
	speaker.scale = speaker.scale.lerp(target_scale, 0.1)
	speaker.position.y = lerpf(speaker.position.y,target_y,0.1)
	
	# Update the position of active balls
	for ball in active_balls:
		
		#var direction = (speaker.global_transform.origin - ball.global_transform.origin).normalized()
		var direction = Vector3.FORWARD
		ball.position.x += 1 * move_speed * delta

		# Check if the ball is behind the speaker and recycle it
		#if (ball.global_transform.origin - speaker.global_transform.origin).z > despawn_distance:
		#if (ball.global_transform.origin).z > despawn_distance:
		if (ball.position).x > despawn_distance:
			recycle_ball(ball)

	# Optionally, spawn a ball at intervals or based on some trigger
	if Input.is_action_just_pressed("spawn_ball"):
		spawn_ball()
#@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"

func my_note_callback(event:Variant, track:int):
	
	var spawn:bool = false
	if (event['subtype'] == MIDI_MESSAGE_NOTE_ON):
		target_scale = scale_on
		spawn = true
	elif (event['subtype'] == MIDI_MESSAGE_NOTE_OFF):
		target_scale = scale_off
	
	var pitch:int = event['note']
	target_y =  pitch/10.0 - 5.0
	if spawn:
		spawn_ball(target_y)
	
	var red:float = clampf((event['note']+120.0  )/255.0,0,255.0)
	
	#print(red)
	#var surface: StandardMaterial3D = mesh_instance_3d.get_active_material(0)
	#surface.albedo_color = Color(red, 0, 0, 1)
	
	
	
	#print(event)
	# print("[Track: " + str(track) + "] Note played: " + str(event['note']))
