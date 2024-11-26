/*
 * +++++++++++++++++++++++++++++++++++++++++ ABOUT THIS FILE +++++++++++++++++++++++++++++++++++++++++++++
 * Not everything here necessarily has the name pattern of [x]_act()
 * This is a file for various atom procs that simply get called when something is happening to that atom.
 * If you're adding something here, you likely want a signal and SHOULD_CALL_PARENT(TRUE)
 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 */

/**
 * Respond to fire being used on our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_FIRE_ACT] and return
 */
/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return FALSE

/**
 * Sends [COMSIG_ATOM_EXTINGUISH] signal, which properly removes burning component if it is present.
 *
 * Default behaviour is to send [COMSIG_ATOM_ACID_ACT] and return
 */
/atom/proc/extinguish()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_EXTINGUISH)

/**
 * React to being hit by an explosion
 *
 * Should be called through the [EX_ACT] wrapper macro.
 * The wrapper takes care of the [COMSIG_ATOM_EX_ACT] signal.
 * as well as calling [/atom/proc/contents_explosion].
 *
 * Returns TRUE by default, and behavior should be implemented on children procs on a per-atom basis. Should only return FALSE if we resist the explosion for any reason.
 * We assume that the default is TRUE because all atoms should be considered destructible in some manner unless they explicitly opt out (in our current framework).
 * However, the return value itself doesn't have any external consumers, it's only so children procs can listen to the value from their parent procs (due to the nature of the [EX_ACT] macro).
 * Thus, the return value only matters on overrides of this proc, and the only thing that truly matters is the code that is executed (applying damage, calling damage procs, etc.)
 *
 */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	return TRUE

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
 * React to a hit by a blob objecd
 *
 * default behaviour is to send the [COMSIG_ATOM_BLOB_ACT] signal
 */
/atom/proc/blob_act(obj/structure/blob/attacking_blob)
	var/blob_act_result = SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, attacking_blob)
	if (blob_act_result & COMPONENT_CANCEL_BLOB_ACT)
		return FALSE
	return TRUE

/**
 * React to an EMP of the given severity
 *
 * Default behaviour is to send the [COMSIG_ATOM_PRE_EMP_ACT] and [COMSIG_ATOM_EMP_ACT] signal
 *
 * If the pre-signal does not return protection, and there are attached wires then we call
 * [emp_pulse][/datum/wires/proc/emp_pulse] on the wires
 *
 * We then return the protection value
 */
/atom/proc/emp_act(severity)
	SHOULD_CALL_PARENT(TRUE)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_PRE_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse()

	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity, protection)
	return protection // Pass the protection value collected here upwards

/**
 * Wrapper for bullet_act used for atom-specific calculations, i.e. armor
 *
 * @params
 * * hitting_projectile - projectile
 * * def_zone - zone hit
 * * piercing_hit - is this hit piercing or normal?
 */

/atom/proc/projectile_hit(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE, blocked = null)
	if (isnull(blocked))
		blocked = check_projectile_armor(def_zone, hitting_projectile)
	return bullet_act(hitting_projectile, def_zone, piercing_hit, blocked)

/**
 * React to a hit by a projectile object
 *
 * @params
 * * hitting_projectile - projectile
 * * def_zone - zone hit
 * * piercing_hit - is this hit piercing or normal?
 * * blocked - total armor value to apply to this hit
 */
/atom/proc/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE, blocked = 0)
	SHOULD_CALL_PARENT(TRUE)

	var/sigreturn = SEND_SIGNAL(src, COMSIG_ATOM_PRE_BULLET_ACT, hitting_projectile, def_zone, piercing_hit, blocked)
	if(sigreturn & COMPONENT_BULLET_PIERCED)
		return BULLET_ACT_FORCE_PIERCE
	if(sigreturn & COMPONENT_BULLET_BLOCKED)
		return BULLET_ACT_BLOCK
	if(sigreturn & COMPONENT_BULLET_ACTED)
		return BULLET_ACT_HIT

	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, hitting_projectile, def_zone, piercing_hit, blocked)
	if(QDELETED(hitting_projectile)) // Signal deleted it?
		return BULLET_ACT_BLOCK

	return hitting_projectile.on_hit(
		target = src,
		// This armor check only matters for the visuals and messages in on_hit(), it's not actually used to reduce damage since
		// only living mobs use armor to reduce damage, but on_hit() is going to need the value no matter what is shot.
		blocked = blocked,
		pierce_hit = piercing_hit,
	)

/**
 * React to being hit by a thrown object
 *
 * Default behaviour is to call [hitby_react][/atom/proc/hitby_react] on ourselves after 2 seconds if we are dense
 * and under normal gravity.
 *
 * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
 * deleted shortly after hitting something (during explosions or other massive events that
 * throw lots of items around - singularity being a notable example)
 *
 * Worth of note: If hitby returns TRUE, it means the object has been blocked or catched by src.
 * So far, this is only possible for living mobs and carbons, who can hold shields and catch thrown items.
 */
/atom/proc/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, hitting_atom, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(hitting_atom)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), hitting_atom), 0.2 SECONDS)
	return FALSE

/**
 * We have have actually hit the passed in atom
 *
 * Default behaviour is to move back from the item that hit us
 */
/atom/proc/hitby_react(atom/movable/harmed_atom)
	if(harmed_atom && isturf(harmed_atom.loc))
		step(harmed_atom, REVERSE_DIR(harmed_atom.dir))

///Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/slipped_carbon, knockdown_amount, obj/slipping_object, lube, paralyze, force_drop)
	return

///Used for making a sound when a mob involuntarily falls into the ground.
/atom/proc/handle_fall(mob/faller)
	return

///Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
 * Respond to the singularity pulling on us
 *
 * Default behaviour is to send [COMSIG_ATOM_SING_PULL] and return
 */
/atom/proc/singularity_pull(atom/singularity, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, singularity, current_size)

/**
 * Respond to acid being used on our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_ACID_ACT] and return
 */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)
	return FALSE

/**
 * Respond to an emag being used on our atom
 *
 * Args:
 * * mob/user: The mob that used the emag. Nullable.
 * * obj/item/card/emag/emag_card: The emag that was used. Nullable.
 *
 * Returns:
 * TRUE if the emag had any effect, falsey otherwise.
 */
/atom/proc/emag_act(mob/user, obj/item/card/emag/emag_card)
	return (SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user, emag_card))

/**
 * Respond to narsie eating our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_NARSIE_ACT] and return
 */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)

/**
 * Respond to an electric bolt action on our item
 *
 * Default behaviour is to return, we define here to allow for cleaner code later on
 */
/atom/proc/zap_act(power, zap_flags)
	return

/**
 * Called when the atom log's in or out
 *
 * Default behaviour is to call on_log on the location this atom is in
 */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)

/**
 * Causes effects when the atom gets hit by a rust effect from heretics
 *
 * Override this if you want custom behaviour in whatever gets hit by the rust
 * /turf/rust_turf should be used instead for overriding rust on turfs
 */
/atom/proc/rust_heretic_act()
	return

///wrapper proc that passes our mob's rust_strength to the target we are rusting
/mob/living/proc/do_rust_heretic_act(atom/target)
	var/datum/antagonist/heretic/heretic_data = GET_HERETIC(src)
	target.rust_heretic_act(heretic_data?.rust_strength)

/mob/living/basic/heretic_summon/rust_walker/do_rust_heretic_act(atom/target)
	target.rust_heretic_act(4)

///Called when something resists while this atom is its loc
/atom/proc/container_resist_act(mob/living/user)
	return

/**
 * Respond to an RCD acting on our item
 *
 * Default behaviour is to send [COMSIG_ATOM_RCD_ACT] and return FALSE
 */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, rcd_data["[RCD_DESIGN_MODE]"])
	return FALSE

///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

///This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
