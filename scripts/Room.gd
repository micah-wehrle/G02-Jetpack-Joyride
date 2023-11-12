extends StaticBody2D

var BASE_SPEED = 300;
var SPEED = BASE_SPEED;
var MAX_SPEED = 1000;

var log_accel = 1;
var log_accel_rate = 0.03;
var log_targ = exp(1);

var running = false;
var sliding = false;

var when_to_show_end = 0;
var show_end_delay = 500;

var game_over = false;

@onready var game_menu = $"../CanvasLayer/Menu";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_over:
		return;
	
	if running:
		var boost = 1; #mainly for dev purposes
		if Input.is_action_pressed("Shift"):
			boost = 5;
		
		# Thanks BJ!
		# He said this might be better, makes a flattened S:   y=1/(1+RATE^-x)
		# 0 -> 700
		log_accel = clamp(log_accel + log_accel_rate * delta, 1, log_targ);
		
		SPEED = BASE_SPEED + log(log_accel) * (MAX_SPEED-BASE_SPEED);
		
		position.x += SPEED*delta * boost;
	elif sliding:
		if SPEED > 0:
			position.x += SPEED * delta;
			SPEED *= 0.9;
			if SPEED < 10:
				SPEED = 0;
				when_to_show_end = Time.get_ticks_msec() + show_end_delay;
		else:
			if Time.get_ticks_msec() > when_to_show_end:
				# When the game is finally over!
				game_over = true;
				game_menu.set_game_over();
				#get_tree().reload_current_scene();
				
				pass;

func slow_down():
	running = false;
	sliding = true;
'''
Logb(x)=y
Where Logb is log base b and b>1, x is the level and x>0, y is the speed. 

At x=1, y=0.
At x=b, y=1

'''
