/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	colourName = "red"


/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	colourName = "orange"


/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	colourName = "yellow"



/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	colourName = "green"


/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	colourName = "blue"


/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	colourName = "purple"



/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(colour != "#FFFFFF")
		colour = "#FFFFFF"
		user << "You will now draw in white with this crayon."
	else
		colour = "#000000"
		user << "You will now draw in black with this crayon."
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	colour = input(user, "Please select the main colour.", "Crayon colour") as color
	return

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(target,/turf/simulated/floor))
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") in list("graffiti","rune","letter")
		switch(drawtype)
			if("letter")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
				user << "You start drawing a letter on the [target.name]."
			if("graffiti")
				user << "You start drawing graffiti on the [target.name]."
			if("rune")
				user << "You start drawing a rune on the [target.name]."
		if(instant || do_after(user, 50))
			new /obj/effect/decal/cleanable/crayon(target,colour,drawtype)
			user << "You finish drawing."
			if(uses)
				uses--
				if(!uses)
					user << "<span class='danger'>You used up your crayon!</span>"
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		user << "You take a bite of the crayon. Delicious!"
		user.nutrition += 5
		if(uses)
			uses -= 5
			if(uses <= 0)
				user << "<span class='danger'>You ate your crayon!</span>"
				qdel(src)
	else
		..()