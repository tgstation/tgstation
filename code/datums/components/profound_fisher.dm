///component that allows player mobs to play the fishing minigame without a rod equipped, non-player mobs will "pretend" fish
/datum/component/profound_fisher
	///the fishing rod this mob will use
	var/obj/item/fishing_rod/mob_fisher/our_rod
	///Wether we should delete the fishing rod along with the component or replace it if it's somehow removed from the parent
	var/delete_rod_when_deleted = TRUE

/datum/component/profound_fisher/Initialize(our_rod, delete_rod_when_deleted = TRUE)
	var/isgloves = istype(parent, /obj/item/clothing/gloves)
	if(!isliving(parent) && !isgloves)
		return COMPONENT_INCOMPATIBLE
	src.our_rod = our_rod || new(parent)
	src.our_rod.internal = TRUE
	src.delete_rod_when_deleted = delete_rod_when_deleted
	ADD_TRAIT(src.our_rod, TRAIT_NOT_BARFABLE, REF(src))
	RegisterSignal(src.our_rod, COMSIG_MOVABLE_MOVED, PROC_REF(on_rod_moved))

	if(!isgloves)
		RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
		RegisterSignal(parent, COMSIG_MOB_COMPLETE_FISHING, PROC_REF(stop_fishing))
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

///Handles replacing the fishing rod if somehow removed from the parent movable if delete_rod_when_deleted is TRUE, otherwise delete the component.
/datum/component/profound_fisher/proc/on_rod_moved(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src) || our_rod.loc == parent)
		return
	if(delete_rod_when_deleted)
		UnregisterSignal(our_rod, COMSIG_MOVABLE_MOVED)
		if(!QDELETED(our_rod))
			qdel(our_rod)
		our_rod = new our_rod.type(parent)
	else
		qdel(src)

/datum/component/profound_fisher/Destroy()
	UnregisterSignal(our_rod, COMSIG_MOVABLE_MOVED)
	if(!delete_rod_when_deleted)
		our_rod.internal = FALSE
		REMOVE_TRAIT(our_rod, TRAIT_NOT_BARFABLE, REF(src))
	else if(!QDELETED(our_rod))
		QDEL_NULL(our_rod)
	our_rod = null
	return ..()

/datum/component/profound_fisher/proc/on_equip(obj/item/source, atom/equipper, slot)
	SIGNAL_HANDLER
	if(slot != ITEM_SLOT_GLOVES)
		return
	RegisterSignal(equipper, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(equipper, COMSIG_MOB_COMPLETE_FISHING, PROC_REF(stop_fishing))

/datum/component/profound_fisher/proc/open_rod_menu(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(our_rod, TYPE_PROC_REF(/datum, ui_interact), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/component/profound_fisher/proc/on_drop(datum/source, atom/dropper)
	SIGNAL_HANDLER
	UnregisterSignal(dropper, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_COMPLETE_FISHING))
	REMOVE_TRAIT(dropper, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC) //this will cancel the current minigame if the fishing rod was internal.

/datum/component/profound_fisher/proc/on_unarmed_attack(mob/living/source, atom/attack_target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!should_fish_on(source, attack_target))
		return
	if(source.client)
		INVOKE_ASYNC(src, PROC_REF(begin_fishing), source, attack_target)
	else
		INVOKE_ASYNC(src, PROC_REF(pretend_fish), source, attack_target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/profound_fisher/proc/pre_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!should_fish_on(source, target))
		return
	if(source.client)
		INVOKE_ASYNC(src, PROC_REF(begin_fishing), source, target)
	else
		INVOKE_ASYNC(src, PROC_REF(pretend_fish), source, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/profound_fisher/proc/should_fish_on(mob/living/user, atom/target)
	if(!HAS_TRAIT(target, TRAIT_FISHING_SPOT) || GLOB.fishing_challenges_by_user[user])
		return FALSE
	if(user.combat_mode || !user.CanReach(target))
		return FALSE
	return TRUE

/datum/component/profound_fisher/proc/begin_fishing(mob/living/user, atom/target)
	our_rod.melee_attack_chain(user, target)
	ADD_TRAIT(user, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC)

/datum/component/profound_fisher/proc/stop_fishing(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_PROFOUND_FISHER, TRAIT_GENERIC)

/datum/component/profound_fisher/proc/pretend_fish(mob/living/source, atom/target)
	if(DOING_INTERACTION_WITH_TARGET(source, target))
		return
	var/list/fish_spot_container[NPC_FISHING_SPOT]
	SEND_SIGNAL(target, COMSIG_NPC_FISHING, fish_spot_container)
	var/datum/fish_source/fish_spot = fish_spot_container[NPC_FISHING_SPOT]
	if(isnull(fish_spot))
		return null
	var/obj/effect/fishing_float/float = new(get_turf(target), target)
	playsound(float, 'sound/effects/splash.ogg', 100)
	if(!PERFORM_ALL_TESTS(fish_sources))
		var/happiness_percentage = source.ai_controller?.blackboard[BB_BASIC_HAPPINESS] * 0.01
		var/fishing_speed = 10 SECONDS - round(4 SECONDS * happiness_percentage)
		if(!do_after(source, fishing_speed, target = target) && !QDELETED(fish_spot))
			qdel(float)
			return
	var/reward_loot = fish_spot.roll_mindless_reward(our_rod, source, target)
	fish_spot.dispense_reward(reward_loot, source, target)
	playsound(float, 'sound/effects/bigsplash.ogg', 100)
	qdel(float)

/obj/item/fishing_rod/mob_fisher
	line = /obj/item/fishing_line/reinforced
	bait = /obj/item/food/bait/doughball/synthetic/unconsumable
	resistance_flags = INDESTRUCTIBLE
	reel_overlay = null
	show_in_wiki = FALSE //abstract fishing rod
	item_flags = ABSTRACT
