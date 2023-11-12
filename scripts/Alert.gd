extends Node2D

@onready var scene = $"../../Obstacle Parent";
@onready var excl = $Exclamation;
@onready var back_spike = $Spike1;
@onready var front_spike = $Spike2;
@onready var player = $"../CharacterBody2D";
@onready var sound_cloud = $"../Sound Cloud";
@onready var alert_arrow = $"Alert Arrow";

@onready var missile_texture = load("res://img/missile1.png");
@onready var missile_script = load("res://scripts/Missile.gd");
@onready var smoke_trail = load("res://scene items/smoke emitter.tscn");

var excl_scale;
var bs_scale;
var fs_scale;

var excl_wiggle_speed = 0.01;
var excl_wiggle_size = 10;
var excl_pulse_speed = 0.007;
var excl_pulse_size = 0.02

var bs_speed = 0.01;
var fs_speed = 0.07;
var bs_pulse_size = 0.2;
var fs_pulse_size = 0.2;
var bs_pulse_speed = 0.005;
var fs_pulse_speed = 0.005;

@onready var alert_arrow_start = alert_arrow.position.x;
var alert_arrow_speed = 0.005;
var alert_arrow_size = 20;

var pursuit_speed = 100;
var pursuit_range = 450;

var missile_inbound: bool = false;
var alert_started = 0;

var alert_delay = 5000;

var missile_counting = false;
var next_missile_beep = 0;
var missile_beeps_data = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false;
	
	excl_scale = excl.scale;
	bs_scale = back_spike.scale;
	fs_scale = front_spike.scale;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		
		# Move alert in a fancy way
		excl.rotation_degrees = sin(Time.get_ticks_msec() * excl_wiggle_speed) * excl_wiggle_size;
		excl.scale = excl_scale + Vector2(1,1) * excl_pulse_size * sin(Time.get_ticks_msec() * excl_pulse_speed);
		back_spike.rotation_degrees = Time.get_ticks_msec() * bs_speed;
		front_spike.rotation_degrees = -Time.get_ticks_msec() * fs_speed;
		back_spike.scale = bs_scale + Vector2(1,1) * bs_pulse_size * abs(sin(Time.get_ticks_msec() * bs_pulse_speed + 11));
		front_spike.scale = fs_scale + Vector2(1,1) * fs_pulse_size * abs(sin(Time.get_ticks_msec() * fs_pulse_speed + 23));
		alert_arrow.position.x = alert_arrow_start + alert_arrow_size * abs(sin(Time.get_ticks_msec() * alert_arrow_speed));
		
		if !missile_inbound:
			# Make alert follow after the player
			var speed = pursuit_speed * delta * ((global_position.y - player.global_position.y) / pursuit_range);
			global_position.y -= speed;
			
			if Time.get_ticks_msec() > next_missile_beep:
				var beeps_data = missile_beeps_data.pop_front();
				sound_cloud.call(beeps_data[1]);
				next_missile_beep = beeps_data[0] + Time.get_ticks_msec();
				
				if missile_beeps_data.size() == 0:
					create_missile();
					visible = false;
					pass;

func send_missile():
	if visible or missile_inbound:
		return false;
	visible = true;
	
	next_missile_beep = 0; # this value is the time to the FIRST beep
	missile_beeps_data = [ # time to next beep, current beep sound
		[500, "play_alert1"],
		[500, "play_alert1"],
		[500, "play_alert1"],
		[500, "play_alert1"],
		[100, "play_alert2"],
		[0, "play_launch"]
	];
	
	alert_started = Time.get_ticks_msec();
	return true;

var missile_count = 0;

func create_missile():
	missile_count += 1;
	
	var missile = Area2D.new();
	scene.add_child(missile);
	missile.global_position = global_position + Vector2(125,0);
	missile.name = 'missile ' + str(missile_count);
	missile.set_collision_mask_value(1, false);
	missile.set_collision_mask_value(2, true);
	missile.set_collision_layer_value(1, false);
	missile.set_collision_layer_value(2, true);
	missile.set_script(missile_script);
	
	var col = CollisionShape2D.new();
	missile.add_child(col);
	col.global_position = missile.global_position - Vector2(90,0);
	col.shape = RectangleShape2D.new();
	col.shape.size = Vector2(70, 27);
	
	var img = Sprite2D.new();
	missile.add_child(img);
	img.global_position = missile.global_position - Vector2(90,0);
	img.texture = missile_texture;
	img.scale = Vector2(0.1,0.1);
	
	var trail = smoke_trail.instantiate();
	missile.add_child(trail);
	trail.position = Vector2(0,0);
	
	#missile.sprite_child = img;
	missile._ready();
	missile.set_process(true);
	
	
