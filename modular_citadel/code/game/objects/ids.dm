
//Polychromatic Knight Badge

/obj/item/card/id/knight
	var/id_color = "#00FF00" //defaults to green
	name = "knight badge"
	icon = 'modular_citadel/icons/obj/id.dmi'
	icon_state = "knight"
	desc = "A badge denoting the owner as a knight! It has a strip for swiping like an ID"

/obj/item/card/id/knight/update_label(newname, newjob)
	. = ..()
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s Knight Badge"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s Knight Badge"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/knight/update_icon()
	var/mutable_appearance/id_overlay = mutable_appearance('modular_citadel/icons/obj/id.dmi', "knight_overlay")

	if(id_color)
		id_overlay.color = id_color
	cut_overlays()

	add_overlay(id_overlay)

/obj/item/card/id/knight/AltClick(mob/living/user)
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(alert("Are you sure you want to recolor your id?", "Confirm Repaint", "Yes", "No") == "Yes")
		var/energy_color_input = input(usr,"","Choose Energy Color",id_color) as color|null
		if(energy_color_input)
			id_color = sanitize_hexcolor(energy_color_input, desired_format=6, include_crunch=1)
		update_icon()

/obj/item/card/id/knight/Initialize()
	. = ..()
	update_icon()

/obj/item/card/id/knight/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to recolor it.</span>")

//=================================================

/obj/item/emagrecharge
	name = "electromagnet charging device"
	desc = "A small cell with two prongs lazily jabbed into it. It looks like it's made for charging the small batteries found in electromagnetic devices."
	icon = 'icons/obj/module.dmi'
	icon_state = "cell_mini"
	item_flags = NOBLUDGEON
	var/uses = 5	//Dictates how many charges the device adds to compatible items

/obj/item/emagrecharge/examine(mob/user)
	. = ..()
	if(uses)
		to_chat(user, "<span class='notice'>It can add up to [uses] charges to compatible devices</span>")
	else
		to_chat(user, "<span class='warning'>It has a small, red, blinking light coming from inside of it. It's spent.</span>")

/obj/item/card/emag
	var/uses = 10

/obj/item/card/emag/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It has <b>[uses ? uses : "no"]</b> charges left.</span>")

/obj/item/card/emag/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/emagrecharge))
		var/obj/item/emagrecharge/ER = W
		if(ER.uses)
			uses += ER.uses
			to_chat(user, "<span class='notice'>You have added [ER.uses] charges to [src]. It now has [uses] charges.</span>")
			playsound(src, "sparks", 100, 1)
			ER.uses = 0
		else
			to_chat(user, "<span class='warning'>[ER] has no charges left.</span>")
		return
	. = ..()

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	if(!uses)
		user.visible_message("<span class='warning'>[src] emits a weak spark. It's burnt out!</span>")
		playsound(src, 'sound/effects/light_flicker.ogg', 100, 1)
		return
	. = ..()
	uses = max(uses - 1, 0)
	if(!uses)
		user.visible_message("<span class='warning'>[src] fizzles and sparks. It seems like it's out of charges.</span>")
		playsound(src, 'sound/effects/light_flicker.ogg', 100, 1)
	else if(uses <= 3)
		playsound(src, 'sound/effects/light_flicker.ogg', 30, 1)	//Tiiiiiiny warning sound to let ya know your emag's almost dead
