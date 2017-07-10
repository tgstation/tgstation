//NEVER USE THIS IT SUX	-PETETHEGOAT
//IT SUCKS A BIT LESS -GIACOM

/obj/item/weapon/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can be removed by the janitor."
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_color = "FFFFFF"
	item_state = "paintcan"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/paintleft = 10

/obj/item/weapon/paint/red
	name = "red paint"
	item_color = "C73232" //"FF0000"
	icon_state = "paint_red"

/obj/item/weapon/paint/green
	name = "green paint"
	item_color = "2A9C3B" //"00FF00"
	icon_state = "paint_green"

/obj/item/weapon/paint/blue
	name = "blue paint"
	item_color = "5998FF" //"0000FF"
	icon_state = "paint_blue"

/obj/item/weapon/paint/yellow
	name = "yellow paint"
	item_color = "CFB52B" //"FFFF00"
	icon_state = "paint_yellow"

/obj/item/weapon/paint/violet
	name = "violet paint"
	item_color = "AE4CCD" //"FF00FF"
	icon_state = "paint_violet"

/obj/item/weapon/paint/black
	name = "black paint"
	item_color = "333333"
	icon_state = "paint_black"

/obj/item/weapon/paint/white
	name = "white paint"
	item_color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/weapon/paint/anycolor
	gender= PLURAL
	name = "any color"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "violet", "black", "white")
	if ((user.get_active_held_item() != src || user.stat || user.restrained()))
		return
	switch(t1)
		if("red")
			item_color = "C73232"
		if("blue")
			item_color = "5998FF"
		if("green")
			item_color = "2A9C3B"
		if("yellow")
			item_color = "CFB52B"
		if("violet")
			item_color = "AE4CCD"
		if("white")
			item_color = "FFFFFF"
		if("black")
			item_color = "333333"
	icon_state = "paint_[t1]"
	add_fingerprint(user)


/obj/item/weapon/paint/afterattack(turf/target, mob/user, proximity)
	if(!proximity) return
	if(paintleft <= 0)
		icon_state = "paint_empty"
		return
	if(!istype(target) || isspaceturf(target))
		return
	var/newcolor = "#" + item_color
	target.add_atom_colour(newcolor, WASHABLE_COLOUR_PRIORITY)

/obj/item/weapon/paint/paint_remover
	gender =  PLURAL
	name = "paint remover"
	desc = "Used to remove color from floors and walls."
	icon_state = "paint_neutral"

/obj/item/weapon/paint/paint_remover/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target) && target.color != initial(target.color))
		target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
