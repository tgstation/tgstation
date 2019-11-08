/obj/item/holobed_projector
	name = "holobed projector"
	desc = "Projects a roller bed formed from hard light."
	var/obj/structure/bed/holobed/loaded = null
	var/projecting = FALSE
	var/holo_range = 4


/obj/item/holobed_projector/examine(mob/user)
	. = ..()
	. += "[src] is [projecting ? "projecting" : "isn't projecting"]."


/obj/item/holobed_projector/emp_act(severity)
	. = ..()
	if(!severity) //Even a love tap shorts out the bed.
		return
	loaded.visible_message("<span class='warning'>[loaded] suddenly flickers and vanishes!</span>")
	qdel(loaded)


/obj/item/holobed_projector/proc/project_holobed(mob/user, atom/location)

	projecting = !projecting //toggle the projection

	if(!projecting)
		qdel(loaded)
		loaded.visible_message("<span class='notice'>[src] flickers and vanishes as you stop projecting it.</span>")
		return

	if(!loaded)
		loaded = new(src)
		loaded.projector = src
	else
		loaded.visible_message("<span class='warning'>[src] suddenly flickers and vanishes!</span>")

	loaded.forceMove(location)
	user.visible_message("<span class='notice'>[user] projects [loaded].</span>", "<span class='notice'>You project [loaded].</span>")





/obj/item/holobed_projector/robot //cyborg version
	name = "integrated holobed projector"
	desc = "Projects a roller bed formed from hard light."



/obj/structure/bed/holobed
	name = "holo bed"
	desc = "A bed formed from projected hard light. Looks surprisingly comfortable."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = FALSE
	buildstacktype = null
	buildstackamount = 0
	bolts = FALSE
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FREEZE_PROOF | UNACIDABLE | FIRE_PROOF | LAVA_PROOF //It's basically indestructible except for EMPs.
	var/obj/item/holobed_projector/projector = null

/obj/structure/bed/holobed/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		to_chat("<span class='notice'>You can't dismantle this! It's made of hard light!</span>")
		return
	else
		return ..()

/obj/structure/bed/holobed/Moved()
	. = ..()
	if(validate_location()) //Check if we're out of projection range
		return
	visible_message("<span class='warning'>[src] suddenly flickers and vanishes!</span>")
	qdel(src)


/obj/structure/bed/holobed/post_buckle_mob(mob/living/M)
	icon_state = "up"


/obj/structure/bed/holobed/proc/validate_location()
	if(!projector) //nothing projecting the bed so auto-fail
		return FALSE
	var/turf/T = get_turf(projector)
	if(T.z == z && get_dist(T, src) <= projector.holo_range)
		return TRUE
	else
		return FALSE

