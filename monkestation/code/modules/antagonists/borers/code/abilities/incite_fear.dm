/datum/action/cooldown/borer/fear_human
	name = "Incite Fear"
	cooldown_time = 12 SECONDS
	button_icon_state = "fear"
	sugar_restricted = TRUE
	ability_explanation = "\
	Causes an extreme fear reaction in a person near you whilst outside of a host\n\
	While inside of a host, it is much more effective and is used on the host itself\n\
	"

/datum/action/cooldown/borer/fear_human/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(cortical_owner.human_host)
		incite_internal_fear()
		StartCooldown()
		return
	var/list/potential_freezers = list()
	for(var/mob/living/carbon/human/listed_human in range(1, cortical_owner))
		if(!ishuman(listed_human)) //no nonhuman hosts
			continue
		if(listed_human.stat == DEAD) //no dead hosts
			continue
		if(considered_afk(listed_human.mind)) //no afk hosts
			continue
		potential_freezers += listed_human
	if(length(potential_freezers) == 1)
		incite_fear(potential_freezers[1])
		return
	var/mob/living/carbon/human/choose_fear = tgui_input_list(cortical_owner, "Choose who you will fear!", "Fear Choice", potential_freezers)
	if(!choose_fear)
		owner.balloon_alert(owner, "no target chosen")
		return
	if(get_dist(choose_fear, cortical_owner) > 1)
		owner.balloon_alert(owner, "chosen target too far")
		return
	incite_fear(choose_fear)
	StartCooldown()

/datum/action/cooldown/borer/fear_human/proc/incite_fear(mob/living/carbon/human/singular_fear)
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	to_chat(singular_fear, span_warning("Something glares menacingly at you!"))
	singular_fear.Paralyze(7 SECONDS)
	singular_fear.stamina.adjust(-50)
	singular_fear.set_confusion_if_lower(9 SECONDS)
	var/turf/human_turf = get_turf(singular_fear)
	var/logging_text = "[key_name(cortical_owner)] feared/paralyzed [key_name(singular_fear)] at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	singular_fear.log_message(logging_text, LOG_GAME)

/datum/action/cooldown/borer/fear_human/proc/incite_internal_fear()
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	owner.balloon_alert(owner, "fear incited into host")
	cortical_owner.human_host.Paralyze(10 SECONDS)
	cortical_owner.human_host.stamina.adjust(-100)
	cortical_owner.human_host.set_confusion_if_lower(15 SECONDS)
	to_chat(cortical_owner.human_host, span_warning("Something moves inside of you violently!"))
	var/turf/human_turf = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] feared/paralyzed [key_name(cortical_owner.human_host)] (internal) at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
