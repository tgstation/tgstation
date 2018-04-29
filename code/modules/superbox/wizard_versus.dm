// Wizard Versus gamemode.

// Clothier which automatically sets the colors of your robe.
/obj/effect/wizard_clothier
	name = "wizard clothier"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE
	opacity = 0

	var/obj/item/clothing/head/head = /obj/item/clothing/head/wizard
	var/obj/item/clothing/suit/suit = /obj/item/clothing/suit/wizrobe
	var/obj/item/bedsheet/sheet = /obj/item/bedsheet/blue
	var/freq = FREQ_CTF_BLUE

/obj/effect/wizard_clothier/red
	head = /obj/item/clothing/head/wizard/red
	suit = /obj/item/clothing/suit/wizrobe/red
	sheet = /obj/item/bedsheet/red
	freq = FREQ_CTF_RED

/obj/effect/wizard_clothier/yellow
	head = /obj/item/clothing/head/wizard/yellow
	suit = /obj/item/clothing/suit/wizrobe/yellow
	sheet = /obj/item/bedsheet/yellow
	freq = FREQ_ENGINEERING

/obj/effect/wizard_clothier/marisa
	head = /obj/item/clothing/head/wizard/marisa
	suit = /obj/item/clothing/suit/wizrobe/marisa
	sheet = /obj/item/bedsheet
	freq = FREQ_MEDICAL

/obj/effect/wizard_clothier/Crossed(AM as mob|obj)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if (!H.head || istype(H.head, /obj/item/clothing/head/wizard))
			qdel(H.head)
			H.equip_to_slot_or_del(new head(H), SLOT_HEAD)
		if (!H.wear_suit || istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
			qdel(H.wear_suit)
			H.equip_to_slot_or_del(new suit(H), SLOT_WEAR_SUIT)
		if (!H.wear_neck || istype(H.wear_neck, /obj/item/bedsheet))
			qdel(H.wear_neck)
			H.equip_to_slot_or_del(new sheet(H), SLOT_NECK)
		if (!H.ears)
			H.equip_to_slot_or_del(new /obj/item/radio/headset(H), SLOT_EARS)
		if (istype(H.ears, /obj/item/radio/headset))
			var/obj/item/radio/headset/R = H.ears
			R.freqlock = TRUE
			R.frequency = freq
			R.subspace_transmission = FALSE
			R.independent = TRUE
	..()

/obj/effect/wizard_clothier/singularity_act()
	return

/obj/effect/wizard_clothier/singularity_pull()
	return

// Areas for the spawn
/area/wizard_versus
	name = "Wizard Versus Lobby"
	icon_state = "green"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = TRUE
	noteleport = TRUE
	flags_1 = NONE

/area/wizard_versus/ready
	var/team

/area/wizard_versus/ready/blue
	name = "Wizard Versus Ready Blue"
	icon_state = "bluenew"
	team = "blue team"

/area/wizard_versus/ready/red
	name = "Wizard Versus Ready Red"
	icon_state = "red"
	team = "red team"

/area/wizard_versus/ready/yellow
	name = "Wizard Versus Ready Yellow"
	icon_state = "yellow"
	team = "yellow team"

/area/wizard_versus/ready/white
	name = "Wizard Versus Ready White"
	icon_state = "purple"
	team = "white team"

// Gamemode code??
/datum/mind
	var/wizard_versus_team

/datum/game_mode/wizard_versus
	name = "wizard versus"
	config_tag = "wizard_versus"
	antag_flag = ROLE_WIZARD
	false_report_weight = 10
	required_players = 1
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 14
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "<b>WIZARD BATTLE!!</b> Group into teams and prepare to fight!"

	var/turf/spawnpoint
	var/check_counter = 0
	var/started = 0
	var/winner

/datum/game_mode/wizard_versus/pre_setup()
	// create the wizard zone
	var/datum/map_template/template = SSmapping.map_templates["wizard_versus.dmm"]
	if (!template)
		return FALSE
	spawnpoint = locate(90, 200, pick(SSmapping.levels_by_trait(ZTRAIT_CENTCOM)))  // I am the best at code
	if (!template.load(spawnpoint, centered = TRUE))
		return FALSE

	// wizardize everybody and teleport them in
	for(var/mob/player in GLOB.player_list)
		var/datum/mind/wiz = player.mind
		wizards += wiz
		wiz.assigned_role = "Wizard"
		wiz.special_role = "Wizard"

	return TRUE

/datum/game_mode/wizard_versus/post_setup()
	for(var/datum/mind/wizard in wizards)
		wizard.add_antag_datum(/datum/antagonist/wizard/versus)
		wizard.current.forceMove(locate(spawnpoint.x + rand(-2, 2), spawnpoint.y + rand(-2, 2), spawnpoint.z))
	return ..()

/datum/game_mode/wizard_versus/process()
	check_counter++
	if (check_counter >= 5)
		check_counter = 0
		if (started == 0)
			check_begin()
		else if (started == 2)
			check_win()

	return FALSE

/datum/game_mode/wizard_versus/proc/check_begin()
	// check if everybody is in the ready rooms
	var/numwizards = 0
	for(var/datum/mind/wizard in wizards)
		if (isliving(wizard.current) && wizard.current.stat != DEAD)
			numwizards++
			var/area/wizard_versus/ready/A = get_area(wizard.current)
			if (!istype(A))
				return
	if (!numwizards)
		return

	// prepare to start
	started = 1
	to_chat(world, "<B>Everybody appears to be ready. The battle will begin momentarily!</b>")
	addtimer(CALLBACK(src, .proc/really_begin), 10 SECONDS)

/datum/game_mode/wizard_versus/proc/really_begin()
	// double-check that nobody has moved
	var/list/used_teams = list()
	var/numwizards = 0
	for(var/datum/mind/wizard in wizards)
		if (isliving(wizard.current) && wizard.current.stat != DEAD)
			var/area/wizard_versus/ready/A = get_area(wizard.current)
			if (istype(A))
				numwizards++
				wizard.wizard_versus_team = A.team
				used_teams |= A.team
			else
				started = 0
				to_chat(world, "<B>Someone wasn't really ready! Maybe next time.</B>")
				return
	if (!numwizards)
		to_chat(world, "<B>Nobody was really ready! Maybe next time.</B>")
		started = 0
		return

	// pick each team an area of the station to drop to
	var/list/areas = GLOB.teleportlocs.Copy()
	for(var/team in used_teams)
		var/list/turfs = list()
		while (!turfs.len && areas.len)
			var/area/A = GLOB.teleportlocs[pick_n_take(areas)]
			for(var/turf/T in get_area_turfs(A.type))
				if (!is_blocked_turf(T))
					turfs += T
		if (!turfs.len)
			to_chat(world, "<B>Having trouble finding a drop point for [team]...<B>")
		used_teams[team] = turfs

	for(var/datum/mind/wizard in wizards)
		if (!wizard.wizard_versus_team)
			continue

		var/turf/T = safepick(used_teams[wizard.wizard_versus_team])
		if(T)
			wizard.current.forceMove(T)
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(2, wizard.current.loc)
			smoke.attach(wizard.current)
			smoke.start()

	// mark started
	started = 2

/datum/game_mode/wizard_versus/check_win()
	if (winner || started != 2)
		return

	var/list/teams_alive = list()
	for(var/datum/mind/wizard in wizards)
		if (isliving(wizard.current) && wizard.current.stat != DEAD && wizard.wizard_versus_team)
			teams_alive[wizard.wizard_versus_team] += 1

	for(var/obj/item/phylactery/P in GLOB.poi_list)
		if(P.mind && P.mind.has_antag_datum(/datum/antagonist/wizard))
			teams_alive[P.mind.wizard_versus_team] += 1

	if (teams_alive.len == 0)
		winner = "nobody"
	else if (teams_alive.len == 1)
		winner = "[teams_alive[1]]"
	else
		return
	to_chat(world, "----------------<br>The winner of the wizard battle is: <b>[winner]</b>!<br>----------------")

/datum/game_mode/wizard_versus/check_finished()
	if (winner)
		return TRUE

/datum/game_mode/wizard_versus/set_round_result()
	..()
	if (winner == "nobody")
		SSticker.mode_result = "loss - draw"
	else
		SSticker.mode_result = "win - [winner] won"

/datum/antagonist/wizard/versus/create_objectives()
	if (!(locate(/datum/objective/survive) in owner.objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = owner
		objectives += survive_objective
		owner.objectives += survive_objective
