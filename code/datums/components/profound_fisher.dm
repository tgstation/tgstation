///component that allows player mobs to play the fishing minigame, non-player mobs will "pretend" fish
/datum/component/profound_fisher
	///the fishing rod this mob will use
	var/obj/item/fishing_rod/mob_fisher/our_rod

/datum/component/profound_fisher/Initialize(list/npc_fishing_preset = list())
	if(!isliving(parent))
		return
	our_rod = new(parent)
	ADD_TRAIT(parent, TRAIT_PROFOUND_FISHER, REF(src))

/datum/component/profound_fisher/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

/datum/component/profound_fisher/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	REMOVE_TRAIT(parent, TRAIT_PROFOUND_FISHER, REF(src))

/datum/component/profound_fisher/Destroy()
	QDEL_NULL(our_rod)
	return ..()

/datum/component/profound_fisher/proc/pre_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!HAS_TRAIT(target, TRAIT_FISHING_SPOT))
		return NONE
	var/mob/living/living_parent = parent
	if(living_parent.combat_mode || !living_parent.CanReach(target))
		return NONE
	if(living_parent.client)
		INVOKE_ASYNC(our_rod, TYPE_PROC_REF(/obj/item, melee_attack_chain), parent, target)
	else
		INVOKE_ASYNC(src, PROC_REF(pretend_fish), target)
	return COMPONENT_HOSTILE_NO_ATTACK

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


