/*An alternative to exit gateways, signposts send you back to somewhere safe onstation with their semiotic magic.*/
/obj/structure/signpost
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE
	var/question = "Travel back?"
	var/list/zlevels

/obj/structure/signpost/Initialize(mapload)
	. = ..()
	set_light(2)
	zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)

/obj/structure/signpost/interact(mob/user)
	. = ..()
	if(.)
		return
	if(tgui_alert(usr,question,name,list("Yes","No")) != "Yes" && !Adjacent(user))
		return

	var/turf/safe_dropoff = zlevels ? find_safe_turf(zlevels) : get_safe_random_station_turf_equal_weight()
	if(!safe_dropoff)
		to_chat(user, "Nothing happens. You feel that this is a bad sign.")
		return

	var/atom/movable/pulled = user.pulling
	user.forceMove(safe_dropoff)
	if(pulled)
		pulled.forceMove(safe_dropoff)
		user.start_pulling(pulled)
	to_chat(user, span_notice("You blink and find yourself in [get_area_name(safe_dropoff)]."))

/obj/structure/signpost/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	return interact(user)

/obj/structure/signpost/attack_paw(mob/user, list/modifiers)
	return interact(user)

/obj/structure/signpost/attack_hulk(mob/user)
	return

/obj/structure/signpost/attack_larva(mob/user, list/modifiers)
	return interact(user)

/obj/structure/signpost/attack_robot(mob/user)
	if (Adjacent(user))
		return interact(user)

/obj/structure/signpost/attack_animal(mob/user, list/modifiers)
	return interact(user)

/obj/structure/signpost/salvation
	name = "\proper salvation"
	desc = "In the darkest times, we will find our way home."
	resistance_flags = INDESTRUCTIBLE

/obj/structure/signpost/exit
	name = "exit"
	desc = "Make sure to bring all your belongings with you when you \
		exit the area."
	question = "Leave? You might never come back."

/obj/structure/signpost/exit/Initialize(mapload)
	. = ..()
	zlevels = list()
	for(var/i in 1 to world.maxz)
		zlevels += i
	zlevels -= SSmapping.levels_by_trait(ZTRAIT_CENTCOM) // no easy victory, even with meme signposts
	// also, could you think of the horror if they ended up in a holodeck
	// template or something
