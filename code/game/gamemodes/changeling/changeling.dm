<<<<<<< HEAD
#define LING_FAKEDEATH_TIME					400 //40 seconds
#define LING_DEAD_GENETICDAMAGE_HEAL_CAP	50	//The lowest value of geneticdamage handle_changeling() can take it to while dead.
#define LING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob

var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")
var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
var/list/slot2slot = list("head" = slot_head, "wear_mask" = slot_wear_mask, "back" = slot_back, "wear_suit" = slot_wear_suit, "w_uniform" = slot_w_uniform, "shoes" = slot_shoes, "belt" = slot_belt, "gloves" = slot_gloves, "glasses" = slot_glasses, "ears" = slot_ears, "wear_id" = slot_wear_id, "s_store" = slot_s_store)
var/list/slot2type = list("head" = /obj/item/clothing/head/changeling, "wear_mask" = /obj/item/clothing/mask/changeling, "back" = /obj/item/changeling, "wear_suit" = /obj/item/clothing/suit/changeling, "w_uniform" = /obj/item/clothing/under/changeling, "shoes" = /obj/item/clothing/shoes/changeling, "belt" = /obj/item/changeling, "gloves" = /obj/item/clothing/gloves/changeling, "glasses" = /obj/item/clothing/glasses/changeling, "ears" = /obj/item/changeling, "wear_id" = /obj/item/changeling, "s_store" = /obj/item/changeling)


/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	antag_flag = ROLE_CHANGELING
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	announce_span = "green"
	announce_text = "Alien changelings have infiltrated the crew!\n\
	<span class='green'>Changelings</span>: Accomplish the objectives assigned to you.\n\
	<span class='notice'>Crew</span>: Root out and eliminate the changeling menace."

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/changeling_amount = 4 //hard limit on changelings if scaling is turned off

	var/changeling_team_objective_type = null //If this is not null, we hand our this objective to all lings

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/num_changelings = 1

	if(config.changeling_scaling_coeff)
		num_changelings = max(1, min( round(num_players()/(config.changeling_scaling_coeff*2))+2, round(num_players()/config.changeling_scaling_coeff) ))
	else
		num_changelings = max(1, min(num_players(), changeling_amount))

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_changelings, i++)
			if(!antag_candidates.len) break
			var/datum/mind/changeling = pick(antag_candidates)
			antag_candidates -= changeling
			changelings += changeling
			changeling.restricted_roles = restricted_jobs
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	modePlayer += changelings
	//Decide if it's ok for the lings to have a team objective
	//And then set it up to be handed out in forge_changeling_objectives
	var/list/team_objectives = subtypesof(/datum/objective/changeling_team_objective)
	var/list/possible_team_objectives = list()
	for(var/T in team_objectives)
		var/datum/objective/changeling_team_objective/CTO = T

		if(changelings.len >= initial(CTO.min_lings))
			possible_team_objectives += T

	if(possible_team_objectives.len && prob(20*changelings.len))
		changeling_team_objective_type = pick(possible_team_objectives)

	for(var/datum/mind/changeling in changelings)
		log_game("[changeling.key] (ckey) has been selected as a changeling")
		changeling.current.make_changeling()
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
		ticker.mode.update_changeling_icons_added(changeling)
	..()

/datum/game_mode/changeling/make_antag_chance(mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/changelingcap = min( round(joined_player_list.len/(config.changeling_scaling_coeff*2))+2, round(joined_player_list.len/config.changeling_scaling_coeff) )
	if(ticker.mode.changelings.len >= changelingcap) //Caps number of latejoin antagonists
		return
	if(ticker.mode.changelings.len <= (changelingcap - 2) || prob(100 - (config.changeling_scaling_coeff*2)))
		if(ROLE_CHANGELING in character.client.prefs.be_special)
			if(!jobban_isbanned(character, ROLE_CHANGELING) && !jobban_isbanned(character, "Syndicate"))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.mind.make_Changling()

/datum/game_mode/proc/forge_changeling_objectives(datum/mind/changeling, var/team_mode = 0)
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/escape_objective_possible = TRUE

	//if there's a team objective, check if it's compatible with escape objectives
	for(var/datum/objective/changeling_team_objective/CTO in changeling.objectives)
		if(!CTO.escape_objective_compatible)
			escape_objective_possible = FALSE
			break

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(6, 8)
	changeling.objectives += absorb_objective

	if(prob(60))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = changeling
		steal_objective.find_target()
		changeling.objectives += steal_objective

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = changeling
		destroy_objective.find_target()
		changeling.objectives += destroy_objective
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			if(team_mode) //No backstabbing while in a team
				kill_objective.find_target_by_role(role = "Changeling", role_type = 1, invert = 1)
			else
				kill_objective.find_target()
			changeling.objectives += kill_objective
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = changeling
			if(team_mode)
				maroon_objective.find_target_by_role(role = "Changeling", role_type = 1, invert = 1)
			else
				maroon_objective.find_target()
			changeling.objectives += maroon_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = changeling
				identity_theft.target = maroon_objective.target
				identity_theft.update_explanation_text()
				changeling.objectives += identity_theft
				escape_objective_possible = FALSE

	if (!(locate(/datum/objective/escape) in changeling.objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = changeling
			changeling.objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = changeling
			if(team_mode)
				identity_theft.find_target_by_role(role = "Changeling", role_type = 1, invert = 1)
			else
				identity_theft.find_target()
			changeling.objectives += identity_theft
		escape_objective_possible = FALSE



/datum/game_mode/changeling/forge_changeling_objectives(datum/mind/changeling)
	if(changeling_team_objective_type)
		var/datum/objective/changeling_team_objective/team_objective = new changeling_team_objective_type
		team_objective.owner = changeling
		changeling.objectives += team_objective

		..(changeling,1)
	else
		..(changeling,0)


/datum/game_mode/proc/greet_changeling(datum/mind/changeling, you_are=1)
	if (you_are)
		changeling.current << "<span class='boldannounce'>You are [changeling.changeling.changelingID], a changeling! You have absorbed and taken the form of a human.</span>"
	changeling.current << "<span class='boldannounce'>Use say \":g message\" to communicate with your fellow changelings.</span>"
	changeling.current << "<b>You must complete the following tasks:</b>"

	if (changeling.current.mind)
		var/mob/living/carbon/human/H = changeling.current
		if(H.mind.assigned_role == "Clown")
			H << "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself."
			H.dna.remove_mutation(CLOWNMUT)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<b>Objective #[obj_count]</b>: [objective.explanation_text]"
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(changelings.len)
		var/text = "<br><font size=3><b>The changelings were:</b></font>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1
			if(!changeling.current)
				changelingwin = 0

			text += printplayer(changeling)

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			text += "<br><b>Changeling ID:</b> [changeling.changeling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [changeling.changeling.absorbedcount]"

			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='danger'>Fail.</span>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><b>The changeling was successful!</b></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><span class='boldannounce'>The changeling has failed.</span>"
				feedback_add_details("changeling_success","FAIL")
			text += "<br>"

		world << text


	return 1

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/stored_profiles = list() //list of datum/changelingprofile
	var/datum/changelingprofile/first_prof = null
	//var/list/absorbed_dna = list()
	//var/list/protected_dna = list() //dna that is not lost when capacity is otherwise full
	var/dna_max = 6 //How many extra DNA strands the changeling can store for transformation.
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_storage = 75
	var/chem_recharge_rate = 1
	var/chem_recharge_slowdown = 0
	var/sting_range = 2
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/islinking = 0
	var/geneticpoints = 10
	var/purchasedpowers = list()
	var/mimicing = ""
	var/canrespec = 0
	var/changeling_speak = 0
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting
	var/datum/cellular_emporium/cellular_emporium
	var/datum/action/innate/cellular_emporium/emporium_action

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

	cellular_emporium = new(src)
	emporium_action = new(cellular_emporium)

/datum/changeling/Destroy()
	qdel(cellular_emporium)
	cellular_emporium = null
	. = ..()

/datum/changeling/proc/regenerate(var/mob/living/carbon/the_ling)
	if(istype(the_ling))
		emporium_action.Grant(the_ling)
		if(the_ling.stat == DEAD)
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), (chem_storage*0.5))
			geneticdamage = max(LING_DEAD_GENETICDAMAGE_HEAL_CAP,geneticdamage-1)
		else //not dead? no chem/geneticdamage caps.
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
			geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/get_dna(dna_owner)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(dna_owner == prof.name)
			return prof

/datum/changeling/proc/has_dna(datum/dna/tDNA)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(tDNA.is_same_as(prof.dna))
			return 1
	return 0

/datum/changeling/proc/can_absorb_dna(mob/living/carbon/user, mob/living/carbon/human/target, var/verbose=1)
	if(stored_profiles.len)
		var/datum/changelingprofile/prof = stored_profiles[1]
		if(prof.dna == user.dna && stored_profiles.len >= dna_max)//If our current DNA is the stalest, we gotta ditch it.
			if(verbose)
				user << "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>"
			return
	if(!target)
		return
	if((target.disabilities & NOCLONE) || (target.disabilities & HUSK))
		if(verbose)
			user << "<span class='warning'>DNA of [target] is ruined beyond usability!</span>"
		return
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			user << "<span class='warning'>We could gain no benefit from absorbing a lesser creature.</span>"
		return
	if(has_dna(target.dna))
		if(verbose)
			user << "<span class='warning'>We already have this DNA in storage!</span>"
		return
	if(!target.has_dna())
		if(verbose)
			user << "<span class='warning'>[target] is not compatible with our biology.</span>"
		return
	return 1

/datum/changeling/proc/create_profile(mob/living/carbon/human/H, mob/living/carbon/human/user, protect = 0)
	var/datum/changelingprofile/prof = new

	H.dna.real_name = H.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new H.dna.type
	H.dna.copy_dna(new_dna)
	prof.dna = new_dna
	prof.name = H.real_name
	prof.protected = protect

	prof.underwear = H.underwear
	prof.undershirt = H.undershirt
	prof.socks = H.socks

	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(slot in H.vars)
			var/obj/item/I = H.vars[slot]
			if(!I)
				continue
			prof.name_list[slot] = I.name
			prof.appearance_list[slot] = I.appearance
			prof.flags_cover_list[slot] = I.flags_cover
			prof.item_color_list[slot] = I.item_color
			prof.item_state_list[slot] = I.item_state
			prof.exists_list[slot] = 1
		else
			continue

	return prof

/datum/changeling/proc/add_profile(datum/changelingprofile/prof)
	if(stored_profiles.len > dna_max)
		if(!push_out_profile())
			return

	stored_profiles += prof
	absorbedcount++

/datum/changeling/proc/add_new_profile(mob/living/carbon/human/H, mob/living/carbon/human/user, protect = 0)
	var/datum/changelingprofile/prof = create_profile(H, protect)
	add_profile(prof)
	return prof

/datum/changeling/proc/remove_profile(mob/living/carbon/human/H, force = 0)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(H.real_name == prof.name)
			if(prof.protected && !force)
				continue
			stored_profiles -= prof
			qdel(prof)

/datum/changeling/proc/get_profile_to_remove()
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(!prof.protected)
			return prof

/datum/changeling/proc/push_out_profile()
	var/datum/changelingprofile/removeprofile = get_profile_to_remove()
	if(removeprofile)
		stored_profiles -= removeprofile
		return 1
	return 0

/proc/changeling_transform(mob/living/carbon/human/user, datum/changelingprofile/chosen_prof)
	var/datum/dna/chosen_dna = chosen_prof.dna
	user.real_name = chosen_prof.name
	user.underwear = chosen_prof.underwear
	user.undershirt = chosen_prof.undershirt
	user.socks = chosen_prof.socks

	chosen_dna.transfer_identity(user, 1)
	user.updateappearance(mutcolor_update=1)
	user.update_body()
	user.domutcheck()

	//vars hackery. not pretty, but better than the alternative.
	for(var/slot in slots)
		if(istype(user.vars[slot], slot2type[slot]) && !(chosen_prof.exists_list[slot])) //remove unnecessary flesh items
			qdel(user.vars[slot])
			continue

		if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_prof.exists_list[slot]))
			continue

		var/obj/item/C
		var/equip = 0
		if(!user.vars[slot])
			var/thetype = slot2type[slot]
			equip = 1
			C = new thetype(user)

		else if(istype(user.vars[slot], slot2type[slot]))
			C = user.vars[slot]

		C.appearance = chosen_prof.appearance_list[slot]
		C.name = chosen_prof.name_list[slot]
		C.flags_cover = chosen_prof.flags_cover_list[slot]
		C.item_color = chosen_prof.item_color_list[slot]
		C.item_state = chosen_prof.item_state_list[slot]
		if(equip)
			user.equip_to_slot_or_del(C, slot2slot[slot])

	user.regenerate_icons()

/datum/changelingprofile
	var/name = "a bug"

	var/protected = 0

	var/datum/dna/dna = null
	var/list/name_list = list() //associative list of slotname = itemname
	var/list/appearance_list = list()
	var/list/flags_cover_list = list()
	var/list/exists_list = list()
	var/list/item_color_list = list()
	var/list/item_state_list = list()

	var/underwear
	var/undershirt
	var/socks

/datum/changelingprofile/Destroy()
	qdel(dna)
	. = ..()

/datum/changelingprofile/proc/copy_profile(datum/changelingprofile/newprofile)
	newprofile.name = name
	newprofile.protected = protected
	newprofile.dna = new dna.type
	dna.copy_dna(newprofile.dna)
	newprofile.name_list = name_list.Copy()
	newprofile.appearance_list = appearance_list.Copy()
	newprofile.flags_cover_list = flags_cover_list.Copy()
	newprofile.exists_list = exists_list.Copy()
	newprofile.item_color_list = item_color_list.Copy()
	newprofile.item_state_list = item_state_list.Copy()
	newprofile.underwear = underwear
	newprofile.undershirt = undershirt
	newprofile.socks = socks

/datum/game_mode/proc/update_changeling_icons_added(datum/mind/changling_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_CHANGELING]
	hud.join_hud(changling_mind.current)
	set_antag_hud(changling_mind.current, "changling")

/datum/game_mode/proc/update_changeling_icons_removed(datum/mind/changling_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_CHANGELING]
	hud.leave_hud(changling_mind.current)
	set_antag_hud(changling_mind.current, null)
=======
var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 1
	required_players_secret = 20
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/changeling_amount = 4

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")

/datum/game_mode/changeling/pre_setup()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		if(mixed && (player in ticker.mode.modePlayer))
			possible_changelings -= player
			continue
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	changeling_amount = 1 + round(num_players() / 10)

// mixed mode scaling
	if(mixed)
		changeling_amount = min(2, changeling_amount)

	if(possible_changelings.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			if(changeling.special_role)
				continue
			changelings += changeling
			modePlayer += changelings
		log_admin("Starting a round of changeling with [changelings.len] changelings.")
		message_admins("Starting a round of changeling with [changelings.len] changelings.")
		if(mixed)
			ticker.mode.modePlayer += changelings //merge into master antag list
			ticker.mode.changelings += changelings
		return 1
	else
		log_admin("Failed to set-up a round of changeling. Couldn't find any volunteers to be changeling.")
		message_admins("Failed to set-up a round of changeling. Couldn't find any volunteers to be changeling.")
		if(mixed)
			ticker.mode.modePlayer -= changelings //merge into master antag list
			ticker.mode.traitors -= changelings
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			if(!mixed) send_intercept()
		..()
	return


/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		to_chat(changeling.current, "<span class='danger'>You are a changeling!</span>")
	to_chat(changeling.current, "<span class='danger'>Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</span>")
	to_chat(changeling.current, "<B>You must complete the following tasks:</B>")

	if (changeling.current.mind)
		if (changeling.current.mind.assigned_role == "Clown")
			to_chat(changeling.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
			changeling.current.mutations.Remove(M_CLUMSY)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		to_chat(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/changeling_mob)
	if(!istype(changeling_mob))	return
	changeling_mob.make_changeling()

/datum/game_mode/proc/auto_declare_completion_changeling()
	var/text = ""
	if(changelings.len)
		var/icon/logoa = icon('icons/mob/mob.dmi', "change-logoa")
		var/icon/logob = icon('icons/mob/mob.dmi', "change-logob")
		end_icons += logoa
		var/tempstatea = end_icons.len
		end_icons += logob
		var/tempstateb = end_icons.len
		text += {"<BR><img src="logo_[tempstatea].png"> <FONT size = 2><B>The changelings were:</B></FONT> <img src="logo_[tempstateb].png">"}
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1

			if(changeling.current)
				var/icon/flat = getFlatIcon(changeling.current, SOUTH, 1, 1)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[changeling.key]</b> was <b>[changeling.name]</b> ("}
				if(changeling.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[changeling.key]</b> was <b>[changeling.name]</b> ("}
				text += "body destroyed"
				changelingwin = 0
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.

			text += {"<br><b>Changeling ID:</b> [changeling.changeling.changelingID].
<b>Genomes Absorbed:</b> [changeling.changeling.absorbedcount]"}
			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><B>The changeling was successful!</B></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The changeling has failed.</B></font>"
				feedback_add_details("changeling_success","FAIL")

			if(changeling.total_TC)
				if(changeling.spent_TC)
					text += "<br><span class='sinister'>TC Remaining: [changeling.total_TC - changeling.spent_TC]/[changeling.total_TC] - The tools used by the Changeling were: "
					for(var/entry in changeling.uplink_items_bought)
						text += "<br>[entry]"
				else
					text += "<br><span class='sinister'>The Changeling was a smooth operator this round (did not purchase any uplink items)</span>"
		text += "<BR><HR>"
	return text

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()
	var/mimicing = ""

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/changeling/proc/regenerate()
	chem_charges = Clamp(chem_charges + chem_recharge_rate, 0, chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/changeling/proc/GetDNA(var/dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/datum/mind/proc/make_new_changeling(var/show_message = 1, var/generate_objectives = 1)
	if(!ischangeling(current))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		if(show_message)
			to_chat(current, "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>")
			var/wikiroute = role_wiki[ROLE_CHANGELING]
			to_chat(current, "<span class='info'><a HREF='?src=\ref[current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
		if(generate_objectives)
			ticker.mode.forge_changeling_objectives(src)
		return 1
	return 0

/datum/mind/proc/remove_changeling_status(var/show_message = 1)
	if(ischangeling(current))
		ticker.mode.changelings -= src
		special_role = null
		current.remove_changeling_powers()
		current.verbs -= /datum/changeling/proc/EvolutionMenu
		if(changeling)
			qdel(changeling)
			changeling = null
		if(show_message)
			to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
		return 1
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
