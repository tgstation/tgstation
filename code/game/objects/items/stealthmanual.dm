/datum/action/innate/agent_box
	name = "Deploy Box"
	desc = "Find inner peace, here, in the box."
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	background_icon_state = "bg_agent"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "deploy_box"
	var/cooldown = 0
	var/obj/structure/closet/cardboard/agent/box



/datum/action/innate/agent_box/Activate()
	if(!box)
		if(cooldown < world.time - 30)
			box = new(get_turf(owner))
			owner.forceMove(box)
			cooldown = world.time
	else
		owner.forceMove(get_turf(box))
		QDEL_NULL(box)
	playsound(box, 'sound/misc/box_deploy.ogg', 50, TRUE)


//Box Object

/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	move_speed_multiplier = 0.5

/obj/structure/closet/cardboard/agent/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/closet/cardboard/agent/open()
	. = ..()
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	alpha = max(0, alpha - 50)

/obj/structure/closet/cardboard/agent/Bump(atom/movable/A)
	. = ..()
	if(isliving(A))
		alpha = 255

obj/structure/closet/cardboard/agent/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()



