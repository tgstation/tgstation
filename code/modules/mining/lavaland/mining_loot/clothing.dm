// Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return (slot & ITEM_SLOT_NECK)

/obj/item/clothing/neck/necklace/memento_mori/dropped(mob/user)
	. = ..()
	if(active_owner)
		mori()

// Just in case
/obj/item/clothing/neck/necklace/memento_mori/Destroy()
	if(active_owner)
		mori()
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/memento(mob/living/carbon/human/user)
	to_chat(user, span_warning("You feel your life being drained by the pendant..."))
	if (!do_after(user, 4 SECONDS, target = user))
		return

	to_chat(user, span_notice("Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die."))
	user.add_traits(list(TRAIT_NODEATH, TRAIT_NOHARDCRIT, TRAIT_NOCRITDAMAGE), CLOTHING_TRAIT)
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_health))
	icon_state = "memento_mori_active"
	active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if (!active_owner)
		return
	UnregisterSignal(active_owner, COMSIG_LIVING_HEALTH_UPDATE)
	var/mob/living/carbon/human/stored_owner = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(stored_owner, span_userdanger("You feel your life rapidly slipping away from you!"))
	stored_owner.dust(TRUE, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/check_health(mob/living/source)
	SIGNAL_HANDLER

	var/list/guardians = source.get_all_linked_holoparasites()
	if (!length(guardians))
		return
	if (source.health <= HEALTH_THRESHOLD_DEAD)
		for (var/mob/guardian in guardians)
			if(guardian.loc == src)
				continue
			consume_guardian(guardian)
	else if (source.health > HEALTH_THRESHOLD_CRIT)
		for (var/mob/guardian in guardians)
			if(guardian.loc != src)
				continue
			regurgitate_guardian(guardian)

/obj/item/clothing/neck/necklace/memento_mori/proc/consume_guardian(mob/living/basic/guardian/guardian)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(guardian))
	guardian.locked = TRUE
	guardian.forceMove(src)
	to_chat(guardian, span_userdanger("You have been locked away in your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)

/obj/item/clothing/neck/necklace/memento_mori/proc/regurgitate_guardian(mob/living/basic/guardian/guardian)
	guardian.locked = FALSE
	guardian.recall(forced = TRUE)
	to_chat(guardian, span_notice("You have been returned back from your summoner's pendant!"))
	guardian.playsound_local(get_turf(guardian), 'sound/effects/magic/repulse.ogg', 50, TRUE)

/datum/action/item_action/hands_free/memento_mori
	check_flags = NONE
	name = "Memento Mori"
	desc = "Bind your life to the pendant."

/datum/action/item_action/hands_free/memento_mori/do_effect(trigger_flags)
	var/obj/item/clothing/neck/necklace/memento_mori/memento = target
	if(memento.active_owner || !ishuman(owner))
		return FALSE
	memento.memento(owner)
	Remove(memento.active_owner) //Remove the action button, since there's no real use in having it now.
	return TRUE

// Concussive Gauntlets

/obj/item/clothing/gloves/gauntlets
	name = "concussive gauntlets"
	desc = "Pickaxes... for your hands!"
	icon_state = "concussive_gauntlets"
	inhand_icon_state = null
	toolspeed = 0.1
	strip_delay = 4 SECONDS
	equip_delay_other = 2 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	body_parts_covered = HANDS|ARMS
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor_type = /datum/armor/gloves_gauntlets

/datum/armor/gloves_gauntlets
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 100
	fire = 100
	acid = 30

/obj/item/clothing/gloves/gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(rocksmash))
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(rocksmash))
	else
		stopmining(user)

/obj/item/clothing/gloves/gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOVABLE_BUMP))

/obj/item/clothing/gloves/gauntlets/proc/rocksmash(mob/living/carbon/human/user, atom/rocks, proximity)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE
	if(!ismineralturf(rocks) && !isasteroidturf(rocks))
		return NONE
	rocks.attackby(src, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN
