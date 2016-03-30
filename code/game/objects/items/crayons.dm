/obj/item/toy/crayon/red
	icon_state = "crayonred"
	paint_color = "#DA0000"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	paint_color = "#FF9300"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	paint_color = "#FFF200"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	paint_color = "#A8E61D"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	paint_color = "#00B7EF"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	paint_color = "#DA00FF"
	colourName = "purple"

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	paint_color = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	paint_color = "#FFFFFF"
	colourName = "mime"
	uses = -1

/obj/item/toy/crayon/mime/attack_self(mob/living/user)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user)
	dat += "<center><span style='border:1px solid #161616; background-color: [paint_color];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if(href_list["color"])
		if(paint_color != "#FFFFFF")
			paint_color = "#FFFFFF"
		else
			paint_color = "#000000"
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	paint_color = "#FFF000"
	colourName = "rainbow"
	uses = -1

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user)
	dat += "<center><span style='border:1px solid #161616; background-color: [paint_color];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])

	if(href_list["color"])
		var/temp = input(usr, "Please select colour.", "Crayon colour") as color
		if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
			return
		paint_color = temp
		update_window(usr)
	else
		..()

/*
 * Crayon Box
 */
/obj/item/weapon/storage/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = 2
	storage_slots = 6
	can_hold = list(
		/obj/item/toy/crayon
	)

/obj/item/weapon/storage/crayons/New()
	..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	update_icon()

/obj/item/weapon/storage/crayons/update_icon()
	overlays.Cut()
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/weapon/storage/crayons/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	..()

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	icon_state = "spraycan_cap"
	item_state = "spraycan"
	desc = "A metallic container containing tasty paint."
	var/capped = 1
	instant = 1
	edible = 0
	validSurfaces = list(/turf/open/floor,/turf/closed/wall)

/obj/item/toy/crayon/spraycan/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(capped)
		user.visible_message("<span class='suicide'>[user] shakes up the [src] with a rattle and lifts it to their mouth, but nothing happens! Maybe they should have uncapped it first! Nonetheless--</span>")
		user.say("MEDIOCRE!!")
	else
		user.visible_message("<span class='suicide'>[user] shakes up the [src] with a rattle and lifts it to their mouth, spraying silver paint across their teeth!</span>")
		user.say("WITNESS ME!!")
		playsound(loc, 'sound/effects/spray.ogg', 5, 1, 5)
		paint_color = "#C0C0C0"
		update_icon()
		H.lip_style = "spray_face"
		H.lip_color = paint_color
		H.update_body()
		uses = max(0, uses - 10)
	return (OXYLOSS)

/obj/item/toy/crayon/spraycan/New()
	..()
	name = "spray can"
	paint_color = pick("#DA0000","#FF9300","#FFF200","#A8E61D","#00B7EF","#DA00FF")
	update_icon()

/obj/item/toy/crayon/spraycan/examine(mob/user)
	..()
	if(uses)
		user << "It has [uses] uses left."
	else
		user << "It is empty."

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user)
	var/choice = input(user,"Spraycan options") as null|anything in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			user << "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>"
			capped = capped ? 0 : 1
			icon_state = "spraycan[capped ? "_cap" : ""]"
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			paint_color = input(user,"Choose Color") as color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(capped)
		user << "<span class='warning'>Take the cap off first!</span>"
		return
	else
		if(iscarbon(target))
			if(uses)
				playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
				var/mob/living/carbon/C = target
				user.visible_message("<span class='danger'>[user] sprays [src] into the face of [target]!</span>")
				target << "<span class='userdanger'>[user] sprays [src] into your face!</span>"
				if(C.client)
					C.blur_eyes(3)
					C.blind_eyes(1)
					if(C.check_eye_prot() <= 0) // no eye protection? ARGH IT BURNS.
						C.confused = max(C.confused, 3)
						C.Weaken(3)
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					H.lip_style = "spray_face"
					H.lip_color = paint_color
					H.update_body()
				uses = max(0,uses-10)
		if(istype(target, /obj/structure/window))
			if(uses)
				target.color = paint_color
				if(color_hex2num(paint_color) < 255)
					target.SetOpacity(255)
				else
					target.SetOpacity(initial(target.opacity))
				uses = max(0, uses-2)
				playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
				return
		..()

/obj/item/toy/crayon/spraycan/update_icon()
	overlays.Cut()
	var/image/I = image('icons/obj/crayons.dmi',icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = paint_color
	overlays += I

/obj/item/toy/crayon/spraycan/gang
	desc = "A modified container containing suspicious paint."
	gang = 1
	uses = 20
	instant = -1

/obj/item/toy/crayon/spraycan/gang/New(loc, datum/gang/G)
	..()
	if(G)
		paint_color = G.color_hex
		update_icon()