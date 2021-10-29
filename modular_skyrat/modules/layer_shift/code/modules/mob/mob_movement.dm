#define MOB_LAYER_SHIFT_INCREMENT	0.01
#define MOB_LAYER_SHIFT_MIN 		3.95
//#define MOB_LAYER 				4   // This is a byond standard define
#define MOB_LAYER_SHIFT_MAX   		4.05

/mob/living/verb/layershift_up()
	set name = "Shift Layer Upwards"
	set category = "IC"

	if(incapacitated() || body_position == LYING_DOWN)
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return

	if(layer >= MOB_LAYER_SHIFT_MAX)
		to_chat(src, "<span class='warning'>You cannot increase your layer priority any further.</span>")
		return

	layer += MOB_LAYER_SHIFT_INCREMENT
	var/layer_priority = (layer - MOB_LAYER) * 100 // Just for text feedback
	to_chat(src, "<span class='notice'>Your layer priority is now [layer_priority].</span>")

/mob/living/verb/layershift_down()
	set name = "Shift Layer Downwards"
	set category = "IC"

	if(incapacitated() || body_position == LYING_DOWN)
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return

	if(layer <= MOB_LAYER_SHIFT_MIN)
		to_chat(src, "<span class='warning'>You cannot decrease your layer priority any further.</span>")
		return
	
	layer -= MOB_LAYER_SHIFT_INCREMENT
	var/layer_priority = (layer - MOB_LAYER) * 100 // Just for text feedback
	to_chat(src, "<span class='notice'>Your layer priority is now [layer_priority].</span>")
