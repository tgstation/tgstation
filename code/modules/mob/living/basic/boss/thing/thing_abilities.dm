/obj/structure/thing_boss_spike
	name = "blades"
	desc = "A sharp flurry of blades that have erupted from the ground."
	icon_state = "thingspike"
	density = FALSE //so ai considers it
	anchored = TRUE
	max_integrity = 1 // 1 hit
	/// time before we fall apart
	var/expiry_time = 10 SECONDS

/obj/structure/thing_boss_spike/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
#ifndef UNIT_TESTS //just in case
	new /obj/effect/temp_visual/mook_dust(loc)
#endif
	var/hit_someone = FALSE
	for(var/atom/movable/potential_target as anything in our_turf)
		if (ismegafauna(potential_target) || potential_target == src)
			continue
		var/mob/living/living_victim = potential_target
		if(isliving(living_victim))
			hit_someone = TRUE
			living_victim.apply_damage(40, damagetype = BRUTE, sharpness = SHARP_POINTY)
		else if(potential_target.uses_integrity && !(potential_target.resistance_flags & INDESTRUCTIBLE) && !isitem(potential_target) && !HAS_TRAIT(potential_target, TRAIT_UNDERFLOOR))
			potential_target.take_damage(100, BRUTE)
	if (hit_someone)
		expiry_time /= 2
		playsound(src, 'sound/items/weapons/slice.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	else
		playsound(src, 'sound/misc/splort.ogg', vol = 25, vary = TRUE, pressure_affected = FALSE)

	QDEL_IN(src, expiry_time)

/obj/structure/thing_boss_spike/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_amount)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
	else
		playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)

/obj/structure/thing_boss_spike/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!istype(mover, /mob/living/basic/boss/thing))
		return FALSE

/obj/structure/thing_boss_spike/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!istype(pass_info.caller_ref?.resolve(), /mob/living/basic/boss/thing))
		return FALSE
	return ..()

/obj/effect/temp_visual/telegraphing/exclamation
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "exclamation"
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/exclamation/Initialize(mapload, duration)
	if(!isnull(duration))
		src.duration = duration
	return ..()

/obj/effect/temp_visual/telegraphing/exclamation/animated
	alpha = 0

/obj/effect/temp_visual/telegraphing/exclamation/animated/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	animate(src, alpha = 255, transform = matrix(), time = duration/3)

/obj/effect/temp_visual/telegraphing/big
	icon = 'icons/mob/telegraphing/telegraph_96x96.dmi'
	icon_state = "target_largebox"
	pixel_x = -32
	pixel_y = -32
	color = COLOR_RED
	duration = 2 SECONDS

/datum/action/cooldown/mob_cooldown/the_thing
	shared_cooldown = MOB_SHARED_COOLDOWN_3
	/// in what phases of The Thing bossfight is this available
	var/list/available_in_phases = list(1,2,3)

/datum/action/cooldown/mob_cooldown/the_thing/IsAvailable(feedback)
	var/mob/living/basic/boss/thing/the_thing = owner
	if(!istype(the_thing))
		return ..()
	return ..() && !!(the_thing.phase in available_in_phases)

/datum/action/cooldown/mob_cooldown/the_thing/decimate
	name = "Decimate"
	desc = "Create spikes in a radius."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = FALSE
	cooldown_time = 10 SECONDS

/datum/action/cooldown/mob_cooldown/the_thing/decimate/Activate(atom/caster)
	if(HAS_TRAIT_FROM(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	. = ..()

	ADD_TRAIT(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	caster.Shake(1.4, 0.8, 0.3 SECONDS)
	caster.visible_message(span_danger("[caster] shakes violently!"))

	for(var/turf/open/target in RANGE_TURFS(2, caster) - caster.loc)
		new /obj/effect/temp_visual/telegraphing/exclamation/animated(target, 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(make_spikes), caster), 1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/the_thing/decimate/proc/make_spikes(atom/caster)
	REMOVE_TRAIT(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	for(var/turf/open/target in RANGE_TURFS(2, caster))
		if(locate(/obj/structure/thing_boss_spike) in target)
			continue
		new /obj/structure/thing_boss_spike(target)

/datum/action/cooldown/mob_cooldown/charge/the_thing
	shared_cooldown = NONE
	charge_damage = 35
	charge_past = 3

/datum/action/cooldown/mob_cooldown/charge/the_thing/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	if(HAS_TRAIT_FROM(owner, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	var/mob/living/basic/boss/thing/the_thing = owner
	var/charge_count = the_thing.phase != 3 ? 1 : 2
	for(var/i in 1 to charge_count)
		do_charge(owner, target_atom, charge_delay * i, charge_past)

/datum/action/cooldown/mob_cooldown/charge/the_thing/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/telegraphing/exclamation/animated(target_turf)
	var/obj/effect/temp_visual/decoy/decoy = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(decoy, alpha = 0, color = COLOR_RED, transform = matrix()*2, time = 3)

/datum/action/cooldown/mob_cooldown/charge/the_thing/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	target.visible_message(span_danger("[source] lunges into [target]!"), span_userdanger("[source] knocks you into the ground, slashing you in the process!"))
	target.apply_damage(damage_dealt, BRUTE)
	target.Knockdown(1 SECONDS)
	playsound(get_turf(target), 'sound/items/weapons/rapierhit.ogg', 100, TRUE)
	shake_camera(target, 4, 3)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils
	name = "Square Tendrils"
	desc = "Create spikes in a square around the target."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	cooldown_time = 5 SECONDS
	available_in_phases = list(2,3)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils/Activate(atom/target)
	if(HAS_TRAIT_FROM(owner, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	. = ..()
	target = get_turf(target)
	var/mob/living/living_owner = owner
	var/delay = 1 SECONDS
	if((living_owner.health <= living_owner.maxHealth/3) ? 2 : 1)
		delay += 1 SECONDS
		new /obj/effect/temp_visual/telegraphing/big(target, delay)
	else
		new /obj/effect/temp_visual/telegraphing/exclamation/animated(target)
	addtimer(CALLBACK(src, PROC_REF(make_spikes), target), delay)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils/proc/make_spikes(atom/epicenter)
	var/mob/living/living_owner = owner
	var/radius = living_owner.health <= living_owner.maxHealth/3 ? 2 : 1
	for(var/turf/open/target in RANGE_TURFS(radius, epicenter))
		if(locate(/obj/structure/thing_boss_spike) in target)
			continue
		new /obj/effect/temp_visual/mook_dust(target)
		new /obj/structure/thing_boss_spike(target)

/datum/action/cooldown/mob_cooldown/the_thing/shriek
	name = "Shriek"
	desc = "Confuse in a radius."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = FALSE
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE
	available_in_phases = list(2,3)

/datum/action/cooldown/mob_cooldown/the_thing/shriek/Activate(atom/caster)
	if(HAS_TRAIT_FROM(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	. = ..()
	ADD_TRAIT(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	caster.visible_message(span_danger("[caster][caster.p_s()] flesh starts becoming filled with holes!"))
	for(var/turf/open/target in RANGE_TURFS(2, caster))
		new /obj/effect/temp_visual/telegraphing/exclamation(target, 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shriek), owner), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/the_thing/shriek/proc/shriek(atom/caster)
	REMOVE_TRAIT(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	caster.visible_message(span_danger("[caster] shrieks! The sheer frequency of the sound makes your skin hurt and you feel like your brain is on fire!"))
	SEND_SOUND(caster, sound('sound/effects/screech.ogg'))
	for(var/turf/open/target_turf in RANGE_TURFS(2, caster))
		for(var/mob/living/target in target_turf)
			if(target == owner)
				continue
			target.set_confusion_if_lower(5 SECONDS)
			target.set_jitter_if_lower(5 SECONDS)
			var/mob/living/carbon/carbon_target = target
			if(istype(carbon_target))
				carbon_target.drop_all_held_items()
			SEND_SOUND(target, sound('sound/effects/screech.ogg'))

/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils
	name = "Cardinal Tendrils"
	desc = "Create tendrils in all cardinal directions."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	cooldown_time = 10 SECONDS
	available_in_phases = list(2,3)
	click_to_activate = FALSE
	/// range of tendril
	var/range = 9

/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils/Activate(atom/targetted_turf)
	if(HAS_TRAIT_FROM(owner, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	. = ..()
	targetted_turf = get_turf(targetted_turf)
	owner.Shake(1.4, 0.8, 0.3 SECONDS)
	owner.visible_message(span_danger("[owner] shakes violently!"))
	var/list/turf/target_turfs = find_turfs(targetted_turf)
	for(var/turf/open/target in target_turfs)
		new /obj/effect/temp_visual/telegraphing/exclamation/animated(target, 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(make_spikes), target_turfs, owner), 1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils/proc/find_turfs(atom/caster)
	. = list()
	for(var/direction in GLOB.cardinals)
		for(var/turf/potential_turf as anything in get_line(caster, get_ranged_target_turf(caster, direction, range)))
			if(potential_turf.density)
				break
			. += potential_turf

/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils/proc/make_spikes(list/target_turfs, atom/caster)
	REMOVE_TRAIT(caster, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	for(var/turf/open/target as anything in target_turfs)
		if(locate(/obj/structure/thing_boss_spike) in target)
			continue
		new /obj/effect/temp_visual/mook_dust(target)
		new /obj/structure/thing_boss_spike(target)

/datum/action/cooldown/mob_cooldown/the_thing/acid_spit
	name = "Acid Shower"
	desc = "Spit patches of acid in a radius around you."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	cooldown_time = 10 SECONDS
	click_to_activate = FALSE
	available_in_phases = list(3)

/datum/action/cooldown/mob_cooldown/the_thing/acid_spit/Activate(atom/target)
	if(HAS_TRAIT_FROM(owner, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return
	. = ..()
	var/turf/owner_turf = get_turf(owner)
	owner.visible_message(span_danger("[owner] spits acid!"))
	var/list/potential = list()
	for(var/turf/open/turf in RANGE_TURFS(6, owner_turf))
		potential += turf

	for(var/i = 1 to rand(2,4))
		new /obj/effect/temp_visual/incoming_thing_acid(pick(potential))

/obj/effect/temp_visual/incoming_thing_acid
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "toxin"
	name = "acid"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 0.9 SECONDS
	pixel_z = 270

/obj/effect/temp_visual/incoming_thing_acid/Initialize(mapload)
	. = ..()
	animate(src, pixel_z = 0, time = duration)
	addtimer(CALLBACK(src, PROC_REF(make_acid)), 0.85 SECONDS)

/obj/effect/temp_visual/incoming_thing_acid/proc/make_acid()
	for(var/turf/open/open in RANGE_TURFS(1, loc))
		new /obj/effect/thing_acid(open)

/obj/effect/thing_acid
	name = "stomach acid"
	icon = 'icons/effects/acid.dmi'
	icon_state = "default"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// how long does the acid exist for
	var/duration_time = 5 SECONDS

/obj/effect/thing_acid/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	QDEL_IN(src, duration_time)

/obj/effect/thing_acid/proc/on_entered(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || ismegafauna(victim))
		return
	for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/blocked = victim.run_armor_check(zone, ACID)
		victim.apply_damage(25, BURN, def_zone = zone, blocked = blocked)
	to_chat(victim, span_userdanger("You are burnt by the acid!"))
	playsound(victim, 'sound/effects/wounds/sizzle1.ogg', vol = 50, vary = TRUE)
	qdel(src)
