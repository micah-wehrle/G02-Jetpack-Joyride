extends CharacterBody2D

const THRUST_VEL = 3000;
const GRAV_MULT = 1.5;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_anim;
var backpack;
var default_anim_offset;
var default_backpack_offset;
var particle_gun;
var muzzle_flash;
@onready var sound_cloud = $"../Sound Cloud";

var flying = false;
var thrust_adj_var: float = 0.0;
var thrust_adj_targ: float = 10.0;
var thrust_adj_return_rate: float = 100.0;
var anim_shake_range = 2;

var backpack_bounce_size: float = 3.0 / 2;
var backpack_bounce_rate: float = 50;
var backpack_shift_size: float = 2.0 / 2;
var backpack_shift_rate: float = 100;

var running = false;
var alive = true;
var sliding = false;
@onready var room = $"..";
@onready var target_x = $"Player Shape".position.x; # From Player Shape
@onready var pregame_speed = room.SPEED;
@onready var obstacle_builder = $"../Obstacle Builder";

var death_velocity = 1000;
var death_spin = 100;
var max_death_vel = 100;
var bounces_left = 4;

func _ready():
	player_anim = $"Player Animation";
	backpack = $"Player Animation/Backpack";
	particle_gun = $"Player Animation/Backpack/Particle Gun";
	muzzle_flash = $"Player Animation/Backpack/Muzzle Flash";
	player_anim.play(); # starting on the ground
	default_backpack_offset = backpack.position;

func _physics_process(delta):
	if running:
		
		if alive:
			if is_on_floor() and flying:
				player_anim.play();
				flying = false;
				sound_cloud.running = true;
			
			if !is_on_floor() and !flying:
				player_anim.stop();
				player_anim.frame = 0;
				flying = true;
				backpack.position = default_backpack_offset;
				sound_cloud.running = false;
				
			
			if Input.is_action_pressed("Thrust"):
				velocity.y -= THRUST_VEL * delta;
				thrust_adj_var = thrust_adj_targ;
				player_anim.position = default_anim_offset + Vector2(randf_range(-anim_shake_range, anim_shake_range), randf_range(-anim_shake_range, anim_shake_range));
				particle_gun.shoot = true;
				if !muzzle_flash.is_playing():
					muzzle_flash.play();
				sound_cloud.shooting = true;
			else:
				muzzle_flash.stop();
				thrust_adj_var -= thrust_adj_return_rate * delta;
				player_anim.position = default_anim_offset;
				if is_on_floor():
					backpack.position.x = default_backpack_offset.x + sin(Time.get_ticks_msec() / backpack_shift_rate + 180)*backpack_shift_size;
					backpack.position.y = default_backpack_offset.y + sin(Time.get_ticks_msec() / backpack_bounce_rate)*backpack_bounce_size;
				particle_gun.shoot = false;
				sound_cloud.shooting = false;
			
			thrust_adj_var = clamp(thrust_adj_var, 0, thrust_adj_targ);
			player_anim.rotation_degrees = thrust_adj_var;
		else: # is dead
			if !sliding:
				player_anim.rotation_degrees += death_spin * delta;
				if is_on_floor():
					bounce();
		
		if !sliding:
			velocity.y += gravity * delta * GRAV_MULT;
			move_and_slide();
	
	elif running == false:
		player_anim.position.x += pregame_speed * delta;
		if player_anim.position.x >= target_x:
			player_anim.position.x = target_x;
			default_anim_offset = player_anim.position;
			running = true;
			room.running = true;
			obstacle_builder.running = true;

func kill_player():
	sound_cloud.running = false;
	sound_cloud.shooting = false;
	alive = false;
	flying = false;
	particle_gun.shoot = false;
	player_anim.stop();
	obstacle_builder.running = false;
	muzzle_flash.stop();
	$"Player Animation/Skull".visible = true;
	$"../../CanvasLayer/Menu".pause_lock = true;
	

func bounce():
	velocity.y -= death_velocity;
	death_velocity /= 2;
	bounces_left -= 1;
	if bounces_left == 0 or death_velocity <= max_death_vel:
		sliding = true;
		room.slow_down();
