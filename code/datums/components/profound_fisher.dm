///component that allows player mobs to play the fishing minigame without a rod equipped, non-player mobs will "pretend" fish
/datum/component/profound_fisher
	///the fishing rod this mob will use
	var/obj/item/fishing_rod/mob_fisher/our_rod

/datum/component/profound_fisher/Initialize(our_rod)
	var/isclothing = isclothing(parent)
	if(!isliving(parent) && !isclothing)
		return COMPONENT_INCOMPATIBLE
	src.our_rod = our_rod || new(parent)
	src.our_rod.display_fishing_line = FALSE
	RegisterSignal(src.our_rod, COMSIG_QDELETING, PROC_REF(on_rod_qdel))

	if(!isclothing)
		RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	else
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(open_rod_menu))

/datum/component/profound_fisher/proc/on_rod_qdel(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/profound_fisher/Destroy()
	if(!QDELETED(our_rod) && istype(our_rod, /obj/item/fishing_rod/mob_fisher))
		QDEL_NULL(our_rod)
	else
		our_rod.display_fishing_line = TRUE
		UnregisterSignal(our_rod, COMSIG_QDELETING)
		our_rod = null
	return ..()

/datum/component/profound_fisher/proc/on_equip(obj/item/source, atom/equipper, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot))
		return
	RegisterSignal(equipper, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/profound_fisher/proc/open_rod_menu(datum/source, mob/user, list/modifiers)
	our_rod.ui_interact(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/component/profound_fisher/proc/on_drop(datum/source, atom/dropper)
	SIGNAL_HANDLER
	UnregisterSignal(dropper, COMSIG_LIVING_UNARMED_ATTACK)
	if(HAS_TRAIT(dropper, TRAIT_PROFOUND_FISHER)) //The dropper is fishing thanks to an equipment with this on.
		REMOVE_TRAIT(dropper, TRAIT_GONE_FISHING, TRAIT_GENERIC)

/datum/component/profound_fisher/proc/on_unarmed_attack(mob/living/source, atom/attack_target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!source.client || !should_fish_on(source, attack_target))
		return
	INVOKE_ASYNC(src, PROC_REF(begin_fishing), source, attack_target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/profound_fisher/proc/pre_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!should_fish_on(source, target))
		return
	if(source.client)
		INVOKE_ASYNC(src, PROC_REF(begin_fishing), source, target)
	else
		INVOKE_ASYNC(src, PROC_REF(pretend_fish), target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/profound_fisher/proc/should_fish_on(mob/living/user, atom/target)
	if(!HAS_TRAIT(target, TRAIT_FISHING_SPOT) || HAS_TRAIT(user, TRAIT_GONE_FISHING))
		return FALSE
	if(user.combat_mode || !user.CanReach(target))
		return NONE

/datum/component/profound_fisher/proc/begin_fishing(mob/living/user, atom/target)
	RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_GONE_FISHING), PROC_REF(actually_fishing_with_internal_rod))
	our_rod.melee_attack_chain(user, target)
	UnregisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_GONE_FISHING))

/datum/component/profound_fisher/proc/actually_fishing_with_internal_rod(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(source, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC)
	RegisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_GONE_FISHING), PROC_REF(remove_profound_fisher))

/datum/component/profound_fisher/proc/remove_profound_fisher(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC)
	UnregisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_GONE_FISHING))

/datum/component/profound_fisher/proc/pretend_fish(atom/target)
	var/mob/living/living_parent = parent
	if(DOING_INTERACTION_WITH_TARGET(living_parent, target))
		return
	var/list/fish_spot_container[NPC_FISHING_SPOT]
	SEND_SIGNAL(target, COMSIG_NPC_FISHING, fish_spot_container)
	var/datum/fish_source/fish_spot = fish_spot_container[NPC_FISHING_SPOT]
	if(isnull(fish_spot))
		return null
	var/obj/effect/fishing_lure/lure = new(get_turf(target), target)
	playsound(lure, 'sound/effects/splash.ogg', 100)
	var/happiness_percentage = living_parent.ai_controller?.blackboard[BB_BASIC_HAPPINESS] / 100
	var/fishing_speed = 10 SECONDS - round(4 SECONDS * happiness_percentage)
	if(!do_after(living_parent, fishing_speed, target = target) && !QDELETED(fish_spot))
		qdel(lure)
		return
	var/reward_loot = fish_spot.roll_reward(our_rod, parent)
	fish_spot.dispense_reward(reward_loot, parent, target)
	playsound(lure, 'sound/effects/bigsplash.ogg', 100)
	qdel(lure)

/obj/item/fishing_rod/mob_fisher
	display_fishing_line = FALSE
	line = /obj/item/fishing_line/reinforced

/obj/item/fishing_rod/mob_fisher/baitless
	bait = null
