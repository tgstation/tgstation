/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	colourName = "red"

/obj/item/toy/crayon/spraycan/red
	icon_state = "spraycanred_cap"
	colour = "#DA0000"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	colourName = "orange"

/obj/item/toy/crayon/spraycan/orange
	icon_state = "spraycanorange_cap"
	colour = "#FF9300"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	colourName = "yellow"

/obj/item/toy/crayon/spraycan/yellow
	icon_state = "spraycanyellow_cap"
	colour = "#FFF200"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	colourName = "green"

/obj/item/toy/crayon/spraycan/green
	icon_state = "spraycangreen_cap"
	colour = "#A8E61D"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	colourName = "blue"

/obj/item/toy/crayon/spraycan/blue
	icon_state = "spraycanblue_cap"
	colour = "#00B7EF"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	colourName = "purple"

/obj/item/toy/crayon/spraycan/purple
	icon_state = "spraycanpurple_cap"
	colour = "#DA00FF"
	colourName = "purple"

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/spraycan/white
	icon_state = "spraycanwhite_cap"
	colour = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/proc/includeColor()
	return "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"

/obj/item/toy/crayon/proc/topicColor(var/href, var/list/href_list, var/blackwhite=FALSE)
	if(blackwhite)
		if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
			return
		if(href_list["color"])
			if(colour != "#FFFFFF")
				colour = "#FFFFFF"
			else
				colour = "#000000"
			update_window(usr)
	else
		if(href_list["color"])
			var/temp = input(usr, "Please select colour.", "Crayon colour") as color
			if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
				return
			colour = temp
			update_window(usr)


/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += includeColor()
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	topicColor(href,href_list,TRUE)
	..()

/obj/item/toy/crayon/spraycan/mime
	icon_state = "spraycanmime_cap"
	desc = "A very sad-looking spraycan."
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/spraycan/mime/update_window(mob/living/user as mob)
	dat += includeColor()
	..()

/obj/item/toy/crayon/spraycan/mime/Topic(href,href_list)
	topicColor(href,href_list,TRUE)
	..()


/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += includeColor()
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])
	topicColor(href,href_list,FALSE)
	..()

/obj/item/toy/crayon/spraycan/rainbow
	icon_state = "spraycanrainbow_cap"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/spraycan/rainbow/update_window(mob/living/user as mob)
	dat += includeColor()
	..()

/obj/item/toy/crayon/spraycan/rainbow/Topic(href,href_list[])
	topicColor(href,href_list,FALSE)
	..()