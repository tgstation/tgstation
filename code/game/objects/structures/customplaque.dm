/obj/structure/customplaque //This is a plaque you can craft with gold, then permanently engrave a title and description on, with a fountain pen.
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque, use a fancy pen to engrave it. It can be detatched from the wall with a wrench."
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	custom_materials = list(/datum/material/gold = 2000)
	max_integrity = 200 //Twice as durable as regular signs.
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	///Custom plaque structures and items both start "unengraved", once engraved with a fountain pen their text can't be altered again.
	var/engraved = FALSE 

/obj/item/customplaque
	icon = 'icons/obj/decals.dmi'
	icon_state = "blankplaque"
	name = "blank plaque"
	desc = "A blank plaque, use a fancy pen to engrave it. It can be placed on a wall."
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/gold = 2000)
	max_integrity = 200
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	///This points the item to make the proper structure when placed on a wall.
	var/plaque_path = /obj/structure/customplaque
	///Custom plaque structures and items both start "unengraved", once engraved with a fountain pen their text can't be altered again.
	var/engraved = FALSE

/obj/structure/customplaque/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/customplaque/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)

/obj/structure/customplaque/wrench_act(mob/living/user, obj/item/wrench/I)
	. = ..()
	user.visible_message("<span class='notice'>[user] starts removing [src]...</span>", \
						 "<span class='notice'>You start unfastening [src].</span>")
	I.play_tool_sound(src)
	if(I.use_tool(src, user, 40))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		user.visible_message("<span class='notice'>[user] unfastens [src].</span>", \
							 "<span class='notice'>You unfasten [src].</span>")
		var/obj/item/customplaque/CP = new (get_turf(user))
		if(engraved) //If it's still just a basic unengraved plaque, we can (and should) skip some of the below variable transfers.
			CP.name = name //Copy over the plaque structure variables to the plaque item we're creating when we unwrench it.
			CP.desc = desc
			CP.engraved = engraved
		CP.obj_integrity = obj_integrity
		CP.setDir(dir)
		qdel(src) //The plaque structure on the wall goes poof and only the plaque item from unwrenching remains.
	return TRUE

/obj/structure/customplaque/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen/fountain))
		if(engraved)
			to_chat(user, "<span class='warning'>This plaque has already been engraved.</span>")
			return
		var/namechoice = input(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization")
		if(!namechoice)
			return
		var/descriptionchoice = input(user, "Engrave this plaque's text.", "Plaque Customization")
		if(!descriptionchoice)
			return
		if(!Adjacent(user)) //Make sure user is adjacent still
			to_chat(user, "<span class='warning'>You need to stand next to the plaque to engrave it!</span>")
			return
		user.visible_message("<span class='notice'>[user] begins engraving [src].</span>", \
							 "<span class='notice'>You begin engraving [src].</span>")
		if(!do_after(user, 40, target = src)) //This spits out a visible message that somebody is engraving a plaque, then has a delay.
			return
		name = "\improper [namechoice]" //We want improper here so examine doesn't get weird if somebody capitalizes the plaque title.
		desc = "The plaque reads: '[descriptionchoice]'"
		engraved = TRUE //The plaque now has a name, description, and can't be altered again.
		user.visible_message("<span class='notice'>[user] engraves [src].</span>", \
							 "<span class='notice'>You engrave [src].</span>")
		return
	if(istype(I, /obj/item/pen))
		if(engraved)
			to_chat(user, "<span class='warning'>This plaque has already been engraved, and your pen isn't fancy enough to engrave it anyway! Find a fountain pen.</span>")
			return
		to_chat(user, "<span class='warning'>Your pen isn't fancy enough to engrave this! Find a fountain pen.</span>") //Go steal the Curator's.
		return
	return ..()

/obj/item/customplaque/attackby(obj/item/I, mob/user, params) //Same as part of the above, except for the item in hand instead of the structure.
	if(istype(I, /obj/item/pen/fountain))
		if(engraved)
			to_chat(user, "<span class='warning'>This plaque has already been engraved.</span>")
			return
		var/namechoice = input(user, "Title this plaque. (e.g. 'Best HoP Award', 'Great Ashwalker War Memorial')", "Plaque Customization")
		if(!namechoice)
			return
		var/descriptionchoice = input(user, "Engrave this plaque's text.", "Plaque Customization")
		if(!descriptionchoice)
			return
		if(!Adjacent(user)) //Make sure user is adjacent still
			to_chat(user, "<span class='warning'>You need to stand next to the plaque to engrave it!</span>")
			return
		user.visible_message("<span class='notice'>[user] begins engraving [src].</span>", \
							 "<span class='notice'>You begin engraving [src].</span>")
		if(!do_after(user, 40, target = src)) //This spits out a visible message that somebody is engraving a plaque, then has a delay.
			return
		name = "\improper [namechoice]" //We want improper here so examine doesn't get weird if somebody capitalizes the plaque title.
		desc = "The plaque reads: '[descriptionchoice]'"
		engraved = TRUE //The plaque now has a name, description, and can't be altered again.
		user.visible_message("<span class='notice'>[user] engraves [src].</span>", \
							 "<span class='notice'>You engrave [src].</span>")
		return
	if(istype(I, /obj/item/pen))
		if(engraved)
			to_chat(user, "<span class='warning'>This plaque has already been engraved, and your pen isn't fancy enough to engrave it anyway! Find a fountain pen.</span>")
			return
		to_chat(user, "<span class='warning'>Your pen isn't fancy enough to engrave this! Find a fountain pen.</span>") //Go steal the Curator's.
		return
	return ..()

/obj/item/customplaque/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!iswallturf(target) || !proximity)
		return
	var/turf/T = target
	user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>", \
						 "<span class='notice'>You attach [src] to [T].</span>")
	playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
	var/obj/structure/customplaque/S = new plaque_path(T)
	if(engraved)
		S.name = name
		S.desc = desc
		S.engraved = engraved
	S.obj_integrity = obj_integrity
	S.setDir(dir)
	qdel(src)
	return ..()
