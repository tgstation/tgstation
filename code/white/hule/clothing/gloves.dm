/obj/item/clothing/gloves/combat/maggloves
	name = "mag-pulse gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "black"
	item_state = "blackgloves"
	var/active = 0
	var/list/stored_items = list()
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/gloves/combat/maggloves/ui_action_click(mob/usr, action)
	active = !active
	if(active)
		for(var/obj/item/I in usr.held_items)
			if(!(I.flags_1 & NODROP_1))
				stored_items += I

		var/list/L = usr.get_empty_held_indexes()
		if(LAZYLEN(L) == usr.held_items.len)
			to_chat(usr, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
			stored_items = list()
		else
			for(var/obj/item/I in stored_items)
				to_chat(usr, "<span class='notice'>Your [usr.get_held_index_name(usr.get_held_index_of_item(I))]'s grip tightens.</span>")
				I.flags_1 |= NODROP_1

	else
		release_items()
		to_chat(usr, "<span class='notice'>Your hands relax...</span>")

/obj/item/clothing/gloves/combat/maggloves/proc/release_items()
	for(var/obj/item/I in stored_items)
		I.flags_1 &= ~NODROP_1
	stored_items = list()

/obj/item/clothing/gloves/combat/maggloves/dropped(mob/user)
	if(active)
		ui_action_click()
	..()