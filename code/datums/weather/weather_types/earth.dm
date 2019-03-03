/datum/weather/earth
	name = "rain"
	desc = "Water falls from the sky, wetting everything that can be wetted."

	telegraph_message = "<span class='boldwarning'>Clouds are on the horizon, it'll be raining soon.</span>"
	telegraph_duration = 300
	telegraph_overlay = "rain_start"

	weather_message = "<span class='boldannounce'><i>It starts pouring down the rain!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "acid_rain"

	end_message = "<span class='boldannounce'>The sun shines through ending the rain.</span>"
	end_duration = 300
	end_overlay = ""

	area_type = /area/lavaland/surface/outdoors
	target_trait = ZTRAIT_STATION

	probability = 60

	barometer_predictable = TRUE

/datum/weather/earth/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)


/datum/weather/earth/weather_act(atom/A)
	if(istype(A,/obj/effect/decal/cleanable))
		del(A) //wash the blood away.
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = A
		H.adjustWater(5)
	if(istype(A,/mob/living))
		var/mob/living/L = A
		if(istype(A,/mob/living/carbon/human))
			L.adjust_bodytemperature(-rand(8,10))
		SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
		L.wash_cream()
		L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		if(iscarbon(L))
			var/mob/living/carbon/M = L
			. = TRUE

			for(var/obj/item/I in M.held_items)
				wash_obj(I)

			if(M.back && wash_obj(M.back))
				M.update_inv_back(0)

			var/list/obscured = M.check_obscured_slots()

			if(M.head && wash_obj(M.head))
				M.update_inv_head()

			if(M.glasses && !(SLOT_GLASSES in obscured) && wash_obj(M.glasses))
				M.update_inv_glasses()

			if(M.wear_mask && !(SLOT_WEAR_MASK in obscured) && wash_obj(M.wear_mask))
				M.update_inv_wear_mask()

			if(M.ears && !(HIDEEARS in obscured) && wash_obj(M.ears))
				M.update_inv_ears()

			if(M.wear_neck && !(SLOT_NECK in obscured) && wash_obj(M.wear_neck))
				M.update_inv_neck()

			if(M.shoes && !(HIDESHOES in obscured) && wash_obj(M.shoes))
				M.update_inv_shoes()

			var/washgloves = FALSE
			if(M.gloves && !(HIDEGLOVES in obscured))
				washgloves = TRUE

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.set_hygiene(HYGIENE_LEVEL_CLEAN)
				SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "rain", /datum/mood_event/rain)

				if(H.wear_suit && wash_obj(H.wear_suit))
					H.update_inv_wear_suit()
				else if(H.w_uniform && wash_obj(H.w_uniform))
					H.update_inv_w_uniform()

				if(washgloves)
					SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

				if(!H.is_mouth_covered())
					H.lip_style = null
					H.update_body()

				if(H.belt && wash_obj(H.belt))
					H.update_inv_belt()
			else
				SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "rain", /datum/mood_event/rain)
		else
			SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "rain", /datum/mood_event/rain)

/datum/weather/earth/thunder
	name = "Lightning"
	desc = "Thunder Storm, being out during this will have a chance of being hit with lightning."

	weather_message = "<span class='userdanger'><i>You hear thunder! Get to shelter!</i></span>"

	probability = 20

/datum/weather/earth/thunder/weather_act(atom/A)
	..()
	if(istype(A,/mob/living))
		var/mob/living/L = A
		if(iscarbon(L) && prob(1))
			var/mob/living/carbon/M = L
			if(prob(25))
				M.visible_message("<span class='userdanger'>[M] was struck by lightning!</span>")
				M.electrocute_act(rand(50,300),"Lightning Bolt",safety=1) //it CAN instantly kill a human.
				playsound(get_turf(M), 'sound/magic/lightningshock.ogg', 50, 1, -1)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "lightning", /datum/mood_event/lightning)
			else
				M.visible_message("<span class='danger'>[L] was nearly struck by lightning!</span>")
				playsound(get_turf(M), 'sound/magic/lightningshock.ogg', 50, 1, -1)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "lightningneardeath", /datum/mood_event/lightningneardeath)

/datum/weather/earth/heatwave
	name = "Heatwave"
	desc = "Being out during this will raise your body temperature and gives plants nutrients."

	telegraph_message = "<span class='boldwarning'>It's getting a bit toasty.</span>"
	telegraph_duration = 300
	telegraph_overlay = ""

	weather_message = "<span class='boldannounce'><i>A heatwave strikes!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "heatwave"

	end_message = "<span class='boldannounce'>It's getting cooler now.</span>"
	end_duration = 300
	end_overlay = ""


	probability = 20

/datum/weather/earth/heatwave/weather_act(atom/A)
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = A
		H.adjustWater(-2)
		H.adjustNutri(1)
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/L = A
		L.adjust_bodytemperature(rand(10,16))