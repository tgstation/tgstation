//**************************************************************
// Chemical Pack
//**************************************************************
//Icons are in chemical.dm, chempack.dmi (left), chempack.dmi (right), and back.dmi

//This item is designed to be a supplement to items which spray reagents, as well as the chemical mask.
//Currently, this applies to /obj/item/weapon/reagent_containers/spray and its childre, including the chemsprayer,
//as well as /obj/item/weapon/extinguisher and its children. When these items are empty, and attempt to spray,
//they will draw just enough reagents out of the chemical pack to make a full spray, after which they are again empty.
//This means that the sprayers serve more as a nozzle for the chemical pack, rather than the chemical pack serving as a
//refilling system.

//The verb set_fill() alters how many units are put into the chemical pack when filling it from a reagent dispenser, such as
//a water tank, fuel tank, or sink. It does not affect filling by handheld reagent containers, that is still governed by
//that reagent container's set_APTFT() verb.

//This item has a large volume, 1200u. As far as I know, the largest volume in the game for a reagent container so far.
//In order to prevent this from just being used as a gigantic beaker, it is not possible to pour reagents out of this
//item into other reagent containers, nor into machines, nor can it be used to force-feed someone the reagents. It cannot
//be loaded into chemistry dispensers or chemmasters, or anything else that takes beakers. It is possible to extract
//reagents from this container using a syringe, but frankly it would be faster to just fill four bluespace beakers rather
//than fill one of these and then extract all 1200u 15u at a time.

/obj/item/weapon/reagent_containers/chempack
	name = "chemical pack"
	desc = "Useful for the storage and transport of large volumes of chemicals. Can be used in conjunction with a wide range of chemical-dispensing devices."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chempack"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/chempack.dmi', "right_hand" = 'icons/mob/in-hand/right/chempack.dmi')
	flags = OPENCONTAINER|FPRINT
	slot_flags = SLOT_BACK
	throwforce = 3
	w_class = 4.0
	origin_tech = "bluespace=3;materials=3;engineering=5"
	var/safety = 0
	var/primed = 0
	var/stage = 0
	var/auxiliary = 0
	var/beaker = null
	volume = 1200
	possible_transfer_amounts = null
	var/possible_fill_amounts = list(5,10,15,25,30,50,100,200,500,1000)
	var/fill_amount = 10

/obj/item/weapon/reagent_containers/chempack/equipped(M as mob, back)
	var/mob/living/carbon/human/H = M
	if(H.back == src)
		if(H.wear_mask && istype(H.wear_mask, /obj/item/clothing/mask/chemmask))
			var/obj/item/clothing/mask/chemmask/C = H.wear_mask
			C.update_verbs()

/obj/item/weapon/reagent_containers/chempack/proc/can_use_verbs(mob/user)
	var/mob/living/carbon/human/M = user
	if (M.stat == DEAD)
		to_chat(user, "You can't do that while you're dead!")
		return 0
	else if (M.stat == UNCONSCIOUS)
		to_chat(user, "You must be conscious to do this!")
		return 0
	else if (M.handcuffed)
		to_chat(user, "You can't reach the controls while you're restrained!")
		return 0
	else
		return 1

/obj/item/weapon/reagent_containers/chempack/examine(mob/user)
	..()
	if(beaker)
		to_chat(user, "\icon[beaker] There is \a [beaker] in \the [src]'s auxiliary chamber.")
		to_chat(user, "It contains:")
		var/obj/item/weapon/reagent_containers/glass/B = beaker
		if(B.reagents.reagent_list.len)
			for(var/datum/reagent/R in B.reagents.reagent_list)
				to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>Nothing.</span>")

/obj/item/weapon/reagent_containers/chempack/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/chempack/update_icon()
	var/mob/living/carbon/human/H = loc
	overlays.len = 0

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/chempackfillings.dmi', src, "[initial(icon_state)]10")
		var/image/fillingback = image('icons/obj/chempackfillings.dmi', src, "[initial(icon_state)]10b")
		var/image/fillinghandr = image('icons/obj/chempackfillings.dmi', src, "[initial(icon_state)]10rh")
		var/image/fillinghandl = image('icons/obj/chempackfillings.dmi', src, "[initial(icon_state)]10lh")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "[initial(icon_state)]-10"
			if(10 to 24) 	filling.icon_state = "[initial(icon_state)]10"
			if(25 to 49)	filling.icon_state = "[initial(icon_state)]25"
			if(50 to 74)	filling.icon_state = "[initial(icon_state)]50"
			if(75 to 79)	filling.icon_state = "[initial(icon_state)]75"
			if(80 to 90)	filling.icon_state = "[initial(icon_state)]80"
			if(91 to INFINITY)	filling.icon_state = "[initial(icon_state)]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		fillingback.icon_state = "[filling.icon_state]b"
		fillinghandr.icon_state = "[filling.icon_state]rh"
		fillinghandl.icon_state = "[filling.icon_state]lh"

		fillingback.icon += mix_color_from_reagents(reagents.reagent_list)
		fillingback.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		fillinghandr.icon += mix_color_from_reagents(reagents.reagent_list)
		fillinghandr.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		fillinghandl.icon += mix_color_from_reagents(reagents.reagent_list)
		fillinghandl.alpha = mix_alpha_from_reagents(reagents.reagent_list)

		dynamic_overlay["[BACK_LAYER]"] = fillingback
		dynamic_overlay["[L_HAND_LAYER]"] = fillinghandl
		dynamic_overlay["[R_HAND_LAYER]"] = fillinghandr

		overlays += filling
		if (istype(loc,/mob/living/carbon/human)) //Needs to always update its own overlay, but only update mob overlays if it's actually on a mob.
			H.update_inv_back()
			H.update_inv_r_hand()
			H.update_inv_l_hand()

	else
		dynamic_overlay = null
		if (istype(loc,/mob/living/carbon/human))
			H.update_inv_back()
			H.update_inv_r_hand()
			H.update_inv_l_hand()

/obj/item/weapon/reagent_containers/chempack/verb/flush_tanks() //Completely empties the chempack's tanks, since you can't pour it onto the floor or into something else.
	set name = "Flush chemical tanks"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	src.reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You flush the contents of \the [src].</span>")
	src.update_icon()

obj/item/weapon/reagent_containers/chempack/verb/set_fill()
	set name = "Set fill amount"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Fill amount for this:","[src]") as null|anything in possible_fill_amounts
	if (N)
		fill_amount = N

/obj/item/weapon/reagent_containers/chempack/afterattack(atom/A as obj, mob/user as mob, var/adjacency_flag)
	if (istype(A, /obj/structure/reagent_dispensers) && adjacency_flag)
		var/tx_amount = transfer_sub(A, src, fill_amount, user)
		if (tx_amount > 0)
			to_chat(user, "<span class='notice'>You fill \the [src][src.is_full() ? " to the brim" : ""] with [tx_amount] units of the contents of \the [A].</span>")
			return

/obj/item/weapon/reagent_containers/chempack/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/glass))
		if(src.safety && auxiliary)
			if (stage)
				to_chat(user, "<span class='warning'>You need to secure the maintenance panel before you can insert a beaker!</span>")
				return
			if(user.type == /mob/living/silicon/robot) //Can't have silicons putting their beakers inside this.
				return
			if(src.beaker)
				to_chat(user, "There is already a beaker loaded into \the [src].")
				return
			else
				src.beaker = W
				user.drop_item(W, src)
				to_chat(user, "You add the beaker to \the [src]'s auxiliary chamber!")
				if(user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/chemmask))
					var/obj/item/clothing/mask/chemmask/C = user.wear_mask
					C.update_verbs()
				return 1
		else
			return

	if(iswrench(W))
		if (stage)
			to_chat(user, "<span class='warning'>You need to secure the maintenance panel before you can access the auxiliary chamber bolts!</span>")
			return
		if (!auxiliary && !src.beaker)
			auxiliary = 1
			to_chat(user, "You loosen the bolts of \the [src]'s auxiliary chamber.")
			return
		else if (!auxiliary)
			auxiliary = 1
			to_chat(user, "You loosen the bolts of \the [src]'s auxiliary chamber. The beaker can now be removed.")
			return
		else if (auxiliary && src.beaker)
			auxiliary = 0
			to_chat(user, "You tighten the bolts of \the [src]'s auxiliary chamber, securing the beaker in place.")
			return
		else
			auxiliary = 0
			to_chat(user, "You tighten the bolts of \the [src]'s auxiliary chamber.")
			return

	switch(stage) //Handles the different stages of overriding the chemical pack's safeties. This can be done completely with a standard set of tools.
		if(0)
			if(isscrewdriver(W) && user.back == src)
				to_chat(user, "<span class='warning'>You can't perform maintenance on \the [src] while you're wearing it!</span>")
				return
			else
				if (iscrowbar(W) && src.beaker && auxiliary)
					var/obj/item/weapon/reagent_containers/glass/B = beaker
					if ((user.get_inactive_hand() == src) || (user.back == src))
						B.loc = user.loc
					else
						B.loc = loc
					beaker = null
					to_chat(user, "You pry the beaker out of \the [src].")
					if(user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/chemmask))
						var/obj/item/clothing/mask/chemmask/C = user.wear_mask
						C.update_verbs()
					return
				else if (iscrowbar(W) && src.beaker && !auxiliary)
					to_chat(user, "<span class='warning'>The beaker is held tight by the bolts of the auxiliary chamber!</span>")
					return
				if (isscrewdriver(W) && src.beaker)
					to_chat(user, "<span class='warning'>You can't reach the maintenance panel with the beaker in the way!</span>")
					return
				else if (isscrewdriver(W))
					stage = 1
					slot_flags = null
					to_chat(user, "<span class='notice'>You unscrew the maintenance panel of \the [src].</span>")
					icon_state = "[initial(icon_state)]3"
					user.update_inv_r_hand() //These procs are to force the item's in_hand mob overlay to update to reflect the different stages of building. It was the only way I could find to accomplish this.
					user.update_inv_l_hand()
					return
		if(1)
			if (iscrowbar(W))
				if (primed == 0)
					stage = 2
				else
					stage = 3
				to_chat(user, "<span class='notice'>You pry open the maintenance panel of \the [src].</span>")
				icon_state = "[initial(icon_state)]2"
				user.update_inv_r_hand()
				user.update_inv_l_hand()
				return
			else if (isscrewdriver(W))
				stage = 0
				slot_flags = SLOT_BACK
				to_chat(user, "<span class='notice'>You secure the maintenance panel of \the [src].</span>")
				if (safety == 0)
					icon_state = "[initial(icon_state)]"
					user.update_inv_r_hand()
					user.update_inv_l_hand()
				else
					icon_state = "[initial(icon_state)]1"
					user.update_inv_r_hand()
					user.update_inv_l_hand()
				return
		if(2)
			if (iswirecutter(W))
				stage = 3
				primed = 1
				to_chat(user, "<span class='notice'>You reroute the connections within \the [src].</span>")
				return
			else if (iscrowbar(W))
				stage = 1
				to_chat(user, "<span class='notice'>You close the maintenance panel of \the [src].</span>")
				icon_state = "[initial(icon_state)]3"
				user.update_inv_r_hand()
				user.update_inv_l_hand()
				return
		if(3)
			if (ismultitool(W))
				if (safety == 0)
					to_chat(user, "<span class='warning'>You activate the manual safety override of \the [src]!</span>")
					to_chat(user, "<span class='warning'>The bolts for the auxiliary chamber of \the [src] have been exposed!</span>")
					safety = 1
				else if (safety == 1)
					to_chat(user, "<span class='notice'>You reactivate the safety restrictions of \the [src].</span>")
					to_chat(user, "<span class='notice'>The bolts for the auxiliary chamber of \the [src] are now hidden.</span>")
					safety = 0
				return
			else if (iscrowbar(W))
				stage = 1
				to_chat(user, "<span class='notice'>You close the maintenance panel of \the [src].</span>")
				icon_state = "[initial(icon_state)]3"
				user.update_inv_r_hand()
				user.update_inv_l_hand()
				return

/obj/item/weapon/reagent_containers/chempack/override
	safety = 1

/obj/item/weapon/reagent_containers/chempack/override/New()
	..()
	icon_state = "[initial(icon_state)]1"

/obj/item/weapon/reagent_containers/chempack/override/fully_loaded

/obj/item/weapon/reagent_containers/chempack/override/fully_loaded/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large
	var/obj/item/weapon/reagent_containers/glass/B = beaker
	B.reagents.add_reagent("creatine",100)
	reagents.add_reagent("kelotane", 125)
	reagents.add_reagent("dermaline", 125)
	reagents.add_reagent("tricordrazine", 125)
	reagents.add_reagent("anti_toxin", 210)
	reagents.add_reagent("bicaridine", 125)
	reagents.add_reagent("hyperzine", 22)
	reagents.add_reagent("imidazoline", 122)
	reagents.add_reagent("arithrazine", 32)
	reagents.add_reagent("hyronalin", 32)
	reagents.add_reagent("alkysine", 32)
	reagents.add_reagent("dexalinp", 125)
	reagents.add_reagent("leporazine", 125)