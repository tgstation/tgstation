/obj/structure/customplaque //This is a plaque you can craft with gold, then permanently engrave a title and description on, with a fountain pen.
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque. Use a fancy pen to engrave it, use a wrench to detatch it from the wall."
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 200 //Twice as durable as regular signs.
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/unengraved = TRUE //Custom plaque structures and items both start "unengraved", once engraved with a fountain pen their text can't be altered again.

/obj/item/customplaque
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque. Place it on a wall and use a fancy pen to engrave it, use a wrench to detatch it from the wall."
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/gold = 2000)
	var/plaque_path = /obj/structure/customplaque //This points the item to make the proper structure when placed on a wall.
	var/unengraved = TRUE

/obj/structure/customplaque/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/smash.ogg', 80, TRUE)
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
			CP.name = name //Copy over the plaque structure variables to the plaque item we're creating when we unwrench it.
			CP.desc = desc
			CP.unengraved = unengraved
			CP.setDir(dir)
			qdel(src) //The plaque structure on the wall goes poof and only the plaque item from unwrenching remains.
		return
	else if(istype(I, /obj/item/pen/fountain) && unengraved)
		var/namechoice = input(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization")
		if(!namechoice)
			return
		var/descriptionchoice = input(user, "Engrave this plaque's text.", "Plaque Customization")
		if(!descriptionchoice)
			return
		user.visible_message("<span class='notice'>[user] begins engraving [src].</span>", \
							 "<span class='notice'>You begin engraving [src].</span>")
		if(do_after(user, 40, target = src)) //This spits out a visible message that somebody is engraving a plaque, then has a delay.
			if(!Adjacent(user)) //Make sure user is adjacent still
				to_chat(user, "<span class='warning'>You have to stand next to the plaque to engrave it!</span>")
				return
			name = "\improper [namechoice]" //We want improper here so examine doesn't get weird if somebody capitalizes the plaque title.
			desc = "The plaque reads: '[descriptionchoice]'"
			unengraved = FALSE //The plaque now has a name, description, and can't be altered again.
			user.visible_message("<span class='notice'>[user] engraves [src].</span>", \
								 "<span class='notice'>You engrave [src].</span>")
	else if(istype(I, /obj/item/pen) && unengraved)
		to_chat(user, "<span class='warning'>Your pen isn't fancy enough to engrave this! Find a fountain pen.</span>") //Go steal the Curator's.
	else
		return ..()

/obj/item/customplaque/attackby(obj/item/I, mob/user, params) //Same as part of the above, except for the item in hand instead of the structure.
	if(istype(I, /obj/item/pen/fountain) && unengraved)
		var/namechoice = input(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization")
		if(!namechoice)
			return
		var/descriptionchoice = input(user, "Engrave this plaque's text.", "Plaque Customization")
		if(!descriptionchoice)
			return
		user.visible_message("<span class='notice'>[user] begins engraving [src].</span>", \
							 "<span class='notice'>You begin engraving [src].</span>")
		if(do_after(user, 40, target = src))
			name = "\improper [namechoice]"
			desc = "The plaque reads: '[descriptionchoice]'"
			unengraved = FALSE
			user.visible_message("<span class='notice'>[user] engraves [src].</span>", \
								 "<span class='notice'>You engrave [src].</span>")
	else if(istype(I, /obj/item/pen) && unengraved)
		to_chat(user, "<span class='warning'>Your pen isn't fancy enough to engrave this! Find a fountain pen.</span>")

/obj/item/customplaque/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>", \
							 "<span class='notice'>You attach [src] to [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
		var/obj/structure/customplaque/S = new plaque_path(T)
		S.name = name
		S.desc = desc
		S.unengraved = unengraved
		S.setDir(dir)
		qdel(src)

/obj/item/customplaque/Move(atom/new_loc, direct = 0)
	// Pulling, throwing, or conveying a plaque does not rotate it.
	var/old_dir = dir
	. = ..()
	setDir(old_dir)

/obj/item/customplaque/attack_self(mob/user)
	. = ..()
	setDir(turn(dir, 90))
	