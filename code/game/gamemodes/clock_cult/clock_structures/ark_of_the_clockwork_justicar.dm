/obj/structure/destructible/clockwork/massive/celestial_gateway //The gateway to Reebe, from which Ratvar emerges
	name = "Gateway to the Celestial Derelict"
	desc = "A massive, thrumming rip in spacetime."
	clockwork_desc = "A portal to the Celestial Derelict. Massive and intimidating, it is the only thing that can both transport Ratvar and withstand the massive amount of energy he emits."
	obj_integrity = 500
	max_integrity = 500
	mouse_opacity = 2
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = TRUE
	can_be_repaired = FALSE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/ratvar_portal = TRUE //if the gateway actually summons ratvar or just produces a hugeass conversion burst
	var/obj/effect/clockwork/overlay/gateway_glow/glow
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/destructible/clockwork/massive/celestial_gateway/New()
	..()
	glow = new(get_turf(src))
	countdown = new(src)
	countdown.start()
	START_PROCESSING(SSobj, src)
	var/area/gate_area = get_area(src)
	hierophant_message("<span class='large_brass'><b>A gateway to the Celestial Derelict has been created in [gate_area.map_name]!</b></span>", FALSE, src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!purpose_fulfilled)
		var/area/gate_area = get_area(src)
		hierophant_message("<span class='large_brass'><b>A gateway to the Celestial Derelict has fallen at [gate_area.map_name]!</b></span>")
		world << sound(null, 0, channel = 8)
	if(glow)
		qdel(glow)
		glow = null
	if(countdown)
		qdel(countdown)
		countdown = null
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!disassembled)
			countdown.stop()
			visible_message("<span class='userdanger'>The [src] begins to pulse uncontrollably... you might want to run!</span>")
			world << sound('sound/effects/clockcult_gateway_disrupted.ogg', 0, channel = 8, volume = 50)
			make_glow()
			glow.icon_state = "clockwork_gateway_disrupted"
			resistance_flags |= INDESTRUCTIBLE
			sleep(27)
			explosion(src, 1, 3, 8, 8)
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/make_glow()
	if(!glow)
		glow = PoolOrNew(/obj/effect/clockwork/overlay/gateway_glow, get_turf(src))
		glow.linked = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/ex_act(severity)
	var/damage = max((obj_integrity * 0.70) / severity, 100) //requires multiple bombs to take down
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/get_arrival_text(s_on_time)
	. = "IMMINENT"
	if(!obj_integrity)
		. = "DETONATING"
	else if(GATEWAY_RATVAR_ARRIVAL - progress_in_seconds > 0)
		. = "[round(max((GATEWAY_RATVAR_ARRIVAL - progress_in_seconds) / (GATEWAY_SUMMON_RATE * 0.5), 0), 1)][s_on_time ? "S":""]"

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	icon_state = "spatial_gateway" //cheat wildly by pretending to have an icon
	..()
	icon_state = initial(icon_state)
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='big'><b>Seconds until [ratvar_portal ? "Ratvar's arrival":"Proselytization"]:</b> [get_arrival_text(TRUE)]</span>"
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				user << "<span class='heavy_brass'>It's still opening.</span>"
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				user << "<span class='heavy_brass'>It's reached the Celestial Derelict and is drawing power from it.</span>"
			if(GATEWAY_RATVAR_COMING to INFINITY)
				user << "<span class='heavy_brass'>[ratvar_portal ? "Ratvar is coming through the gateway":"The gateway is glowing with massed power"]!</span>"
	else
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				user << "<span class='warning'>It's a swirling mass of blackness.</span>"
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				user << "<span class='warning'>It seems to be leading somewhere.</span>"
			if(GATEWAY_RATVAR_COMING to INFINITY)
				user << "<span class='boldwarning'>[ratvar_portal ? "Something is coming through":"It's glowing brightly"]!</span>"

/obj/structure/destructible/clockwork/massive/celestial_gateway/process()
	if(!progress_in_seconds || prob(7))
		for(var/M in mob_list)
			M << "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>"
	if(!obj_integrity)
		return 0
	progress_in_seconds += GATEWAY_SUMMON_RATE
	switch(progress_in_seconds)
		if(-INFINITY to GATEWAY_REEBE_FOUND)
			if(!first_sound_played)
				world << sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = 8, volume = 30)
				first_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!second_sound_played)
				world << sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = 8, volume = 35)
				second_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!third_sound_played)
				world << sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = 8, volume = 40)
				third_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_closing"
		if(GATEWAY_RATVAR_ARRIVAL to INFINITY)
			if(!purpose_fulfilled)
				countdown.stop()
				resistance_flags |= INDESTRUCTIBLE
				purpose_fulfilled = TRUE
				make_glow()
				animate(glow, transform = matrix() * 1.5, alpha = 255, time = 125)
				world << sound('sound/effects/ratvar_rises.ogg', 0, channel = 8) //End the sounds
				sleep(125)
				make_glow()
				animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
				var/turf/startpoint = get_turf(src)
				sleep(3)
				QDEL_IN(src, 3)
				clockwork_gateway_activated = TRUE
				if(ratvar_portal)
					new/obj/structure/destructible/clockwork/massive/ratvar(startpoint)
				else
					world << "<span class='ratvar'>\"[text2ratvar("Behold")]!\"</span>\n<span class='inathneq_large'>\"[text2ratvar("See Engine's mercy")]!\"</span>\n\
					<span class='sevtug_large'>\"[text2ratvar("Observe Engine's design skills")]!\"</span>\n<span class='nezbere_large'>\"[text2ratvar("Behold Engine's light")]!!\"</span>\n\
					<span class='nzcrentr_large'>\"[text2ratvar("Gaze upon Engine's power")]!\"</span>"
					world << 'sound/magic/clockwork/invoke_general.ogg'
					var/x0 = startpoint.x
					var/y0 = startpoint.y
					for(var/I in spiral_range_turfs(255, startpoint))
						var/turf/T = I
						if(!T)
							continue
						var/dist = cheap_hypotenuse(T.x, T.y, x0, y0)
						if(dist < 60)
							dist = TRUE
						else
							dist = FALSE
						T.ratvar_act(dist)
						CHECK_TICK
					for(var/I in all_clockwork_mobs)
						var/mob/M = I
						if(M.stat == CONSCIOUS)
							clockwork_say(M, text2ratvar(pick("Purge all untruths and honor Engine!", "All glory to Engine's light!", "Engine's power is unmatched!")))

//the actual appearance of the Gateway to the Celestial Derelict; an object so the edges of the gate can be clicked through.
/obj/effect/clockwork/overlay/gateway_glow
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_charging"
	pixel_x = -32
	pixel_y = -32
	layer = MASSIVE_OBJ_LAYER
