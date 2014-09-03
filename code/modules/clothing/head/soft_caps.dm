/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES
	item_state = "helmet"
	_color = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9

	proc/flip(var/mob/user as mob)
		if(user.canmove && !user.stat && !user.restrained())
			src.flipped = !src.flipped
			if(src.flipped)
				icon_state = "[_color]soft_flipped"
				user << "You flip the hat backwards."
			else
				icon_state = "[_color]soft"
				user << "You flip the hat back in normal position."
			user.update_inv_head()	//so our mob-overlays update

	attack_self(var/mob/user as mob)
		flip(user)

	verb/flip_cap()
		set category = "Object"
		set name = "Flip cap"
		set src in usr
		flip(usr)

	dropped()
		src.icon_state = "[_color]soft"
		src.flipped=0
		..()

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	_color = "sec"

/obj/item/clothing/head/soft/paramedic
	name = "paramedic cap"
	desc = "It's a baseball hat in a tasteful blue colour."
	icon_state = "paramedicsoft"
	_color = "paramedic"