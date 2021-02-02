/datum/id_trim
	var/trim_icon = 'icons/obj/card.dmi'
	var/trim_state
	var/assignment

	var/list/basic_access = list()
	var/list/wildcard_access = list()

/datum/id_trim/proc/apply_to_card(obj/item/card/id/id_card)
	if(!id_card.can_add_wildcards(wildcard_access))
		return FALSE

	id_card.timberpoes_trim = src
	id_card.timberpoes_access = basic_access.Copy()
	id_card.add_wildcards(wildcard_access)

	if(assignment)
		id_card.assignment = assignment

	id_card.update_label()
