/obj/item/clothing/head/cargosoft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"
	var/flipped = 0

	dropped()
		src.icon_state = "cargosoft"
		src.flipped=0
		..()

	verb/flip()
		set category = "Object"
		set name = "Flip cap"
		set src in usr
		if(usr.canmove && !usr.stat && !usr.restrained())
			src.flipped = !src.flipped
			if(src.flipped)
				icon_state = "cargosoft_flipped"
				usr << "You flip the hat backwards."
			else
				icon_state = "cargosoft"
				usr << "You flip the hat back in normal position."
			usr.update_inv_head()	//so our mob-overlays update
