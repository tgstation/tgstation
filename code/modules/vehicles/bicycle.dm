/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	max_integrity = 150
	integrity_failure = 0.5
	var/fried = FALSE

/obj/vehicle/ridden/bicycle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/bicycle)

/obj/vehicle/ridden/bicycle/zap_act(power, zap_flags) // :::^^^)))
	//This didn't work for 3 years because none ever tested it I hate life
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	fried = TRUE
	. = ..()
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)

/obj/vehicle/ridden/bicycle/welder_act(mob/living/user, obj/item/I)
	if(fried)
		balloon_alert(user, "it's fried!")
		return TRUE
	if(atom_integrity >= max_integrity)
		return TRUE
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	atom_integrity += min(10, max_integrity-atom_integrity)
	if(atom_integrity == max_integrity)
		balloon_alert(user, "fully repaired")
	else
		balloon_alert(user, "repaired some damages")
	return TRUE
