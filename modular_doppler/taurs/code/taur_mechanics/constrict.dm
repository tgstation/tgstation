/// When a mob is constricted, its pixel_x will be modified by this. Reverted on unconstriction. Modified by sprite scaling.
#define CONSTRICT_BASE_PIXEL_SHIFT 12
/// The base chance a mob has to escape from a constriction.
#define CONSTRICT_ESCAPE_CHANCE 25

/datum/action/innate/constrict
	name = "Constrict"
	desc = "<b>Left click</b> to coil/uncoil your powerful tail around something, <b>right click</b> to begin crushing."
	check_flags = AB_CHECK_LYING|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_PHASED

	button_icon = 'modular_doppler/taurs/icons/taur_mechanics/ability.dmi'
	button_icon_state = "constrict"

	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'

	click_action = TRUE

	/// The tail we use to constrict mobs with. Nullable, if inactive.
	var/obj/structure/serpentine_tail/tail
	/// The base time it takes for us to constrict a mob.
	var/base_coil_delay = 1.2 SECONDS

/datum/action/innate/constrict/Destroy()
	qdel(tail) // we already listen for COMSIG_QDELETING on our tail, so it already sets it to null via the signal
	return ..()

/datum/action/innate/constrict/Trigger(trigger_flags)
	if(!..())
		return FALSE

	if (trigger_flags & TRIGGER_SECONDARY_ACTION)
		unset_ranged_ability(owner)
		if (isnull(tail))
			owner.balloon_alert(owner, "coil tail first!")
			return FALSE
		tail.toggle_crushing()
		return FALSE
	return TRUE

/datum/action/innate/constrict/do_ability(mob/living/clicker, atom/clicked_on)
	if (!isliving(clicked_on))
		if (tail)
			qdel(tail)
			return TRUE

		create_tail()
		return TRUE

	var/mob/living/living_target = clicked_on

	if (living_target == clicker)
		return TRUE

	if (!can_coil_target(living_target))
		return TRUE

	clicker.balloon_alert_to_viewers("starts coiling tail")
	clicker.visible_message(span_warning("[clicker] starts coiling [clicker.p_their()] tail around [living_target]..."), span_notice("You start coiling your tail around [living_target]..."), ignored_mobs = list(living_target))
	to_chat(living_target, span_userdanger("[clicker] starts coiling [clicker.p_their()] tail around you!"))

	owner.changeNext_move(base_coil_delay) // prevent interaction during this
	unset_ranged_ability(owner) // because we sleep
	var/result = do_after(clicker, base_coil_delay, living_target, IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(can_coil_target), living_target))
	owner.changeNext_move(-base_coil_delay)
	if (!result)
		return TRUE

	do_constriction(living_target)
	return TRUE

/// Actually constricts the mob, by setting constricted to this mob and spawning a tail if needed.
/datum/action/innate/constrict/proc/do_constriction(mob/living/living_target)
	owner.visible_message(span_boldwarning("[owner] coils [owner.p_their()] tail around [living_target]!"), span_notice("You coil your tail around [living_target]!"), ignored_mobs = list(living_target))
	to_chat(living_target, span_userdanger("[owner] coils [owner.p_their()] tail around you!"))
	create_tail()
	tail.set_constricted(living_target)
	return TRUE

/// Returns TRUE if the target can be constricted, FALSE otherwise. If silent is TRUE, sends no feedback messages.
/datum/action/innate/constrict/proc/can_coil_target(mob/living/target, silent = FALSE)
	if (!owner.Adjacent(target))
		if (!silent)
			owner.balloon_alert(owner, "too far!")
		return FALSE

	if (target.buckled)
		if (!silent)
			owner.balloon_alert(owner, "unbuckle [target.p_them()] first!")
		return FALSE

	if (owner.buckled)
		if (!silent)
			owner.balloon_alert(owner, "unbuckle yourself first!")
		return FALSE

	return TRUE

/// If we have no tail, sets our tail to a new tail instance.
/datum/action/innate/constrict/proc/create_tail()
	RETURN_TYPE(/obj/structure/serpentine_tail)

	if (isnull(tail))
		set_tail(new /obj/structure/serpentine_tail(owner.loc, owner))
	return tail

/// Setter proc for tail. Handles signals.
/datum/action/innate/constrict/proc/set_tail(obj/structure/serpentine_tail/new_tail)
	if (tail)
		UnregisterSignal(tail, COMSIG_QDELETING)

	tail = new_tail

	if (tail)
		RegisterSignal(tail, COMSIG_QDELETING, PROC_REF(tail_qdeleting))

	return tail

/// Signal handler for COMSIG_QDELETING. Sets our tail to null.
/datum/action/innate/constrict/proc/tail_qdeleting(datum/signal_source)
	SIGNAL_HANDLER

	set_tail(null)

/obj/structure/serpentine_tail
	name = "serpentine tail"
	desc = "A scaley tail, currently coiled."

	icon = 'modular_doppler/taurs/icons/taur_mechanics/tail.dmi'
	icon_state = "naga"
	pixel_x = -16

	can_buckle = TRUE
	buckle_lying = FALSE
	layer = ABOVE_OBJ_LAYER
	anchored = TRUE
	density = FALSE
	max_integrity = 60

	/// The overlay for our coiled tail.
	var/mutable_appearance/tail_overlay

	/// The mob we are originating from.
	var/mob/living/carbon/human/owner

	/// The mob we are currently constricting, usually coincides with what we have buckled to us. Nullable.
	var/mob/living/constricted
	/// The pixel shift we have applied to constricted. Is null if constricted is null. Used to unapply it.
	var/applied_x_shift

	/// If we're currently allowing constricted to be grabbed. Only briefly true, during set_constricted.
	var/allowing_grab_on_constricted = FALSE

	/// Are we currently crushing constricted?
	var/currently_crushing = FALSE
	/// The amount of brute damage we will do per second to constricted if we are crushing.
	var/brute_per_second = 3
	/// How likely are we, per second, to cause a blunt wound on constricted if we are crushing?
	var/chance_to_cause_wound = 5

	/// Chance, per second, of us causing losebreath for a constricted target we are crushing.
	var/chance_to_losebreath = 55
	/// Assuming we proc chance_to_losebreath, this is the losebreath we will inflict on our target.
	var/losebreath_to_cause = 2 // above 1 to allow potential suffocation

	/// If we try to do crush damage and total below 5 (the minimum wounding amount), we store it here for next time.
	var/stored_damage = 0

	/// Used for escaping the tail, separate from grab cooldowns.
	COOLDOWN_DECLARE(escape_cooldown)

/obj/structure/serpentine_tail/New(loc, mob/living/carbon/human/new_owner)
	if (isnull(new_owner))
		qdel(src) // requires an owner, not stack tracing because it fails tests
		return FALSE

	set_owner(new_owner)

	return ..()

/obj/structure/serpentine_tail/Initialize(mapload)
	. = ..()

	add_tail_overlay()
	sync_sprite()

/// If we have no tail overlay, creates a new one and sets it up.
/obj/structure/serpentine_tail/proc/add_tail_overlay()
	RETURN_TYPE(/mutable_appearance)

	if (tail_overlay)
		return tail_overlay // we already have it

	tail_overlay = mutable_appearance('modular_doppler/taurs/icons/taur_mechanics/tail.dmi', "naga_top", ABOVE_MOB_LAYER + 0.01, src)
	tail_overlay.appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER
	tail_overlay.setDir(owner.dir)
	add_overlay(tail_overlay)

	return tail_overlay

/obj/structure/serpentine_tail/Destroy()
	INVOKE_ASYNC(src, PROC_REF(set_constricted), null) // safe - the only time it can potentially sleep is if we dont pass in null
	var/mob/living/carbon/human/old_owner = owner
	set_owner(null)

	old_owner?.update_body_parts()

	tail_overlay = null
	return ..()

/// Since slimepeople are transparent, we have to match their alpha. What our alpha is set to when our owner is a slime.
#define SERPENTINE_TAIL_SLIME_ALPHA 130


/// Syncs our colors, size, sprite, etc. with owner.
/obj/structure/serpentine_tail/proc/sync_sprite()
	//coloring
	var/list/finished_list = list()

	finished_list += rgb2num("[owner.dna.features["taur_color_1"]]00")
	finished_list += rgb2num("[owner.dna.features["taur_color_2"]]00")
	finished_list += rgb2num("[owner.dna.features["taur_color_3"]]00")

	finished_list += list(0, 0, 0, 255)
	for(var/index in 1 to finished_list.len)
		finished_list[index] /= 255

	color = finished_list
	if(isslimeperson(owner) || isjellyperson(owner)) // slimes are translucent
		alpha = SERPENTINE_TAIL_SLIME_ALPHA

	var/scale_multiplier = get_scale_change_mult()
	// If our owner is big and we scale, we need to move to the side so we remain aligned with them.
	var/translate = ((scale_multiplier-1) * 32)/2
	transform = transform.Scale(scale_multiplier)
	transform = transform.Translate(0, translate) // re-align ourselves
	appearance_flags = PIXEL_SCALE

	sync_direction()

#undef SERPENTINE_TAIL_SLIME_ALPHA

/// Syncs our dir with our owner. Fails to sync if we have a constricted mob and we move in a way that would spin them around.
/obj/structure/serpentine_tail/proc/sync_direction()
	SIGNAL_HANDLER

	if (dir == owner.dir)
		return

	if (constricted)
		/// Assoc list of stringified dir to dir. Controls what dir we can switch to from any given dir.
		var/static/list/switchable_dirs = list(
		"[NORTH]" = EAST,
		"[EAST]" = NORTH,
		"[WEST]" = SOUTH,
		"[SOUTH]" = WEST
	)
		// prevents snakes from spinning their victims around
		var/switchable_dir = switchable_dirs["[dir]"]
		if (switchable_dir != owner.dir)
			return

	dir = owner.dir
	tail_overlay.setDir(owner.dir)

/// Returns the scale, compared to default, our owner has.
/obj/structure/serpentine_tail/proc/get_scale_change_mult()
	return owner.current_size / RESIZE_DEFAULT_SIZE

/// Returns the x shift for anything we constrict.
/obj/structure/serpentine_tail/proc/get_constriction_pixel_x_shift()
	var/static/list/dirs_to_shift = list( // stringified since dirs are numbers
		"[SOUTH]" = CONSTRICT_BASE_PIXEL_SHIFT,
		"[WEST]" = CONSTRICT_BASE_PIXEL_SHIFT,
		"[NORTH]" = -CONSTRICT_BASE_PIXEL_SHIFT,
		"[EAST]" = -CONSTRICT_BASE_PIXEL_SHIFT,
	)

	return dirs_to_shift["[owner.dir]"]

/obj/structure/serpentine_tail/process(seconds_per_tick)
	stored_damage += (brute_per_second * seconds_per_tick)
	if (stored_damage < WOUND_MINIMUM_DAMAGE)
		return
	var/losebreath = 0
	if (SPT_PROB(chance_to_losebreath, seconds_per_tick))
		losebreath += losebreath_to_cause
	squeeze_constricted(stored_damage, losebreath, SPT_PROB(chance_to_cause_wound, seconds_per_tick))
	stored_damage = 0

/// The minimum wound bonus caused by a forced wound in squeeze_constricted.
#define CONSTRICTED_FORCE_WOUND_BONUS_MIN 40
/// The maximum wound bonus caused by a forced wound in squeeze_constricted.
#define CONSTRICTED_FORCE_WOUND_BONUS_MAX 70

/**
 * Attempts to squeeze constricted with ourselves, dealing blunt brute damage to them based on the damage arg.
 *
 * Arguments:
 * * damage: Float - The numerical damage to apply, with MELEE armor flag and BLUNT wounding type.
 * * force_wound: Boolean - If we should force a wound to be applied to constricted.
 *
 * Returns:
 * * FALSE if we aborted trying to inflict damage, TRUE otherwise.
 */
/obj/structure/serpentine_tail/proc/squeeze_constricted(damage, losebreath_to_use, force_wound = FALSE)
	if (!constricted)
		return FALSE

	constricted.losebreath += losebreath_to_use

	if (damage <= 0)
		return FALSE

	var/armor = constricted.run_armor_check(attack_flag = MELEE)
	var/wound_bonus = 0
	if (force_wound)
		wound_bonus += rand(CONSTRICTED_FORCE_WOUND_BONUS_MIN, CONSTRICTED_FORCE_WOUND_BONUS_MAX)
	var/def_zone = null
	if (iscarbon(constricted))
		var/mob/living/carbon/carbon_target = constricted
		def_zone = pick(carbon_target.bodyparts)
	constricted.apply_damage(stored_damage, BRUTE, def_zone = def_zone, blocked = armor, wound_bonus = wound_bonus)
	owner.visible_message(span_warning("[owner] squeezes [constricted] with [owner.p_their()] tail!"), span_danger("You squeeze [constricted] with your tail!"), ignored_mobs = list(constricted))
	to_chat(constricted, span_warning("[owner] squeezes you with [owner.p_their()] tail!"))
	return TRUE

#undef CONSTRICTED_FORCE_WOUND_BONUS_MIN
#undef CONSTRICTED_FORCE_WOUND_BONUS_MAX


/// The damage dealt to a serpentine tail's owner apon its destruction.
#define SERPENTINE_TAIL_DESTRUCTION_OWNER_BRUTE_DAMAGE 30
/// The chance that the damage dealt to a destroyed tail's owner goes to the right leg over the left leg.
#define SERPENTINE_TAIL_DESTRUCTION_R_LEG_CHANCE 50

/obj/structure/serpentine_tail/atom_destruction(damage_flag)
	/// Assoc list of [damage_flag -> damage_type], e.g. ACID = BURN.
	var/static/list/damage_flags_to_types = list(
		ACID = BURN,
		LASER = BURN,
		ENERGY = BURN,
		BIO = BURN,
		FIRE = BURN,
		CONSUME = BRUTE,
		MELEE = BRUTE,
		BULLET = BRUTE,
		BOMB = BRUTE,
	)

	var/damage_type = damage_flags_to_types[damage_flag]
	if (!damage_type)
		damage_type = BRUTE

	var/obj/item/bodypart/def_zone = owner.get_bodypart(BODY_ZONE_L_LEG)
	if (!def_zone || rand(SERPENTINE_TAIL_DESTRUCTION_R_LEG_CHANCE))
		def_zone = owner.get_bodypart(BODY_ZONE_R_LEG)
	if (!def_zone)
		def_zone = owner.get_bodypart(BODY_ZONE_CHEST)

	to_chat(owner, span_userdanger("You recall your tail as a sharp pain shoots through it!"))
	owner.apply_damage(SERPENTINE_TAIL_DESTRUCTION_OWNER_BRUTE_DAMAGE, damage_type, def_zone)

	return ..()

#undef SERPENTINE_TAIL_DESTRUCTION_OWNER_BRUTE_DAMAGE
#undef SERPENTINE_TAIL_DESTRUCTION_R_LEG_CHANCE

/// Setter proc for constricted. Handles signals, pixel shifting, status effects, etc.
/obj/structure/serpentine_tail/proc/set_constricted(mob/living/target)
	if (constricted == target)
		return

	if (currently_crushing && !target)
		stop_crushing()

	if (constricted)
		unregister_constricted()
		unapply_pixel_shift()
		constricted.remove_status_effect(/datum/status_effect/constricted)

	constricted = target

	if (!constricted)
		return

	register_constricted()
	apply_pixel_shift()
	constricted.apply_status_effect(/datum/status_effect/constricted)

	restrain_constricted()

/// Applies our pixel shift to our constricted. Do not call if we have already applied our pixel shift.
/obj/structure/serpentine_tail/proc/apply_pixel_shift()
	if (!constricted)
		return FALSE

	if (!isnull(applied_x_shift)) // this isnt a proc to call willy nilly so this is fine
		stack_trace("apply_pixel_shift called with a non-null applied_x_shift! value: [applied_x_shift]")
		return FALSE

	var/pixel_shift = get_constriction_pixel_x_shift()
	var/scale_change_mult = get_scale_change_mult()
	var/final_shift = (pixel_shift * scale_change_mult)

	constricted.pixel_x += final_shift
	applied_x_shift = final_shift

	return TRUE

/// Unapplies our pixel shift to our constricted. Do not call if we have not applied our pixel shift.
/obj/structure/serpentine_tail/proc/unapply_pixel_shift()
	if (!constricted)
		return FALSE

	if (isnull(applied_x_shift))
		stack_trace("unapply_pixel_shift called with a null applied_x_shift!")
		return FALSE

	constricted.pixel_x -= applied_x_shift
	applied_x_shift = null

	return TRUE

/// Registers signals to constricted.
/obj/structure/serpentine_tail/proc/register_constricted()
	RegisterSignal(constricted, COMSIG_MOVABLE_MOVED, PROC_REF(constricted_moved))
	RegisterSignal(constricted, COMSIG_ATOM_EXAMINE, PROC_REF(constricted_examined))
	RegisterSignal(constricted, COMSIG_LIVING_TRY_PULL, PROC_REF(constricted_tried_pull))
	RegisterSignal(constricted, COMSIG_QDELETING, PROC_REF(constricted_qdeleting))

/// Unregisters signals to constricted.
/obj/structure/serpentine_tail/proc/unregister_constricted()
	UnregisterSignal(constricted, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_EXAMINE, COMSIG_LIVING_TRY_PULL, COMSIG_QDELETING))

/// Buckles constricted to ourselves, and migrates the current grab constricted may have on them.
/obj/structure/serpentine_tail/proc/restrain_constricted()
	if (!constricted)
		return FALSE

	if (constricted.buckled == src) // already restrained
		return FALSE

	var/old_grab_state = owner.grab_state
	constricted.forceMove(get_turf(src))
	buckle_mob(constricted)

	if (old_grab_state < GRAB_AGGRESSIVE)
		return FALSE

	allowing_grab_on_constricted = TRUE
	owner.grab(constricted) // can potentially sleep
	owner.setGrabState(old_grab_state)
	allowing_grab_on_constricted = FALSE

	return FALSE

/// Toggle proc for crushing. See stop_crushing and start_crushing.
/obj/structure/serpentine_tail/proc/toggle_crushing()
	if (!constricted)
		owner.balloon_alert(owner, "not constricting anything!")
		return FALSE

	if (currently_crushing)
		stop_crushing()
	else
		start_crushing()

	return TRUE

/// Setter proc for currently_crushing that handles processing and warnings.
/obj/structure/serpentine_tail/proc/start_crushing()
	if (currently_crushing)
		return FALSE

	currently_crushing = TRUE
	START_PROCESSING(SSobj, src)

	owner.balloon_alert_to_viewers("starts crushing")
	owner.visible_message(span_boldwarning("[owner] starts crushing [constricted] with [owner.p_their()] tail!"), span_warning("You start crushing [constricted] with your tail!"), ignored_mobs = list(constricted))
	to_chat(constricted, span_userdanger("[owner] starts crushing you with [owner.p_their()] tail!"))
	return TRUE

/// Setter proc for currently_crushing that handles processing and warnings.
/obj/structure/serpentine_tail/proc/stop_crushing()
	if (!currently_crushing)
		return FALSE

	owner.balloon_alert_to_viewers("stops crushing")
	owner.visible_message(span_warning("[owner] stops crushing [constricted] with [owner.p_their()] tail."), span_notice("You stop crushing [constricted] with your tail."), ignored_mobs = list(constricted))
	to_chat(constricted, span_boldwarning("[owner] stops crushing you with [owner.p_their()] tail."))

	currently_crushing = FALSE
	STOP_PROCESSING(SSobj, src)
	stored_damage = 0
	return TRUE

/// Setter proc for owner that handles signals, bodyparts, etc.
/obj/structure/serpentine_tail/proc/set_owner(mob/living/carbon/human/new_owner)
	if (owner)
		UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_GRAB, COMSIG_LIVING_TRY_PULL, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_ATOM_POST_DIR_CHANGE))

	if (owner)
		var/obj/item/organ/taur_body/taur_body = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
		taur_body.hide_self = FALSE

	owner = new_owner

	if (owner)
		var/obj/item/organ/taur_body/taur_body = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
		taur_body.hide_self = TRUE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(owner_moved))
	RegisterSignal(owner, COMSIG_LIVING_GRAB, PROC_REF(owner_tried_grab))
	RegisterSignal(owner, COMSIG_LIVING_TRY_PULL, PROC_REF(owner_tried_pull))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(owner_body_position_changed))
	RegisterSignal(owner, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(sync_direction))
	owner?.update_body_parts()

/// The time it takes for a constricted thing to do a break-out attempt.
#define SERPENTINE_TAIL_UNBUCKLE_TIME 0.5 SECONDS // arbitrary

/obj/structure/serpentine_tail/is_buckle_possible(mob/living/target, force, check_loc)
	if (target == owner)
		return FALSE

	return ..()

/obj/structure/serpentine_tail/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if (!constricted || (user != constricted)) // anyone can easily free them except themselves
		return ..()

	if (!COOLDOWN_FINISHED(src, escape_cooldown))
		to_chat(user, span_warning("You're still recovering from your last escape attempt!")) // prevent escape spam
		return FALSE

	var/escape_chance = CONSTRICT_ESCAPE_CHANCE

	if (!prob(escape_chance))
		user.visible_message(span_warning("[user] squirms as they fail to escape from [owner]'s tail!"), span_warning("You squirm as you fail to escape from [owner]'s tail!"), ignored_mobs = owner)
		to_chat(owner, span_warning("[user] squirms as they fail to escape from the grip of your tail!"))
		COOLDOWN_START(src, escape_cooldown, SERPENTINE_TAIL_UNBUCKLE_TIME)
		return FALSE

	user.visible_message(span_warning("[user] breaks free from [owner]'s tail!"), span_warning("You break free from [owner]'s tail!"), ignored_mobs = owner)
	to_chat(owner, span_boldwarning("[user] breaks free from the grip of your tail!"))
	return ..()

#undef SERPENTINE_TAIL_UNBUCKLE_TIME

/obj/structure/serpentine_tail/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()

	if (unbuckled_mob == constricted)
		set_constricted(null)

/obj/structure/serpentine_tail/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/weapons/bladeslice.ogg', 100, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(!damage_amount)
				return

			playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)


/// Signal proc for when owner moves. Qdels src.
/obj/structure/serpentine_tail/proc/owner_moved(datum/signal_source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	qdel(src)

/// Signal proc for if our owner changes body positions. Qdels src if they lie down.
/obj/structure/serpentine_tail/proc/owner_body_position_changed(datum/signal_source, new_position, old_position)
	SIGNAL_HANDLER

	if (new_position == LYING_DOWN)
		qdel(src)

/// Signal proc for if constricted moves. If the new loc isnt our loc, we stop constricting them. Used for teleportation escapes.
/obj/structure/serpentine_tail/proc/constricted_moved(datum/signal_source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if (constricted.loc != loc)
		INVOKE_ASYNC(src, PROC_REF(set_constricted), null)

/// Signal proc for constricted being examined. Appends a string warning the viewer of them being crushed.
/obj/structure/serpentine_tail/proc/constricted_examined(datum/signal_source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if (currently_crushing)
		examine_text += span_boldwarning("[owner] is crushing [constricted.p_them()] with [owner.p_their()] tail!")

/// Signal proc for constricted qdeleting. Sets constricted to null.
/obj/structure/serpentine_tail/proc/constricted_qdeleting(datum/signal_source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(set_constricted), null)

/// Signal proc for owner pulling someone. Forbids them from pulling constricted.
/obj/structure/serpentine_tail/proc/owner_tried_pull(datum/signal_source, atom/movable/thing, force)
	SIGNAL_HANDLER

	if (!allowing_grab_on_constricted && thing == constricted)
		owner.balloon_alert(owner, "can't grab constricted!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Signal proc for owner grabbing someone, separate from pulling. Forbids them from upgrading grabs on constricted.
/obj/structure/serpentine_tail/proc/owner_tried_grab(datum/signal_source, mob/living/grabbing)
	SIGNAL_HANDLER

	if (!allowing_grab_on_constricted && grabbing == constricted)
		owner.balloon_alert(owner, "can't grab constricted!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Signal proc that prevents constricted from grabbing owner.
/obj/structure/serpentine_tail/proc/constricted_tried_pull(datum/signal_source, atom/movable/thing, force)
	SIGNAL_HANDLER

	if (thing == owner)
		constricted.balloon_alert(constricted, "can't grab constrictor!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/constricted
	id = "constricted_tail"

	alert_type = /atom/movable/screen/alert/status_effect/constricted

/atom/movable/screen/alert/status_effect/constricted
	name = "Constricted"
	desc = "You're being constricted by a giant tail! You can resist, attack the tail, or attack the constrictor to escape!"

	icon = 'modular_doppler/taurs/icons/taur_mechanics/ability.dmi'
	icon_state = "constrict"

#undef CONSTRICT_BASE_PIXEL_SHIFT
#undef CONSTRICT_ESCAPE_CHANCE
