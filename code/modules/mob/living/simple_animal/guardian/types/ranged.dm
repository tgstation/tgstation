//Ranged
/obj/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	combat_mode = FALSE
	friendly_verb_continuous = "quietly assesses"
	friendly_verb_simple = "quietly assess"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, CLONE = 0.9, STAMINA = 0, OXY = 0.9)
	projectiletype = /obj/projectile/guardian
	ranged_cooldown_time = 1 //fast!
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	playstyle_string = "<span class='holoparasite'>As a <b>ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Sentinel, an alien master of ranged combat.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Ranged combat modules active. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one, it's a ranged carp. This fishy can watch people pee in the ocean.</span>"
	miner_fluff_string = "<span class='holoparasite'>You encounter... Diamond, a powerful projectile thrower.</span>"
	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = 8
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(loc == summoner)
		if(toggle)
			ranged = initial(ranged)
			melee_damage_lower = initial(melee_damage_lower)
			melee_damage_upper = initial(melee_damage_upper)
			obj_damage = initial(obj_damage)
			environment_smash = initial(environment_smash)
			alpha = 255
			range = initial(range)
			to_chat(src, "[span_danger("<B>You switch to combat mode.")]</B>")
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			obj_damage = 0
			environment_smash = ENVIRONMENT_SMASH_NONE
			alpha = 45
			range = 255
			to_chat(src, "[span_danger("<B>You switch to scout mode.")]</B>")
			toggle = TRUE
	else
		to_chat(src, "[span_danger("<B>You have to be recalled to toggle modes!")]</B>")

/mob/living/simple_animal/hostile/guardian/ranged/Shoot(atom/targeted_atom)
	. = ..()
	if(istype(., /obj/projectile))
		var/obj/projectile/P = .
		if(guardiancolor)
			P.color = guardiancolor

/mob/living/simple_animal/hostile/guardian/ranged/ToggleLight()
	var/msg
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "You activate your night vision."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "You increase your night vision."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "You maximize your night vision."
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "You deactivate your night vision."

	to_chat(src, span_notice("[msg]"))


/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Snare"
	set category = "Guardian"
	set desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5"
	if(length(snares) < 6)
		var/turf/snare_loc = get_turf(loc)
		var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		snares |= S
		to_chat(src, "[span_danger("<B>Surveillance snare deployed!")]</B>")
	else
		to_chat(src, "[span_danger("<B>You have too many snares deployed. Remove some first.")]</B>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Snare"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance snares."
	var/picked_snare = tgui_input_list(src, "Pick which snare to remove", "Remove Snare", sort_names(snares))
	if(isnull(picked_snare))
		return
	snares -= picked_snare
	qdel(picked_snare)
	to_chat(src, "[span_danger("<B>Snare disarmed.")]</B>")

/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/guardian/spawner
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/snare/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/snare/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(isliving(AM) && spawner && spawner.summoner && AM != spawner && !spawner.hasmatchingsummoner(AM))
		to_chat(spawner.summoner, "[span_danger("<B>[AM] has crossed surveillance snare, [name].")]</B>")
		var/list/guardians = spawner.summoner.hasparasites()
		for(var/para in guardians)
			to_chat(para, "[span_danger("<B>[AM] has crossed surveillance snare, [name].")]</B>")

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return

/mob/living/simple_animal/hostile/guardian/ranged/Manifest(forced)
	if (toggle)
		incorporeal_move = INCORPOREAL_MOVE_BASIC
	. = ..()

/mob/living/simple_animal/hostile/guardian/ranged/Recall(forced)
	// To stop scout mode from moving when recalled
	incorporeal_move = FALSE
	. = ..()

/mob/living/simple_animal/hostile/guardian/ranged/AttackingTarget()
	if(toggle)
		return
	..()
