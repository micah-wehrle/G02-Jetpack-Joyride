extends Line2D
var trail_length = 100;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var last_time = -1;
var rate_mult = 100;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cur_time = Time.get_ticks_msec();
	
	if last_time != -1:
		var point = get_parent().position;
		var dif = cur_time-last_time;
		var steps = round(dif*delta*rate_mult);
		var next_point;
		for i in steps:
			next_point = point + Vector2(  steps/20*i, sin(    (last_time + (1/steps*i*dif)) /100   )*50   )   
			#get_parent().position += Vector2(20/steps,   sin( ((1/steps)*dif)/100)  *50   );
			add_point(next_point);
			#get_parent().position += Vector2(100/steps, sin(last_time/100 + dif * ((i+1)/steps) )*50 );
			#add_point(get_parent().position);
			pass;
		get_parent().position = next_point;
		#get_parent().position += Vector2(20, sin(last_time/100)*50);
		#add_point(get_parent().position);
	last_time = cur_time;
	pass
