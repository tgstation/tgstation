/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 100
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/buildable_sign = 1 //unwrenchable
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/is_editable = FALSE //This determines if you can select this sign type when using a pen on a sign backing. False by default, set to true per sign subtype to override.
	var/sign_change_name = "Sign - Blank" //sign_change_name is used to make nice looking, alphebetized and categorized names when you use a pen on a sign backing.

/obj/structure/sign/basic
	name = "blank sign"
	desc = "How can signs be real if our eyes aren't real? Use a pen to change the decal."
	icon_state = "backing"

/obj/structure/sign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/sign/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)

GLOBAL_VAR(editable_sign_types)
/obj/structure/sign/proc/populate_editable_sign_types() //The first time a pen is used on any sign, this populates the above, a global list of all the signs that you can set a sign backing to with a pen.
	GLOB.editable_sign_types = list()
	for(var/s in subtypesof(/obj/structure/sign))
		var/obj/structure/sign/potential_sign = s
		if(!initial(potential_sign.is_editable))
			continue
		GLOB.editable_sign_types[initial(potential_sign.sign_change_name)] = potential_sign
	GLOB.editable_sign_types = sortList(GLOB.editable_sign_types) //Alphabetizes the results.

/obj/structure/sign/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && buildable_sign)
		user.visible_message("<span class='notice'>[user] starts removing [src]...</span>", \
							 "<span class='notice'>You start unfastening [src].</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 40))
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			user.visible_message("<span class='notice'>[user] unfastens [src].</span>", \
								 "<span class='notice'>You unfasten [src].</span>")
			var/obj/item/sign_backing/SB = new (get_turf(user))
			SB.icon_state = icon_state //Copy over the sign structure variables to the sign item we're creating when we unwrench a sign.
			SB.sign_path = type
			SB.setDir(dir)
			qdel(src) //The sign structure on the wall goes poof and only the sign item from unwrenching remains.
		return
	else if(istype(I, /obj/item/pen) && is_editable)
		if(!length(GLOB.editable_sign_types))
			populate_editable_sign_types()
			if(!length(GLOB.editable_sign_types))
				CRASH("GLOB.editable_sign_types failed to populate")
		var/choice = input(user, "Select a sign type.", "Sign Customization") as null|anything in GLOB.editable_sign_types
		if(!choice)
			return
		user.visible_message("<span class='notice'>[user] begins changing [src].</span>", \
							 "<span class='notice'>You begin changing [src].</span>")
		if(do_after(user, 40, target = src)) //Small delay for changing signs instead of it being instant, so somebody could be shoved or stunned to prevent them from doing so.
			var/sign_type = GLOB.editable_sign_types[choice]
			if(!Adjacent(user)) //Make sure user is adjacent still.
				return
			if(!sign_type)
				return
			//It's import to clone the pixel layout information
			//Otherwise signs revert to being on the turf and
			//move jarringly
			var/obj/structure/sign/newsign = new sign_type(get_turf(src))
			newsign.pixel_x = pixel_x
			newsign.pixel_y = pixel_y
			qdel(src)
			user.visible_message("<span class='notice'>[user] finishes changing the sign.</span>", \
						 "<span class='notice'>You finish changing the sign.</span>")
	else
		return ..()

/obj/item/sign_backing
	name = "sign backing"
	desc = "A plastic sign with adhesive backing. Use a pen to change the decal once installed."
	icon = 'icons/obj/decals.dmi'
	icon_state = "backing"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/plastic = 2000)
	resistance_flags = FLAMMABLE
	var/sign_path = /obj/structure/sign/basic //The type of sign structure that will be created when placed on a turf, the default looks just like a sign backing item.

/obj/item/sign_backing/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>", \
							 "<span class='notice'>You attach the sign to [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
		var/obj/structure/sign/S = new sign_path(T)
		S.setDir(dir)
		qdel(src)

/obj/item/sign_backing/Move(atom/new_loc, direct = 0)
	// pulling, throwing, or conveying a sign backing does not rotate it
	var/old_dir = dir
	. = ..()
	setDir(old_dir)

/obj/item/sign_backing/attack_self(mob/user)
	. = ..()
	setDir(turn(dir, 90))

/obj/structure/sign/nanotrasen
	name = "\improper Nanotrasen logo sign"
	sign_change_name = "Corporate Logo - Nanotrasen"
	desc = "A sign with the Nanotrasen logo on it. Glory to Nanotrasen!"
	icon_state = "nanotrasen"
	is_editable = TRUE

/obj/structure/sign/logo
	name = "\improper Nanotrasen logo sign"
	desc = "The Nanotrasen corporate logo."
	icon_state = "nanotrasen_sign1"
