/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = 0
	density = 1
	var/mob/living/carbon/human/attached = null
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/weapon/reagent_containers/beaker = null


/obj/machinery/iv_drip/New()
	..()
	update_icon()

/obj/machinery/iv_drip/update_icon()
	if(src.attached)
		if(mode)
			icon_state = "injecting"
		else
			icon_state = "donating"
	else
		if(mode)
			icon_state = "injectidle"
		else
			icon_state = "donateidle"

	overlays = null

	if(beaker)
		if(attached)
			overlays += "beakeractive"
		else
			overlays += "beakeridle"
		if(beaker.reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(beaker.reagents.reagent_list)
			overlays += filling

/obj/machinery/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()

	if(!ishuman(over_object))
		usr << "<span class='warning'>The drip beeps: Warning, human patients only!</span>"

	if(attached)
		visible_message("[src.attached] is detached from \the [src]")
		src.attached = null
		src.update_icon()
		return

	if(in_range(src, usr) && ishuman(over_object) && get_dist(over_object, src) <= 1)
		if(src.beaker)
			visible_message("[usr] attaches \the [src] to \the [over_object].")
			src.attached = over_object
			src.update_icon()
		else
			usr << "There's nothing attached to the IV drip!"


/obj/machinery/iv_drip/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(src.beaker))
			user << "There is already a reagent container loaded!"
			return

		user.drop_item()
		W.loc = src
		src.beaker = W
		user << "You attach \the [W] to \the [src]."
		src.update_icon()
		return
	else
		return ..()


/obj/machinery/iv_drip/process()
	if(src.attached)

		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			attached << "<span class='warning'>The IV drip needle is ripped out of you, doesn't that hurt?</span>"
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
				src.beaker.reagents.reaction(src.attached, INGEST, 0,0) //make reagents reacts, but don't spam messages
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
			if(NOCLONE in T.mutations)
				return

			if(NOBLOOD in T.dna.species.specflags)
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_SAFE) if(prob(5))
				visible_message("\The [src] beeps loudly.")
				playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/machinery/iv_drip/attack_hand(mob/user)
	if(src.attached)
		visible_message("[src.attached] is detached from \the [src]")
		src.attached = null
		update_icon()
		return
	else if(src.beaker)
		eject_beaker(user)
	else
		toggle_mode()

/obj/machinery/iv_drip/verb/eject_beaker(mob/user)
	set category = "Object"
	set name = "Remove IV Container"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='notice'>You can't do that.</span>"
		return

	if(usr.stat)
		return

	if(src.beaker)
		src.beaker.loc = get_turf(src)
		src.beaker = null
		update_icon()

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		usr << "<span class='notice'>You can't do that.</span>"
		return

	if(usr.stat)
		return

	mode = !mode
	usr << "The IV drip is now [mode ? "injecting" : "taking blood"]."
	update_icon()

/obj/machinery/iv_drip/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return

	usr << "The IV drip is [mode ? "injecting" : "taking blood"]."

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			usr << "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>"
		else
			usr << "<span class='notice'>Attached is an empty [beaker].</span>"
	else
		usr << "<span class='notice'>No chemicals are attached.</span>"

	usr << "<span class='notice'>[attached ? attached : "No one"] is attached.</span>"