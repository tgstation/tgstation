GLOBAL_DATUM(main_clock_cult, /datum/team/clock_cult)

//this is effectively 2 higher due to the first anchoring crystal always allowing 2 more servants
#define DEFAULT_MAX_HUMAN_SERVANTS 10
#define CONVERSION_WARNING_NONE 0
#define CONVERSION_WARNING_HALFWAY 1
#define CONVERSION_WARNING_THREEQUARTERS 2
#define CONVERSION_WARNING_CRITIAL 3
/datum/team/clock_cult
	name = "Clock Cult"
	/// maximum number of human servants we can have
	var/max_human_servants = DEFAULT_MAX_HUMAN_SERVANTS
	/// list of our human servants
	var/list/human_servants = list()
	/// list of our non-human servants
	var/list/non_human_servants = list()
	/// what warning stage are we at
	var/warning_stage = CONVERSION_WARNING_NONE
	/// have we used our recall
	var/member_recalled = FALSE

/datum/team/clock_cult/add_member(datum/mind/new_member)
	. = ..()
	var/mob/current_mob = new_member.current
	if(current_mob && ishuman(current_mob))
		human_servants |= new_member
	else
		non_human_servants |= new_member

	check_member_count()

/datum/team/clock_cult/remove_member(datum/mind/member)
	. = ..()
	if(member in human_servants)
		human_servants -= member
	else
		non_human_servants -= member

/datum/team/clock_cult/roundend_report()
	var/list/parts = list()
	var/list/checked_objectives = list()
	var/failure = FALSE
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				checked_objectives += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				checked_objectives += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				failure = TRUE
			count++

	if(failure)
		parts += "<span class='redtext big'>The clock cult has failed to protect the ark and summon Rat'var, he will remain forever trapped!</span>"
	else
		parts += "<span class='greentext big'>The clock cult has succeeded! Rat'var's light shall shine forever more!</span>"

	if(length(checked_objectives))
		parts += "<b>The clock cultists' objectives were:</b>"
		for(var/i in 1 to length(checked_objectives))
			parts += checked_objectives[i]

	if(length(members))
		parts += "<span class='header'>The clock cultists were:</span>"
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

///check how many human members we have and anything that goes with that
/datum/team/clock_cult/proc/check_member_count()
	check_member_distribution()
	max_human_servants = round(max((get_active_player_count() / 8), max_human_servants))
	var/human_servant_count = length(human_servants)
	var/main_message = "The Ark will be torn open if [max_human_servants - human_servant_count] more minds are converted to the faith of Rat'var\
						[get_charged_anchor_crystals() >= ANCHORING_CRYSTALS_TO_SUMMON ? "." : " and \
						[ANCHORING_CRYSTALS_TO_SUMMON] Anchoring Crystal[ANCHORING_CRYSTALS_TO_SUMMON > 1 ? "s are" : " is"] summoned and protected on the station."]"

	if((human_servant_count * 2) > max_human_servants && warning_stage < CONVERSION_WARNING_HALFWAY)
		send_clock_message(null, span_bigbrass("Rat'var's influence is growing. [main_message]"), sent_sound = 'sound/magic/clockwork/scripture_tier_up.ogg')
		warning_stage = CONVERSION_WARNING_HALFWAY

	else if(human_servant_count > ((3/4) * max_human_servants) && warning_stage < CONVERSION_WARNING_THREEQUARTERS)
		send_clock_message(null, span_bigbrass("You feel the boundary between reality and fiction lessen as the Ark sparks with an arcane energy.<br> [main_message]"), \
						   sent_sound = 'sound/magic/clockwork/scripture_tier_up.ogg')
		warning_stage = CONVERSION_WARNING_THREEQUARTERS

	else if((human_servant_count == max_human_servants - 1) && warning_stage < CONVERSION_WARNING_CRITIAL && get_charged_anchor_crystals() >= 2)
		send_clock_message(span_bigbrass("The internal cogs of the Ark begin spinning, ready for activation.<br> \
										  Upon the next conversion, the dimensional barrier will become too weak for The Ark to remain closed and it will be forced open."), \
						   sent_sound = 'sound/magic/clockwork/scripture_tier_up.ogg')
		warning_stage = CONVERSION_WARNING_CRITIAL

	else if((human_servant_count >= max_human_servants) && get_charged_anchor_crystals() >= ANCHORING_CRYSTALS_TO_SUMMON)
		GLOB.clock_ark?.prepare_ark()

///check that our human_servants and non_human_servants lists are correct and if not then set them to be correct
/datum/team/clock_cult/proc/check_member_distribution()
	for(var/datum/mind/member in human_servants)
		if(ishuman(member.current))
			continue
		human_servants -= member
		non_human_servants |= member
		var/datum/antagonist/clock_cultist/servant_datum = member.has_antag_datum(/datum/antagonist/clock_cultist)
		servant_datum.recall.Remove(member.current)

	for(var/datum/mind/member in non_human_servants)
		if(!ishuman(member))
			continue
		non_human_servants -= member
		human_servants |= member
		var/datum/antagonist/clock_cultist/servant_datum = member.has_antag_datum(/datum/antagonist/clock_cultist)
		servant_datum.recall.Grant(member.current)

/datum/team/clock_cult/proc/setup_objectives()
	if(length(objectives))
		return
	GLOB.main_clock_cult = src
	var/datum/objective/anchoring_crystals/crystals_objective = new
	crystals_objective.team = src
	objectives += crystals_objective

	var/datum/objective/ratvar/summon_objective = new
	summon_objective.team = src
	objectives += summon_objective

#undef DEFAULT_MAX_HUMAN_SERVANTS
#undef CONVERSION_WARNING_NONE
#undef CONVERSION_WARNING_HALFWAY
#undef CONVERSION_WARNING_THREEQUARTERS
#undef CONVERSION_WARNING_CRITIAL

#define POSSIBLE_CRYSTAL_AREAS 6
/datum/objective/anchoring_crystals
	var/list/valid_areas = list()

/datum/objective/anchoring_crystals/New()
	. = ..()

	var/sanity = 0
	while(length(valid_areas) < POSSIBLE_CRYSTAL_AREAS && sanity < 100)
		var/area/summon_area = pick(GLOB.areas - valid_areas)
		if(summon_area && is_station_level(summon_area.z) && (summon_area.area_flags & VALID_TERRITORY))
			valid_areas += summon_area
		sanity++
	update_explanation_text()

/datum/objective/anchoring_crystals/update_explanation_text()
	var/plural = ANCHORING_CRYSTALS_TO_SUMMON > 1
	explanation_text = "Summon [ANCHORING_CRYSTALS_TO_SUMMON] anchoring crystal[plural ? "s" : ""] on the station and protect [plural ? "them" : "it"] for 5 \
						minutes to allow the ark to open. Crystals after the first one must be summoned in [english_list(valid_areas)]. \
						Up to 2 additional crystals can be created for extra power."

/datum/objective/anchoring_crystals/check_completion()
	return get_charged_anchor_crystals() >= ANCHORING_CRYSTALS_TO_SUMMON || completed

/datum/objective/ratvar
	explanation_text = "Protect The Ark so that Rat'var may enlighten this world!"

/datum/objective/ratvar/check_completion()
	return GLOB.ratvar_risen || completed

#undef POSSIBLE_CRYSTAL_AREAS
