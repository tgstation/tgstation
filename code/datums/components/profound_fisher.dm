///component that allows player mobs to play the fishing minigame, non-player mobs will "pretend" fish
/datum/component/profound_fisher
	///the fishing rod this mob will use
	var/obj/item/fishing_rod/mob_fisher/our_rod
	///if controlled by an AI, the things this mob can "pretend" fish
	var/list/npc_fishing_preset

/datum/component/profound_fisher/Initialize(list/npc_fishing_preset = list())
	if(!isliving(parent))
		return
	our_rod = new(parent)
	src.npc_fishing_preset = npc_fishing_preset
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
	if(!living_parent.CanReach(target))
		return NONE
	if(living_parent.client)
		INVOKE_ASYNC(our_rod, TYPE_PROC_REF(/obj/item, melee_attack_chain), parent, target)
	else
		INVOKE_ASYNC(src, PROC_REF(pretend_fish), target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/profound_fisher/proc/pretend_fish(atom/target)
	var/fishing_type
	for(var/type in npc_fishing_preset)
		if(!istype(target, type))
			continue
		fishing_type = npc_fishing_preset[type]
		break
	var/datum/fish_source/fish_spot = GLOB.preset_fish_sources[fishing_type]
	if(isnull(fish_spot))
		return null
	var/obj/effect/fishing_lure/lure = new(get_turf(target), target)
	var/mob/living/living_parent = parent
	if(!do_after(living_parent, 10 SECONDS, target = target))
		qdel(lure)
		return
	var/reward_loot = pick_weight(fish_spot.fish_table)
	if(ispath(reward_loot))
		new reward_loot(get_turf(living_parent))
	qdel(lure)

/obj/item/fishing_rod/mob_fisher
	display_fishing_line = FALSE
	line = /obj/item/fishing_line/reinforced


