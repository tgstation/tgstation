/datum/component/hand_offset

/datum/component/hand_offset/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/offset)

/datum/component/hand_offset/proc/offset()
	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		for(var/I in C.overlays_standing[HANDS_LAYER])
			var/mutable_appearance/M = I
			M.pixel_x += 5
			switch(M.dir)
				if(NORTH)
					M.pixel_x = 32
					M.pixel_y = 53
				if(SOUTH)
					M.pixel_x = 38
					M.pixel_y = 38
			to_chat(parent, "[M.type]")


