/obj/structure/clockwork/massive //For objects that are typically very large
	name = "massive construct"
	desc = "A very large construction."
	layer = MASSIVE_OBJ_LAYER
	density = FALSE
	burn_state = LAVA_PROOF

/obj/structure/clockwork/massive/New()
	..()
	poi_list += src

/obj/structure/clockwork/massive/Destroy()
	poi_list -= src
	return ..()

/obj/structure/clockwork/massive/celestial_gateway //The gateway to Reebe, from which Ratvar emerges
	name = "Gateway to the Celestial Derelict"
	desc = "A massive, thrumming rip in spacetime."
	clockwork_desc = "A portal to the Celestial Derelict. Massive and intimidating, it is the only thing that can both transport Ratvar and withstand the massive amount of energy he emits."
	health = 500
	max_health = 500
	mouse_opacity = 2
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "nothing"
	density = TRUE
	var/progress_in_seconds = 0 //Once this reaches GATEWAY_RATVAR_ARRIVAL, it's game over
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE
	var/obj/effect/clockwork/gateway_glow/glow
	var/obj/effect/countdown/clockworkgate/countdown

/obj/structure/clockwork/massive/celestial_gateway/New()
	..()
	glow = new(get_turf(src))
	countdown = new(src)
	countdown.start()
	SSshuttle.emergencyNoEscape = TRUE
	SSobj.processing += src
	var/area/gate_area = get_area(src)
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='large_brass'><b>A gateway to the Celestial Derelict has been created in [gate_area.map_name]!</b></span>"

/obj/structure/clockwork/massive/celestial_gateway/Destroy()
	SSshuttle.emergencyNoEscape = FALSE
	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		SSshuttle.emergency.mode = SHUTTLE_DOCKED
		SSshuttle.emergency.timer = world.time
		if(!purpose_fulfilled)
			priority_announce("Hostile enviroment resolved. You have 3 minutes to board the Emergency Shuttle.", null, 'sound/AI/shuttledock.ogg', "Priority")
	SSobj.processing -= src
	if(!purpose_fulfilled)
		var/area/gate_area = get_area(src)
		for(var/mob/M in mob_list)
			if(is_servant_of_ratvar(M) || isobserver(M))
				M << "<span class='large_brass'><b>A gateway to the Celestial Derelict has fallen at [gate_area.map_name]!</b></span>"
		world << sound(null, 0, channel = 8)
	qdel(glow)
	glow = null
	qdel(countdown)
	countdown = null
	return ..()

/obj/structure/clockwork/massive/celestial_gateway/destroyed()
	countdown.stop()
	visible_message("<span class='userdanger'>The [src] begins to pulse uncontrollably... you might want to run!</span>")
	world << sound('sound/effects/clockcult_gateway_disrupted.ogg', 0, channel = 8, volume = 50)
	make_glow()
	glow.icon_state = "clockwork_gateway_disrupted"
	takes_damage = FALSE
	sleep(27)
	explosion(src, 1, 3, 8, 8)
	qdel(src)
	return 1

/obj/structure/clockwork/massive/celestial_gateway/proc/make_glow()
	if(!glow)
		glow = new(get_turf(src))
		glow.linked_gate = src

/obj/structure/clockwork/massive/celestial_gateway/ex_act(severity)
	return 0 //Nice try, Toxins!

/obj/structure/clockwork/massive/celestial_gateway/process()
	if(prob(5))
		for(var/mob/M in mob_list)
			M << "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>"
	if(!health)
		return 0
	progress_in_seconds += GATEWAY_SUMMON_RATE
	switch(progress_in_seconds)
		if(-INFINITY to GATEWAY_REEBE_FOUND)
			if(!first_sound_played)
				world << sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = 8, volume = 50)
				first_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_charging"
		if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
			if(!second_sound_played)
				world << sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = 8, volume = 50)
				second_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_active"
		if(GATEWAY_RATVAR_COMING to GATEWAY_RATVAR_ARRIVAL)
			if(!third_sound_played)
				world << sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = 8, volume = 50)
				third_sound_played = TRUE
			make_glow()
			glow.icon_state = "clockwork_gateway_closing"
		if(GATEWAY_RATVAR_ARRIVAL to INFINITY)
			if(!purpose_fulfilled)
				countdown.stop()
				takes_damage = FALSE
				purpose_fulfilled = TRUE
				make_glow()
				animate(glow, transform = matrix() * 1.5, alpha = 255, time = 126)
				world << sound('sound/effects/ratvar_rises.ogg', 0, channel = 8) //End the sounds
				sleep(131)
				make_glow()
				animate(glow, transform = matrix() * 3, alpha = 0, time = 5)
				sleep(5)
				new/obj/structure/clockwork/massive/ratvar(get_turf(src))
				qdel(src)

/obj/structure/clockwork/massive/celestial_gateway/examine(mob/user)
	icon_state = "spatial_gateway" //cheat wildly by pretending to have an icon
	..()
	icon_state = initial(icon_state)
	if(is_servant_of_ratvar(user) || isobserver(user))
		var/arrival_text = "IMMINENT"
		if(GATEWAY_RATVAR_ARRIVAL - progress_in_seconds > 0)
			arrival_text = "[round(max((GATEWAY_RATVAR_ARRIVAL - progress_in_seconds) / (GATEWAY_SUMMON_RATE * 0.5), 0), 1)]"
		user << "<span class='big'><b>Seconds until Ratvar's arrival:</b> [arrival_text]s</span>"
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				user << "<span class='heavy_brass'>It's still opening.</span>"
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				user << "<span class='heavy_brass'>It's reached the Celestial Derelict and is drawing power from it.</span>"
			if(GATEWAY_RATVAR_COMING to INFINITY)
				user << "<span class='heavy_brass'>Ratvar is coming through the gateway!</span>"
	else
		switch(progress_in_seconds)
			if(-INFINITY to GATEWAY_REEBE_FOUND)
				user << "<span class='warning'>It's a swirling mass of blackness.</span>"
			if(GATEWAY_REEBE_FOUND to GATEWAY_RATVAR_COMING)
				user << "<span class='warning'>It seems to be leading somewhere.</span>"
			if(GATEWAY_RATVAR_COMING to INFINITY)
				user << "<span class='warning'><b>Something is coming through!</b></span>"

/obj/effect/clockwork/gateway_glow //the actual appearance of the Gateway to the Celestial Derelict; an object so the edges of the gate can be clicked through.
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_charging"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = 0
	layer = MASSIVE_OBJ_LAYER
	var/obj/structure/clockwork/massive/celestial_gateway/linked_gate

/obj/effect/clockwork/gateway_glow/Destroy()
	if(linked_gate)
		linked_gate.glow = null
		linked_gate = null
	return ..()

/obj/effect/clockwork/gateway_glow/examine(mob/user)
	if(linked_gate)
		linked_gate.examine(user)

/obj/effect/clockwork/gateway_glow/ex_act(severity, target)
	return FALSE


/obj/structure/clockwork/massive/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "<span class='userdanger'>What is what is what are what real what is all a lie all a lie it's all a lie why how can what is</span>"
	clockwork_desc = "<span class='large_brass'><b><i>Ratvar, the Clockwork Justiciar, your master eternal.</i></b></span>"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	pixel_x = -235
	pixel_y = -248
	takes_damage = FALSE
	var/atom/prey //Whatever Ratvar is chasing
	var/clashing = FALSE //If Ratvar is FUCKING FIGHTING WITH NAR-SIE
	var/proselytize_range = 10

/obj/structure/clockwork/massive/ratvar/New()
	..()
	ratvar_awakens = TRUE
	for(var/obj/item/clockwork/ratvarian_spear/R in all_clockwork_objects)
		R.update_force()
	SSobj.processing += src
	world << "<span class='heavy_brass'><font size=6>\"BAPR NTNVA ZL YVTUG FUNYY FUVAR NPEBFF GUVF CNGURGVP ERNYZ!!\"</font></span>"
	world << 'sound/effects/ratvar_reveal.ogg'
	var/image/alert_overlay = image('icons/effects/clockwork_effects.dmi', "ratvar_alert")
	var/area/A = get_area(src)
	notify_ghosts("The Justiciar's light calls to you! Reach out to Ratvar in [A.name] to be granted a shell to spread his glory!", null, source = src, alert_overlay = alert_overlay)
	spawn(50)
		SSshuttle.emergency.request(null, 0.3)


/obj/structure/clockwork/massive/ratvar/Destroy()
	ratvar_awakens = FALSE
	for(var/obj/item/clockwork/ratvarian_spear/R in all_clockwork_objects)
		R.update_force()
	SSobj.processing -= src
	world << "<span class='heavy_brass'><font size=6>\"NO! I will not... be...</font> <font size=5>banished...</font> <font size=4>again...\"</font></span>"
	return ..()


/obj/structure/clockwork/massive/ratvar/attack_ghost(mob/dead/observer/O)
	if(alert(O, "Embrace the Justiciar's light? You can no longer be cloned!",,"Yes", "No") == "No" || !O)
		return 0
	var/mob/living/simple_animal/hostile/clockwork/reclaimer/R = new(get_turf(src))
	R.visible_message("<span class='warning'>[R] forms and hums to life!</span>")
	R.key = O.key


/obj/structure/clockwork/massive/ratvar/Bump(atom/A)
	forceMove(get_turf(A))
	A.ratvar_act()


/obj/structure/clockwork/massive/ratvar/Process_Spacemove()
	return clashing


/obj/structure/clockwork/massive/ratvar/process()
	if(clashing) //I'm a bit occupied right now, thanks
		return
	for(var/atom/A in range(proselytize_range, src))
		A.ratvar_act()
	var/dir_to_step_in = pick(cardinal)
	if(!prey)
		for(var/obj/singularity/narsie/N in poi_list)
			if(N.z == z)
				prey = N
				break
		if(!prey) //In case there's a Nar-Sie
			var/list/meals = list()
			for(var/mob/living/L in living_mob_list)
				if(L.z == z && !is_servant_of_ratvar(L) && L.mind)
					meals += L
			if(meals.len)
				prey = pick(meals)
				prey << "<span class='heavy_brass'><font size=5>\"You will do.\"</font></span>\n\
				<span class='userdanger'>Something very large and very malevolent begins lumbering its way towards you...</span>"
				prey << 'sound/effects/ratvar_reveal.ogg'
	else
		if(prob(10) || is_servant_of_ratvar(prey) || prey.z != z)
			prey << "<span class='heavy_brass'><font size=5>\"How dull. Leave me.\"</font></span>\n\
			<span class='userdanger'>You feel tremendous relief as a set of horrible eyes loses sight of you...</span>"
			prey = null
		else
			dir_to_step_in = get_dir(src, prey) //Unlike Nar-Sie, Ratvar ruthlessly chases down his target
	step(src, dir_to_step_in)

/obj/structure/clockwork/massive/ratvar/narsie_act()
	if(clashing)
		return 0
	clashing = TRUE
	world << "<span class='heavy_brass'><font size=5>\"[pick("BLOOD GOD!!!", "NAR-SIE!!!", "AT LAST, YOUR TIME HAS COME!")]\"</font></span>"
	world << "<span class='cult'><font size=5>\"<b>Ratvar?! How?!</b>\"</font></span>"
	for(var/obj/singularity/narsie/N in range(15, src))
		if(N.clashing)
			continue
		N.clashing = TRUE
		clash_of_the_titans(N) //IT'S TIME FOR THE BATTLE OF THE AGES
		break
	return 1

/obj/structure/clockwork/massive/ratvar/proc/clash_of_the_titans(obj/singularity/narsie/narsie)
	var/winner = "Undeclared"
	var/base_victory_chance = 0
	while(TRUE)
		world << 'sound/magic/clockwork/ratvar_attack.ogg'
		sleep(5.2)
		for(var/mob/M in mob_list)
			if(M.client)
				M.client.color = rgb(150, 100, 0)
				spawn(1)
					M.client.color = initial(M.client.color)
			shake_camera(M, 4, 3)
		var/r_success_modifier = (ticker.mode.servants_of_ratvar.len * 2) //2% for each cultist
		var/n_success_modifier = (ticker.mode.cult.len * 2)
		for(var/mob/living/simple_animal/hostile/construct/harvester/C in player_list)
			n_success_modifier += 2
		if(prob(base_victory_chance + r_success_modifier))
			winner = "Ratvar"
			break
		sleep(rand(2,5))
		world << 'sound/magic/clockwork/narsie_attack.ogg'
		sleep(7.4)
		for(var/mob/M in mob_list)
			if(M.client)
				M.client.color = rgb(200, 0, 0)
				spawn(1)
					M.client.color = initial(M.client.color)
			shake_camera(M, 4, 3)
		if(prob(base_victory_chance + n_success_modifier))
			winner = "Nar-Sie"
			break
		base_victory_chance++ //The clash has a higher chance of resolving each time both gods attack one another
	switch(winner)
		if("Ratvar")
			world << "<span class='heavy_brass'><font size=5>\"[pick("DIE! DIE! DIE!", "REEEEEEEEE!", "FILTH!!!", "SUFFER!!!", "EBG SBE PRAGHEVRF NF V UNIR!!")]\"</font></span>" //nar-sie get out
			world << "<span class='cult'><font size=5>\"<b>[pick("Nooooo...", "Not die. To y-", "Die. Ratv-", "Sas tyen re-")]\"</b></font></span>"
			world << 'sound/magic/clockwork/anima_fragment_attack.ogg'
			world << 'sound/magic/demon_dies.ogg'
			clashing = FALSE
			qdel(narsie)
			return 1
		if("Nar-Sie")
			world << "<span class='cult'><font size=5>\"<b>[pick("Ha.", "Ra'sha fonn dest.", "You fool. To come here.")]</b>\"</font></span>" //Broken English
			world << 'sound/magic/demon_attack1.ogg'
			world << 'sound/magic/clockwork/anima_fragment_death.ogg'
			narsie.clashing = FALSE
			qdel(src)
			return 1
