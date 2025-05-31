/// If we spawn an ERT with the "choose experienced leader" option, select the leader from the top X playtimes
#define ERT_EXPERIENCED_LEADER_CHOOSE_TOP 3

///Dummy mob reserve slot for admin use
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"

// CENTCOM RESPONSE TEAM

/datum/admins/proc/makeERTTemplateModified(list/settings)
	. = settings
	var/datum/ert/newtemplate = settings["mainsettings"]["template"]["value"]
	if (isnull(newtemplate))
		return
	if (!ispath(newtemplate))
		newtemplate = text2path(newtemplate)
	newtemplate = new newtemplate
	.["mainsettings"]["teamsize"]["value"] = newtemplate.teamsize
	.["mainsettings"]["mission"]["value"] = newtemplate.mission
	.["mainsettings"]["polldesc"]["value"] = newtemplate.polldesc
	.["mainsettings"]["open_armory"]["value"] = newtemplate.opendoors ? "Yes" : "No"
	.["mainsettings"]["leader_experience"]["value"] = newtemplate.leader_experience ? "Yes" : "No"
	.["mainsettings"]["random_names"]["value"] = newtemplate.random_names ? "Yes" : "No"
	.["mainsettings"]["spawn_admin"]["value"] = newtemplate.spawn_admin ? "Yes" : "No"
	.["mainsettings"]["use_custom_shuttle"]["value"] = newtemplate.use_custom_shuttle ? "Yes" : "No"


/datum/admins/proc/equipAntagOnDummy(mob/living/carbon/human/dummy/mannequin, datum/antagonist/antag)
	for(var/I in mannequin.get_equipped_items(INCLUDE_POCKETS))
		qdel(I)
	if (ispath(antag, /datum/antagonist/ert))
		var/datum/antagonist/ert/ert = antag
		mannequin.equipOutfit(initial(ert.outfit), TRUE)

/datum/admins/proc/makeERTPreviewIcon(list/settings)
	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)

	var/prefs = settings["mainsettings"]
	var/datum/ert/template = prefs["template"]["value"]
	if (isnull(template))
		return null
	if (!ispath(template))
		template = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

	template = new template
	var/datum/antagonist/ert/ert = template.leader_role

	equipAntagOnDummy(mannequin, ert)

	CHECK_TICK
	var/icon/preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)
	CHECK_TICK
	mannequin.setDir(NORTH)
	var/icon/stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)
	CHECK_TICK
	mannequin.setDir(WEST)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)
	CHECK_TICK
	mannequin.setDir(SOUTH)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)
	CHECK_TICK
	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	CHECK_TICK
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_ADMIN)
	return preview_icon

/datum/admins/proc/make_emergency_response_team(datum/ert/ertemplate = null)
	if (ertemplate)
		ertemplate = new ertemplate
	else
		ertemplate = new /datum/ert/centcom_official

	var/human_authority_setting = CONFIG_GET(string/human_authority)

	var/list/settings = list(
		"preview_callback" = CALLBACK(src, PROC_REF(makeERTPreviewIcon)),
		"mainsettings" = list(
		"template" = list("desc" = "Template", "callback" = CALLBACK(src, PROC_REF(makeERTTemplateModified)), "type" = "datum", "path" = "/datum/ert", "subtypesonly" = TRUE, "value" = ertemplate.type),
		"teamsize" = list("desc" = "Team Size", "type" = "number", "value" = ertemplate.teamsize),
		"mission" = list("desc" = "Mission", "type" = "string", "value" = ertemplate.mission),
		"polldesc" = list("desc" = "Ghost poll description", "type" = "string", "value" = ertemplate.polldesc),
		"enforce_human" = list("desc" = "Enforce human authority", "type" = "boolean", "value" = "[(human_authority_setting == HUMAN_AUTHORITY_ENFORCED ? "Yes" : "No")]"),
		"open_armory" = list("desc" = "Open armory doors", "type" = "boolean", "value" = "[(ertemplate.opendoors ? "Yes" : "No")]"),
		"leader_experience" = list("desc" = "Pick an experienced leader", "type" = "boolean", "value" = "[(ertemplate.leader_experience ? "Yes" : "No")]"),
		"random_names" = list("desc" = "Randomize names", "type" = "boolean", "value" = "[(ertemplate.random_names ? "Yes" : "No")]"),
		"spawn_admin" = list("desc" = "Spawn yourself as briefing officer", "type" = "boolean", "value" = "[(ertemplate.spawn_admin ? "Yes" : "No")]"),
		"use_custom_shuttle" = list("desc" = "Use the ERT's custom shuttle (if it has one)", "type" = "boolean", "value" = "[(ertemplate.use_custom_shuttle ? "Yes" : "No")]"),
		"mob_type" = list("desc" = "Base Species", "callback" = CALLBACK(src, PROC_REF(makeERTTemplateModified)), "type" = "datum", "path" = "/mob/living/carbon/human", "subtypesonly" = TRUE, "value" = ertemplate.mob_type),
		)
	)

	var/list/pref_return = present_pref_like_picker(usr, "Customize ERT", "Customize ERT", width = 600, timeout = 0, settings = settings)

	if (isnull(pref_return) || pref_return["button"] != 1)
		message_admins("[key_name_admin(owner)] changed [owner.p_their()] mind and didn't create a CentCom response team.")
		return FALSE

	var/list/prefs = settings["mainsettings"]

	var/templtype = prefs["template"]["value"]
	if (!ispath(prefs["template"]["value"]))
		templtype = text2path(prefs["template"]["value"]) // new text2path ... doesn't compile in 511

	if (ertemplate.type != templtype)
		ertemplate = new templtype

	ertemplate.teamsize = prefs["teamsize"]["value"]
	ertemplate.mission = prefs["mission"]["value"]
	ertemplate.polldesc = prefs["polldesc"]["value"]
	ertemplate.enforce_human = prefs["enforce_human"]["value"] == "Yes" // these next 6 are effectively toggles
	ertemplate.opendoors = prefs["open_armory"]["value"] == "Yes"
	ertemplate.leader_experience = prefs["leader_experience"]["value"] == "Yes"
	ertemplate.random_names = prefs["random_names"]["value"] == "Yes"
	ertemplate.spawn_admin = prefs["spawn_admin"]["value"] == "Yes"
	ertemplate.use_custom_shuttle = prefs["use_custom_shuttle"]["value"] == "Yes"
	ertemplate.mob_type = prefs["mob_type"]["value"]

	var/list/spawn_points = GLOB.emergencyresponseteamspawn

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates("Do you wish to be considered for [span_notice(ertemplate.polldesc)]?", check_jobban = "deathsquad", alert_pic = /obj/item/card/id/advanced/centcom/ert, role_name_text = "emergency response team")

	if(!length(candidates))
		message_admins("[key_name_admin(owner)] tried to create a CentCom response team but [owner.p_they()] didn't find any candidates.")
		return FALSE

	// This list will take priority over spawn_points if not empty
	var/list/spawn_turfs = list()

	// Takes precedence over spawn_points[1] if not null
	var/turf/brief_spawn

	if(ertemplate.use_custom_shuttle && ertemplate.ert_template)
		to_chat(usr, span_boldnotice("Attempting to spawn ERT custom shuttle, this may take a few seconds..."))
		var/datum/map_template/shuttle/ship = new ertemplate.ert_template
		var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
		var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
		var/z = SSmapping.empty_space.z_value
		var/turf/located_turf = locate(x, y, z)
		if(!located_turf)
			CRASH("ERT shuttle found no place to load in")

		if(!ship.load(located_turf))
			CRASH("Loading ERT shuttle failed!")

		var/list/shuttle_turfs = ship.get_affected_turfs(located_turf)

		for(var/turf/affected_turf as anything in shuttle_turfs)
			for(var/obj/effect/landmark/ert_shuttle_spawn/spawner in affected_turf)
				spawn_turfs += get_turf(spawner)

			if(!brief_spawn)
				brief_spawn = get_turf(locate(/obj/effect/landmark/ert_shuttle_brief_spawn) in affected_turf)

		if(!length(spawn_turfs))
			stack_trace("ERT shuttle loaded but found no spawn points, placing the ERT at wherever inside the shuttle instead.")

			for(var/turf/open/floor/open_turf in shuttle_turfs)
				if(!is_safe_turf(open_turf))
					continue
				spawn_turfs += open_turf


	if(ertemplate.spawn_admin)
		if(isobserver(usr))
			var/mob/living/carbon/human/admin_officer = new (brief_spawn || spawn_points[1])
			var/chosen_outfit = usr.client?.prefs?.read_preference(/datum/preference/choiced/brief_outfit)
			usr.client.prefs.safe_transfer_prefs_to(admin_officer, is_antag = TRUE)
			admin_officer.equipOutfit(chosen_outfit)
			admin_officer.PossessByPlayer(usr.key)

		else
			to_chat(usr, span_warning("Could not spawn you in as briefing officer as you are not a ghost!"))

	//Pick the (un)lucky players
	var/numagents = min(ertemplate.teamsize, length(candidates))

	//Create team
	var/datum/team/ert/ert_team = new ertemplate.team()
	if(ertemplate.rename_team)
		ert_team.name = ertemplate.rename_team

	//Assign team objective
	var/datum/objective/missionobj = new ()
	missionobj.team = ert_team
	missionobj.explanation_text = ertemplate.mission
	missionobj.completed = TRUE
	ert_team.objectives += missionobj
	ert_team.mission = missionobj

	var/mob/dead/observer/earmarked_leader
	var/leader_spawned = FALSE // just in case the earmarked leader disconnects or becomes unavailable, we can try giving leader to the last guy to get chosen

	if(ertemplate.leader_experience)
		var/list/candidate_living_exps = list()
		for(var/i in candidates)
			var/mob/dead/observer/potential_leader = i
			candidate_living_exps[potential_leader] = potential_leader.client?.get_exp_living(TRUE)

		candidate_living_exps = sort_list(candidate_living_exps, cmp=/proc/cmp_numeric_dsc)
		if(candidate_living_exps.len > ERT_EXPERIENCED_LEADER_CHOOSE_TOP)
			candidate_living_exps.Cut(ERT_EXPERIENCED_LEADER_CHOOSE_TOP+1) // pick from the top ERT_EXPERIENCED_LEADER_CHOOSE_TOP contenders in playtime
		earmarked_leader = pick(candidate_living_exps)
	else
		earmarked_leader = pick(candidates)

	var/spawn_index = 0
	while(numagents && candidates.len)
		var/turf/spawnloc
		if(length(spawn_turfs))
			spawnloc = pick(spawn_turfs)
		else
			spawnloc = spawn_points[spawn_index+1]
			spawn_index = WRAP_UP(spawn_index, spawn_points.len)

		var/mob/dead/observer/chosen_candidate = earmarked_leader || pick(candidates) // this way we make sure that our leader gets chosen
		candidates -= chosen_candidate

		//Spawn the body
		var/mob/living/carbon/human/ert_operative
		if(ertemplate.mob_type)
			ert_operative = new ertemplate.mob_type(spawnloc)
		else
			ert_operative = new /mob/living/carbon/human(spawnloc)
			chosen_candidate.client.prefs.safe_transfer_prefs_to(ert_operative, is_antag = TRUE)
		ert_operative.PossessByPlayer(chosen_candidate.key)

		if(ertemplate.enforce_human || !(ert_operative.dna.species.changesource_flags & ERT_SPAWN))
			ert_operative.set_species(/datum/species/human)

		//Give antag datum
		var/datum/antagonist/ert/ert_antag

		if((chosen_candidate == earmarked_leader) || (numagents == 1 && !leader_spawned))
			ert_antag = new ertemplate.leader_role ()
			earmarked_leader = null
			leader_spawned = TRUE
		else
			ert_antag = ertemplate.roles[WRAP(numagents,1,length(ertemplate.roles) + 1)]
			ert_antag = new ert_antag ()
		ert_antag.random_names = ertemplate.random_names

		ert_operative.mind.add_antag_datum(ert_antag,ert_team)
		ert_operative.mind.set_assigned_role(SSjob.get_job_type(ert_antag.ert_job_path))

		//Logging and cleanup
		ert_operative.log_message("has been selected as \a [ert_antag.name].", LOG_GAME)
		numagents--

	//Open the Armory doors
	if(ertemplate.opendoors)
		for(var/obj/machinery/door/poddoor/ert/door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor/ert))
			door.open()
			CHECK_TICK

	message_admins("[key_name_admin(owner)] created a CentCom response team.")
	message_admins("[capitalize(ertemplate.polldesc)] has spawned with the mission: [ertemplate.mission]")
	return TRUE

ADMIN_VERB(summon_ert, R_FUN, "Summon ERT", "Summons an emergency response team.", ADMIN_CATEGORY_FUN)
	message_admins("[key_name_admin(user)] is creating a CentCom response team...")
	if(user.holder?.make_emergency_response_team())
		log_admin("[key_name(user)] created a CentCom response team.")
	else
		log_admin("[key_name(user)] failed to create a CentCom response team.")

#undef ERT_EXPERIENCED_LEADER_CHOOSE_TOP
#undef DUMMY_HUMAN_SLOT_ADMIN
