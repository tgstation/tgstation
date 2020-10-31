/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	fall_off_if_missing_arms = TRUE

/obj/vehicle/ridden/bicycle/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/bicycle)

/obj/vehicle/ridden/bicycle/zap_act(power, zap_flags) // :::^^^)))
	//This didn't work for 3 years because none ever tested it I hate life
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	. = ..()
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
