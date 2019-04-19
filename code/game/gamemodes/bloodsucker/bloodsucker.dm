#define ROLE_BLOODSUCKER			"Bloodsucker"

/datum/game_mode
	var/list/datum/mind/bloodsuckers = list() 	// List of minds belonging to this game mode.
	var/list/datum/mind/vassals = list() 		// List of minds that have been turned into Vassals.
	var/list/datum/mind/vamphunters = list() 	// List of minds hunting vampires.

/datum/game_mode/bloodsucker
	name = "bloodsucker"
	config_tag = "bloodsucker"
	report_type = "traitor"
	traitor_name = "Bloodsucker"//Nanotrasen Internal Affairs Agent"
	antag_flag = ROLE_BLOODSUCKER
	false_report_weight = 1
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 7

	announce_span = "danger"
	announce_text = "Filthy, bloodsucking vampires are crawling around disguised as crewmembers!\n\
	<span class='danger'>Bloodsuckers</span>: The crew are cattle, while you are both shepherd and slaughterhouse.\n\
	<span class='notice'>Crew</span>: Put an end to the undead infestation before the station is overcome!"






/datum/game_mode/proc/make_bloodsucker(datum/mind/bloodsucker, datum/mind/creator = null) // NOTE: This is a game_mode/proc, NOT a game_mode/bloodsucker/proc! We need to access this function despite the game mode.
	return





/datum/game_mode/proc/can_make_vassal(mob/living/target, datum/mind/creator)
	// Not Correct Type: Abort
	if (!iscarbon(target) || !creator)
		//message_admins("DEBUG1: can_make_vassal() Abort: Creator or Not Carbon [target] / [iscarbon(target)] / [creator]")
		//to_chat(creator, "<span class='danger'>[src].</span>")
		return FALSE
	if (target.stat > UNCONSCIOUS)
		//message_admins("DEBUG1: can_make_vassal() Abort: Dead")
		return FALSE
	// Check Overdose: Am I even addicted to blood? Do I even have any in me?
	//if (!target.reagents.addiction_list || !target.reagents.reagent_list)
		//message_admins("DEBUG2: can_make_vassal() Abort: No reagents")
	//	return 0
	// Check Overdose: Did my current volume go over the Overdose threshold?
	//var/am_addicted = 0
	//for (var/datum/reagent/blood/vampblood/blood in target.reagents.addiction_list) // overdosed is tracked in reagent_list, not addiction_list.
		//message_admins("DEBUG3: can_make_vassal() Found Blood! [blood] [blood.overdose]")
		//if (blood.overdosed)
	//	am_addicted = 1 // Blood is present in addiction? That's all we need.
	//	break

	//if (!am_addicted)
		//message_admins("DEBUG4: can_make_vassal() Abort: No Blood")
	//	return 0
	// No Mind!
	if (!target.mind || !target.mind.key)
		to_chat(creator, "<span class='danger'>[target] isn't self-aware enough to be made into a Vassal!</span>")
		return FALSE
	// Already MY Vassal
	var/datum/antagonist/vassal/V = target.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	if (V && V.master && V.master.owner == creator)
		//message_admins("DEBUG5: can_make_vassal() Abort: Already Mine")
		to_chat(creator, "<span class='danger'>[target] is already your loyal Vassal!</span>")
		return FALSE
	// Already Antag or Loyal (Vamp Hunters count as antags)
	if (target.mind.antag_datums && target.mind.antag_datums.len > 0 || (target.mind in SSticker.mode.vassals) || target.mind.enslaved_to || target.has_trait(TRAIT_MINDSHIELD))
		//message_admins("DEBUG6: can_make_vassal() Abort: Am Bad Guy Already [target.mind.antag_datums] [target.mind.current.isloyal()]")
		to_chat(creator, "<span class='danger'>[target] resists the power of your blood to dominate their mind!</span>")
		return FALSE
	return TRUE


/datum/game_mode/proc/make_vassal(mob/living/target, datum/mind/creator)
	if (!can_make_vassal(target,creator))
		return FALSE
	// Make Vassal
	var/datum/antagonist/vassal/V = new ANTAG_DATUM_VASSAL(target.mind)
	V.master = creator.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	target.mind.add_antag_datum(V, V.master.get_team())
	// Log
	message_admins("[target] has become a Vassal, and is enslaved to [creator].")
	log_admin("[target] has become a Vassal, and is enslaved to [creator].")

	return TRUE

/datum/game_mode/proc/remove_vassal(datum/mind/vassal)
	vassal.remove_antag_datum(ANTAG_DATUM_VASSAL)
