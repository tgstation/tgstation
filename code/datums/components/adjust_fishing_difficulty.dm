///Influences the difficulty of the minigame when worn or if buckled to.
/datum/component/adjust_fishing_difficulty
	///The additive numerical modifier to the difficulty of the minigame
	var/modifier
	///For items, in which slot it has to be worn to influence the difficulty of the minigame
	var/slots

/datum/component/adjust_fishing_difficulty/Initialize(modifier, slots = NONE)
	if(!ismovable(parent) || !modifier)
		return COMPONENT_INCOMPATIBLE

	if(!isitem(parent))
		var/atom/movable/movable_parent = parent
		if(!movable_parent.can_buckle)
			return COMPONENT_INCOMPATIBLE

	src.modifier = modifier
	src.slots = slots

/datum/component/adjust_fishing_difficulty/RegisterWithParent()
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_item_examine))
	else
		RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))
		RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_buckle_examine))

	update_check()

/datum/component/adjust_fishing_difficulty/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_UNBUCKLE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

	update_check(TRUE)

/datum/component/adjust_fishing_difficulty/proc/update_check(removing = FALSE)
	var/atom/movable/movable_parent = parent
	for(var/mob/living/buckled_mob as anything in movable_parent.buckled_mobs)
		update_user(buckled_mob, removing)
	if(!isitem(movable_parent) || !isliving(movable_parent.loc))
		return
	var/mob/living/holder = movable_parent.loc
	var/obj/item/item = parent
	if(holder.get_slot_by_item(movable_parent) & (slots || item.slot_flags))
		update_user(holder, removing)

/datum/component/adjust_fishing_difficulty/proc/on_item_examine(obj/item/item, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISH))
		return
	var/method = "[(slots || item.slot_flags) & ITEM_SLOT_HANDS ? "Holding" : "Wearing"] [item.p_them()]"
	add_examine_line(user, examine_text, method)

/datum/component/adjust_fishing_difficulty/proc/on_buckle_examine(atom/movable/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISH))
		return
	add_examine_line(user, examine_text, "Buckling to [source.p_them()]")

/datum/component/adjust_fishing_difficulty/proc/add_examine_line(mob/user, list/examine_text, method)
	var/percent = HAS_MIND_TRAIT(user, TRAIT_EXAMINE_DEEPER_FISH) ? "[abs(modifier)]% " : ""
	var/text = "[method] will make fishing [percent][modifier < 0 ? "easier" : "harder"]."
	if(modifier < 0)
		examine_text += span_nicegreen(text)
	else
		examine_text += span_danger(text)

/datum/component/adjust_fishing_difficulty/proc/on_buckle(atom/movable/source, mob/living/buckled_mob, forced)
	SIGNAL_HANDLER
	update_user(buckled_mob)

/datum/component/adjust_fishing_difficulty/proc/on_unbuckle(atom/movable/source, mob/living/buckled_mob, forced)
	SIGNAL_HANDLER
	update_user(buckled_mob, TRUE)

/datum/component/adjust_fishing_difficulty/proc/on_equipped(obj/item/source, mob/living/wearer, slot)
	SIGNAL_HANDLER
	if(slot & (slots || source.slot_flags))
		update_user(wearer)

/datum/component/adjust_fishing_difficulty/proc/on_dropped(obj/item/source, mob/living/dropper)
	SIGNAL_HANDLER
	update_user(dropper, TRUE)

/datum/component/adjust_fishing_difficulty/proc/update_user(mob/living/user, removing = FALSE)
	var/datum/fishing_challenge/challenge = GLOB.fishing_challenges_by_user[user]
	if(removing)
		UnregisterSignal(user, COMSIG_MOB_BEGIN_FISHING)
		if(challenge)
			UnregisterSignal(challenge, COMSIG_FISHING_CHALLENGE_GET_DIFFICULTY)
	else
		RegisterSignal(user, COMSIG_MOB_BEGIN_FISHING, PROC_REF(on_minigame_started), TRUE)
		if(challenge)
			RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_GET_DIFFICULTY, PROC_REF(adjust_difficulty), TRUE)
	challenge?.update_difficulty()

/datum/component/adjust_fishing_difficulty/proc/on_minigame_started(mob/living/source, datum/fishing_challenge/challenge)
	SIGNAL_HANDLER
	RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_GET_DIFFICULTY, PROC_REF(adjust_difficulty), TRUE)

/datum/component/adjust_fishing_difficulty/proc/adjust_difficulty(datum/fishing_challenge/challenge, reward_path, obj/item/fishing_rod/rod, mob/living/user, list/holder)
	SIGNAL_HANDLER
	holder[1] += modifier
