/datum/round_event_control/paradox_clone
	name = "Spawn Paradox Clone"
	typepath = /datum/round_event/ghost_role/paradox_clone
	max_occurrences = 1
	min_players = 15
	earliest_start = 20 MINUTES
	category = EVENT_CATEGORY_INVASION
	description = "A time-space anomaly will occur and spawn a paradox clone somewhere on the station."

/datum/round_event/ghost_role/paradox_clone
	minimum_required = 1
	role_name = "Paradox Clone"
	fakeable = TRUE

/datum/round_event/ghost_role/paradox_clone/spawn_role()
	var/list/candidates = get_candidates(ROLE_PARADOX_CLONE, ROLE_PARADOX_CLONE)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/list/possible_spawns = list()
	for(var/turf/warp_point in GLOB.xeno_spawn)
		if(istype(warp_point.loc, /area/station/maintenance))
			possible_spawns += warp_point
	if(!possible_spawns.len)
		message_admins("No valid spawn locations found for Paradox Clone event, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/clone = new ((pick(possible_spawns)))
	player_mind.transfer_to(clone)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/paradox_clone))
	player_mind.special_role = ROLE_PARADOX_CLONE
	player_mind.add_antag_datum(/datum/antagonist/paradox_clone)

	//cloning appearence/name/dna
	var/datum/antagonist/paradox_clone/cloned = player_mind.has_antag_datum(/datum/antagonist/paradox_clone)
	var/mob/living/carbon/carbon_cloned = cloned.original.current //target
	var/mob/living/carbon/human/human_cloned = cloned.original.current

	clone.fully_replace_character_name(null, carbon_cloned.dna.real_name)
	clone.name = carbon_cloned.name
	carbon_cloned.dna.transfer_identity(clone, transfer_SE=1)
	clone.underwear = human_cloned.underwear
	clone.undershirt = human_cloned.undershirt
	clone.socks = human_cloned.socks
	for(var/datum/quirk/target_quirk as anything in human_cloned.quirks)
		clone.add_quirk(target_quirk.type)
	clone.updateappearance(mutcolor_update=1)
	clone.domutcheck()

	//cloning clothing/ID/bag
	clone.mind.assigned_role = carbon_cloned.mind.assigned_role

	if(isplasmaman(carbon_cloned))
		clone.equipOutfit(carbon_cloned.mind.assigned_role.plasmaman_outfit)
		clone.internal = clone.get_item_for_held_index(1)
	clone.equipOutfit(carbon_cloned.mind.assigned_role.outfit)

	var/obj/item/clothing/under/sensor_clothes = clone.w_uniform
	var/obj/item/modular_computer/tablet/pda/messenger = locate() in clone
	if(messenger)
		var/datum/computer_file/program/messenger/message_app = locate() in messenger.stored_files
		if(message_app)
			message_app.invisible = TRUE //clone doesnt show up on message lists
	clone.backpack = human_cloned.backpack
	if(sensor_clothes)
		sensor_clothes.sensor_mode = SENSOR_OFF //dont want anyone noticing there's two now
		clone.update_suit_sensors()

	message_admins("[ADMIN_LOOKUPFLW(clone)] has been made into a Paradox Clone by an event.")
	clone.log_message("was spawned as a Paradox Clone of [key_name(human_cloned)] by an event.", LOG_GAME)
	spawned_mobs += clone
	playsound(clone, 'sound/weapons/zapbang.ogg', 30, TRUE)
	new /obj/item/storage/toolbox/mechanical(clone.loc) //so they dont get stuck in maints


	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/paradox_clone/announce(fake)
	priority_announce("A time-space anomaly has been detected on the station, be aware of possible discrepancies.", "General Alert")


