/**
 * The shielded component causes the parent item to nullify a certain number of attacks against the wearer, see: shielded hardsuits.
 */

/datum/component/shielded
	/// The person currently wearing us
	var/mob/living/wearer
	/// How many charges we can have max, and how many we start with
	var/max_charges
	/// How many charges we currently have
	var/current_charges
	/// How long we have to avoid being hit to replenish charges. If set to 0, we never recharge lost charges
	var/last_hit_recharge_delay = 20 SECONDS
	/// Once we go unhit long enough to recharge, we replenish charges this often. The floor is effectively 1 second, AKA how often SSdcs processes
	var/charge_increment_delay = 1 SECONDS
	/// What .dmi we're pulling the shield icon from
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// What icon is used when someone has a functional shield up
	var/shield_icon = "shield-old"
	/// Do we still shield if we're being held in-hand? If FALSE, it needs to be equipped to a slot to work
	var/shield_inhand = FALSE
	/// The cooldown tracking when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)
	/// The cooldown tracking when we last replenished a charge
	COOLDOWN_DECLARE(charge_add_cd)

/datum/component/shielded/Initialize(max_charges = 3, last_hit_recharge_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, shield_icon_file = 'icons/effects/effects.dmi', shield_icon = "shield-old", shield_inhand = FALSE)
	if(!isitem(parent) || max_charges <= 0)
		return COMPONENT_INCOMPATIBLE

	src.max_charges = max_charges
	src.last_hit_recharge_delay = last_hit_recharge_delay
	src.charge_increment_delay = charge_increment_delay
	src.shield_icon_file = shield_icon_file
	src.shield_icon = shield_icon
	src.shield_inhand = shield_inhand

	current_charges = max_charges
	if(last_hit_recharge_delay)
		START_PROCESSING(SSdcs, src)

/datum/component/shielded/Destroy(force, silent)
	if(wearer)
		UnregisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS)
		wearer.update_appearance(UPDATE_ICON)
		wearer = null
	return ..()

/datum/component/shielded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_dropped)
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, .proc/on_hit_react)

/datum/component/shielded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ITEM_HIT_REACT))

// Handle recharging, if we want to
/datum/component/shielded/process(delta_time)
	if(current_charges >= max_charges)
		STOP_PROCESSING(SSdcs, src)
		return

	if(!COOLDOWN_FINISHED(src, recently_hit_cd))
		return
	if(!COOLDOWN_FINISHED(src, charge_add_cd))
		return

	var/obj/item/item_parent = parent
	COOLDOWN_START(src, charge_add_cd, charge_increment_delay)
	current_charges++
	if(wearer && current_charges == 1)
		wearer.update_appearance(UPDATE_ICON)
	playsound(item_parent.loc, 'sound/magic/charge.ogg', 50, TRUE)
	if(current_charges == max_charges)
		playsound(item_parent.loc, 'sound/machines/ding.ogg', 50, TRUE)

/// Check if we've been equipped to a valid slot to shield
/datum/component/shielded/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_HANDS && !shield_inhand)
		on_dropped(source, user)
		return

	wearer = user
	RegisterSignal(wearer, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)
	RegisterSignal(wearer, COMSIG_PARENT_QDELETING, .proc/on_wearer_qdel)
	if(current_charges)
		wearer.update_appearance(UPDATE_ICON)

/// When dropped, forget about whoever we were worn by
/datum/component/shielded/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER

	if(wearer)
		UnregisterSignal(wearer, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_PARENT_QDELETING))
		wearer.update_appearance(UPDATE_ICON)
		wearer = null

/// Panic button if the wearer is qdel'd
/datum/component/shielded/proc/on_wearer_qdel(datum/source)
	SIGNAL_HANDLER

	if(wearer)
		UnregisterSignal(wearer, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_PARENT_QDELETING))
		wearer.update_appearance(UPDATE_ICON)
		wearer = null

/// Used to draw the shield overlay on the wearer
/datum/component/shielded/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	overlays += mutable_appearance('icons/effects/effects.dmi', (current_charges > 0 ? shield_icon : "broken"), MOB_LAYER + 0.01)

/// The initial check to see if we have a charge to block the hit
/datum/component/shielded/proc/on_hit_react(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	SIGNAL_HANDLER

	COOLDOWN_START(src, recently_hit_cd, last_hit_recharge_delay)

	if(current_charges <= 0)
		return
	. = COMPONENT_HIT_REACTION_BLOCK
	current_charges = max(current_charges - 1, 0)
	if(last_hit_recharge_delay) // if this is 0, it doesn't recharge
		START_PROCESSING(SSdcs, src)
	INVOKE_ASYNC(src, .proc/on_hit_effects, owner, attack_text)

/// The messages and visuals for the flying sparks // TODO: make this a callback because cult is stupid and has their own effects/descriptions/whatever
/datum/component/shielded/proc/on_hit_effects(mob/living/owner, attack_text)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, owner)
	s.start()
	owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!<span>")
	if(current_charges <= 0)
		owner.visible_message("<span class='warning'>[owner]'s shield overloads!</span>")
		wearer.update_appearance(UPDATE_ICON)
