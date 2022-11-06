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
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/station/maintenance))
			possible_spawns += X
	if(!possible_spawns.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/S = new ((pick(possible_spawns)))
	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/paradox_clone))
	player_mind.special_role = ROLE_PARADOX_CLONE
	player_mind.add_antag_datum(/datum/antagonist/paradox_clone)

	//cloning appearence/name/dna
	var/datum/antagonist/paradox_clone/cloned = player_mind.has_antag_datum(/datum/antagonist/paradox_clone)
	var/mob/living/carbon/carbon_cloned = cloned.original.current //target
	var/mob/living/carbon/human/human_cloned = cloned.original.current

	S.fully_replace_character_name(null, carbon_cloned.dna.real_name)
	S.name = carbon_cloned.name
	carbon_cloned.dna.transfer_identity(S, transfer_SE=1)
	S.underwear = human_cloned.underwear
	S.undershirt = human_cloned.undershirt
	S.socks = human_cloned.socks
	S.updateappearance(mutcolor_update=1)
	S.domutcheck()

	//cloning clothing/ID/bag
	S.mind.assigned_role = carbon_cloned.mind.assigned_role

	if(isplasmaman(carbon_cloned))
		S.equipOutfit(carbon_cloned.mind.assigned_role.plasmaman_outfit)
		S.internal = S.get_item_for_held_index(1)
	S.equipOutfit(carbon_cloned.mind.assigned_role.outfit)

	var/obj/item/clothing/under/sensor_clothes = S.w_uniform
	var/list/all_items = S.get_all_contents()
	var/obj/item/modular_computer/tablet/pda/messenger = locate(/obj/item/modular_computer/tablet/pda/) in S
	S.backpack = human_cloned.backpack
	for(var/charter in all_items)
		if(istype(charter, /obj/item/station_charter))
			qdel(charter) //so there wont be two station charters
	if(sensor_clothes)
		sensor_clothes.sensor_mode = SENSOR_OFF //dont want anyone noticing there's two now
		S.update_suit_sensors()
	if(messenger)
		messenger.invisible = TRUE //clone doesnt show up on PDA message list

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Paradox Clone by an event.")
	S.log_message("was spawned as a Paradox Clone by an event.", LOG_GAME)
	spawned_mobs += S
	playsound(S, 'sound/weapons/zapbang.ogg', 50, TRUE)
	new /obj/item/storage/toolbox/mechanical(S.loc) //so they dont get stuck in maints

	priority_announce("A time-space anomaly has been detected on the station, be aware of possible discrepancies.", "General Alert")

	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/paradox_clone/announce(fake)
	priority_announce("A time-space anomaly has been detected on the station, be aware of possible discrepancies.", "General Alert")


