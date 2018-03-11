/datum/antagonist/joejoe
	name = "Guardian User"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/joejoe/on_gain()
	owner.special_role = "Guardian User"
	. = ..()
	give_guardian()

/datum/antagonist/joejoe/greet()
	to_chat(owner, "<B>You realize you need to get your guardian ready. Check your backpack.</B>")

/datum/antagonist/joejoe/proc/give_guardian()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	var/obj/item/storage/box/syndie_kit/guardian/G = new(H)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store
	)
	H.equip_in_one_of_slots(G, slots)
