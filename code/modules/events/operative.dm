/datum/round_event_control/operative
	name = "Lone Operative"
	typepath = /datum/round_event/ghost_role/operative
	weight = 0 //Admin only
	max_occurrences = 1

/datum/round_event/ghost_role/operative
	minimum_required = 1
	role_name = "lone operative"

/datum/round_event/ghost_role/operative/spawn_role()
	var/list/candidates = get_candidates("operative", null, ROLE_OPERATIVE)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name in list("ninjaspawn","carpspawn"))
			spawn_locs += L.loc
	if(!spawn_locs.len)
		return MAP_ERROR

	var/mob/living/carbon/human/operative = new(pick(spawn_locs))
	var/datum/preferences/A = new
	A.copy_to(operative)
	operative.dna.update_dna_identity()

	operative.equipOutfit(/datum/outfit/syndicate/full)

	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.assigned_role = "Lone Operative"
	Mind.special_role = "Lone Operative"
	SSticker.mode.traitors |= Mind
	Mind.active = 1

	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.machines
	if(nuke)
		var/nuke_code
		if(!nuke.r_code || nuke.r_code == "ADMIN")
			nuke_code = random_nukecode()
			nuke.r_code = nuke_code
		else
			nuke_code = nuke.r_code

		Mind.store_memory("<B>Station Self-Destruct Device Code</B>: [nuke_code]", 0, 0)
		to_chat(Mind.current, "The nuclear authorization code is: <B>[nuke_code]</B>")

		var/datum/objective/nuclear/O = new()
		O.owner = Mind
		Mind.objectives += O

	Mind.transfer_to(operative)

	message_admins("[key_name_admin(operative)] has been made into lone operative by an event.")
	log_game("[key_name(operative)] was spawned as a lone operative by an event.")
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN
