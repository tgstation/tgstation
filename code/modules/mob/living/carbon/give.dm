/mob/living/verb/give()
	set category = "IC"
	set name = "Give"
	set src in oview(1) //Cannot handle giving shit to mobs on your own tile, but it's a small, small loss

	give_item(usr)

/mob/living/proc/give_item(mob/living/carbon/user)


/mob/living/carbon/give_item(mob/living/carbon/user)
	if(!istype(user))
		return
	if(src.stat == 2 || user.stat == 2 || src.client == null)
		return
	if(src.handcuffed)
		user << "<span class='warning'>Those hands are cuffed right now.</span>"
		return //Can't receive items while cuffed
	var/obj/item/I
	if(user.get_active_held_item() == null)
		user << "You don't have anything in your [get_held_index_name(get_held_index_of_item(I))] to give to [src]."
		return
	I = user.get_active_held_item()
	if(!I)
		return
	if(src == user) //Shouldn't happen
		user << "<span class='warning'>You tried to give yourself \the [I], but you didn't want it.</span>"
		return
	if(get_empty_held_index_for_side())
		switch(alert(src, "[user] wants to give you \a [I]?", , "Yes", "No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(user))
					user <<"<span class='warning'>You need to stay still while giving an object.</span>"
					src << "<span class='warning'>[user] moved away.</span>"//What an asshole

					return
				if(user.get_active_held_item() != I)
					user << "<span class='warning'>You need to keep the item in your hand.</span>"
					src << "<span class='warning'>[user] has put \the [I] away!</span>"
					return
				if(!get_empty_held_index_for_side())
					user << "<span class='warning'>Your hands are full.</span>"
					user << "<span class='warning'>Their hands are full.</span>"
					return
				if(!user.dropItemToGround(I))
					src << "<span class='warning'>[user] can't let go of \the [I]!</span>"
					user << "<span class='warning'>You can't seem to let go of \the [I].</span>"
					return

				src.put_in_hands(I)
				update_inv_hands()
				src.visible_message("<span class='notice'>[user] handed \the [I] to [src].</span>")
			if("No")
				src.visible_message("<span class='warning'>[user] tried to hand \the [I] to [src] but \he didn't want it.</span>")
	else
		user << "<span class='warning'>[src]'s hands are full.</span>"
