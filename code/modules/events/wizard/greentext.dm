/datum/round_event_control/wizard/greentext //Gotta have it!
	name = "Greentext"
	weight = 4
	typepath = /datum/round_event/wizard/greentext
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/greentext/start()

	var/list/holder_canadates = GLOB.player_list.Copy()
	for(var/mob/M in holder_canadates)
		if(!ishuman(M))
			holder_canadates -= M
	if(!holder_canadates) //Very unlikely, but just in case
		return FALSE

	var/mob/living/carbon/human/H = pick(holder_canadates)
	new /obj/item/greentext(H.loc)
	to_chat(H, "<font color='green'>The mythical greentext appear at your feet! Pick it up if you dare...</font>")


/obj/item/greentext
	name = "greentext"
	desc = "No one knows what this massive tome does, but it feels <i><font color='green'>desirable</font></i> all the same..."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/wizard.dmi'
	icon_state = "greentext"
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/greentext/ComponentInitialize()
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/greentext)
