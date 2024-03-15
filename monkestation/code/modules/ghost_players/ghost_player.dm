GLOBAL_VAR_INIT(disable_ghost_spawning, FALSE)

/client/proc/flip_ghost_spawn()
	set category = "Admin.Fun"
	set name = "Toggle Centcomm Spawning"
	set desc= "Toggles whether dead players can respawn in the centcomm area"

	if(!check_rights(R_FUN))
		return
	GLOB.disable_ghost_spawning = !GLOB.disable_ghost_spawning

/mob/living/carbon/human/ghost
	var/revive_prepped = FALSE
	var/old_key
	var/datum/mind/old_mind
	var/old_reenter
	var/obj/item/organ/internal/brain/old_human

	///the button we are tied to for dueling
	var/obj/structure/fight_button/linked_button
	///are we dueling?
	var/dueling = FALSE

/mob/living/carbon/human/ghost/death(gibbed)
	. = ..()
	life_or_death()

/mob/living/carbon/human/ghost/New(_old_key, datum/mind/_old_mind, _old_reenter, obj/item/organ/internal/brain/_old_human)
	. = ..()
	old_key = _old_key
	old_mind = _old_mind
	old_reenter = _old_reenter
	old_human = _old_human

/mob/living/carbon/human/ghost/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/return_to_ghost/created_ability = new /datum/action/cooldown/mob_cooldown/return_to_ghost(src)
	created_ability.Grant(src)

/mob/living/carbon/human/ghost/Destroy()
	if(dueling && linked_button)
		addtimer(CALLBACK(linked_button, TYPE_PROC_REF(/obj/structure/fight_button, end_duel), src), 3 SECONDS)

	if(linked_button)
		linked_button.remove_user(src)
		linked_button = null
	return ..()

/mob/living/carbon/human/ghost/Life(seconds_per_tick, times_fired)
	. = ..()
	if(. && stat > SOFT_CRIT)
		life_or_death()

/mob/living/carbon/human/ghost/proc/disolve_ghost()
	var/mob/dead/observer/new_ghost = ghostize(can_reenter_corpse = FALSE)
	if(!QDELETED(new_ghost))
		new_ghost.key = old_key
		new_ghost.mind = old_mind
		new_ghost.can_reenter_corpse = old_reenter
	old_human?.temporary_sleep = FALSE
	qdel(src)

/mob/living/carbon/human/ghost/proc/life_or_death()
	if(QDELING(src) || QDELETED(client) || client.is_afk())
		disolve_ghost()
	else
		move_to_ghostspawn()
		revive(full_heal_flags = ADMIN_HEAL_ALL)

/datum/action/cooldown/mob_cooldown/return_to_ghost
	name = "Return to Ghost"
	desc = "Either returns you to being a ghost or sends your soul back to your last body if it's revived."

	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	click_to_activate = FALSE
	check_flags = NONE
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/return_to_ghost/Activate(atom/target)
	var/mob/living/carbon/human/ghost/living_owner = owner
	if(!istype(living_owner))
		return
	if(living_owner.revive_prepped)
		return TRUE
	living_owner.disolve_ghost()
	return TRUE


//ghost stuff

/mob/dead/observer/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/create_ghost_player/created_ability = new /datum/action/cooldown/mob_cooldown/create_ghost_player(src)
	created_ability.Grant(src)

/datum/action/cooldown/mob_cooldown/create_ghost_player
	name = "Create Ghost Player"
	desc = "Become a ghost player that can mess around in the ghost area."

	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	click_to_activate = FALSE
	check_flags = NONE
	cooldown_time = 40 SECONDS
	shared_cooldown = NONE


/datum/action/cooldown/mob_cooldown/create_ghost_player/IsAvailable(feedback)
	. = ..()
	if(GLOB.disable_ghost_spawning)
		return FALSE

/datum/action/cooldown/mob_cooldown/create_ghost_player/Activate(atom/target)
	var/mob/dead/observer/player = owner
	if(!istype(player))
		return
	player.create_ghost_body()


/mob/dead/observer/proc/create_ghost_body()
	var/mob/living/carbon/human/old_mob = mind?.current
	var/obj/item/organ/internal/brain/brain
	if(istype(old_mob))
		brain = old_mob.get_organ_by_type(/obj/item/organ/internal/brain)
		if(brain)
			brain.temporary_sleep = TRUE

	var/client/our_client = client || GLOB.directory[ckey]
	var/mob/living/carbon/human/ghost/new_existence = new(key, mind, can_reenter_corpse, brain)
	our_client?.prefs.safe_transfer_prefs_to(new_existence, TRUE, FALSE)
	new_existence.move_to_ghostspawn()
	new_existence.key = key
	new_existence.equip_outfit_and_loadout(/datum/outfit/ghost_player, our_client.prefs)
	for(var/datum/loadout_item/item as anything in loadout_list_to_datums(our_client?.prefs?.loadout_list))
		if(length(item.restricted_roles))
			continue
		item.post_equip_item(our_client.prefs, new_existence)
	SSquirks.AssignQuirks(new_existence, our_client)
	our_client?.init_verbs()
	qdel(src)
	return TRUE


/// Iterates over all turfs in the target area and returns the first non-dense one
/mob/living/carbon/human/ghost/proc/move_to_ghostspawn()
	var/list/turfs = get_area_turfs(/area/centcom/central_command_areas/ghost_spawn)
	var/turf/open/target_turf = null
	var/sanity = 0
	while(!target_turf && sanity < 100)
		sanity++
		var/turf/turf = pick(turfs)
		if(!turf.density)
			target_turf = turf
	forceMove(target_turf)


/obj/item/organ/internal/brain
	var/temporary_sleep = FALSE
