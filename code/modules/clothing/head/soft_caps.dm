/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0

	dropped()
		src.icon_state = "[item_color]soft"
		src.flipped=0
		..()

	verb/flipcap()
		set category = "Object"
		set name = "Flip cap"

		flip(usr)


/obj/item/clothing/head/soft/AltClick(mob/user)
	..()
	if(!user.canUseTopic(user))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		flip(user)


/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(user.canmove && !user.stat && !user.restrained())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[item_color]soft_flipped"
			user << "<span class='notice'>You flip the hat backwards.</span>"
		else
			icon_state = "[item_color]soft"
			user << "<span class='notice'>You flip the hat back in normal position.</span>"
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click the cap to flip it [flipped ? "forwards" : "backwards"].</span>"

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	item_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	item_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	item_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "blacksoft"
	item_color = "black"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's a robust baseball hat in tasteful red colour."
	icon_state = "secsoft"
	item_color = "sec"
	armor = list(melee = 30, bullet = 25, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)
	strip_delay = 60

/obj/item/clothing/head/soft/emt
	name = "EMT cap"
	desc = "It's a baseball hat with a dark turquoise color and a reflective cross on the top."
	icon_state = "emtsoft"
	item_color = "emt"