/**
 * Component allowing you to create a linked list of mobs.
 * These mobs will follow each other and attack as one, as well as sharing damage taken.
 */
/datum/component/mob_chain

	/// If true then damage we take is passed backwards along the line
	var/pass_damage_back
	/// If true then we will set our icon state based on line position
	var/vary_icon_state

	/// Mob in front of us in the chain
	var/mob/living/front
	/// Mob behind us in the chain
	var/mob/living/back

/datum/component/mob_chain/Initialize(mob/living/front, pass_damage_back = TRUE, vary_icon_state = FALSE)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.front = front
	src.pass_damage_back = pass_damage_back
	src.vary_icon_state = vary_icon_state
	if (!isnull(front))
		SEND_SIGNAL(front, COMSIG_MOB_GAINED_CHAIN_TAIL, parent)
		parent.AddComponent(/datum/component/leash, owner = front, distance = 1) // Handles catching up gracefully
		var/mob/living/living_parent = parent
		living_parent.set_glide_size(front.glide_size)

/datum/component/mob_chain/Destroy(force, silent)
	if (!isnull(front))
		SEND_SIGNAL(front, COMSIG_MOB_LOST_CHAIN_TAIL, parent)
	front = null
	back = null
	return ..()

/datum/component/mob_chain/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_GAINED_CHAIN_TAIL, PROC_REF(on_gained_tail))
	RegisterSignal(parent, COMSIG_MOB_LOST_CHAIN_TAIL, PROC_REF(on_lost_tail))
	RegisterSignal(parent, COMSIG_MOB_CHAIN_CONTRACT, PROC_REF(on_contracted))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_deletion))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ATOM_CAN_BE_PULLED, PROC_REF(on_pulled))
	RegisterSignals(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_ATTACK_RANGED), PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_glide_size_changed))
	if (vary_icon_state)
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
		update_mob_appearance()
	if (pass_damage_back)
		RegisterSignals(parent, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_adjust_damage))
		RegisterSignal(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_adjust_stamina))
		RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))

	var/datum/action/cooldown/worm_contract/shrink = new(parent)
	shrink.Grant(parent)

/datum/component/mob_chain/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_CAN_BE_PULLED,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_CARBON_LIMB_DAMAGED,
		COMSIG_LIVING_ADJUST_BRUTE_DAMAGE,
		COMSIG_LIVING_ADJUST_BURN_DAMAGE,
		COMSIG_LIVING_ADJUST_CLONE_DAMAGE,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_ADJUST_OXY_DAMAGE,
		COMSIG_LIVING_ADJUST_STAMINA_DAMAGE,
		COMSIG_LIVING_ADJUST_TOX_DAMAGE,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_MOB_ATTACK_RANGED,
		COMSIG_MOB_CHAIN_CONTRACT,
		COMSIG_MOB_GAINED_CHAIN_TAIL,
		COMSIG_MOB_LOST_CHAIN_TAIL,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UPDATE_GLIDE_SIZE,
		COMSIG_QDELETING,
	))
	qdel(parent.GetComponent(/datum/component/leash))
	var/mob/living/living_parent = parent
	var/datum/action/cooldown/worm_contract/shrink = locate() in living_parent.actions
	qdel(shrink)

/// Update how we look
/datum/component/mob_chain/proc/update_mob_appearance()
	if (!vary_icon_state)
		return
	var/mob/living/body = parent
	body.update_appearance(UPDATE_ICON_STATE)

/// Called when something sets us as IT'S front
/datum/component/mob_chain/proc/on_gained_tail(mob/living/body, mob/living/tail)
	SIGNAL_HANDLER
	back = tail
	update_mob_appearance()

/// Called when our tail loses its chain component
/datum/component/mob_chain/proc/on_lost_tail()
	SIGNAL_HANDLER
	back = null
	update_mob_appearance()

/// Called when our tail gets pulled up to our body
/datum/component/mob_chain/proc/on_contracted(mob/living/shrinking)
	SIGNAL_HANDLER
	if (isnull(back))
		return
	back.forceMove(shrinking.loc)
	var/datum/action/cooldown/worm_contract/shrink = locate() in back.actions
	if (isnull(shrink))
		return
	INVOKE_ASYNC(shrink, TYPE_PROC_REF(/datum/action, Trigger))

/// If we die so does the guy behind us, then stop following the leader
/datum/component/mob_chain/proc/on_death()
	SIGNAL_HANDLER
	back?.death()
	qdel(src)

/// If we get deleted so does the guy behind us
/datum/component/mob_chain/proc/on_deletion()
	SIGNAL_HANDLER
	QDEL_NULL(back)
	front?.update_appearance(UPDATE_ICON)

/// Pull our tail behind us when we move
/datum/component/mob_chain/proc/on_moved(mob/living/mover, turf/old_loc)
	SIGNAL_HANDLER
	if(isnull(back) || back.loc == old_loc)
		return
	back.Move(old_loc)

/// Update our visuals based on if we have someone in front and behind
/datum/component/mob_chain/proc/on_update_icon_state(mob/living/our_mob)
	SIGNAL_HANDLER
	var/current_icon_state = our_mob.base_icon_state
	if(isnull(front))
		current_icon_state = "[current_icon_state]_start"
	else if(isnull(back))
		current_icon_state = "[current_icon_state]_end"
	else
		current_icon_state = "[current_icon_state]_mid"

	our_mob.icon_state = current_icon_state
	if (isanimal_or_basicmob(our_mob))
		var/mob/living/basic/basic_parent = our_mob
		basic_parent.icon_living = current_icon_state

/// Do not allow someone to be pulled out of the chain
/datum/component/mob_chain/proc/on_pulled(mob/living/our_mob)
	SIGNAL_HANDLER
	if (!isnull(front))
		return COMSIG_ATOM_CANT_PULL

/// Tell our tail to attack too
/datum/component/mob_chain/proc/on_attack(mob/living/our_mob, atom/target)
	SIGNAL_HANDLER
	if (target == back || target == front)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (isnull(back) || QDELETED(target))
		return
	INVOKE_ASYNC(back, TYPE_PROC_REF(/mob, ClickOn), target)

/// Maintain glide size backwards
/datum/component/mob_chain/proc/on_glide_size_changed(mob/living/our_mob, new_size)
	SIGNAL_HANDLER
	back?.set_glide_size(new_size)

/// On gain or lose stamina, adjust our tail too
/datum/component/mob_chain/proc/on_adjust_stamina(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (forced)
		return
	back?.adjustStaminaLoss(amount, forced = forced)

/// On damage or heal, affect our furthest segment
/datum/component/mob_chain/proc/on_adjust_damage(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (isnull(back) || forced)
		return
	switch (type)
		if(BRUTE)
			back.adjustBruteLoss(amount, forced = forced)
		if(BURN)
			back.adjustFireLoss(amount, forced = forced)
		if(TOX)
			back.adjustToxLoss(amount, forced = forced)
		if(OXY) // If all segments are suffocating we pile damage backwards until our ass starts dying forwards
			back.adjustOxyLoss(amount, forced = forced)
		if(CLONE)
			back.adjustCloneLoss(amount, forced = forced)
	return COMPONENT_IGNORE_CHANGE

/// Special handling for if damage is delegated to a mob's limbs instead of its overall damage
/datum/component/mob_chain/proc/on_limb_damage(mob/living/our_mob, limb, brute, burn)
	SIGNAL_HANDLER
	if (isnull(back))
		return
	if (brute != 0)
		back.adjustBruteLoss(brute, updating_health = FALSE)
	if (burn != 0)
		back.adjustFireLoss(burn, updating_health = FALSE)
	if (brute != 0 || burn != 0)
		back.updatehealth()
	return COMPONENT_PREVENT_LIMB_DAMAGE

/**
 * Shrink the chain of mobs into one tile.
 */
/datum/action/cooldown/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"
	cooldown_time = 30 SECONDS
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/worm_contract/Activate(atom/target)
	SEND_SIGNAL(owner, COMSIG_MOB_CHAIN_CONTRACT)
	StartCooldown()
