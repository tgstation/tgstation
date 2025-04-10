/************************************************************************/
/*								BRASH									*/
/************************************************************************/

/// A Brujah exclusive ability that acts as an enhanced version of "Brawn"
/// 'bloodcost' and 'cooldown_time' vary depending on what the power is used for.
/// Lots of code has been copied over from Brawn wherever inheritance might prove insufficient.
/// Comments from copied code have been removed (they can still be found in their original location.)

/datum/action/cooldown/bloodsucker/targeted/brawn/brash
	name = "Brash"
	desc = "Break most structures apart with overwhelming force. Cooldown and cost vary depending on the object broken."
	button_icon_state = "power_strength_brujah"
	power_explanation = "Brash:\n\
		This is an enhanced version of a regular (non-Brujah) vampire's \"Brawn\" ability.\n\
		Use on a person to send them flying. Use while restrained, grabbed, or trapped in a locker to break free.\n\
		Punching a cyborg will temporarily disable it in addition to usual damage. \n\
		At level 2 this ability will allow you to break through unbolted airlocks. \n\
		At level 3 this ability will allow you to break through bolted airlocks. \n\
		At level 4 this ability will allow you to break through normal walls and windows. \n\
		At level 5 this ability will allow you to break through reinforced walls and windows. \n\
		Higher levels will increase this ability's damage and knockdown."
	purchase_flags = BRUJAH_DEFAULT_POWER
	power_flags = BP_AM_VERY_DYNAMIC_COOLDOWN
	bloodcost = null		  // Set on use
	cooldown_time = 1 SECONDS // Same as above
	damage_coefficient = 1.625
	brujah = TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/brash/ActivatePower(trigger_flags)
	if(break_restraints())
		cooldown_time = 5 SECONDS
		bloodcost = 10
		power_activated_sucessfully()
		return FALSE
	if(level_current >= 1 && escape_puller())
		cooldown_time = 7.5 SECONDS
		bloodcost = 20
		power_activated_sucessfully()
		return FALSE
	return ..()

/// Hit an atom, set bloodcost, set cooldown time, play a sound, and deconstruct the atom
/// with this one convenient proc!
/datum/action/cooldown/bloodsucker/targeted/brawn/brash/proc/HitWithStyle(atom/target_atom, sound, vol as num, var/cost as num, var/cooldown)
	if(!isobj(target_atom))
		return
	var/obj/target_obj = target_atom
	owner.do_attack_animation(target_obj)
	bloodcost = cost
	cooldown_time = cooldown
	playsound(target_atom, sound, 75, TRUE)
	target_obj.deconstruct(FALSE)

/datum/action/cooldown/bloodsucker/targeted/brawn/brash/FireTargetedPower(atom/target_atom)
	. = ..()
	if(isliving(target_atom))
		bloodcost = 25
		cooldown_time = 10 SECONDS
		return

	if(istype(target_atom, /obj/structure/closet))
		bloodcost = 8
		cooldown_time = 7 SECONDS
		return

	if(istype(target_atom, /obj/structure/girder))
		HitWithStyle(target_atom, 'sound/effects/bang.ogg', 60, 10, 5 SECONDS)
		return

	if(istype(target_atom, /obj/structure/grille))
		HitWithStyle(target_atom, 'sound/effects/grillehit.ogg', 50, 1, 0.5 SECONDS)
		return

	if(istype(target_atom, /obj/structure/window))
		var/obj/structure/window/window = target_atom
		if(level_current < 4 || (istype(window, /obj/structure/window/reinforced) && level_current < 5))
			window.balloon_alert(owner, "you need more ranks!")
			return
		if(istype(window, /obj/structure/window/reinforced) || istype(window, /obj/structure/window/plasma))
			HitWithStyle(window, 'sound/effects/bang.ogg', 30, 25, 15 SECONDS)
		else
			HitWithStyle(window, 'sound/effects/bang.ogg', 20, 15, 10 SECONDS)
		return

	if(istype(target_atom, /obj/machinery/door/window))
		HitWithStyle(target_atom, 'sound/effects/bang.ogg', 50, 10, 5 SECONDS)
		return

	if(istype(target_atom, /obj/structure/table))
		HitWithStyle(target_atom, 'sound/effects/bang.ogg', 35, 10, 5 SECONDS)

	if(!iswallturf(target_atom))
		return
	if(level_current < 4 || (istype(target_atom, /turf/closed/wall/r_wall) && level_current < 5))
		target_atom.balloon_alert(owner, "you need more ranks!")
		return
	if(isindestructiblewall(target_atom))
		target_atom.balloon_alert(owner, "this wall is indestructible!")
		return

	/// If we get past all of the if statements then it's almost certainly a wall at this point.
	rip_and_tear(owner, target_atom)

/// Copied over from '/datum/element/wall_tearer/proc/rip_and_tear' with appropriate adjustment.
/datum/action/cooldown/bloodsucker/targeted/brawn/brash/proc/rip_and_tear(mob/living/tearer, atom/target)
	var/tear_time = 0.75 SECONDS
	var/reinforced_multiplier = 5
	var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time)

	if(istype(target, /turf/closed/wall/r_wall))
		bloodcost = 40
		cooldown_time = 20 SECONDS
	else
		bloodcost = 20
		cooldown_time = 15 SECONDS

	while(istype(target, /turf/closed/wall))
		tearer.visible_message(span_warning("[tearer] viciously rips into [target]!"))
		playsound(tearer, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 50, vary = TRUE, frequency = 2)
		target.balloon_alert(tearer, "tearing...")

		if (!do_after(tearer, delay = rip_time, target = target, interaction_key = "bloodsucker interaction"))
			tearer.balloon_alert(tearer, "interrupted!")
			return

		tearer.do_attack_animation(target)
		target.AddComponent(/datum/component/torn_wall)
		tearer.UnarmedAttack(target, proximity_flag = TRUE)

/// TODO: check if switch statements work with istype()
/// and maybe refactor 'CheckValidTarget()'/'CheckCanTarget()' entirely
/datum/action/cooldown/bloodsucker/targeted/brawn/brash/CheckValidTarget(atom/A)
	if(A == owner)
		return FALSE
	if(INDESTRUCTIBLE in A.resistance_flags)
		return FALSE
	if(isliving(A))
		return TRUE
	if(istype(A, /obj/machinery/door))
		return TRUE
	if(istype(A, /obj/structure/table) || istype(A, /obj/structure/table_frame))
		return TRUE
	if(istype(A, /obj/structure/closet))
		return TRUE
	if(istype(A, /obj/structure/girder))
		return TRUE
	if(istype(A, /obj/structure/grille))
		return TRUE
	if(((iswallturf(A) && !isindestructiblewall(A))) || istype(A, /obj/structure/window))
		return TRUE
	return FALSE
