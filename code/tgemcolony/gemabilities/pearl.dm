/datum/action/innate/gem/store
	name = "Store Item"
	desc = "Store something inside your Gem."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "store"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/store/Activate()
	var/mob/living/carbon/human/H = owner
	var/limit = 30
	if(H.gemstatus == "offcolor")
		limit = 3 //a defective pearl isn't very good at storing items, you CAN get around using backpacks though.
	if(H.gemstatus == "prime")
		limit = 300 //effectively limitless storage.

	var/obj/item/item = H.get_active_held_item()
	if(item != null)
		var/itamm = 0
		for(var/atom/A in H.stored_items)
			itamm = itamm+1
		if(itamm >= limit)
			to_chat(usr, "<span class='warning'>You can't seem to store anything else! ([itamm]/[limit])</span>")
			return
		else
			H.dropItemToGround(item)
			H.stored_items.Add(item)
			item.forceMove(H)
			H.visible_message("<b>[H]</b> stores <b>[item]</b> in their gem!")
			itamm = itamm+1
			to_chat(usr, "<span class='warning'>You store the [item]! ([itamm]/[limit])</span>")


/datum/action/innate/gem/withdraw
	name = "Withdraw Item"
	desc = "Withdraw something from your Gem."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "withdraw"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/withdraw/Activate()
	if(!owner.get_empty_held_indexes())
		to_chat(usr, "<span class='warning'>You need an empty hand to withdraw!</span>")
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/item = input("What do you want to withdraw?") as null|anything in H.stored_items
	if(item != null)
		owner.put_in_hands(item)
		H.stored_items.Remove(item)
		var/limit = 30
		if(H.gemstatus == "offcolor")
			limit = 3 //a defective pearl isn't very good at storing items, you CAN get around using backpacks though.
		if(H.gemstatus == "prime")
			limit = 300 //effectively limitless storage.
		var/itamm = 0
		for(var/atom/A in H.stored_items)
			itamm = itamm+1
		H.visible_message("<b>[H]</b> withdraws <b>[item]</b> from their gem!")
		to_chat(usr, "<span class='warning'>You withdraw the [item]! ([itamm]/[limit])</span>")