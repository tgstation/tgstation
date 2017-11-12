/obj/machinery/hivebot_swarm_core //A hulking machine armed with several weapons. Creates hivebots and defends itself with a buzzsaw and mounted weapons.
	name = "hivebot swarm core"
	desc = "An incredibly dangerous machine with random weapons haphazardly attached with spot welds. Its main body seems impervious to damage, but the head is vulnerable."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hivebot_swarm_core"
	pixel_x = -32
	pixel_y = -16
	use_power = FALSE
	max_integrity = 250
	anchored = TRUE
	density = TRUE
	var/recharge_period = 0 //The number of ticks the core is waiting for and cannot do anything
	var/atom/movable/threat_to_swarm //The core's "target" for its attacks
	var/hivebot_limit = 40 //Stop making hivebots if there are this many in a 7x7 square around us

/obj/machinery/hivebot_swarm_core/Destroy()
	visible_message("<span class='warning'>[src] falls apart, its red eyes sputtering out.</span>")
	playsound(src, 'sound/magic/clockwork/anima_fragment_death.ogg', 50, 0)
	new/obj/structure/fluff/hivebot_swarm_core(get_turf(src))
	return ..()

/obj/machinery/hivebot_swarm_core/examine(mob/user)
	..()
	if(recharge_period)
		to_chat(user, "<span class='warning'>It seems to be recharging.</span>")

/obj/machinery/hivebot_swarm_core/process()
	if(recharge_period)
		recharge_period--
		return
	acquire_target()
	if(!threat_to_swarm)
		make_hivebot()
	else
		defend_the_swarm()

/obj/machinery/hivebot_swarm_core/proc/make_hivebot() //Only called if we don't find a threat
	var/hivebots = 0
	for(var/mob/living/simple_animal/hostile/hivebot/H in range(7, src))
		hivebots++
	if(hivebots >= hivebot_limit)
		return
	var/turf/T = get_step(src, SOUTHWEST)
	var/mob/living/simple_animal/hostile/hivebot/H = new(T)
	H.color = rgb(0, 255, 0)
	animate(H, color = initial(H.color), time = 10)

/obj/machinery/hivebot_swarm_core/proc/acquire_target() //If we find a mob in our view, it becomes the threat. Robots don't count because we're too stupid to recognize them.
	if(threat_to_swarm)
		return
	var/list/potential_targets = list()
	for(var/mob/living/carbon/C in view(7, src))
		potential_targets += C
	for(var/mob/living/silicon/S in view(7, src))
		potential_targets += S
	for(var/obj/mecha/M in view(7, src))
		potential_targets += M
	for(var/mob/living/L in potential_targets)
		if(L.stat)
			potential_targets -= L
		else
			if("hivebot" in L.faction)
				potential_targets -= L
	if(!potential_targets.len) //Run another sanity check, just in case
		return
	threat_to_swarm = pick(potential_targets)
	visible_message("<span class='warning'>[src] turns ominously towards [threat_to_swarm]!</span>")
	say("SUBJECT STATUS: THREAT TO SWARM. TARGET LOCKED.")

/obj/machinery/hivebot_swarm_core/proc/defend_the_swarm()
	var/atom/movable/threat_to_swarm = src.threat_to_swarm
	var/mob/living/L = threat_to_swarm
	if(!istype(L))
		L = null
	if(QDELETED(threat_to_swarm) || !(threat_to_swarm in view(7, src)) || (L && L.stat))
		say("TARGET LOST. RESUMING FABRICATION ROUTINE.")
		threat_to_swarm = null
		return
	var/turf/T = get_turf(src)
	var/list/combat_actions = list("saw" = 1 * (get_dist(threat_to_swarm, src) <= 2), "swarm" = 1, "laser" = 2)
	switch(pickweight(combat_actions))
		if("laser")
			threat_to_swarm.Beam(T, "sat_beam", time = 5)
			if(L)
				L.adjustFireLoss(15)
			else
				var/obj/threat = threat_to_swarm
				threat.take_damage(15, "fire", "laser")
			playsound(src, 'sound/weapons/plasma_cutter.ogg', 50, 1)
			playsound(threat_to_swarm, 'sound/weapons/sear.ogg', 50, 1)
		if("swarm")
			visible_message("<span class='warning'>[src] warps in a swarm of hivebots!</span>")
			playsound(src, 'sound/effects/phasein.ogg', 100, 1)
			for(var/i in 1 to 3)
				new/mob/living/simple_animal/hostile/hivebot(T)
			for(var/i in 1 to 2)
				new/mob/living/simple_animal/hostile/hivebot/range(T)
			new/mob/living/simple_animal/hostile/hivebot/engineer(T)
			recharge_period = 5 //Give some time to mop up the adds
		if("saw")
			var/turf/target_turf = get_turf(threat_to_swarm)
			visible_message("<span class='warning'>[src] revs its buzzsaw!</span>")
			say("COMMENCING ANNIHILATION.")
			playsound(src, 'sound/machines/buzzsaw_windup.ogg', 100, 0)
			recharge_period = 2
			addtimer(CALLBACK(src, .proc/saw_turf, target_turf), 12.5) //To match up with the sound

/obj/machinery/hivebot_swarm_core/proc/saw_turf(turf/target) //Instacrits anyone standing on the turf
	playsound(target, 'sound/machines/buzzsaw_BRRRRR.ogg', 100, 0)
	for(var/mob/living/L in target) //you fucked up now
		L.visible_message("<span class='warning'>[src]'s buzzsaw rips into [L]!</span>", "<span class='userdanger'>[src]'s buzzsaw rips into you!</span>")
		L.emote("scream")
		var/datum/callback/cb = CALLBACK(src, .proc/saw_target, L)
		cb.Invoke()
		for(var/I in 1 to 4)
			addtimer(cb, 5 * I)

/obj/machinery/hivebot_swarm_core/proc/saw_target(mob/living/L)
	L.adjustBruteLoss(rand(20, 30)) //Guaranteed crit at least
	L.Knockdown(40)
	playsound(L, "desecration", 75, 1)
	playsound(L, 'sound/effects/splat.ogg', 50, 1)
