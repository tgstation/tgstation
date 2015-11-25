/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = 0
	density = 0 //Tired of these blocking up the station


/obj/machinery/iv_drip/var/mob/living/carbon/human/attached = null
/obj/machinery/iv_drip/var/mode = 1 // 1 is injecting, 0 is taking blood.
/obj/machinery/iv_drip/var/obj/item/weapon/reagent_containers/beaker = null

/obj/machinery/iv_drip/update_icon()
	if(src.attached)
		icon_state = "hooked"
	else
		icon_state = ""

	overlays = null

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

/obj/machinery/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()
	if(isobserver(usr)) return
	if(usr.stat) // Stop interacting with shit while dead pls
		return
	if(isanimal(usr))
		return
	if(attached)
		visible_message("[src.attached] is detached from \the [src]")
		src.attached = null
		src.update_icon()
		return

	if(in_range(src, usr) && ishuman(over_object) && get_dist(over_object, src) <= 1)
		var/mob/living/carbon/human/H = over_object
		if(H.species && (H.species.chem_flags & NO_INJECT))
			H.visible_message("<span class='warning'>[usr] struggles to place the IV into [H] but fails.</span>","<span class='notice'>[usr] tries to place the IV into your arm but is unable to.</span>")
			return
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		src.attached = over_object
		src.update_icon()

/obj/machinery/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isobserver(user)) return
	if(user.stat)
		return
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal,get_turf(src))
		M.amount = 2
		if(src.beaker)
			src.beaker.loc = get_turf(src)
			src.beaker = null
		to_chat(user, "<span class='notice'>You dismantle \the [name].</span>")
		qdel(src)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return

		user.drop_item(W, src)
		src.beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		src.update_icon()
		return
	else
		return ..()


/obj/machinery/iv_drip/process()
	//set background = 1

	if(src.attached)
		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			src.attached:apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
			src.attached = null
			src.update_icon()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(src.beaker.volume > 0)
				var/transfer_amount = REAGENTS_METABOLISM
				if(istype(src.beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 4
				src.beaker.reagents.trans_to(src.attached, transfer_amount)
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5)) visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(M_NOCLONE in T.mutations)
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_SAFE) if(prob(5))
				visible_message("\The [src] beeps loudly.")

			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user as mob)
	if(isobserver(usr) || user.stat)
		return
	if(attached)
		visible_message("[src.attached] is detached from \the [src].")
		src.attached = null
		src.update_icon()
	else if(src.beaker)
		src.beaker.loc = get_turf(src)
		src.beaker = null
		update_icon()
	else
		return ..()


/obj/machinery/iv_drip/verb/toggle_mode()
	set name = "Toggle Mode"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(usr.stat || (usr.status_flags & FAKEDEATH))
		return

	mode = !mode
	to_chat(usr, "The [src] is now [mode ? "injecting" : "taking blood"].")

/obj/machinery/iv_drip/examine(mob/user)
	..()
	to_chat(user, "The [src] is [mode ? "injecting" : "taking blood"].")
	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			to_chat(user, "<span class='info'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
		else
			to_chat(user, "<span class='info'>Attached is \an empty [beaker].</span>")
	else
		to_chat(user, "<span class='info'>No chemicals are attached.</span>")
	to_chat(user, "<span class='info'>It is attached to [attached ? attached : "no one"].</span>")
