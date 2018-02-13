/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in view(1)

	if(src == usr)
		to_chat(usr,"<span class='warning'>You feel stupider, suddenly.</span>")
		return

	if(!ismonkey(src)&&!ishuman(src) || isalien(src) || src.stat || usr.stat || !src.client)
		to_chat(usr,"<span class='warning'>[src.name] can't take anything</span>")
		return

	var/obj/item/I = usr.get_active_held_item()
	if(!I)
		to_chat(usr,"<span class='warning'>You don't have anything in your active hand to give to [src].</span>")
		return

	if(!usr.canUnEquip(I))
		return

	var/list/empty_hands = get_empty_held_indexes()
	if(!empty_hands.len)
		to_chat(usr,"<span class='warning'>[src]'s hands are full.</span>")
		return

	switch(alert(src,"[usr] wants to give you \a [I]?",,"Yes","No"))
		if("Yes")
			if(!I || !usr)
				return
			if(!Adjacent(usr))
				to_chat(usr,"<span class='warning'>You need to stay in reaching distance while giving an object.</span>")
				to_chat(usr,"<span class='warning'>[usr] moved too far away.</span>")
				return

			if(I != usr.get_active_held_item())
				to_chat(usr,"<span class='warning'>You need to keep the item in your active hand.</span>")
				to_chat(usr,"<span class='warning'>[name] seem to have given up on giving [I] to you.</span>")
				return

			if(src.lying || src.handcuffed)
				to_chat(usr,"<span class='warning'>He is restrained.</span>")
				return

			empty_hands = get_empty_held_indexes()
			if(!empty_hands.len)
				to_chat(usr,"<span class='warning'>Your hands are full.</span>")
				to_chat(usr,"<span class='warning'>Their hands are full.</span>")
				return

			if(!usr.dropItemToGround(I))
				return

			if(!put_in_hands(I))
				to_chat(usr,"<span class='warning'>You can't take [I], so [usr] gave up!</span>")
				to_chat(usr,"<span class='warning'>[src] can't take [I]!</span>")
				return

			src.visible_message("<span class='notice'>[usr] handed [I] to [src].</span>")
		if("No")
			src.visible_message("<span class='warning'>[usr] tried to hand [I] to [src] but [src] didn't want it.</span>")