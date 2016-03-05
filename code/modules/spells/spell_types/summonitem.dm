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
		var/list/hand_items = list(L.get_active_hand(),L.get_inactive_hand())
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

		else if(marked_item && qdeleted(marked_item)) //the item was destroyed at some point
			message = "<span class='warning'>You sense your marked item has been destroyed!</span>"
			name = "Instant Summons"
			marked_item = 		null

		else	//Getting previously marked item
			var/obj/item_to_retrive = marked_item
			var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

			if(!item_to_retrive.loc)
				if(isorgan(item_to_retrive)) // Organs are usually stored in nullspace
					var/obj/item/organ/internal/organ = item_to_retrive
					if(organ.owner)
						// If this code ever runs I will be happy
						add_logs(L, organ.owner, "magically removed [organ.name] from", addition="INTENT: [uppertext(L.a_intent)]")
						organ.Remove(organ.owner)
			else
				while(!isturf(item_to_retrive.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
					if(ismob(item_to_retrive.loc)) //If its on someone, properly drop it
						var/mob/M = item_to_retrive.loc

						if(issilicon(M)) //Items in silicons warp the whole silicon
							M.loc.visible_message("<span class='warning'>[M] suddenly disappears!</span>")
							M.loc = L.loc
							M.loc.visible_message("<span class='caution'>[M] suddenly appears!</span>")
							item_to_retrive = null
							break
						M.unEquip(item_to_retrive)

						if(iscarbon(M)) //Edge case housekeeping
							var/mob/living/carbon/C = M
							if(C.stomach_contents && item_to_retrive in C.stomach_contents)
								C.stomach_contents -= item_to_retrive

					else
						if(istype(item_to_retrive.loc,/obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
							var/obj/machinery/portable_atmospherics/P = item_to_retrive.loc
							P.disconnect()
							P.update_icon()

						item_to_retrive = item_to_retrive.loc

					infinite_recursion += 1

			if(!item_to_retrive)
				return

			if(item_to_retrive.loc)
				item_to_retrive.loc.visible_message("<span class='warning'>The [item_to_retrive.name] suddenly disappears!</span>")


			if(L.hand) //left active hand
				if(!L.equip_to_slot_if_possible(item_to_retrive, slot_l_hand, 0, 1, 1))
					if(!L.equip_to_slot_if_possible(item_to_retrive, slot_r_hand, 0, 1, 1))
						butterfingers = 1
			else			//right active hand
				if(!L.equip_to_slot_if_possible(item_to_retrive, slot_r_hand, 0, 1, 1))
					if(!L.equip_to_slot_if_possible(item_to_retrive, slot_l_hand, 0, 1, 1))
						butterfingers = 1
			if(butterfingers)
				item_to_retrive.loc = L.loc
				item_to_retrive.loc.visible_message("<span class='caution'>The [item_to_retrive.name] suddenly appears!</span>")
				playsound(get_turf(L),"sound/magic/SummonItems_generic.ogg",50,1)
			else
				item_to_retrive.loc.visible_message("<span class='caution'>The [item_to_retrive.name] suddenly appears in [L]'s hand!</span>")
				playsound(get_turf(L),"sound/magic/SummonItems_generic.ogg",50,1)


		if(message)
			L << message
