/**
 * The shielded component causes the parent item to nullify a certain number of attacks against the wearer, see: shielded vests.
 */

/datum/component/shielded
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The person currently wearing us
	var/mob/living/wearer
	/// How many charges we can have max, and how many we start with
	var/max_charges
	/// How many charges we currently have
	var/current_charges
	/// How long we have to avoid being hit to replenish charges. If set to 0, we never recharge lost charges
	var/recharge_start_delay = 20 SECONDS
	/// Once we go unhit long enough to recharge, we replenish charges this often. The floor is effectively 1 second, AKA how often SSdcs processes
	var/charge_increment_delay = 1 SECONDS
	/// How many charges we recover on each charge increment
	var/charge_recovery = 1
	/// What .dmi we're pulling the shield icon from
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// What icon is used when someone has a functional shield up
	var/shield_icon = "shield-old"
	/// Do we still shield if we're being held in-hand? If FALSE, it needs to be equipped to a slot to work
	var/shield_inhand = FALSE
	/// Should the shield lose charges equal to the damage dealt by a hit?
	var/lose_multiple_charges = FALSE
	/// Should the shield's alpha change to show its remaining charge
	var/show_charge_as_alpha = FALSE
	/// The item we use for recharging
	var/recharge_path
	/// Whether or not we lose a charge when hit by 0 damage items or projectiles
	var/lose_charge_on_damageless = FALSE

	/// The cooldown tracking when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)
	/// The cooldown tracking when we last replenished a charge
	COOLDOWN_DECLARE(charge_add_cd)
	/// A callback for the sparks/message that play when a charge is used, see [/datum/component/shielded/proc/default_run_hit_callback]
	var/datum/callback/on_hit_effects

/datum/component/shielded/Initialize(max_charges = 3, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, show_charge_as_alpha = FALSE, recharge_path = null, starting_charges = null, shield_icon_file = 'icons/effects/effects.dmi', shield_icon = "shield-old", shield_inhand = FALSE, run_hit_callback)
	if(!isitem(parent) || max_charges <= 0)
		return COMPONENT_INCOMPATIBLE

	src.max_charges = max_charges
	src.recharge_start_delay = recharge_start_delay
	src.charge_increment_delay = charge_increment_delay
	src.charge_recovery = charge_recovery
	src.lose_multiple_charges = lose_multiple_charges
	src.show_charge_as_alpha = show_charge_as_alpha
	src.recharge_path = recharge_path
	src.shield_icon_file = shield_icon_file
	src.shield_icon = shield_icon
	src.shield_inhand = shield_inhand
	src.on_hit_effects = run_hit_callback || CALLBACK(src, PROC_REF(default_run_hit_callback))
	if(isnull(starting_charges))
		current_charges = max_charges
	else
		current_charges = starting_charges
	if(recharge_start_delay)
		START_PROCESSING(SSdcs, src)

/datum/component/shielded/Destroy(force)
	if(wearer)
		shield_icon = "broken"
		UnregisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS)
		wearer.update_appearance(UPDATE_ICON)
		wearer = null
	on_hit_effects = null
	return ..()

/datum/component/shielded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(lost_wearer))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(on_hit_react))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_recharge_rune))
	var/atom/shield = parent
	if(ismob(shield.loc))
		var/mob/holder = shield.loc
		if(holder.is_holding(parent) && !shield_inhand)
			return
		set_wearer(holder)

/datum/component/shielded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ITEM_HIT_REACT, COMSIG_ATOM_ATTACKBY))
	var/atom/shield = parent
	if(shield.loc == wearer)
		lost_wearer(src, wearer)

// Handle recharging, if we want to
/datum/component/shielded/process(seconds_per_tick)
	if(current_charges >= max_charges)
		STOP_PROCESSING(SSdcs, src)
		return

	if(!COOLDOWN_FINISHED(src, recently_hit_cd))
		return
	if(!COOLDOWN_FINISHED(src, charge_add_cd))
		return

	var/obj/item/item_parent = parent
	COOLDOWN_START(src, charge_add_cd, charge_increment_delay)
	adjust_charge(charge_recovery) // set the number of charges to current + recovery per increment, clamped from zero to max_charges
	playsound(item_parent, 'sound/effects/magic/charge.ogg', 50, TRUE)
	if(current_charges == max_charges)
		playsound(item_parent, 'sound/machines/ding.ogg', 50, TRUE)

/datum/component/shielded/proc/adjust_charge(change)
	current_charges = clamp(current_charges + change, 0, max_charges)
	if(wearer)
		wearer.update_appearance(UPDATE_ICON)

/// Check if we've been equipped to a valid slot to shield
/datum/component/shielded/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(user.is_holding(parent) && !shield_inhand)
		lost_wearer(source, user)
		return
	set_wearer(user)

/// Either we've been dropped or our wearer has been QDEL'd. Either way, they're no longer our problem
/datum/component/shielded/proc/lost_wearer(datum/source, mob/user)
	SIGNAL_HANDLER

	if(wearer)
		UnregisterSignal(wearer, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_QDELETING))
		wearer.update_appearance(UPDATE_ICON)
		wearer = null

/datum/component/shielded/proc/set_wearer(mob/user)
	if(wearer == user)
		return
	if(!isnull(wearer))
		CRASH("[type] called set_wearer with [user] but [wearer] was already the wearer!")

	wearer = user
	RegisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(lost_wearer))
	if(current_charges)
		wearer.update_appearance(UPDATE_ICON)

/// Used to draw the shield overlay on the wearer
/datum/component/shielded/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/shield_appearance = mutable_appearance(shield_icon_file, (current_charges > 0 ? shield_icon : "broken"), MOB_SHIELD_LAYER)
	if(show_charge_as_alpha)
		shield_appearance.alpha = (current_charges/max_charges)*255
	overlays += shield_appearance

/**
 * This proc fires when we're hit, and is responsible for checking if we're charged, then deducting one + returning that we're blocking if so.
 * It then runs the callback in [/datum/component/shielded/var/on_hit_effects] which handles the messages/sparks (so the visuals)
 */
/datum/component/shielded/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type, damage_type)
	SIGNAL_HANDLER

	COOLDOWN_START(src, recently_hit_cd, recharge_start_delay)

	//No wearer? No block.
	if(isnull(wearer))
		return

	//if our wearer isn't the owner of the block, don't block
	if(owner != wearer)
		return

	if(current_charges <= 0)
		return
	. = COMPONENT_HIT_REACTION_BLOCK

	var/charge_loss = 1 // how many charges do we lose

	if(lose_multiple_charges) // if the shield has health like damage we'll lose charges equal to the damage of the hit
		charge_loss = damage

	else if(!lose_charge_on_damageless && !damage)
		charge_loss = 0

	adjust_charge(-charge_loss)

	INVOKE_ASYNC(src, PROC_REF(actually_run_hit_callback), owner, attack_text, current_charges)

	if(!recharge_start_delay) // if recharge_start_delay is 0, we don't recharge
		return

	START_PROCESSING(SSdcs, src) // if we DO recharge, start processing so we can do that

/// The wrapper to invoke the on_hit callback, so we don't have to worry about blocking in the signal handler
/datum/component/shielded/proc/actually_run_hit_callback(mob/living/owner, attack_text, current_charges)
	on_hit_effects.Invoke(owner, attack_text, current_charges)

/// Default on_hit proc, since cult robes are stupid and have different descriptions/sparks
/datum/component/shielded/proc/default_run_hit_callback(mob/living/owner, attack_text, current_charges)
	do_sparks(2, TRUE, owner)
	owner.visible_message(span_danger("[owner]'s shields deflect [attack_text] in a shower of sparks!"))
	if(current_charges <= 0)
		owner.visible_message(span_warning("[owner]'s shield overloads!"))

/datum/component/shielded/proc/check_recharge_rune(datum/source, obj/item/recharge_rune, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(recharge_rune, recharge_path))
		return
	. = COMPONENT_NO_AFTERATTACK

	adjust_charge(charge_recovery)
	to_chat(user, span_notice("You charge \the [parent]. It can now absorb [current_charges] hits."))
	qdel(recharge_rune)
