/obj/item/toy/crayon/red
	icon_state = "crayonred"
	color = "#DA0000"
	colorName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	color = "#FF9300"
	colorName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	color = "#FFF200"
	colorName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	color = "#A8E61D"
	colorName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	color = "#00B7EF"
	colorName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	color = "#DA00FF"
	colorName = "purple"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	color = "#FFFFFF"
	colorName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [color];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if(href_list["color"])
		if(color != "#FFFFFF")
			color = "#FFFFFF"
		else
			color = "#000000"
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	color = "#FFF000"
	colorName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [color];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])

	if(href_list["color"])
		var/temp = input(usr, "Please select color.", "Crayon color") as color
		if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
			return
		color = temp
		update_window(usr)
	else
		..()