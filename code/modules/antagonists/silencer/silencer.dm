///The mime gone sour. Needs to remove 50% of tongues from living crew.
/datum/antagonist/silencer
	name = "\improper Silencer"
	show_name_in_check_antagonists = TRUE
	antagpanel_category = "Other"
	show_to_ghosts = TRUE
	suicide_cry = "" // >speaking
	preview_outfit = /datum/outfit/silencer

/datum/outfit/silencer
	name = "Silencer (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/mime
	suit = /obj/item/clothing/suit/toggle/suspenders
	gloves = /obj/item/clothing/gloves/color/white
	mask = /obj/item/clothing/mask/gas/mime
	l_hand = /obj/item/scalpel
	r_hand = /obj/item/circular_saw

/datum/antagonist/silencer/on_gain()
	var/datum/objective/remove_tongues/the_silencers_task = new /datum/objective/remove_tongues("Ensure half of the surviving crew are tongueless.")
	the_silencers_task.completed = TRUE //YES!
	the_silencers_task.owner = owner
	objectives += the_silencers_task
	. = ..()

/datum/objective/remove_tongues //spend some time around someone, handled by the obsessed trauma since that ticks
	name = "Remove Tongues"

/datum/objective/remove_tongues/check_completion()
	var/required_tongues_removed = round(GLOB.alive_player_list.len / 2) - 1
	for(var/mob/player in GLOB.alive_player_list)
		if(!ishuman(player) || player.mind == owner)
			//okay, doesn't count
			required_tongues_removed--
			continue
		var/mob/living/carbon/human/human_player = player
		var/obj/item/organ/internal/tongue/tongue = human_player.getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			required_tongues_removed--
	return required_tongues_removed <= 0
