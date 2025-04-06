
/obj/hitby(atom/movable/hit_by, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	var/damage_taken = hit_by.throwforce
	if(isitem(hit_by))
		var/obj/item/as_item = hit_by
		damage_taken *= as_item.demolition_mod
	take_damage(damage_taken, BRUTE, MELEE, 1, get_dir(src, hit_by))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE

	. = ..() //contents explosion
	if(QDELETED(src))
		return TRUE
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return TRUE
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

	return TRUE

/obj/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if(. != BULLET_ACT_HIT)
		return .

	var/damage_sustained = 0
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		damage_sustained = take_damage(
			hitting_projectile.damage * hitting_projectile.demolition_mod,
			hitting_projectile.damage_type,
			hitting_projectile.armor_flag,
			FALSE,
			REVERSE_DIR(hitting_projectile.dir),
			hitting_projectile.armour_penetration,
		)
	if(hitting_projectile.suppressed != SUPPRESSED_VERY)
		visible_message(
			span_danger("[src] is hit by \a [hitting_projectile][damage_sustained ? "" : ", [no_damage_feedback]"]!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
		)

	return damage_sustained > 0 ? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/obj/attack_hulk(mob/living/carbon/human/user)
	..()
	if(density)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	var/damage = take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
	user.visible_message(span_danger("[user] smashes [src][damage ? "" : ", [no_damage_feedback]"]!"), span_danger("You smash [src][damage ? "" : ", [no_damage_feedback]"]!"), null, COMBAT_MESSAGE_RANGE)
	return TRUE

/obj/blob_act(obj/structure/blob/B)
	if (!..())
		return
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src.loc, 'sound/items/weapons/slash.ogg', 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(!user.melee_damage_upper && !user.obj_damage)
		user.emote("custom", message = "[user.friendly_verb_continuous] [src].")
		return FALSE
	else
		var/turf/current_turf = get_turf(src) //we want to save the turf to play the sound there, cause being destroyed deletes us!
		var/play_soundeffect = user.environment_smash
		if(user.obj_damage)
			. = attack_generic(user, user.obj_damage, user.melee_damage_type, MELEE, play_soundeffect, user.armour_penetration)
		else
			. = attack_generic(user, rand(user.melee_damage_lower,user.melee_damage_upper), user.melee_damage_type, MELEE, play_soundeffect, user.armour_penetration)
		if(. && play_soundeffect)
			playsound(current_turf, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		if(user.client)
			log_combat(user, src, "attacked")

/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE, attack_dir = REVERSE_DIR(direction))

/obj/singularity_act()
	SSexplosions.high_mov_atom += src
	if(src && !QDELETED(src))
		qdel(src)
	return 2


///// ACID

///the obj's reaction when touched by acid
/obj/acid_act(acidpwr, acid_volume)
	. = ..()
	if((resistance_flags & UNACIDABLE) || (acid_volume <= 0) || (acidpwr <= 0))
		return FALSE

	AddComponent(/datum/component/acid, acidpwr, acid_volume, custom_acid_overlay || GLOB.acid_overlay)
	return TRUE

///called when the obj is destroyed by acid.
/obj/proc/acid_melt()
	deconstruct(FALSE)

//// FIRE

///Called when the obj is exposed to fire.
/obj/fire_act(exposed_temperature, exposed_volume)
	if(isturf(loc))
		var/turf/our_turf = loc
		if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		AddComponent(/datum/component/burning, custom_fire_overlay || GLOB.fire_overlay, burning_particles)
		SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
		return TRUE
	return ..()

/// Should be called when the atom is destroyed by fire, comparable to acid_melt() proc
/obj/proc/burn()
	deconstruct(FALSE)

///Called when the obj is hit by a tesla bolt.
/obj/zap_act(power, zap_flags)
	if(QDELETED(src))
		return 0
	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	return power / 2

//The surgeon general warns that being buckled to certain objects receiving powerful shocks is greatly hazardous to your health
///Only tesla coils, vehicles, and grounding rods currently call this because mobs are already targeted over all other objects, but this might be useful for more things later.
/obj/proc/zap_buckle_check(strength)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act((clamp(round(strength * 1.25e-3), 10, 90) + rand(-5, 5)), src, flags = SHOCK_TESLA)

/**
 * Custom behaviour per atom subtype on how they should deconstruct themselves
 * Arguments
 *
 * * disassembled - TRUE means we cleanly took this atom apart using tools. FALSE means this was destroyed in a violent way
 */
/obj/proc/atom_deconstruct(disassembled = TRUE)
	PROTECTED_PROC(TRUE)

	return

/**
 * The interminate proc between deconstruct() & atom_deconstruct(). By default this delegates deconstruction to
 * atom_deconstruct if NO_DEBRIS_AFTER_DECONSTRUCTION is absent but subtypes can override this to handle NO_DEBRIS_AFTER_DECONSTRUCTION in their
 * own unique way. Override this if for example you want to dump out important content like mobs from the
 * atom before deconstruction regardless if NO_DEBRIS_AFTER_DECONSTRUCTION is present or not
 * Arguments
 *
 * * disassembled - TRUE means we cleanly took this atom apart using tools. FALSE means this was destroyed in a violent way
 */
/obj/proc/handle_deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(FALSE)

	if(!(obj_flags & NO_DEBRIS_AFTER_DECONSTRUCTION))
		atom_deconstruct(disassembled)

/**
 * The obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
 * Arguments
 *
 * * disassembled - TRUE means we cleanly took this atom apart using tools. FALSE means this was destroyed in a violent way
 */
/obj/proc/deconstruct(disassembled = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	//allow objects to deconstruct themselves
	handle_deconstruct(disassembled)

	//inform objects we were deconstructed
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)

	//delete our self
	qdel(src)

///what happens when the obj's integrity reaches zero.
/obj/atom_destruction(damage_flag)
	. = ..()
	if(damage_flag == ACID)
		acid_melt()
	else if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

///returns how much the object blocks an explosion. Used by subtypes.
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
