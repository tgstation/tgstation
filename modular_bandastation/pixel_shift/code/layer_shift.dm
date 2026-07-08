#define MOB_LAYER_SHIFT_INCREMENT	0.01
#define MOB_LAYER_SHIFT_MIN 		3.95
//#define MOB_LAYER 				4   // This is a byond standard define
#define MOB_LAYER_SHIFT_MAX   		4.05

GAME_VERB(/mob/living, layershift_up, "Shift Layer Upwards", "Special")
	if(build_incapacitated())
		to_chat(src, span_warning("You can't do that right now!"))
		return

	if(layer >= MOB_LAYER_SHIFT_MAX)
		to_chat(src, span_warning("You cannot increase your layer priority any further."))
		return

	layer += MOB_LAYER_SHIFT_INCREMENT
	var/layer_priority = round((layer - MOB_LAYER) * 100, 1) // Just for text feedback
	to_chat(src, span_notice("Your layer priority is now [layer_priority]."))

GAME_VERB(/mob/living, layershift_down, "Shift Layer Downwards", "Special")
	if(build_incapacitated())
		to_chat(src, span_warning("You can't do that right now!"))
		return

	if(layer <= MOB_LAYER_SHIFT_MIN)
		to_chat(src, span_warning("You cannot decrease your layer priority any further."))
		return

	layer -= MOB_LAYER_SHIFT_INCREMENT
	var/layer_priority = round((layer - MOB_LAYER) * 100, 1) // Just for text feedback
	to_chat(src, span_notice("Your layer priority is now [layer_priority]."))
