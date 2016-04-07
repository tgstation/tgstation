/obj/item/weapon/hatchet/tomahawk
	name = "tomahawk"
	desc = "A makeshift handaxe with a crude blade of broken glass."
	icon_state = "tomahawk"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 8.0
	var/w_condition = 1
	var/ismetal = 0
	var/ispipe = 0

/obj/item/weapon/hatchet/tomahawk/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/surgicaldrill))
		to_chat(user, "You begin drilling a hole through the handle of \the [src].")
		playsound(user, 'sound/machines/juicer.ogg', 50, 1)
		if(do_after(user, src, 30))
			to_chat(user, "You drill a hole through the handle of \the [src].")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				if(ismetal)
					var/obj/item/weapon/hatchet/tomahawk/metal/drilled/I = new (get_turf(user))
					user.put_in_hands(I)
				else
					var/obj/item/weapon/hatchet/tomahawk/drilled/I = new (get_turf(user))
					user.put_in_hands(I)
			else
				if(ismetal)
					new /obj/item/weapon/hatchet/tomahawk/metal/drilled(get_turf(src.loc))
				else
					new /obj/item/weapon/hatchet/tomahawk/drilled(get_turf(src.loc))
			qdel(src)

/obj/item/weapon/hatchet/tomahawk/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	var/parent_return = ..()
	degrade(user)
	return parent_return //Originally returned ..() itself, but I couldn't do that if I wanted the attack to appear before the break in the chat logs.

/obj/item/weapon/hatchet/tomahawk/proc/degrade(mob/user)
	if(ismetal)
		return
	var/deg_chance = 0
	switch(w_condition)
		if(1)
			if(rand(1,100) <=20)
				deg_chance = 1
		if(2)
			if(rand(1,100) <=30)
				deg_chance = 1
		if(3)
			if(rand(1,100) <=40)
				deg_chance = 1
		if(4)
			if(rand(1,100) <=50)
				deg_chance = 1
		if(5)
			if(rand(1,100) <=60)
				deg_chance = 1

	if(deg_chance)
		if(w_condition == 5)
			shatter(user)
		else
			w_condition++
	return

/obj/item/weapon/hatchet/tomahawk/proc/shatter(mob/user)
	if(ismetal)
		return
	to_chat(user, "<span class='warning'>\The [src]'s blade shatters!</span>")
	playsound(get_turf(user), "shatter", 50, 1)
	if(src.loc == user)
		user.drop_item(src, force_drop = 1)
		if(istype(src, /obj/item/weapon/hatchet/tomahawk/pipe))
			var/obj/item/weapon/hatchet/tomahawk/pipe/P = src
			if(P.current_blunt)
				to_chat(user, "The crushed [P.blunt_name] falls out of \the [src].")
			var/obj/item/weapon/broken_pipe_tomahawk/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			var/obj/item/weapon/wrench/I = new (get_turf(user))
			user.put_in_hands(I)
	else
		if(istype(src, /obj/item/weapon/hatchet/tomahawk/pipe))
			new /obj/item/weapon/broken_pipe_tomahawk(get_turf(src.loc))
		else
			new /obj/item/weapon/wrench(get_turf(src.loc))
	qdel(src)

/obj/item/weapon/hatchet/tomahawk/examine(mob/user)
	..()
	if(ismetal)
		return
	switch(w_condition)
		if(1)
			to_chat(user, "<span class='info'>\The [src] is in good condition.</span>")
		if(2)
			to_chat(user, "<span class='info'>\The [src] is in okay condition.</span>")
		if(3)
			to_chat(user, "<span class='info'>\The [src] is in poor condition.</span>")
		if(4)
			to_chat(user, "<span class='info'>\The [src] is in terrible condition.</span>")
		if(5)
			to_chat(user, "<span class='warning'>\The [src] looks like it could fall apart at any moment!</span>")

/obj/item/weapon/hatchet/tomahawk/drilled

/obj/item/weapon/hatchet/tomahawk/drilled/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>There is a hole drilled through the handle.</span>")

/obj/item/weapon/hatchet/tomahawk/drilled/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/ashtray))
		to_chat(user, "You affix \the [W] to the end of \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/hatchet/tomahawk/pipe/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/hatchet/tomahawk/pipe(get_turf(src.loc))
		qdel(src)
		qdel(W)

/obj/item/weapon/hatchet/tomahawk/metal
	ismetal = 1
	desc = "A well-made handaxe with a fine blade of strong metal."
	icon_state = "tomahawk_metal"

/obj/item/weapon/hatchet/tomahawk/metal/drilled

/obj/item/weapon/hatchet/tomahawk/metal/drilled/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>There is a hole drilled through the handle.</span>")

/obj/item/weapon/hatchet/tomahawk/metal/drilled/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/ashtray))
		to_chat(user, "You affix \the [W] to the end of \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/hatchet/tomahawk/pipe/metal/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/hatchet/tomahawk/pipe/metal(get_turf(src.loc))
		qdel(src)
		qdel(W)

/obj/item/weapon/hatchet/tomahawk/pipe
	name = "pipe tomahawk"
	desc = "Smokum peace pipe."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "pipe_tomahawk_glass"
	item_state = "pipe_tomahawk_glass"
	ispipe = 1
	var/current_blunt = null
	var/blunt_name = null
	var/is_lit = 0
	var/blunt_hook = null //the hook to call the burnout proc when the blunt is destroyed
	var/not_burned_out = 0 //prevent the going-out message from qdel()s other than the blunt's own qdel().
	slot_flags = SLOT_MASK

/obj/item/weapon/hatchet/tomahawk/pipe/Destroy()
	if(blunt_hook && current_blunt)
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = current_blunt
		B.on_destroyed.Remove()
	if(current_blunt)
		qdel(current_blunt)
		current_blunt = null
	..()

/obj/item/weapon/hatchet/tomahawk/pipe/examine(mob/user)
	..()
	if(current_blunt)
		to_chat(user, "<span class='info'>There is crushed [blunt_name] in the bowl.</span>")
	if(is_lit)
		to_chat(user, "<span class='info'>\The [src] is lit.</span>")

/obj/item/weapon/hatchet/tomahawk/pipe/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown))
		if(current_blunt)
			to_chat(user, "<span class='notice'>There is already crushed [blunt_name] in the bowl.</span>")
			return
		to_chat(user, "<span class='notice'>You crush \the [W] into \the [src].</span>")
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/rolled(src)
		blunt_hook = B.on_destroyed.Add(src, "burnout")
		B.inside_item = 1
		W.reagents.trans_to(B, (W.reagents.total_volume))
		B.update_brightness()
		B.name = name
		current_blunt = B
		blunt_name = "[W.name]"
		user.drop_item(W, force_drop = 1)
		qdel(W)
		verbs += /obj/item/weapon/hatchet/tomahawk/pipe/verb/empty_pipe
		return
	if(W.is_hot())
		if(current_blunt)
			if(is_lit)
				to_chat(user, "<span class='notice'>\The [src] is already lit.</span>")
				return
			var/obj/item/clothing/mask/cigarette/blunt/rolled/C = current_blunt
			C.name = name
			C.attackby(W,user)
			C.update_brightness()
			set_light(C.brightness_on)
			if(ismetal)
				icon_state = "pipe_tomahawk_metal_on"
				item_state = "pipe_tomahawk_metal_on"
			else
				icon_state = "pipe_tomahawk_glass_on"
				item_state = "pipe_tomahawk_glass_on"
			is_lit = 1
			if (istype(loc,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_wear_mask()
		else
			to_chat(user, "<span class='notice'>There's nothing in the bowl to light.</span>")

/obj/item/weapon/hatchet/tomahawk/pipe/attack_self(mob/user as mob)
	if(!is_lit)
		return
	if(current_blunt)
		var/obj/item/clothing/mask/cigarette/blunt/rolled/C = current_blunt
		C.lit = 0
		C.update_brightness()
		set_light(0)
		user.visible_message("<span class='notice'>[user] snuffs out \his [src].</span>","<span class='notice'>You snuff out \the [src].</span>")
		is_lit = 0
		if(ismetal)
			icon_state = "pipe_tomahawk_metal"
			item_state = "pipe_tomahawk_metal"
		else
			icon_state = "pipe_tomahawk_glass"
			item_state = "pipe_tomahawk_glass"

/obj/item/weapon/hatchet/tomahawk/pipe/verb/empty_pipe()
	set name = "Empty pipe"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(current_blunt)
		to_chat(usr, "<span class='notice'>You empty the crushed [blunt_name] out of \the [src].</span>")
		not_burned_out = 1
		qdel(current_blunt)
		current_blunt = null
		verbs -= /obj/item/weapon/hatchet/tomahawk/pipe/verb/empty_pipe

/obj/item/weapon/hatchet/tomahawk/pipe/proc/burnout()
	current_blunt = null
	set_light(0)
	is_lit = 0
	if(ismob(loc) && !not_burned_out)
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
	not_burned_out = 0
	if(ismetal)
		icon_state = "pipe_tomahawk_metal"
		item_state = "pipe_tomahawk_metal"
	else
		icon_state = "pipe_tomahawk_glass"
		item_state = "pipe_tomahawk_glass"
	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_mask()
	verbs -= /obj/item/weapon/hatchet/tomahawk/pipe/verb/empty_pipe

/obj/item/weapon/hatchet/tomahawk/pipe/metal
	ismetal = 1
	icon_state = "pipe_tomahawk_metal"
	item_state = "pipe_tomahawk_metal"

//BROKEN PIPE TOMAHAWK BEGIN

/obj/item/weapon/broken_pipe_tomahawk
	name = "broken pipe tomahawk"
	desc = "Its blade appears to have broken off. What poor craftsmanship."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "pipe_tomahawk_broken"
	item_state = "pipe_tomahawk_broken"
	hitsound = "sound/weapons/smash.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_MASK
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	starting_materials = list(MAT_IRON = 150)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "materials=1;engineering=2"
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")
	var/current_blunt = null
	var/blunt_name = null
	var/is_lit = 0
	var/blunt_hook = null
	var/not_burned_out = 0 //prevent the going-out message from qdel()s other than the blunt's own qdel().

/obj/item/weapon/broken_pipe_tomahawk/examine(mob/user)
	..()
	if(current_blunt)
		to_chat(user, "<span class='info'>There is crushed [blunt_name] in the bowl.</span>")
	if(is_lit)
		to_chat(user, "<span class='info'>\The [src] is lit.</span>")

/obj/item/weapon/broken_pipe_tomahawk/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/shard))
		to_chat(user, "You fasten \the [W] to \the [src].")
		if(current_blunt)
			to_chat(user, "The crushed [blunt_name] falls out in the process.")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/hatchet/tomahawk/pipe/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/hatchet/tomahawk/pipe(get_turf(src.loc))
		qdel(src)
		qdel(W)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown))
		if(current_blunt)
			to_chat(user, "<span class='notice'>There is already crushed [blunt_name] in the bowl.</span>")
			return
		to_chat(user, "<span class='notice'>You crush \the [W] into \the [src].</span>")
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/rolled(src)
		blunt_hook = B.on_destroyed.Add(src, "burnout")
		B.inside_item = 1
		W.reagents.trans_to(B, (W.reagents.total_volume))
		B.update_brightness()
		B.name = name
		current_blunt = B
		blunt_name = "[W.name]"
		user.drop_item(W, force_drop = 1)
		qdel(W)
		verbs += /obj/item/weapon/broken_pipe_tomahawk/verb/empty_pipe
		return
	if(W.is_hot())
		if(current_blunt)
			if(is_lit)
				to_chat(user, "<span class='notice'>\The [src] is already lit.</span>")
				return
			var/obj/item/clothing/mask/cigarette/blunt/rolled/C = current_blunt
			C.name = name
			C.attackby(W,user)
			C.update_brightness()
			set_light(C.brightness_on)
			icon_state = "pipe_tomahawk_broken_on"
			item_state = "pipe_tomahawk_broken_on"
			is_lit = 1
			if (istype(loc,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_wear_mask()
		else
			to_chat(user, "<span class='notice'>There's nothing in the bowl to light.</span>")

/obj/item/weapon/broken_pipe_tomahawk/attack_self(mob/user as mob)
	if(!is_lit)
		return
	if(current_blunt)
		var/obj/item/clothing/mask/cigarette/blunt/rolled/C = current_blunt
		C.lit = 0
		C.update_brightness()
		set_light(0)
		user.visible_message("<span class='notice'>[user] snuffs out \his [src].</span>","<span class='notice'>You snuff out \the [src].</span>")
		is_lit = 0
		icon_state = "pipe_tomahawk_broken"
		item_state = "pipe_tomahawk_broken"

/obj/item/weapon/broken_pipe_tomahawk/verb/empty_pipe()
	set name = "Empty pipe"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(current_blunt)
		to_chat(usr, "<span class='notice'>You empty the crushed [blunt_name] out of \the [src].</span>")
		not_burned_out = 1
		qdel(current_blunt)
		current_blunt = null
		verbs -= /obj/item/weapon/broken_pipe_tomahawk/verb/empty_pipe

/obj/item/weapon/broken_pipe_tomahawk/proc/burnout()
	current_blunt = null
	set_light(0)
	is_lit = 0
	if(ismob(loc) && !not_burned_out)
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
	not_burned_out = 0
	icon_state = "pipe_tomahawk_broken"
	item_state = "pipe_tomahawk_broken"
	if (istype(loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_mask()
	verbs -= /obj/item/weapon/broken_pipe_tomahawk/verb/empty_pipe

//BROKEN PIPE TOMAHAWK END