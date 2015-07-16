/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in view(1)
	if(src.stat == 2 || usr.stat == 2 || src.client == null)
		return
	if(src == usr)
		usr << "<span class='warning'>I feel stupider, suddenly.</span>"
		return
	var/obj/item/I
	if(!usr.hand && usr.r_hand == null)
		usr << "<span class='warning'>You don't have anything in your right hand to give to [src.name]</span>"
		return
	if(usr.hand && usr.l_hand == null)
		usr << "<span class='warning'>You don't have anything in your left hand to give to [src.name]</span>"
		return
	if(usr.hand)
		I = usr.l_hand
	else if(!usr.hand)
		I = usr.r_hand
	if(!I)
		return
	if(src.r_hand == null || src.l_hand == null)
		switch(alert(src,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					usr << "<span class='warning'>You need to stay in reaching distance while giving an object.</span>"
					src << "<span class='warning'>[usr.name] moved too far away.</span>"
					return
				if((usr.hand && usr.l_hand != I) || (!usr.hand && usr.r_hand != I))
					usr << "<span class='warning'>You need to keep the item in your active hand.</span>"
					src << "<span class='warning'>[usr.name] seem to have given up on giving \the [I.name] to you.</span>"
					return
				if(src.r_hand != null && src.l_hand != null)
					src << "<span class='warning'>Your hands are full.</span>"
					usr << "<span class='warning'>Their hands are full.</span>"
					return
				else
					usr.drop_item()
					if(src.r_hand == null)
						src.r_hand = I
					else
						src.l_hand = I
				I.loc = src
				I.layer = 20
				I.add_fingerprint(src)
				src.update_inv_l_hand()
				src.update_inv_r_hand()
				usr.update_inv_l_hand()
				usr.update_inv_r_hand()
				src.visible_message("<span class='notice'>[usr.name] handed \the [I.name] to [src.name].</span>")
			if("No")
				src.visible_message("<span class='warning'>[usr.name] tried to hand [I.name] to [src.name] but [src.name] didn't want it.</span>")
	else
		usr << "<span class='warning'>[src.name]'s hands are full.</span>"