extends Sprite2D

var floor_object;
var anim;

var vel_dir;
var speed = 2000;
var flying = true;
var frame_data;

# Called when the node enters the scene tree for the first time.
func _ready():
	if !floor_object:
		floor_object = $"../Room/Floor";
	vel_dir = Vector2(sin(-rotation), cos(rotation)) * speed;;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flying:
		global_position = global_position - vel_dir * delta;
		if global_position.y > floor_object.global_position.y:
			flying = false;
			
			texture = null;
			
			anim = AnimatedSprite2D.new();
			anim.scale = Vector2(3,-1.5);
			anim.global_position.y = floor_object.global_position.y;
			anim.sprite_frames = frame_data;
			anim.z_index = 2;
			anim.play();
			add_child(anim);
	elif anim.frame == 14:
		anim.queue_free();
		queue_free();
		
	pass
