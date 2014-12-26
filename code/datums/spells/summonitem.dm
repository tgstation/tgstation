/obj/effect/proc_holder/spell/targeted/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "GAR YOK"
	invocation_type = "whisper"
	range = -1
	level_max = 1 //cannot be improved
	cooldown_min = 100
	include_user = 1

	var/obj/marked_item
	var/marked_item_name

/obj/effect/proc_holder/spell/targeted/summonitem/cast(list/targets)
	for(var/mob/living/user in targets)
		var/list/hand_items = list(user.get_active_hand(),user.get_inactive_hand())
		var/butterfingers = 0
		var/message

		if(!marked_item) //linking item to the spell
			message = "<span class='notice'>"
			for(var/obj/item in hand_items)
				if(ABSTRACT in item.flags)
					continue
				if(NODROP in item.flags)
					message += "Though it feels redundant, "
				marked_item = 		item
				marked_item_name = 	item.name
				message += "You mark [item] for recall.</span>"
				name = "Recall [item]"
				processing_objects.Add(src)
				break

			if(!marked_item)
				if(hand_items)
					message = "<span class='caution'>You aren't holding anything that can be marked for recalled.</span>"
				else
					message = "<span class='notice'>You must hold the desired item in your hands to mark it for recall.</span>"

		else if(marked_item && marked_item in hand_items) //unlinking item to the spell
			message = "<span class='notice'>You remove the mark on [marked_item] to use elsewhere.</span>"
			name = "Instant Summons"
			marked_item = 		null
			marked_item_name = 	null
			processing_objects.Remove(src)

		else	//Getting previously marked item
			var/obj/item_to_retrive = marked_item
			item_to_retrive.loc.visible_message("<span class='warning'>The [item_to_retrive.name] suddenly disappears!</span>")

			if(isobj(marked_item.loc)) //To prevent some weird recursive item removal things if your item is stored in something else. you get the whole dang thing.
				item_to_retrive = marked_item.loc

			if(ismob(item_to_retrive.loc)) //If its on someone, properly drop it before we steal it
				var/mob/M = item_to_retrive.loc
				M.unEquip(item_to_retrive)

			if(user.hand) //left active hand
				if(!user.equip_to_slot_if_possible(item_to_retrive, slot_l_hand, 0, 1, 1))
					if(!user.equip_to_slot_if_possible(item_to_retrive, slot_r_hand, 0, 1, 1))
						butterfingers = 1
			else			//right active hand
				if(!user.equip_to_slot_if_possible(item_to_retrive, slot_r_hand, 0, 1, 1))
					if(!user.equip_to_slot_if_possible(item_to_retrive, slot_l_hand, 0, 1, 1))
						butterfingers = 1
			if(butterfingers)
				item_to_retrive.loc = user.loc
				item_to_retrive.loc.visible_message("<span class='caution'>The [item_to_retrive.name] suddenly appears!</span>")
			else
				item_to_retrive.loc.visible_message("<span class='caution'>The [item_to_retrive.name] suddenly appears in [user]'s hand!</span>")

		if(message)
			user << message

/obj/effect/proc_holder/spell/targeted/summonitem/process()
	if(!marked_item.loc) //item was destroyed
		name = "Instant Summons"
		marked_item = 		null
		marked_item_name = 	null
		processing_objects.Remove(src)
