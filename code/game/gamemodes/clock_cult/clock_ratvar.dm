/obj/structure/clockwork/massive //For objects that are typically very large
	name = "massive construct"
	desc = "A very large construction."
	layer = MASSIVE_OBJ_LAYER

/obj/structure/clockwork/massive/celestial_gateway //The gateway to Reebe, from which Ratvar emerges
	name = "Gateway to the Celestial Derelict"
	desc = "A massive, thrumming rip in spacetime."
	clockwork_desc = "A portal to the Celestial Derelict. Massive and intimidating, it is the only thing that can both transport Ratvar and withstand the massive amount of energy he emits."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_charging"
	pixel_x = -30
	pixel_y = -30
	alpha = 175
	health = 1000
	max_health = 1000
	var/progress_in_seconds = 0 //Once this reaches 300, it's game over
	var/purpose_fulfilled = FALSE
	var/first_sound_played = FALSE
	var/second_sound_played = FALSE
	var/third_sound_played = FALSE

/obj/structure/clockwork/massive/celestial_gateway/New()
	..()
	SSshuttle.emergencyNoEscape = TRUE
	SSobj.processing += src
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='large_brass'><b>A gateway to the Celestial Derelict has been created in [get_area(src)]!</b></span>"

/obj/structure/clockwork/massive/celestial_gateway/Destroy()
	SSshuttle.emergencyNoEscape = FALSE
	SSobj.processing -= src
	if(!purpose_fulfilled)
		for(var/mob/M in mob_list)
			if(is_servant_of_ratvar(M) || isobserver(M))
				M << "<span class='large_brass'><b>A gateway to the Celestial Derelict has fallen at [get_area(src)]!</b></span>"
				world << sound(null, 0, channel = 8)
	..()

/obj/structure/clockwork/massive/celestial_gateway/destroyed()
	visible_message("<span class='userdanger'>The [src] begins to pulse uncontrollably... you might want to run!</span>")
	world << sound('sound/effects/clockcult_gateway_disrupted.ogg', 0, channel = 8, volume = 50)
	icon_state = "clockwork_gateway_disrupted"
	takes_damage = FALSE
	sleep(27)
	animate(src, transform = matrix() * 2, time = 2)
	explosion(src, 1, 3, 8, 8)
	qdel(src)
	return 1

/obj/structure/clockwork/massive/celestial_gateway/ex_act(severity)
	return 0 //Nice try, Toxins!

/obj/structure/clockwork/massive/celestial_gateway/process()
	if(prob(5))
		for(var/mob/M in mob_list)
			M << "<span class='warning'><b>You hear otherworldly sounds from the [dir2text(get_dir(get_turf(M), get_turf(src)))]...</span>"
	if(!health)
		return 0
	progress_in_seconds++
	switch(progress_in_seconds)
		if(-INFINITY to 100)
			if(!first_sound_played)
				world << sound('sound/effects/clockcult_gateway_charging.ogg', 1, channel = 8, volume = 50)
				first_sound_played = TRUE
			icon_state = "clockwork_gateway_charging"
		if(100 to 250)
			if(!second_sound_played)
				world << sound('sound/effects/clockcult_gateway_active.ogg', 1, channel = 8, volume = 50)
				second_sound_played = TRUE
			icon_state = "clockwork_gateway_active"
		if(250 to 300)
			if(!third_sound_played)
				world << sound('sound/effects/clockcult_gateway_closing.ogg', 1, channel = 8, volume = 50)
				third_sound_played = TRUE
			icon_state = "clockwork_gateway_closing"
		if(300 to INFINITY)
			if(!purpose_fulfilled)
				takes_damage = FALSE
				purpose_fulfilled = TRUE
				animate(src, transform = matrix() * 1.5, time = 136)
				world << sound('sound/effects/ratvar_rises.ogg', 0, channel = 8) //End the sounds
				sleep(136)
				new/obj/structure/clockwork/massive/ratvar(get_turf(src))
				qdel(src)

/obj/structure/clockwork/massive/celestial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user))
		var/arrival_text = "IMMINENT"
		if(300 - progress_in_seconds > 0)
			arrival_text = "[max(300 - progress_in_seconds, 0)]s"
		user << "<span class='big'><b>Seconds until Ratvar's arrival:</b> [arrival_text]</span>"
		switch(progress_in_seconds)
			if(-INFINITY to 100)
				user << "<span class='heavy_brass'>It's still opening.</span>"
			if(100 to 250)
				user << "<span class='heavy_brass'>It's reached the Celestial Derelict and is drawing power from it.</span>"
			if(250 to INFINITY)
				user << "<span class='heavy_brass'>Ratvar is coming through the gateway!</span>"
	else
		switch(progress_in_seconds)
			if(-INFINITY to 100)
				user << "<span class='warning'>It's a swirling mass of blackness.</span>"
			if(100 to 250)
				user << "<span class='warning'>It seems to be leading somewhere.</span>"
			if(250 to INFINITY)
				user << "<span class='warning'><b>Something is coming through!</b></span>"

/obj/structure/clockwork/massive/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "<span class='userdanger'>What is what is what are what real what is all a lie all a lie it's all a lie why how can what is</span>"
	clockwork_desc = "<span class='large_brass'><b><i>Ratvar, the Clockwork Justiciar, your master eternal.</i></b></span>"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	pixel_x = -248
	pixel_y = -248
	takes_damage = FALSE
	var/mob/living/prey //Whoever Ratvar is chasing
	var/clashing = FALSE //If Ratvar is FUCKING FIGHTING WITH NAR-SIE

/obj/structure/clockwork/massive/ratvar/New()
	..()
	SSobj.processing += src
	world << "<span class='heavy_brass'><font size=15>\"I AM FREE!\"</font></span>"
	ratvar_awakens = TRUE
	spawn(50)
		SSshuttle.emergency.request(null, 0.3)

/obj/structure/clockwork/massive/ratvar/Destroy()
	SSobj.processing -= src
	world << "<span class='heavy_brass'><font size=7>\"NO! I will not... be...</font> <font size=6>banished...</font> <font size=5>again...\"</font></span>"
	ratvar_awakens = FALSE
	..()

/obj/structure/clockwork/massive/ratvar/process()
	for(var/atom/A in range(7, src))
		A.ratvar_act()
	if(clashing) //Doesn't move during a clash
		return 0
	var/dir_to_step_in = pick(cardinal)
	if(!prey)
		var/list/meals = list()
		for(var/mob/living/L in living_mob_list)
			if(L.z == z && !is_servant_of_ratvar(L) && L.mind)
				meals += L
		if(meals.len)
			prey = pick(meals)
			prey << "<span class='heavy_brass'><font size=5>\"You will do.\"</font></span>\n\
			<span class='userdanger'>Something very large and very malevolent begins lumbering its way towards you...</span>"
	else
		if(prob(10) || prey.stat == DEAD || is_servant_of_ratvar(prey) || prey.z != z)
			prey << "<span class='heavy_brass'><font size=5>\"How dull. Leave me.\"</font></span>\n\
			<span class='userdanger'>You feel tremendous relief as a set of horrible eyes loses sight of you...</span>"
			prey = null
		else
			if(prob(75))
				dir_to_step_in = get_dir(src, prey)
	for(var/i in 1 to 2)
		loc = get_step(src, dir_to_step_in)

/obj/structure/clockwork/massive/ratvar/narsie_act()
	if(clashing)
		return 0
	clashing = TRUE
	world << "<span class='heavy_brass'><font size=5>\"[pick("BLOOD GOD!!!", "NAR-SIE!!!", "AT LAST, YOUR TIME HAS COME!")]\"</font></span>"
	world << "<span class='cult'><font size=5>\"<b>Ratvar?! How?!</b>\"</font></span>"
	for(var/obj/singularity/narsie/N in range(7, src))
		clash_of_the_titans(N) //IT'S TIME FOR THE BATTLE OF THE AGES
		N.clashing = TRUE
		break
	return 1

/obj/structure/clockwork/massive/ratvar/proc/clash_of_the_titans(obj/singularity/narsie/narsie) //IT'S TIME FOR A BATTLE OF THE ELDER GODS
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
			world << "<span class='heavy_brass'><font size=5>\"[pick("DIE! DIE! DIE!", "RAAAAAAAAAAAAAHH!", "FILTH!!!", "SUFFER!!!", "EBG SBE PRAGHEVRF NF V UNIR!!")]\"</font></span>"
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

/atom/proc/ratvar_act() //Called on everything near Ratvar
	return

/turf/closed/wall/ratvar_act() //Walls and floors are changed to their clockwork variants
	if(prob(20))
		ChangeTurf(/turf/closed/wall/clockwork)
/turf/open/floor/ratvar_act()
	if(prob(20))
		ChangeTurf(/turf/open/floor/clockwork)

/obj/structure/window/ratvar_act() //Windows turn yellow
	color = rgb(75, 53, 0)

/mob/living/ratvar_act()
	add_servant_of_ratvar(src)

/mob/dead/observer/ratvar_act() //Ghosts flash yellow for a second
	var/old_color = color
	color = rgb(75, 53, 0) //A nice brassy yellow
	animate(src, color = old_color, time = 10)
