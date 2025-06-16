/datum/antagonist/wishgranter
	name = "\improper Wishgranter Avatar"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	hijack_speed = 2 //You literally are here to do nothing else. Might as well be fast about it.
	suicide_cry = "HAHAHAHAHA!!"

/datum/antagonist/wishgranter/forge_objectives()
	var/datum/objective/hijack/hijack = new
	hijack.owner = owner
	objectives += hijack

/datum/antagonist/wishgranter/on_gain()
	owner.special_role = "Avatar of the Wish Granter"
	forge_objectives()
	. = ..()
	give_powers()

/datum/antagonist/wishgranter/greet()
	. = ..()
	to_chat(owner, "<B>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</B>")
	owner.announce_objectives()

/datum/antagonist/wishgranter/proc/give_powers()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.dna.add_mutation(/datum/mutation/hulk, MUTATION_SOURCE_WISHGRANTER)
	H.dna.add_mutation(/datum/mutation/xray, MUTATION_SOURCE_WISHGRANTER)
	H.dna.add_mutation(/datum/mutation/adaptation/pressure, MUTATION_SOURCE_WISHGRANTER)
	H.dna.add_mutation(/datum/mutation/telekinesis, MUTATION_SOURCE_WISHGRANTER)
