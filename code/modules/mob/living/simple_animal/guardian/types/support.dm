//Healer
/mob/living/simple_animal/hostile/guardian/healer
	a_intent = "harm"
	friendly = "heals"
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "<span class='holoparasite'>As a <b>support</b> type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent object or mob will warp them to your bluespace beacon after a short delay.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the CMO, a potent force of life... and death.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught a support carp. It's a kleptocarp!</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Support modules active. Holoparasite swarm online.</span>"
	toggle_button_type = /obj/screen/guardian/ToggleMode
	var/turf/open/floor/beacon
	var/beacon_cooldown = 0
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/healer/New()
	..()
	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/Stat()
	..()
	if(statpanel("Status"))
		if(beacon_cooldown >= world.time)
			stat(null, "Beacon Cooldown Remaining: [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	if(..())
		if(toggle == TRUE)
			if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.adjustBruteLoss(-5)
				C.adjustFireLoss(-5)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				var/obj/effect/overlay/temp/heal/H = PoolOrNew(/obj/effect/overlay/temp/heal, get_turf(C))
				if(namedatum)
					H.color = namedatum.colour

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = "harm"
			speed = 0
			damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
			melee_damage_lower = 15
			melee_damage_upper = 15
			src << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			a_intent = "help"
			speed = 1
			damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			melee_damage_lower = 0
			melee_damage_upper = 0
			src << "<span class='danger'><B>You switch to healing mode.</span></B>"
			toggle = TRUE
	else
		src << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"


/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."
	if(beacon_cooldown<world.time)
		var/turf/beacon_loc = get_turf(src.loc)
		if(istype(beacon_loc, /turf/open/floor))
			var/turf/open/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace recieving pad"
			F.desc = "A recieving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			F.luminosity = 1
			if(namedatum)
				F.color = namedatum.colour
			src << "<span class='danger'><B>Beacon placed! You may now warp targets to it, including your user, via Alt+Click. </span></B>"
			if(beacon)
				beacon.ChangeTurf(/turf/open/floor/plating)
			beacon = F
			beacon_cooldown = world.time+3000

	else
		src << "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>"

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to warp a target!</span></B>"
		return
	if(!beacon)
		src << "<span class='danger'><B>You need a beacon placed to warp things!</span></B>"
		return
	if(!Adjacent(A))
		src << "<span class='danger'><B>You must be adjacent to your target!</span></B>"
		return
	if((A.anchored))
		src << "<span class='danger'><B>Your target cannot be anchored!</span></B>"
		return

	var/turf/T = get_turf(A)
	if(beacon.z == T.z)
		src << "<span class='danger'><B>You begin to warp [A].</span></B>"
		A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", "<span class='userdanger'>You start to faintly glow, and you feel strangely weightless!</span>")
		do_attack_animation(A)
		if(do_mob(src, A, 60)) //now start the channel
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, T)
			if(isliving(A))
				var/mob/living/L = A
				L.flash_eyes()
			A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", "<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
			do_teleport(A, beacon, 0)
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(A))
		else
			src << "<span class='danger'><B>You need to hold still!</span></B>"

	else
		src << "<span class='danger'><B>The beacon is too far away to warp to!</span></B>"
