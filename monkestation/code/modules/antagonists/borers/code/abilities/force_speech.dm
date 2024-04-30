/datum/action/cooldown/borer/force_speak
	name = "Force Host Speak"
	cooldown_time = 30 SECONDS
	button_icon_state = "speak"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Forces your host to speak any words you desire.\
	"

/datum/action/cooldown/borer/force_speak/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	var/borer_message = input(cortical_owner, "What would you like to force your host to say?", "Force Speak") as message|null
	if(!borer_message)
		owner.balloon_alert(owner, "no message given")
		return
	borer_message = sanitize(borer_message)
	var/mob/living/carbon/human/cortical_host = cortical_owner.human_host
	to_chat(cortical_host, span_boldwarning("Your voice moves without your permission!"))
	var/obj/item/organ/internal/brain/victim_brain = cortical_owner.human_host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(victim_brain)
		cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * cortical_owner.host_harm_multiplier)
	cortical_host.say(message = borer_message, forced = "borer ([key_name(cortical_owner)])")
	var/turf/human_turf = get_turf(cortical_owner.human_host)
	var/logging_text = "[key_name(cortical_owner)] forced [key_name(cortical_owner.human_host)] to say [borer_message] at [loc_name(human_turf)]"
	cortical_owner.log_message(logging_text, LOG_GAME)
	cortical_owner.human_host.log_message(logging_text, LOG_GAME)
	StartCooldown()
