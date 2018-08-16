/obj/item/melee/baton/stunsword
	name = "stunsword"
	desc = "not actually sharp, this sword is functionally identical to a stunbaton"
	icon = 'modular_citadel/icons/obj/stunsword.dmi'
	icon_state = "stunsword"
	item_state = "sword"
	lefthand_file = 'modular_citadel/icons/mob/inhands/stunsword_left.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/stunsword_right.dmi'

/obj/item/ssword_kit
	name = "stunsword kit"
	desc = "a modkit for making a stunbaton into a stunsword"
	icon = 'icons/obj/vending_restock.dmi'
	icon_state = "refill_donksoft"
	var/product = /obj/item/melee/baton/stunsword //what it makes
	var/list/fromitem = list(/obj/item/melee/baton, /obj/item/melee/baton/loaded) //what it needs
	afterattack(obj/O, mob/user as mob)
		if(istype(O, product))
			to_chat(user,"<span class='warning'>[O] is already modified!")
		else if(O.type in fromitem) //makes sure O is the right thing
			var/obj/item/melee/baton/B = O
			if(!B.cell) //checks for a powercell in the baton. If there isn't one, continue. If there is, warn the user to take it out
				new product(usr.loc) //spawns the product
				user.visible_message("<span class='warning'>[user] modifies [O]!","<span class='warning'>You modify the [O]!")
				qdel(O) //Gets rid of the baton
				qdel(src) //gets rid of the kit

			else
				to_chat(user,"<span class='warning'>Remove the powercell first!</span>") //We make this check because the stunsword starts without a battery.
		else
			to_chat(user, "<span class='warning'> You can't modify [O] with this kit!</span>")


