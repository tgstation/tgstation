/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in oview(1) //Cannot handle giving shit to mobs on your own tile, but it's a small, small loss

	give_item(usr)

/mob/living/carbon/proc/give_item(mob/living/carbon/user)

	if(src.stat == 2 || user.stat == 2 || src.client == null)
		return
	if(src == user) //Shouldn't happen
		user << "<span class='warning'>You feel stupider, suddenly.</span>"
		return
	var/obj/item/I
	if(user.get_active_hand() == null)
		user << "You don't have anything in your [user.hand ? "left hand" : "right hand"] to give to [src]."
		return
	I = user.get_active_hand()
	if(!I)
		return
	if(src.r_hand == null || src.l_hand == null)
		switch(alert(src, "[user] wants to give you \a [I]?", , "Yes", "No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(user))
					user << "<span class='warning'>You need to stay still while giving an object.</span>"
					src << "<span class='warning'>[user] moved away.</span>" //What an asshole
					return
				if(user.get_active_hand() != I)
					user << "<span class='warning'>You need to keep the item in your hand.</span>"
					src << "<span class='warning'>[user] has put \the [I] away!</span>"
					return
				if(src.r_hand != null && src.l_hand != null)
					src << "<span class='warning'>Your hands are full.</span>"
					user << "<span class='warning'>Their hands are full.</span>"
					return
				else
					user.drop_item()
					src.put_in_hands(I)
				I.loc = src
				I.layer = 20
				I.add_fingerprint(src)
				src.update_inv_l_hand()
				src.update_inv_r_hand()
				user.update_inv_l_hand()
				user.update_inv_r_hand()
				src.visible_message("<span class='notice'>[user] handed \the [I] to [src].</span>")
			if("No")
				src.visible_message("<span class='warning'>[user] tried to hand \the [I] to [src] but \he didn't want it.</span>")
	else
		user << "<span class='warning'>[src]'s hands are full.</span>"
