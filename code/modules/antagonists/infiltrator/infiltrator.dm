/datum/antagonist/traitor/infiltrator
	name = "Infiltrator"
	roundend_category = "syndicate infiltrators"
	show_to_ghosts = TRUE
	special_role = ROLE_INFILTRATOR
	job_rank = "Syndicate Infiltrator"
	should_give_codewords = FALSE //They already get syndicate comms for this.
	var/hijack_chance = 15 //Some corps are more stealthier, but standard chance is high.
	var/dagd_chance = 5 //Why would you infiltrate the station and die here?
	var/kill_chance = 70
	var/obj_mod = 0 //Number of additional objectives that are not affected by config, but by faction
	var/extra_tc = 0 //Used by some factions
	var/faction = "Random"

/datum/antagonist/traitor/infiltrator/event
	name = "Infiltrator (Event)"
	should_give_codewords = TRUE //There is a pretty good chance that infiltrator will spawn in Traitors round, so why not?
	hijack_chance = 0 //Normal mid-round infiltrators will not interrupt the ongoing round with hjiack, \
	unless they get lucky with faction.
	dagd_chance = 0

/datum/antagonist/traitor/infiltrator/event/move_to_spawnpoint() //Mid-round infiltrators are moved on spawn by event.
	owner.current.reagents.add_reagent(/datum/reagent/medicine/leporazine, 20)

/datum/antagonist/traitor/infiltrator/on_gain()
	equip_agent()
	move_to_spawnpoint()
	. = ..()
	//Additional TCs (Mostly for Tiger Co. and MI13)
	var/datum/component/uplink/U = owner.find_syndicate_uplink()
	if (U)
		U.telecrystals += extra_tc
		U.set_gamemode(/datum/game_mode/traitor/infiltrator) //For gamemode-specific uplink stuff during dynamic rounds

/datum/antagonist/traitor/infiltrator/proc/move_to_spawnpoint()
	var/list/emergency_locs = list() //In case map doesn't contain landmarks for infils
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		emergency_locs += L.loc

	if (GLOB.infiltrator_start.len == 0) //No spawn-points for infiltrators - use carp landmarks
		owner.current.forceMove(pick(emergency_locs))
	else
		owner.current.forceMove(pick(GLOB.infiltrator_start))

	owner.current.reagents.add_reagent(/datum/reagent/medicine/leporazine, 30) //Fool-Proof: They won't just die in space due to thermal regulator being turned off.

/datum/antagonist/traitor/infiltrator/proc/equip_agent()
	var/mob/living/carbon/human/H = owner.current
	var/datum/outfit/infiltrator/InfilFit = new /datum/outfit/infiltrator

	H.delete_equipment()
	owner.special_role = special_role
	if(CONFIG_GET(flag/infiltrator_give_codespeak))
		H.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)
	if(faction == "Random")
		faction = pickweight(list("Syndicate" = CONFIG_GET(number/infiltrator_faction_syndicate), "Cybersun" = CONFIG_GET(number/infiltrator_faction_cybersun), "Gorlex" = CONFIG_GET(number/infiltrator_faction_gorlex), "Tiger Co." = CONFIG_GET(number/infiltrator_faction_tiger), "MI13" = CONFIG_GET(number/infiltrator_faction_mi)))
	owner.assigned_role = "[faction] Infiltrator"

	switch(faction)
		if("Cybersun")
			hijack_chance = 5 //We don't like this loud mess of hijack here in Cybersun.
			dagd_chance = 0 //Dying on a mission? Not today.
			InfilFit = new /datum/outfit/infiltrator/cybersun

		if("Gorlex")
			hijack_chance = 20 //That's why we're here.
			kill_chance = 80
			InfilFit = new /datum/outfit/infiltrator/gorlex

		if("Tiger Co.") //The rarest of them all - 100% DAGD.
			hijack_chance = 0 //Who need the shuttle when you are going to die anyway?
			kill_chance = 100 //RIP AND TEAR
			dagd_chance = 100 //UNTIL IT'S DONE
			obj_mod = 2 //More murders before going full DAGD.
			extra_tc = 15 //To sustain absolute destruction.
			InfilFit = new /datum/outfit/infiltrator/tiger

		if("MI13") //Another "rarest" faction. Unlike tigers - has no chance to get hijack/dagd,
		//but gets epic equipment and a lot of random objectives.
			hijack_chance = 0
			dagd_chance = 0
			kill_chance = 90
			obj_mod = 4 //Something to do for an hour.
			extra_tc = 10 //Have fun while staying -=STEALTHY=-
			InfilFit = new /datum/outfit/infiltrator/cybersun/mi13

	if(isplasmaman(owner.current)) //Plasmamen equipment
		InfilFit.uniform = /obj/item/clothing/under/plasmaman
		InfilFit.gloves = /obj/item/clothing/gloves/color/plasmaman/black
		InfilFit.l_pocket = /obj/item/tank/internals/plasmaman/belt/full
		InfilFit.backpack_contents = list(/obj/item/storage/box/survival=1, /obj/item/tank/jetpack/oxygen/harness=1, /obj/item/clothing/head/helmet/space/plasmaman=1)

	H.equipOutfit(InfilFit) //Equip final outfit

/datum/antagonist/traitor/infiltrator/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.assigned_role].</span>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()
	switch(owner.assigned_role)
		if("Cybersun Infiltrator")
			to_chat(owner.current, "<span class='alertwarning'>[CONFIG_GET(string/infiltrator_cybersun_message)] \n</span>")
		if("Gorlex Infiltrator")
			to_chat(owner.current, "<span class='alertwarning'>[CONFIG_GET(string/infiltrator_gorlex_message)] \n</span>")
		if("Tiger Co. Infiltrator")
			to_chat(owner.current, "<span class='alertwarning'>[CONFIG_GET(string/infiltrator_tiger_message)] \n</span>")
		if("MI13 Infiltrator")
			to_chat(owner.current, "<span class='alertwarning'>[CONFIG_GET(string/infiltrator_mi_message)] \n</span>")

		else //Used for Syndicate "faction" and non-existant factions, in case there is an error.
			to_chat(owner.current, "<span class='alertwarning'>[CONFIG_GET(string/infiltrator_syndicate_message)] \n</span>")

/datum/antagonist/traitor/infiltrator/forge_traitor_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 60)
		is_hijacker = prob(hijack_chance)
	var/martyr_chance = prob(dagd_chance)
	var/objective_count = is_hijacker
	var/toa = CONFIG_GET(number/infiltrator_objectives_amount) + obj_mod //Additional objective.
	for(var/i = objective_count, i < toa, i++)
		forge_single_inf_objective()

	if(is_hijacker && objective_count <= toa)
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return

	var/martyr_compatibility = 1
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

	if(prob(20))
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_with_identity/infiltrator/id_theft = new
			id_theft.owner = owner
			id_theft.find_target_by_role(role = ROLE_INFILTRATOR, role_type = TRUE, invert = TRUE)
			add_objective(id_theft)
			return

	else
		if(!(locate(/datum/objective/survive) in objectives)) //Infiltrators don't have to escape on shuttle.
			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = owner
			add_objective(survive_objective)
			return

/datum/antagonist/traitor/infiltrator/proc/forge_single_inf_objective()
	.=1
	if(prob(kill_chance))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/datum/antagonist/traitor/infiltrator/admin_add(datum/mind/new_owner,mob/admin)
	var/faction_t = input("What kind of infiltrator?", "Infiltrator") as null|anything in list("Random","Syndicate","Cybersun","Gorlex", "Tiger Co.", "MI13")
	if(faction_t in list("Random","Syndicate","Cybersun","Gorlex", "Tiger Co.", "MI13"))
		faction = faction_t
	else
		return
	new_owner.special_role = ROLE_INFILTRATOR
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has turned [key_name_admin(new_owner)] into [faction] Infiltrator.")
	log_admin("[key_name(admin)] has turned [key_name(new_owner)] into [faction] Infiltrator.")
