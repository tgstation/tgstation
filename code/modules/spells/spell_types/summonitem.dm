/obj/effect/proc_holder/spell/targeted/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "GAR YOK"
	invocation_type = "whisper"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 100
	include_user = 1

	var/obj/marked_item

	action_icon_state = "summons"

/obj/effect/proc_holder/spell/targeted/summonitem/cast(list/targets,mob/user = usr)
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_held_item(),L.get_inactive_held_item())
		var/message

		if(!marked_item || qdeleted(marked_item)) //linking item to the spell
			message = "<span class='notice'>"
			for(var/obj/item in hand_items)
				if(ABSTRACT in item.flags)
					continue
				if(NODROP in item.flags)
					message += "Though it feels redundant, "
				marked_item = 		item
				message += "You mark [item] for recall.</span>"
				name = "Recall [item]"
				break

			if(!marked_item)
				if(hand_items)
					message = "<span class='caution'>You aren't holding anything that can be marked for recall.</span>"
				else
					message = "<span class='notice'>You must hold the desired item in your hands to mark it for recall.</span>"

		else if(marked_item && marked_item in hand_items) //unlinking item to the spell
			message = "<span class='notice'>You remove the mark on [marked_item] to use elsewhere.</span>"
			name = "Instant Summons"
			marked_item = 		null

		else	//Getting previously marked item
			if(!marked_item.loc)
				if(isorgan(marked_item)) //Organs are usually stored in nullspace
					var/obj/item/organ/organ = marked_item
					if(organ.owner)
						// If this code ever runs I will be happy
						add_logs(L, organ.owner, "magically removed [organ.name] from", addition="INTENT: [uppertext(L.a_intent)]")
						organ.Remove(organ.owner)

			marked_item.visible_message("<span class='warning'>The [marked_item.name] suddenly disappears!</span>")
			playsound(marked_item,"sound/magic/SummonItems_generic.ogg",50,1)
			marked_item.forceMove(L.loc)
			if(!L.put_in_hands(marked_item))
				marked_item.visible_message("<span class='warning'>The [marked_item.name] suddenly appears!</span>")
			else
				L.visible_message("<span class='warning'>The [marked_item.name] suddenly appears in [L]'s hand!</span>")
			playsound(marked_item,"sound/magic/SummonItems_generic.ogg",50,1)

		if(message)
			L << message
