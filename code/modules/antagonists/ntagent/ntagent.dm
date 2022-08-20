/datum/antagonist/ntagent
	name = "\improper NT Agent"
	antag_hud_name = "ntagent"
	antagpanel_category = "Nanotrasen"
	show_name_in_check_antagonists = TRUE
	job_rank = ROLE_NT_AGENT
	show_to_ghosts = FALSE
	preview_outfit = /datum/outfit/ntagent_preview
	suicide_cry = "Syndicate i sikeyim!!!"

/datum/antagonist/ntagent/on_gain()
	. = ..()
	give_objective()
	ntagent_equipt_items()



/datum/antagonist/ntagent/greet()
	. = ..()
	to_chat(owner, span_boldannounce("Sen bir Nanotrasen ajanısın. Amacın istasyonda bir tehlike söz konusu olursa o tehlikenin peşine düşmektir. Onun dışında istasyonda mesleğini yerine getirmek zorundasın. Eğer üstünde olmaması gereken bir şey ile security e yakalanırsan asla ve asla Nanotrasen ajanı olduğunu söylememelisin. Unutma ajan, ölmek de görevinin bir parçası."))
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/nanoagent.ogg', 200, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/ntagent/proc/ntagent_equipt_items(mob/living/carbon/human/ntagent = owner.current)
	return ntagent.equipOutfit(/datum/outfit/ntagent)

/datum/antagonist/ntagent/proc/give_objective()
	var/datum/objective/NTobjec = new()
	NTobjec.explanation_text = "Istasyonda bir tehlike var ise peşine düş ve kimliğini gizle."
	NTobjec.completed = TRUE
	NTobjec.owner = owner
	objectives |= NTobjec
