#define ASH_CATCHER_INTACT 0 //No ash caught.
#define ASH_CATCHER_STRESSED 150 //The goliath hide is starting to buckle, but is still holding.
#define ASH_CATCHER_COLLAPSING 300 //The hide can't hold much more before it falls apart.
#define ASH_CATCHER_COLLAPSE 400 //The whole thing collapses!

//Ash catchers are goliath-hide tarps that allow for expansion into lavaland without worrying about ash storms.
//They accumulate ash over time and must be periodically shaken out.
//If the catchers are too heavy and collect too much ash, they will collapse and allow ash storms through.
/obj/structure/ash_catcher
	name = "ash catcher"
	desc = "A sheet of goliath's hide stretched over four metal rods."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ash_catcher_intact"
	layer = ABOVE_ALL_MOB_LAYER
	obj_integrity = 50
	max_integrity = 50
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/ash_caught = 0 //How much ash we're holding

/obj/structure/ash_catcher/examine(mob/user)
	..()
	user << "<span class='notice'>Interact on Help intent to clear out the ash, and Disarm intent to tear it down.</span>"

/obj/structure/ash_catcher/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/structure/ash_catcher/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/ash_catcher/process()
	handle_ash()
	for(var/datum/weather/ash_storm/A in SSweather.processing) //Yes, even emberfall!
		adjust_ash(1)

/obj/structure/ash_catcher/proc/adjust_ash(amt) //Adds or removes ash from catcher.
	ash_caught = min(max(0, ash_caught + amt), ASH_CATCHER_COLLAPSE)

/obj/structure/ash_catcher/proc/handle_ash() //Handles sprites, names, and descpritions for ash thresholds.
	switch(ash_caught)
		if(ASH_CATCHER_INTACT to ASH_CATCHER_STRESSED)
			name = initial(name)
			desc = initial(desc)
			icon_state = initial(icon_state)
		if(ASH_CATCHER_STRESSED to ASH_CATCHER_COLLAPSING)
			name = "stressed ash catcher"
			desc = "A sheet of goliath's hide stretched over four metal rods. It's starting to buckle under the weight."
			icon_state = "ash_catcher_stressed"
		if(ASH_CATCHER_COLLAPSING to ASH_CATCHER_COLLAPSE)
			name = "collapsing ash catcher"
			desc = "A sheet of goliath's hide stretched over four metal rods. <span class='warning'>It's falling apart under the weight!</span>"
			icon_state = "ash_catcher_collapsing"
		if(ASH_CATCHER_COLLAPSE)
			visible_message("<span class='warning'>[src] collapses under the weight of the ash!</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			qdel(src)

/obj/structure/ash_catcher/attack_hand(mob/living/user)
	if(user.a_intent == "help")
		user.visible_message("<span class='notice'>[user] starts clearing the ash out of [src]...</span>", "<span class='notice'>You start clearing [src]'s caught ash...</span>")
		playsound(user, 'sound/effects/shovel_dig.ogg', 50, 1)
		if(!do_after(user, 50, target = src))
			return
		user.visible_message("<span class='notice'>[user] clears out [src]!</span>", "<span class='notice'>You clear out the ash.</span>")
		playsound(user, 'sound/effects/shovel_dig.ogg', 50, 1)
		adjust_ash(ash_caught)
		handle_ash()
		return 1
	else if(user.a_intent == "disarm")
		user.visible_message("<span class='notice'>[user] starts tearing down [src]...</span>", "<span class='notice'>You start tearing down [src]...</span>")
		playsound(user, 'sound/effects/shovel_dig.ogg', 50, 1)
		if(!do_after(user, 75, target = src))
			return
		user.visible_message("<span class='notice'>[user] tears down [src]!</span>", "<span class='notice'>You tear down and fold up [src].</span>")
		playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)
		new/obj/item/ash_catcher(get_turf(src))
		qdel(src)
		return 1
	else
		return ..()

/obj/item/ash_catcher
	name = "ash catcher"
	desc = "Four metal rods with a sheet of goliath hide stretched over them. Used to expand into the wastes and provide mobile shelter."
	icon = 'icons/obj/items.dmi'
	icon_state = "bacon_fork"
	force = 8 //Heavy enough to make a passable weapon!
	w_class = 5
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	throw_range = 1
	throw_speed = 1

/obj/item/ash_catcher/attack_self(mob/living/user)
	var/turf/open/floor/plating/asteroid/basalt/lava_land_surface/L = get_turf(user)
	if(!istype(L))
		user << "<span class='warning'>You can't set up [src] here!</span>"
		return
	user.visible_message("<span class='notice'>[user] starts setting up [src]...</span>", "<span class='notice'>You start driving the spikes into the earth...</span>")
	playsound(user, 'sound/effects/break_stone.ogg', 50, 1)
	if(!do_after(user, 75, target = user))
		return
	user.visible_message("<span class='notice'>[user] sets up [src]!</span>", "<span class='notice'>You set up [src]!</span>")
	playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)
	new/obj/structure/ash_catcher(get_turf(src))
	user.drop_item()
	qdel(src)
	return 1
