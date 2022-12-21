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
	playstyle_string = span_holoparasite("As a <b>ranged</b> type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit.")
	magic_fluff_string = span_holoparasite("..And draw the Sentinel, an alien master of ranged combat.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Ranged combat modules active. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one, it's a ranged carp. This fishy can watch people pee in the ocean.")
	miner_fluff_string = span_holoparasite("You encounter... Diamond, a powerful projectile thrower.")
	creator_name = "Ranged"
	creator_desc = "Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; where it cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode."
	creator_icon = "ranged"
	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = NIGHTVISION_FOV_RANGE
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode
	/// List of all deployed snares.
	var/list/snares = list()
	/// Is it in scouting mode?
	var/toggle = FALSE
	/// Maximum snares deployed at once.
	var/max_snares = 6
	/// Lower damage before scouting.
	var/previous_lower_damage = 0
	/// Upper damage before scouting.
	var/previous_upper_damage = 0

/mob/living/simple_animal/hostile/guardian/ranged/toggle_modes()
	if(is_deployed() && summoner)
		to_chat(src, span_bolddanger("You have to be recalled to toggle modes!"))
		return
	if(toggle)
		ranged = initial(ranged)
		melee_damage_lower = previous_lower_damage
		melee_damage_upper = previous_upper_damage
		previous_lower_damage = 0
		previous_upper_damage = 0
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = 255
		range = initial(range)
		to_chat(src, span_bolddanger("You switch to combat mode."))
		toggle = FALSE
	else
		ranged = 0
		previous_lower_damage = melee_damage_lower
		melee_damage_lower = 0
		previous_upper_damage = melee_damage_upper
		melee_damage_upper = 0
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		alpha = 45
		range = 255
		to_chat(src, span_bolddanger("You switch to scout mode."))
		toggle = TRUE


/mob/living/simple_animal/hostile/guardian/ranged/Shoot(atom/targeted_atom)
	. = ..()
	if(!istype(., /obj/projectile))
		return
	var/obj/projectile/shot_projectile = .
	shot_projectile.color = guardian_color

/mob/living/simple_animal/hostile/guardian/ranged/toggle_light()
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
	sync_lighting_plane_alpha()
	to_chat(src, span_notice(msg))


/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Snare"
	set category = "Guardian"
	set desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5"
	if(length(snares) < max_snares)
		var/turf/snare_loc = get_turf(src)
		var/obj/effect/snare/new_snare = new /obj/effect/snare(snare_loc, src)
		new_snare.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		snares += new_snare
		to_chat(src, span_bolddanger("Surveillance snare deployed!"))
	else
		to_chat(src, span_bolddanger("You have too many snares deployed. Remove some first."))

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Snare"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance snares."
	var/picked_snare = tgui_input_list(src, "Pick which snare to remove.", "Remove Snare", sort_names(snares))
	if(isnull(picked_snare))
		return
	qdel(picked_snare)
	to_chat(src, span_bolddanger("Snare disarmed."))

/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	invisibility = INVISIBILITY_ABSTRACT
	var/datum/weakref/guardian_ref

/obj/effect/snare/Initialize(mapload, spawning_guardian)
	. = ..()
	guardian_ref = WEAKREF(spawning_guardian)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/snare/Destroy(force)
	var/mob/living/simple_animal/hostile/guardian/ranged/spawning_guardian = guardian_ref?.resolve()
	if(spawning_guardian)
		spawning_guardian.snares -= src
	return ..()

/obj/effect/snare/proc/on_entered(datum/source, crossed_object)
	SIGNAL_HANDLER
	var/mob/living/simple_animal/hostile/guardian/ranged/spawning_guardian = guardian_ref?.resolve()
	if(!spawning_guardian)
		qdel(src)
		return
	if(!isliving(crossed_object) || crossed_object == spawning_guardian || spawning_guardian.hasmatchingsummoner(crossed_object))
		return
	send_message(spawning_guardian.summoner || spawning_guardian, crossed_object)

/obj/effect/snare/proc/send_message(mob/living/recipient, crossed_object)
	to_chat(recipient, span_bolddanger("[crossed_object] has crossed [name]."))
	var/list/guardians = recipient.get_all_linked_holoparasites()
	for(var/guardian in guardians)
		send_message(guardian, crossed_object)

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return

/mob/living/simple_animal/hostile/guardian/ranged/manifest_effects()
	if(toggle)
		incorporeal_move = INCORPOREAL_MOVE_BASIC

/mob/living/simple_animal/hostile/guardian/ranged/recall_effects()
	// To stop scout mode from moving when recalled
	incorporeal_move = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/AttackingTarget(atom/attacked_target)
	if(toggle)
		return
	return ..()
