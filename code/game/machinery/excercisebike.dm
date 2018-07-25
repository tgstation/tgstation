#define RESEARCH_MODE 0
#define POWER_MODE 1

/obj/machinery/power/excercise_bike
	name = "Excercise bike"
	desc = "The new NT 4FA5 AS5 excercise bike allows you to power the station through your excercise: <I> buckle into it and then move around whilst riding it to generate power</I>. You can also use a crowbar on it to contribute to the research network instead."
	icon = 'icons/obj/machines/excercise_bike.dmi'
	icon_state = "bike-off"
	can_buckle = TRUE
	max_buckled_mobs = 1
	var/power = 200 //How many watts are generated per pedal turn
	var/nerdpoints = 5 //How much research it makes per pedal turn
	var/delay = 12 //Delay to avoid ultraspam
	var/cooldown_time = 0
	anchored = TRUE
	can_be_unanchored = TRUE
	buckle_lying = 0
	circuit = /obj/item/circuitboard/machine/excercise_bike
	var/datum/techweb/linked_techweb
	var/mode = POWER_MODE

/obj/machinery/power/excercise_bike/examine(mob/user)
	. = ..()
	if(powernet)
		to_chat(user, "<span_class='warning'>It's connected to a powernet</span>")
	else
		to_chat(user, "<span_class='warning'>It's not connected to a powernet, and will not generate power.</span>")

/obj/machinery/power/excercise_bike/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W, time = 20))
		powernet = null
		return
	if(istype(W, /obj/item/crowbar))
		to_chat(user, "<span class='notice'>You begin tweaking [src]'s settings..</span>")
		if(W.use_tool(src, user, 20, volume=100))
			switch(mode)
				if(RESEARCH_MODE)
					to_chat(user, "[src] will now contribute to the station's powernet")
					mode = POWER_MODE
					return
				if(POWER_MODE)
					to_chat(user, "[src] will now contribute to the station's research network")
					mode = RESEARCH_MODE
					return
	return ..()

/obj/machinery/power/excercise_bike/RefreshParts()
	power = 0
	nerdpoints = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power += C.rating*200 //Make it actually viable with better parts
		nerdpoints += 5*C.rating

/obj/machinery/power/excercise_bike/relaymove(mob/user, direction)
	user.setDir(dir)
	if(!linked_techweb)
		linked_techweb = SSresearch.science_tech
	if(!powernet || !anchored)
		connect_to_network()
		to_chat(user, "The wheels on [src] lock up, is it connected to a power source?")
		return
	if(isliving(user))
		if(world.time >= cooldown_time+delay)
			var/mob/living/L = user
			if(!L.has_trait(TRAIT_NOHUNGER))
				if(L.nutrition <= NUTRITION_LEVEL_STARVING)
					to_chat(user, "<span_class='warning'>You're too famished to pedal any more!</span>")
					return
				L.nutrition -= HUNGER_FACTOR //It's tiring work, this is 10* more tiring than running
			icon_state = "bike-on"
			cooldown_time = world.time
			playsound(loc, 'sound/effects/bikepedal.ogg', 20, 1)
			L.apply_status_effect(STATUS_EFFECT_EXERCISED)
			switch(mode)
				if(RESEARCH_MODE)
					linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min(nerdpoints, 1))
					return
				if(POWER_MODE)
					add_avail(power)
					return

/obj/machinery/power/excercise_bike/buckle_mob(mob/living/M, force = 0, check_loc = 1)
	M.pixel_y = 5
	. = ..()

/obj/machinery/power/excercise_bike/unbuckle_mob(mob/living/buckled_mob,force = 0)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
	icon_state = initial(icon_state)
	. = ..()