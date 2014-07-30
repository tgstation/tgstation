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

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(color != "#FFFFFF")
		color = "#FFFFFF"
		user << "You will now draw in white with this crayon."
	else
		color = "#000000"
		user << "You will now draw in black with this crayon."
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	color = "#FFF000"
	colorName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	color = input(user, "Please select the main color.", "Crayon color") as color
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
			new /obj/effect/decal/cleanable/crayon(target,color,drawtype)
			user << "You finish drawing."
			if(uses)
				uses--
				if(!uses)
					user << "\red You used up your crayon!"
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		user << "You take a bite of the crayon. Delicious!"
		user.nutrition += 5
		if(uses)
			uses -= 5
			if(uses <= 0)
				user << "\red You ate your crayon!"
				qdel(src)
	else
		..()