/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in view(1)
	give_item(usr)

/mob/living/carbon/proc/give_item(mob/living/carbon/user)

	if(src.stat == 2 || user.stat == 2 || src.client == null)
		return
	if(src == user)
		user << "\red I feel stupider, suddenly."
		return
	var/obj/item/I
	if(!user.hand && user.r_hand == null)
		user << "\red You don't have anything in your right hand to give to [src.name]"
		return
	if(user.hand && user.l_hand == null)
		user << "\red You don't have anything in your left hand to give to [src.name]"
		return
	if(user.hand)
		I = user.l_hand
	else if(!user.hand)
		I = user.r_hand
	if(!I)
		return
	if(src.r_hand == null || src.l_hand == null)
		switch(alert(src,"[user] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(user))
					user << "\red You need to stay in reaching distance while giving an object."
					src << "\red [user.name] moved too far away."
					return
				if((user.hand && user.l_hand != I) || (!user.hand && user.r_hand != I))
					user << "\red You need to keep the item in your active hand."
					src << "\red [user.name] seem to have given up on giving \the [I.name] to you."
					return
				if(src.r_hand != null && src.l_hand != null)
					src << "\red Your hands are full."
					user << "\red Their hands are full."
					return
				else
					user.drop_item()
					if(src.r_hand == null)
						src.r_hand = I
					else
						src.l_hand = I
				I.loc = src
				I.layer = 20
				I.add_fingerprint(src)
				src.update_inv_l_hand()
				src.update_inv_r_hand()
				user.update_inv_l_hand()
				user.update_inv_r_hand()
				src.visible_message("\blue [user.name] handed \the [I.name] to [src.name].")
			if("No")
				src.visible_message("\red [user.name] tried to hand [I.name] to [src.name] but [src.name] didn't want it.")
	else
		user << "\red [src.name]'s hands are full."
