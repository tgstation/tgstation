///component that allows player mobs to play the fishing minigame without a rod equipped, non-player mobs will "pretend" fish
/datum/component/profound_fisher
	///the fishing rod this mob will use
	var/obj/item/fishing_rod/mob_fisher/our_rod

/datum/component/profound_fisher/Initialize(our_rod)
	var/isgloves = istype(parent, /obj/item/clothing/gloves)
	if(!isliving(parent) && !isgloves)
		return COMPONENT_INCOMPATIBLE
	src.our_rod = our_rod || new(parent)
	src.our_rod.internal = TRUE
	RegisterSignal(src.our_rod, COMSIG_QDELETING, PROC_REF(on_rod_qdel))

	if(!isgloves)
		RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	else
		var/obj/item/clothing/gloves = parent
		RegisterSignal(gloves, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(gloves, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
		RegisterSignal(gloves, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(open_rod_menu))
		RegisterSignal(gloves, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
		gloves.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
		RegisterSignal(gloves, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))
		var/mob/living/wearer = gloves.loc
		if(istype(wearer) && wearer.get_item_by_slot(ITEM_SLOT_GLOVES) == gloves)
			RegisterSignal(wearer, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/profound_fisher/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER
	if(isnull(held_item) && user.contains(parent))
		context[SCREENTIP_CONTEXT_RMB] = "Open rod UI"
		return CONTEXTUAL_SCREENTIP_SET

/datum/component/profound_fisher/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_info("When [EXAMINE_HINT("held")] or [EXAMINE_HINT("equipped")], [EXAMINE_HINT("right-click")] with a empty hand to open the integrated fishing rod interface.")
	examine_list += span_tinynoticeital("To fish, you need to turn combat mode off.")

/datum/component/profound_fisher/proc/on_rod_qdel(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/profound_fisher/Destroy()
	our_rod.internal = FALSE
	UnregisterSignal(our_rod, COMSIG_QDELETING)
	our_rod = null
	return ..()

/datum/component/profound_fisher/proc/on_equip(obj/item/source, atom/equipper, slot)
	SIGNAL_HANDLER
	if(slot != ITEM_SLOT_GLOVES)
		return
	RegisterSignal(equipper, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/profound_fisher/proc/open_rod_menu(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(our_rod, TYPE_PROC_REF(/datum, ui_interact), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/component/profound_fisher/proc/on_drop(datum/source, atom/dropper)
	SIGNAL_HANDLER
	UnregisterSignal(dropper, COMSIG_LIVING_UNARMED_ATTACK)
	REMOVE_TRAIT(dropper, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC) //this will cancel the current minigame if the fishing rod was internal.

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
		return FALSE
	return TRUE

/datum/component/profound_fisher/proc/begin_fishing(mob/living/user, atom/target)
	RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_GONE_FISHING), PROC_REF(actually_fishing_with_internal_rod))
	our_rod.melee_attack_chain(user, target)
	UnregisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_GONE_FISHING))

/datum/component/profound_fisher/proc/actually_fishing_with_internal_rod(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(source, TRAIT_PROFOUND_FISHER, REF(parent))
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
	var/obj/effect/fishing_float/float = new(get_turf(target), target)
	playsound(float, 'sound/effects/splash.ogg', 100)
	var/happiness_percentage = living_parent.ai_controller?.blackboard[BB_BASIC_HAPPINESS] / 100
	var/fishing_speed = 10 SECONDS - round(4 SECONDS * happiness_percentage)
	if(!do_after(living_parent, fishing_speed, target = target) && !QDELETED(fish_spot))
		qdel(float)
		return
	var/reward_loot = fish_spot.roll_reward(our_rod, parent)
	fish_spot.dispense_reward(reward_loot, parent, target)
	playsound(float, 'sound/effects/bigsplash.ogg', 100)
	qdel(float)

/obj/item/fishing_rod/mob_fisher
	line = /obj/item/fishing_line/reinforced
	bait = /obj/item/food/bait/doughball/synthetic/unconsumable
	resistance_flags = INDESTRUCTIBLE
