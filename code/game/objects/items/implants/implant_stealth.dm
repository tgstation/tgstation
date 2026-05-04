/obj/item/implant/stealth
	name = "S3 implant"
	desc = "Allows you to be hidden in plain sight."
	actions_types = list(/datum/action/item_action/agent_box)

	implant_info = "Activated manually. \
		Fabricates a horrifically fragile cardboard box around the user that has integrated gradual optical camouflage."

	implant_lore = "The Cybersun S3 Implant, colloquially the \"stealth\" implant, allows users to fabricate, \
		on the spot, a \"stealth\" box around them, which sacrifices most of its (miniscule) strength as a cardboard box \
		in order to support an optical camouflage weave. Unfortunately, the optical camouflage cannot instantly initialize; \
		bumping into living beings will disrupt the camouflage, and after disruption or upon initial activation, \
		the camouflage system has to recalibrate to its surroundings. However, once calibrated, it is invisible to the naked eye."

/obj/item/implanter/stealth
	name = "implanter (stealth)"
	imp_type = /obj/item/implant/stealth

//Box Object

/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	max_integrity = 1 // "This dumb box shouldn't take more than one hit to make it vanish."
	move_speed_multiplier = 0.5
	enable_door_overlay = FALSE

/obj/structure/closet/cardboard/agent/Initialize(mapload)
	. = ..()
	go_invisible()

/obj/structure/closet/cardboard/agent/proc/go_invisible()
	animate(src, alpha = 0, time = 20)

/obj/structure/closet/cardboard/agent/after_open(mob/living/user)
	. = ..()
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	alpha = max(0, alpha - 50)

/obj/structure/closet/cardboard/agent/proc/reveal()
	alpha = 255
	addtimer(CALLBACK(src, PROC_REF(go_invisible)), 10, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/structure/closet/cardboard/agent/Bump(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door))
		for(var/mob/mob_in_box in contents)
			A.Bumped(mob_in_box)
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/Bumped(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()
