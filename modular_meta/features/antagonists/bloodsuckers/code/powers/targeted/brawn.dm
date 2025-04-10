/datum/action/cooldown/bloodsucker/targeted/brawn
	name = "Brawn"
	desc = "Snap restraints, break lockers and doors, or deal substantial damage with your bare hands."
	button_icon_state = "power_strength"
	power_explanation = "Brawn:\n\
		Click a person to bash into them. Use while restrained or grabbed to break restraints or knock your grabber down. Only one of these can be done per use.\n\
		Punching a cyborg will heavily EMP them in addition to dealing damage.\n\
		At level 3, this ability will break closets open. Additionally you may both break restraints and knock a grabber down in the same use.\n\
		At level 4, this ability wlil bash airlocks open as long as they aren't bolted.\n\
		Higher levels will increase this ability's damage and knockdown."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 8
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

	/// Only changed by the '/brawn/brash' subtype; acts as a general purpose damage multipler.
	var/damage_coefficient = 1.25
	/// Boolean indicating whether or not this version of '/brawn' is in the '/brash' subtype and should
	/// bypass typical ability level restrictions. (There is probably a better way to do this.)
	var/brujah = FALSE

/datum/action/cooldown/bloodsucker/targeted/brawn/ActivatePower(trigger_flags)
	// Did we break out of our handcuffs?
	if(break_restraints())
		power_activated_sucessfully()
		return FALSE
	// Did we knock a grabber down? We can only do this while not also breaking restraints if strong enough.
	if(level_current >= 3 && escape_puller())
		power_activated_sucessfully()
		return FALSE
	// Did neither, now we can PUNCH.
	return ..()

// Look at 'biodegrade.dm' for reference
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_restraints()
	var/mob/living/carbon/human/user = owner
	///Only one form of shackles removed per use
	var/used = FALSE

	// Breaks out of lockers
	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		closet.visible_message(
			span_warning("[closet] tears apart as [user] bashes it open from within!"),
			span_warning("[closet] tears apart as you bash it open from within!"),
		)
		to_chat(user, span_warning("We bash [closet] wide open!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, closet), 1)
		used = TRUE

	// Remove both Handcuffs & Legcuffs
	var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(!used && (istype(cuffs) || istype(legcuffs)))
		user.visible_message(
			span_warning("[user] breaks their restraint like it's nothing!"),
			span_warning("We break through our restraint!"),
		)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
		used = TRUE

	// Remove Straightjackets
	if(user.wear_suit?.breakouttime && !used)
		var/obj/item/clothing/suit/straightjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		user.visible_message(
			span_warning("[user] rips straight through the [user.p_their()] [straightjacket]!"),
			span_warning("We tear through our [straightjacket]!"),
		)
		if(straightjacket && user.wear_suit == straightjacket)
			qdel(straightjacket)
		used = TRUE

	// Did we end up using our ability? If so, play the sound effect and return TRUE
	if(used)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, 1, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()

/datum/action/cooldown/bloodsucker/targeted/brawn/proc/escape_puller()
	if(!owner.pulledby) // || owner.pulledby.grab_state <= GRAB_PASSIVE)
		return FALSE
	var/mob/pulled_mob = owner.pulledby
	var/pull_power = pulled_mob.grab_state
	playsound(get_turf(pulled_mob), 'sound/effects/woodhit.ogg', 75, 1, -1)
	// Knock Down (if Living)
	if(isliving(pulled_mob))
		var/mob/living/hit_target = pulled_mob
		hit_target.Knockdown(pull_power * 10 + 20)
	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, pulled_mob)
	var/turf/turf_thrown_at = get_ranged_target_turf(pulled_mob, send_dir, pull_power)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	pulled_mob.throw_at(turf_thrown_at, pull_power, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.
	// /proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	log_combat(owner, pulled_mob, "used [src.name] power")
	owner.visible_message(
		span_warning("[owner] tears free of [pulled_mob]'s grasp!"),
		span_warning("You shrug off [pulled_mob]'s grasp!"),
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner

	// Target Type: Mob
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		//You know what I'm just going to take the average of the user's limbs max damage instead of dealing with 2 hands
		var/obj/item/bodypart/user_active_arm = carbonuser.get_active_hand()
		var/hitStrength = user_active_arm.unarmed_damage_high * damage_coefficient + 2
		// Knockdown!
		var/powerlevel = min(5, 1 + level_current)
		if(rand(5 + powerlevel) >= 5)
			target.visible_message(
				span_danger("[user] lands a vicious punch, sending [target] away!"), \
				span_userdanger("[user] has landed a horrifying punch on you, sending you flying!"),
			)
			target.Knockdown(min(5, rand(10, 10 * powerlevel)))
		// Attack!
		owner.balloon_alert(owner, "you punch [target]!")
		playsound(get_turf(target), 'sound/items/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		var/blocked = target.run_armor_check(affecting, MELEE, armour_penetration = (brujah ? 30 : 20))	//20 AP, will ignore light armor but not heavy stuff
		target.apply_damage(hitStrength, BRUTE, affecting, blocked)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, powerlevel, TRUE, owner) //new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)

	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet) && (level_current >= 3 || brujah))
		var/obj/structure/closet/target_closet = target_atom
		user.balloon_alert(user, "you prepare to bash [target_closet] open...")
		if(!do_after(user, 2.5 SECONDS, target_closet))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		target_closet.visible_message(span_danger("[target_closet] breaks open as [user] bashes it!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, target_closet), 1)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)

	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door) && (brujah ? level_current >= 2 : level_current >= 4))
		var/obj/machinery/door/airlock/target_airlock = target_atom
		playsound(get_turf(user), 'sound/machines/airlock/airlock_alien_prying.ogg', 40, TRUE, -1)
		owner.balloon_alert(owner, "you prepare to tear open [target_airlock]...")
		if(!do_after(user, 2.5 SECONDS, target_airlock))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		if(target_airlock.Adjacent(user))
			target_airlock.visible_message(span_danger("[target_airlock] breaks open as [user] bashes it!"))

			// Adjust cost and cooldown if Brujah
			if(brujah)
				if(target_airlock.locked)
					bloodcost = 20
					cooldown_time = 10 SECONDS
				else
					bloodcost = 10
					cooldown_time = 6 SECONDS
			else // If not Brujah then just make the vampire wait a second...
				user.Stun(10)

			user.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, 1, -1)
			if(brujah && level_current >= 3 && target_airlock.locked)
				target_airlock.unbolt()
			target_airlock.open(2) // open(2) is like a crowbar or jaws of life.

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(target_atom))
		return TRUE
	if(istype(target_atom, /obj/machinery/door))
		return TRUE
	if(istype(target_atom, /obj/structure/closet))
		return TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	if(!.) // Disable range notice for Brawn.
		return FALSE
	// Must outside Closet to target anyone!
	if(!isturf(owner.loc))
		return FALSE
