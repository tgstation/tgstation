/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
<<<<<<< HEAD
	icon_state = "iv_drip"
	anchored = 0
	density = 1
	var/mob/living/carbon/attached = null
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/weapon/reagent_containers/beaker = null


/obj/machinery/iv_drip/New()
	..()
	update_icon()

/obj/machinery/iv_drip/update_icon()
	if(attached)
		if(mode)
			icon_state = "injecting"
		else
			icon_state = "donating"
	else
		if(mode)
			icon_state = "injectidle"
		else
			icon_state = "donateidle"
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	overlays = null

	if(beaker)
<<<<<<< HEAD
		if(attached)
			add_overlay("beakeractive")
		else
			add_overlay("beakeridle")
		if(beaker.reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)
					filling.icon_state = "reagent0"
				if(10 to 24)
					filling.icon_state = "reagent10"
				if(25 to 49)
					filling.icon_state = "reagent25"
				if(50 to 74)
					filling.icon_state = "reagent50"
				if(75 to 79)
					filling.icon_state = "reagent75"
				if(80 to 90)
					filling.icon_state = "reagent80"
				if(91 to INFINITY)
					filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(beaker.reagents.reagent_list)
			add_overlay(filling)

/obj/machinery/iv_drip/MouseDrop(mob/living/target)
	if(!ishuman(usr) || !usr.canUseTopic(src,BE_CLOSE))
		return

	if(attached)
		visible_message("<span class='warning'>[attached] is detached from \the [src].</span>")
		attached = null
		update_icon()
		return

	if(!target.has_dna())
		usr << "<span class='danger'>The drip beeps: Warning, incompatible creature!</span>"
		return

	if(Adjacent(target) && usr.Adjacent(target))
		if(beaker)
			usr.visible_message("<span class='warning'>[usr] attaches \the [src] to \the [target].</span>", "<span class='notice'>You attach \the [src] to \the [target].</span>")
			attached = target
			START_PROCESSING(SSmachine, src)
			update_icon()
		else
			usr << "<span class='warning'>There's nothing attached to the IV drip!</span>"


/obj/machinery/iv_drip/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(beaker))
			user << "<span class='warning'>There is already a reagent container loaded!</span>"
			return
		if(!user.drop_item())
			return

		W.loc = src
		beaker = W
		user << "<span class='notice'>You attach \the [W] to \the [src].</span>"
		update_icon()
		return
=======
		var/datum/reagents/reagents = beaker.reagents
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, REAGENT)

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
	if(usr.incapacitated()) // Stop interacting with shit while dead pls
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
	if(iswrench(W))
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

		if(user.drop_item(W, src))
			src.beaker = W
			to_chat(user, "You attach \the [W] to \the [src].")
			investigation_log(I_CHEMS, "was loaded with \a [W] by [key_name(user)], containing [W.reagents.get_reagent_ids(1)]")
			src.update_icon()
			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	else
		return ..()


/obj/machinery/iv_drip/process()
<<<<<<< HEAD
	if(!attached)
		return PROCESS_KILL

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		attached << "<span class='userdanger'>The IV drip needle is ripped out of you!</span>"
		attached.apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
		attached = null
		update_icon()
		return PROCESS_KILL

	if(beaker)
		// Give blood
		if(mode)
			if(beaker.volume > 0)
				var/transfer_amount = 5
				if(istype(beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 10
				var/fraction = min(transfer_amount/beaker.volume, 1) //the fraction that is transfered of the total volume
				beaker.reagents.reaction(attached, INJECT, fraction,0) //make reagents reacts, but don't spam messages
				beaker.reagents.trans_to(attached, transfer_amount)
=======
	//set background = 1

	if(src.attached)
		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			src.attached:apply_damage(3, BRUTE, pick(LIMB_RIGHT_ARM, LIMB_LEFT_ARM))
			src.attached = null
			src.update_icon()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(src.beaker.volume > 0)
				var/transfer_amount = REAGENTS_METABOLISM
				if(beaker.reagents.reagent_list.len == 1 && beaker.reagents.has_reagent(BLOOD))
					// speed up transfer if the container has ONLY blood
					transfer_amount = 4
				src.beaker.reagents.trans_to(src.attached, transfer_amount)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5)) visible_message("\The [src] pings.")
				return

<<<<<<< HEAD
			// If the human is losing too much blood, beep.
			if(attached.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
				visible_message("\The [src] beeps loudly.")
				playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
			attached.transfer_blood_to(beaker, amount)
			update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(attached)
		visible_message("[attached] is detached from \the [src]")
		attached = null
		update_icon()
		return
	else if(beaker)
		eject_beaker(user)
	else
		toggle_mode()

/obj/machinery/iv_drip/verb/eject_beaker(mob/user)
	set category = "Object"
	set name = "Remove IV Container"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that!</span>"
		return

	if(usr.stat)
		return

	if(beaker)
		beaker.loc = get_turf(src)
		beaker = null
		update_icon()

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='warning'>You can't do that!</span>"
		return

	if(usr.stat)
		return

	mode = !mode
	usr << "The IV drip is now [mode ? "injecting" : "taking blood"]."
	update_icon()

/obj/machinery/iv_drip/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=loc) return

	usr << "The IV drip is [mode ? "injecting" : "taking blood"]."

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			usr << "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>"
		else
			usr << "<span class='notice'>Attached is an empty [beaker].</span>"
	else
		usr << "<span class='notice'>No chemicals are attached.</span>"

	usr << "<span class='notice'>[attached ? attached : "No one"] is attached.</span>"
=======
			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(M_NOCLONE in T.mutations)
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount(BLOOD) < BLOOD_VOLUME_SAFE) if(prob(5))
				visible_message("\The [src] beeps loudly.")

			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user as mob)
	if(isobserver(usr) || user.incapacitated())
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

	if(usr.isUnconscious())
		return

	mode = !mode
	to_chat(usr, "<span class='info'>The [src] is now [mode ? "injecting" : "taking blood"].</span>")

/obj/machinery/iv_drip/AltClick()
	if(!usr.isUnconscious() && Adjacent(usr))
		toggle_mode()
		return
	return ..()

/obj/machinery/iv_drip/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>\The [src] is [mode ? "injecting" : "taking blood"].</span>")
	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			to_chat(user, "<span class='info'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
		else
			to_chat(user, "<span class='info'>Attached is \an empty [beaker].</span>")
	else
		to_chat(user, "<span class='info'>No chemicals are attached.</span>")
	to_chat(user, "<span class='info'>It is attached to [attached ? attached : "no one"].</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
