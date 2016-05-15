
/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	item_color = "red"
	w_class = 1
	attack_verb = list("attacked", "coloured")
	var/paint_color = "#FF0000" //RGB
	var/drawtype = "rune"
	var/text_buffer = ""
	var/list/graffiti = list("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","body","cyka","arrow","star","poseur tag")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/list/numerals = list("0","1","2","3","4","5","6","7","8","9")
	var/list/oriented = list("arrow","body") // These turn to face the same way as the drawer
	var/uses = 30 //-1 or less for unlimited uses
	var/instant = 0
	var/dat
	var/list/validSurfaces = list(/turf/open/floor)
	var/gang = 0 //For marking territory
	var/edible = 1

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/New()
	..()
	name = "[item_color] crayon" //Makes crayons identifiable in things like grinders
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1,6)]")
	if(config)
		if(config.mutant_races == 1)
			graffiti |= "antilizard"
			graffiti |= "prolizard"

/obj/item/toy/crayon/initialize()
	if(config.mutant_races == 1)
		graffiti |= "antilizard"
		graffiti |= "prolizard"

/obj/item/toy/crayon/attack_self(mob/living/user)
	update_window(user)

/obj/item/toy/crayon/proc/update_window(mob/living/user)
	dat += "<center><h2>Currently selected: [drawtype]</h2><br>"
	dat += "<a href='?src=\ref[src];type=random_letter'>Random letter</a><a href='?src=\ref[src];type=letter'>Pick letter/number</a>"
	dat += "<a href='?src=\ref[src];buffer=1'>Write</a>"
	dat += "<hr>"
	dat += "<h3>Runes:</h3><br>"
	dat += "<a href='?src=\ref[src];type=random_rune'>Random rune</a>"
	for(var/i = 1; i <= 6; i++)
		dat += "<a href='?src=\ref[src];type=rune[i]'>Rune[i]</a>"
		if(!((i + 1) % 3)) //3 buttons in a row
			dat += "<br>"
	dat += "<hr>"
	graffiti.Find()
	dat += "<h3>Graffiti:</h3><br>"
	dat += "<a href='?src=\ref[src];type=random_graffiti'>Random graffiti</a>"
	var/c = 1
	for(var/T in graffiti)
		dat += "<a href='?src=\ref[src];type=[T]'>[T]</a>"
		if(!((c + 1) % 3)) //3 buttons in a row
			dat += "<br>"
		c++
	dat += "<hr>"
	var/datum/browser/popup = new(user, "crayon", name, 300, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	dat = ""

/obj/item/toy/crayon/proc/crayon_text_strip(text)
	var/list/base = char_split(lowertext(text))
	var/list/out = list()
	for(var/a in base)
		if(a in (letters|numerals))
			out += a
	return jointext(out,"")

/obj/item/toy/crayon/Topic(href, href_list, hsrc)
	var/temp = "a"
	if(href_list["buffer"])
		text_buffer = crayon_text_strip(stripped_input(usr,"Choose what to write.", "Scribbles",default = text_buffer))
	if(href_list["type"])
		switch(href_list["type"])
			if("random_letter")
				temp = pick(letters)
			if("letter")
				temp = input("Choose what to write.", "Scribbles") in (letters|numerals)
			if("random_rune")
				temp = "rune[rand(1,6)]"
			if("random_graffiti")
				temp = pick(graffiti)
			else
				temp = href_list["type"]
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	drawtype = temp
	update_window(usr)

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !check_allowed_items(target)) return
	if(!uses)
		user << "<span class='warning'>There is no more of [src.name] left!</span>"
		if(!instant)
			qdel(src)
		return
	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc
	if(is_type_in_list(target,validSurfaces))

		var/temp = "rune"
		if(letters.Find(drawtype))
			temp = "letter"
		else if(graffiti.Find(drawtype))
			temp = "graffiti"
		else if(numerals.Find(drawtype))
			temp = "number"

		////////////////////////// GANG FUNCTIONS
		var/area/territory
		var/gangID
		if(gang)
			//Determine gang affiliation
			gangID = user.mind.gang_datum

			//Check area validity. Reject space, player-created areas, and non-station z-levels.
			if(gangID)
				territory = get_area(target)
				if(territory && (territory.z == ZLEVEL_STATION) && territory.valid_territory)
					//Check if this area is already tagged by a gang
					if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
						if(territory_claimed(territory, user))
							return
					if(locate(/obj/machinery/power/apc) in (user.loc.contents | target.contents))
						user << "<span class='warning'>You cannot tag here.</span>"
						return
				else
					user << "<span class='warning'>[territory] is unsuitable for tagging.</span>"
					return
		/////////////////////////////////////////

		var/graf_rot
		if(oriented.Find(drawtype))
			switch(user.dir)
				if(EAST)
					graf_rot = 90
				if(SOUTH)
					graf_rot = 180
				if(WEST)
					graf_rot = 270
				else
					graf_rot = 0

		user << "<span class='notice'>You start [instant ? "spraying" : "drawing"] a [temp] on the [target.name]...</span>"
		if(instant)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		if((instant>0) || do_after(user, 50, target = target))

			if(length(text_buffer))
				drawtype = copytext(text_buffer,1,2)
				text_buffer = copytext(text_buffer,2)

			//Gang functions
			if(gangID)
				//Delete any old markings on this tile, including other gang tags
				if(!(locate(/obj/effect/decal/cleanable/crayon/gang) in target)) //Ignore the check if the tile being sprayed has a gang tag
					if(territory_claimed(territory, user))
						return
				for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
					qdel(old_marking)
				new /obj/effect/decal/cleanable/crayon/gang(target,gangID,"graffiti",graf_rot)
				user << "<span class='notice'>You tagged [territory] for your gang!</span>"

			else
				new /obj/effect/decal/cleanable/crayon(target,paint_color,drawtype,temp,graf_rot)

			user << "<span class='notice'>You finish [instant ? "spraying" : "drawing"] \the [temp].</span>"
			if(instant<0)
				playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
			if(uses < 0)
				return
			uses = max(0,uses-1)
			if(!uses)
				user << "<span class='warning'>There is no more of [src.name] left!</span>"
				if(!instant)
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M, mob/user)
	if(edible && (M == user))
		user << "You take a bite of the [src.name]. Delicious!"
		user.nutrition += 5
		if(uses < 0)
			return
		uses = max(0,uses-5)
		if(!uses)
			user << "<span class='warning'>There is no more of [src.name] left!</span>"
			qdel(src)
	else
		..()

/obj/item/toy/crayon/proc/territory_claimed(area/territory,mob/user)
	var/occupying_gang
	for(var/datum/gang/G in ticker.mode.gangs)
		if(territory.type in (G.territory|G.territory_new))
			occupying_gang = G.name
			break
	if(occupying_gang)
		user << "<span class='danger'>[territory] has already been tagged by the [occupying_gang] gang! You must get rid of or spray over the old tag first!</span>"
		return 1
	return 0



/obj/item/toy/crayon/red
	icon_state = "crayonred"
	paint_color = "#DA0000"
	item_color = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	paint_color = "#FF9300"
	item_color = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	paint_color = "#FFF200"
	item_color = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	paint_color = "#A8E61D"
	item_color = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	paint_color = "#00B7EF"
	item_color = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	paint_color = "#DA00FF"
	item_color = "purple"

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	paint_color = "#FFFFFF"
	item_color = "white"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	paint_color = "#FFFFFF"
	item_color = "mime"
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
	item_color = "rainbow"
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
		overlays += image('icons/obj/crayons.dmi',crayon.item_color)

/obj/item/weapon/storage/crayons/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		switch(C.item_color)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	return ..()

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
				// Caution, spray cans contain inflammable substances
				if(C.reagents)
					C.reagents.add_reagent("welding_fuel", 5)
					C.reagents.add_reagent("ethanol", 5)
					C.reagents.reaction(C, VAPOR, 10)

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

/obj/item/toy/crayon/spraycan/borg
	desc = "A metallic container containing shiny paint."
	// Use depletion of uses to determine what the energy cost is
	uses = 100

/obj/item/toy/crayon/spraycan/borg/afterattack(atom/target,mob/user,proximity)
	..()
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/borgy = user

	var/starting_uses = initial(uses)
	var/diff = starting_uses - uses
	if(diff)
		uses = starting_uses
		// 25 is our cost per unit of paint, making it cost 25 energy per
		// normal tag, 50 per window, and 250 per attack
		var/cost = diff * 25
		// Cyborgs shouldn't be able to use modules without a cell. But if they do
		// it's free.
		if(borgy.cell)
			borgy.cell.use(cost)
