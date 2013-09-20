/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"
	colour = "cargo"
	var/flipped = 0

	dropped()
		src.icon_state = "[colour]soft"
		src.flipped=0
		..()

	verb/flip()
		set category = "Object"
		set name = "Flip cap"
		set src in usr
		if(usr.canmove && !usr.stat && !usr.restrained())
			src.flipped = !src.flipped
			if(src.flipped)
				icon_state = "[colour]soft_flipped"
				usr << "You flip the hat backwards."
			else
				icon_state = "[colour]soft"
				usr << "You flip the hat back in normal position."
			usr.update_inv_head(0)	//so our mob-overlays update

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	colour = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	colour = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	colour = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	colour = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	colour = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	colour = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	colour = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	colour = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colours."
	icon_state = "rainbowsoft"
	colour = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	colour = "sec"