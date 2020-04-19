/obj/structure/customplaque
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque. Use a fancy pen to engrave it, use a wrench to take it off the wall."
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 100
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/unengraved = TRUE

/obj/item/customplaque
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque. Place it on a wall and use a fancy pen to engrave it, use a wrench to take it off the wall."
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/gold = 2000)
//	resistance_flags = FLAMMABLE
	var/sign_path = /obj/structure/customplaque //the type of sign that will be created when placed on a turf
	var/unengraved = TRUE

/obj/structure/customplaque/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/customplaque/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)


/obj/structure/customplaque/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		user.visible_message("<span class='notice'>[user] starts removing [src]...</span>", \
							 "<span class='notice'>You start unfastening [src].</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 40))
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			user.visible_message("<span class='notice'>[user] unfastens [src].</span>", \
								 "<span class='notice'>You unfasten [src].</span>")
			var/obj/item/customplaque/CP = new (get_turf(user))
			CP.name = name
			CP.desc = desc
			CP.unengraved = unengraved
			CP.setDir(dir)
			qdel(src)
		return
	else if(istype(I, /obj/item/pen/fountain) && unengraved)
		var/namechoice = input(user, "Title this plaque.", "Plaque Customization")
		if(!namechoice)
			return
		var/descriptionchoice = input(user, "Engrave this plaque's text.", "Plaque Customization")
		if(!descriptionchoice)
			return
		//Make sure user is adjacent still
		if(!Adjacent(user))
			return
		name = namechoice
		desc = descriptionchoice
		unengraved = FALSE
	else
		return ..()

/obj/item/customplaque/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>", \
							 "<span class='notice'>You attach the sign to [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
		var/obj/structure/customplaque/S = new sign_path(T)
		S.name = name
		S.desc = desc
		S.unengraved = unengraved
		S.setDir(dir)
		qdel(src)

/obj/item/customplaque/Move(atom/new_loc, direct = 0)
	// pulling, throwing, or conveying a sign backing does not rotate it
	var/old_dir = dir
	. = ..()
	setDir(old_dir)

/obj/item/customplaque/attack_self(mob/user)
	. = ..()
	setDir(turn(dir, 90))