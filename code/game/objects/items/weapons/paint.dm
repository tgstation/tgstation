//NEVER USE THIS IT SUX	-PETETHEGOAT
<<<<<<< HEAD
//IT SUCKS A BIT LESS -GIACOM

/obj/item/weapon/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can not be removed by the janitor."
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_color = "FFFFFF"
	item_state = "paintcan"
	w_class = 3
	burn_state = FLAMMABLE
	burntime = 5
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
=======

var/global/list/cached_icons = list()

/obj/item/weapon/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	melt_temperature = MELTPOINT_STEEL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = FPRINT | OPENCONTAINER
	var/paint_type = ""

/obj/item/weapon/reagent_containers/glass/paint/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is taking \his hand and eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (TOXLOSS|OXYLOSS)

/obj/item/weapon/reagent_containers/glass/paint/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/paint/afterattack(turf/simulated/target, mob/user , flag)
	if(!flag || user.stat)
		return ..()

	if(istype(target) && reagents.total_volume > 5)
		for(var/mob/O in viewers(user))
			O.show_message("<span class='warning'>\The [target] has been splashed with something by [user]!</span>", 1)
		spawn(5)
			reagents.reaction(target, TOUCH)
			reagents.remove_any(5)
	else
		return ..()

/obj/item/weapon/reagent_containers/glass/paint/New()
	if(paint_type == "remover")
		name = "paint remover bucket"
	else if(paint_type && length(paint_type) > 0)
		name = paint_type + " " + name
	..()
	reagents.add_reagent("paint_[paint_type]", volume)

/obj/item/weapon/reagent_containers/glass/paint/red
	icon_state = "paint_red"
	paint_type = "red"

/obj/item/weapon/reagent_containers/glass/paint/green
	icon_state = "paint_green"
	paint_type = "green"

/obj/item/weapon/reagent_containers/glass/paint/blue
	icon_state = "paint_blue"
	paint_type = "blue"

/obj/item/weapon/reagent_containers/glass/paint/yellow
	icon_state = "paint_yellow"
	paint_type = "yellow"

/obj/item/weapon/reagent_containers/glass/paint/violet
	icon_state = "paint_violet"
	paint_type = "violet"

/obj/item/weapon/reagent_containers/glass/paint/black
	icon_state = "paint_black"
	paint_type = "black"

/obj/item/weapon/reagent_containers/glass/paint/white
	icon_state = "paint_white"
	paint_type = "white"

/obj/item/weapon/reagent_containers/glass/paint/remover
	paint_type = "remover"
/*
/obj/item/weapon/paint
	name = "Paint Can"
	desc = "Used to recolor floors and walls. Can not be removed by the janitor."
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	color = "FFFFFF"
	item_state = "paintcan"
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/paint/red
	name = "Red paint"
	color = "FF0000"
	icon_state = "paint_red"

/obj/item/weapon/paint/green
	name = "Green paint"
	color = "00FF00"
	icon_state = "paint_green"

/obj/item/weapon/paint/blue
	name = "Blue paint"
	color = "0000FF"
	icon_state = "paint_blue"

/obj/item/weapon/paint/yellow
	name = "Yellow paint"
	color = "FFFF00"
	icon_state = "paint_yellow"

/obj/item/weapon/paint/violet
	name = "Violet paint"
	color = "FF00FF"
	icon_state = "paint_violet"

/obj/item/weapon/paint/black
	name = "Black paint"
	color = "333333"
	icon_state = "paint_black"

/obj/item/weapon/paint/white
	name = "White paint"
	color = "FFFFFF"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	icon_state = "paint_white"


/obj/item/weapon/paint/anycolor
<<<<<<< HEAD
	gender= PLURAL
	name = "any color"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "violet", "black", "white")
	if ((user.get_active_hand() != src || user.stat || user.restrained()))
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
	if(!istype(target) || istype(target, /turf/open/space))
		return
	target.color = "#" + item_color

/obj/item/weapon/paint/paint_remover
	gender =  PLURAL
	name = "paint remover"
	icon_state = "paint_neutral"

/obj/item/weapon/paint/paint_remover/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target) && target.color != initial(target.color))
		target.color = initial(target.color)
=======
	name = "Any color"
	icon_state = "paint_neutral"

	attack_self(mob/user as mob)
		var/t1 = input(user, "Please select a color:", "Locking Computer", null) in list( "red", "blue", "green", "yellow", "black", "white")
		if ((user.get_active_hand() != src || user.stat || user.restrained()))
			return
		switch(t1)
			if("red")
				color = "FF0000"
			if("blue")
				color = "0000FF"
			if("green")
				color = "00FF00"
			if("yellow")
				color = "FFFF00"
			if("violet")
				color = "FF00FF"
			if("white")
				color = "FFFFFF"
			if("black")
				color = "333333"
		icon_state = "paint_[t1]"
		add_fingerprint(user)
		return


/obj/item/weapon/paint/afterattack(turf/target, mob/user as mob)
	if(!istype(target) || istype(target, /turf/space))
		return
	var/ind = "[initial(target.icon)][color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(initial(target.icon))
		overlay.Blend("#[color]",ICON_MULTIPLY)
		overlay.SetIntensity(1.4)
		target.icon = overlay
		cached_icons[ind] = target.icon
	else
		target.icon = cached_icons[ind]
	return

/obj/item/weapon/paint/paint_remover
	name = "Paint remover"
	icon_state = "paint_neutral"

	afterattack(turf/target, mob/user as mob)
		if(istype(target) && target.icon != initial(target.icon))
			target.icon = initial(target.icon)
		return
*/

datum/reagent/paint
	name = "Paint"
	id = "paint_"
	description = "Floor paint is used to color floor tiles."
	reagent_state = 2
	color = "#808080"

	reaction_turf(var/turf/T, var/volume)
		if(!istype(T) || istype(T, /turf/space))
			return
		var/ind = "[initial(T.icon)][color]"
		if(!cached_icons[ind])
			var/icon/overlay = new/icon(initial(T.icon))
			overlay.Blend(color,ICON_MULTIPLY)
			overlay.SetIntensity(1.4)
			T.icon = overlay
			cached_icons[ind] = T.icon
		else
			T.icon = cached_icons[ind]
		return

	red
		name = "Red Paint"
		id = "paint_red"
		color = "#FF0000"

	green
		name = "Green Paint"
		color = "#00FF00"
		id = "paint_green"

	blue
		name = "Blue Paint"
		color = "#0000FF"
		id = "paint_blue"

	yellow
		name = "Yellow Paint"
		color = "#FFFF00"
		id = "paint_yellow"

	violet
		name = "Violet Paint"
		color = "#FF00FF"
		id = "paint_violet"

	black
		name = "Black Paint"
		color = "#333333"
		id = "paint_black"

	white
		name = "White Paint"
		color = "#FFFFFF"
		id = "paint_white"

datum/reagent/paint_remover
	name = "Paint Remover"
	id = "paint_remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = 2
	color = "#808080"

	reaction_turf(var/turf/T, var/volume)
		if(istype(T) && T.icon != initial(T.icon))
			T.icon = initial(T.icon)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
