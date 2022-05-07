/datum/antagonist/ntagent
	name = "\improper NT Agent"
	antagpanel_category = "Nanotrasen"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	preview_outfit = /datum/outfit/ntagent
	suicide_cry = "Syndicate i sikeyim!!!"

/datum/antagonist/ntagent/on_gain()
	. = ..()
	give_objective()
	ntagent_equipt_items()



/datum/antagonist/ntagent/greet()
	. = ..()
	to_chat(owner, span_boldannounce("Sen bir Nanotrasen ajanısın. Amacın istasyonda bir tehlike söz konusu olursa o tehlikenin peşine düşmektir. Onun dışında istasyonda mesleğini yerine getirmek zorundasın. Eğer üstünde olmaması gereken bir şey ile security e yakalanırsan asla ve asla Nanotrasen ajanı olduğunu söylememelisin. Unutma ajan, ölmekte görevinin bir parçası."))

/datum/antagonist/ntagent/proc/ntagent_equipt_items(mob/living/carbon/human/ntagent = owner.current)
	return ntagent.equipOutfit(/datum/outfit/ntagent)

	

/datum/antagonist/ntagent/proc/give_objective()
	var/datum/objective/NTobjec = new()
	NTobjec.explanation_text = "Istasyonda bir tehlike var ise peşine düş ve kimliğini gizle."
	NTobjec.completed = TRUE 
	NTobjec.owner = owner
	objectives |= NTobjec
