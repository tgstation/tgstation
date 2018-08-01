/obj/item/implant/stealth
	name = "S3 implant"
	desc = "Allows you to be hidden in plain sight."
	actions_types = list(/datum/action/item_action/agent_box)

//Box Object

/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	use_mob_movespeed = TRUE

/obj/structure/closet/cardboard/agent/proc/go_invisible()
	animate(src, , alpha = 0, time = 5)
	START_PROCESSING(SSobj, src)

/obj/structure/closet/cardboard/agent/Initialize()
	. = ..()
	go_invisible()


/obj/structure/closet/cardboard/agent/open()
	. = ..()
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	animate(src, , alpha = alpha - 50, time = 3)

/obj/structure/closet/cardboard/agent/Move()
	. = ..()
	if(.)
		alpha = min(alpha + 5, 255)

/obj/structure/closet/cardboard/agent/Bump(atom/movable/A)
	. = ..()
	if(isliving(A))
		alpha = 255
