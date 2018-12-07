#define IV_TAKING 0
#define IV_INJECTING 1

/obj/machinery/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/atom/movable/attached = null
	var/mode = IV_INJECTING
	var/obj/item/reagent_containers/beaker = null
	var/static/list/drip_containers = typecacheof(list(/obj/item/reagent_containers/blood,
									/obj/item/reagent_containers/food,
									/obj/item/reagent_containers/glass))
	var/mob/lastuser
	var/lastuserckey

/obj/machinery/iv_drip/Initialize()
	. = ..()
	update_icon()

/obj/machinery/iv_drip/Destroy()
	attached = null
	QDEL_NULL(beaker)
	return ..()

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

	cut_overlays()

	if(beaker)
		if(attached)
			add_overlay("beakeractive")
		else
			add_overlay("beakeridle")
		if(beaker.reagents.total_volume)
			var/mutable_appearance/filling_overlay = mutable_appearance('icons/obj/iv_drip.dmi', "reagent")

			var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)
					filling_overlay.icon_state = "reagent0"
				if(10 to 24)
					filling_overlay.icon_state = "reagent10"
				if(25 to 49)
					filling_overlay.icon_state = "reagent25"
				if(50 to 74)
					filling_overlay.icon_state = "reagent50"
				if(75 to 79)
					filling_overlay.icon_state = "reagent75"
				if(80 to 90)
					filling_overlay.icon_state = "reagent80"
				if(91 to INFINITY)
					filling_overlay.icon_state = "reagent100"

			filling_overlay.color = list("#0000", "#0000", "#0000", "#000f", mix_color_from_reagents(beaker.reagents.reagent_list))
			add_overlay(filling_overlay)

/obj/machinery/iv_drip/MouseDrop(atom/movable/target)
	. = ..()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return

	var/mob/living/carbon/M
	if(istype(target,/mob/living))
		M = target
		if(!M.has_dna())
			to_chat(usr, "<span class='danger'>The drip beeps: Warning, incompatible creature!</span>")
			return
	if(!M && !target.is_injectable() && !(M && M.can_inject()))
		return

	if(attached)
		visible_message("<span class='warning'>[attached] is detached from [src].</span>")
		attached = null
		update_icon()
		return

	if(Adjacent(target) && usr.Adjacent(target))
		if(beaker)
			usr.visible_message("<span class='warning'>[usr] attaches [src] to [target].</span>", "<span class='notice'>You attach [src] to [target].</span>")
			attached = target
			START_PROCESSING(SSmachines, src)
			update_icon()
			lastuser = usr
			if(usr.ckey)
				lastuserckey = usr.ckey
		else
			to_chat(usr, "<span class='warning'>There's nothing attached to the IV drip!</span>")


/obj/machinery/iv_drip/attackby(obj/item/W, mob/user, params)
	if(is_type_in_typecache(W, drip_containers))
		if(beaker)
			to_chat(user, "<span class='warning'>There is already a reagent container loaded!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		beaker = W
		to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
		update_icon()
		return
	else
		return ..()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

/obj/machinery/iv_drip/process()
	if(!attached)
		return PROCESS_KILL

	var/mob/living/M
	if(istype(attached,/mob/living))
		M = attached
	var/ripped = 0
	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		ripped = 1
	if((M && !M.can_inject())||ripped||!attached.is_injectable())
		if(M && ripped)
			to_chat(M, "<span class='userdanger'>The IV drip needle is ripped out of you!</span>")
			M.apply_damage(3, BRUTE, pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		attached = null
		update_icon()
		return PROCESS_KILL

	if(beaker)
		// Give blood
		var/transfer_amount = 0
		var/transfer_text = "nothing"
		if(mode)
			if(beaker.reagents.total_volume)
				transfer_amount = 5
				if(istype(beaker, /obj/item/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 10
				if(beaker.reagents.reagent_list.len)
					transfer_text = ""
					for(var/i=1,i<=beaker.reagents.reagent_list.len,i++)
						var/datum/reagent/R = beaker.reagents.reagent_list[i]
						if(istype(R))
							transfer_text += "[R.id]"
							if(i < beaker.reagents.reagent_list.len-1)
								transfer_text += ", "
							else if(i == beaker.reagents.reagent_list.len-1)
								transfer_text += " and "
				var/fraction = min(transfer_amount/beaker.reagents.total_volume, 1) //the fraction that is transfered of the total volume
				beaker.reagents.reaction(attached, INJECT, fraction, FALSE) //make reagents reacts, but don't spam messages
				beaker.reagents.trans_to(attached, transfer_amount)
				update_icon()


		else
			// Take blood
			transfer_amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			transfer_amount = min(transfer_amount, 4)
			// If the beaker is full, ping
			if(!transfer_amount)
				if(prob(5))
					visible_message("[src] pings.")
				return
			if(M)
				transfer_text = "blood"
				// If the human is losing too much blood, beep.
				if(M.blood_volume < BLOOD_VOLUME_SAFE && prob(5))
					visible_message("[src] beeps loudly.")
					playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
				M.transfer_blood_to(beaker, transfer_amount)
			else if(isobj(attached))
				attached.reagents.trans_to(beaker, transfer_amount)
			update_icon()
		if(istype(attached,/mob/living/carbon))
			var/mob/living/carbon/C = attached
			if((lastuser || lastuserckey) && transfer_amount)
				var/turf/T = get_turf(C)
				if(T)
					var/attackertext = ""
					if(lastuser)
						attackertext = "[lastuser.name]([lastuser.ckey])"
					else if(lastuserckey)
						attackertext = "lastckey:[lastuserckey]"
					var/logtext = "[attackertext] has [mode ? "injected" : "extracted"] [transfer_amount] total units of reagents containing [transfer_text] [mode ? "in to" : "from"] [C][C.ckey ? "([C.ckey])" : ""] with the [name] at [T.x] [T.y] [T.z]"
					if(lastuser && C != lastuser)
						lastuser.log_message("<font color='red'>[logtext]</font>", INDIVIDUAL_ATTACK_LOG)
					C.log_message("<font color='orange'>[logtext]</font>", INDIVIDUAL_ATTACK_LOG)

/obj/machinery/iv_drip/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(attached)
		visible_message("[attached] is detached from [src]")
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

	if(!isliving(usr))
		to_chat(usr, "<span class='warning'>You can't do that!</span>")
		return

	if(usr.incapacitated())
		return

	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null
		update_icon()

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, "<span class='warning'>You can't do that!</span>")
		return

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")
	update_icon()

/obj/machinery/iv_drip/examine(mob/user)
	..()
	if(get_dist(user, src) > 2)
		return

	to_chat(user, "The IV drip is [mode ? "injecting" : "taking blood"].")

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			to_chat(user, "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
		else
			to_chat(user, "<span class='notice'>Attached is an empty [beaker.name].</span>")
	else
		to_chat(user, "<span class='notice'>No chemicals are attached.</span>")

	to_chat(user, "<span class='notice'>[attached ? attached : "No one"] is attached.</span>")

#undef IV_TAKING
#undef IV_INJECTING