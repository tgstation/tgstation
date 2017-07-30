/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	flags = NOBLUDGEON
	container_type = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/stream_mode = 0 //whether we use the more focused mode
	var/current_range = 3 //the range of tiles the sprayer will reach.
	var/spray_range = 3 //the range of tiles the sprayer will reach when in spray mode.
	var/stream_range = 1 //the range of tiles the sprayer will reach when in stream mode.
	var/stream_amount = 10 //the amount of reagents transfered when in stream mode.
	amount_per_transfer_from_this = 5
	volume = 250
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)


/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user)
	if(istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/machinery/hydroponics))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>\The [A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return

		var/trans = A.reagents.trans_to(src, 50) //transfer 50u , using the spray's transfer amount would take too long to refill
		to_chat(user, "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [A].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return

	spray(A)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	user.changeNext_move(CLICK_CD_RANGE*2)
	user.newtonian_move(get_dir(A, user))
	var/turf/T = get_turf(src)
	var/area/area = get_area(src)
	if(reagents.has_reagent("sacid"))
		message_admins("[ADMIN_LOOKUPFLW(user)] fired sulphuric acid from \a [src] at [area] [ADMIN_COORDJMP(T)].")
		log_game("[key_name(user)] fired sulphuric acid from \a [src] at [area] ([T.x], [T.y], [T.z]).")
	if(reagents.has_reagent("facid"))
		message_admins("[ADMIN_LOOKUPFLW(user)] fired Fluacid from \a [src] at [area] [ADMIN_COORDJMP(T)].")
		log_game("[key_name(user)] fired Fluacid from \a [src] at [area] [COORD(T)].")
	if(reagents.has_reagent("lube"))
		message_admins("[ADMIN_LOOKUPFLW(user)] fired Space lube from \a [src] at [area] [ADMIN_COORDJMP(T)].")
		log_game("[key_name(user)] fired Space lube from \a [src] at [area] [COORD(T)].")
	return


/obj/item/weapon/reagent_containers/spray/proc/spray(atom/A)
	var/range = max(min(current_range, get_dist(src, A)), 1)
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	var/puff_reagent_left = range //how many turf, mob or dense objet we can react with before we consider the chem puff consumed
	if(stream_mode)
		reagents.trans_to(D, amount_per_transfer_from_this)
		puff_reagent_left = 1
	else
		reagents.trans_to(D, amount_per_transfer_from_this, 1/range)
	D.color = mix_color_from_reagents(D.reagents.reagent_list)
	var/wait_step = max(round(2+3/range), 2)
	do_spray(A, wait_step, D, range, puff_reagent_left)

/obj/item/weapon/reagent_containers/spray/proc/do_spray(atom/A, wait_step, obj/effect/decal/chempuff/D, range, puff_reagent_left)
	set waitfor = FALSE
	var/range_left = range
	for(var/i=0, i<range, i++)
		range_left--
		step_towards(D,A)
		sleep(wait_step)

		for(var/atom/T in get_turf(D))
			if(T == D || T.invisibility) //we ignore the puff itself and stuff below the floor
				continue
			if(puff_reagent_left <= 0)
				break

			if(stream_mode)
				if(ismob(T))
					var/mob/M = T
					if(!M.lying || !range_left)
						D.reagents.reaction(M, VAPOR)
						puff_reagent_left -= 1
				else if(!range_left)
					D.reagents.reaction(T, VAPOR)
			else
				D.reagents.reaction(T, VAPOR)
				if(ismob(T))
					puff_reagent_left -= 1

		if(puff_reagent_left > 0 && (!stream_mode || !range_left))
			D.reagents.reaction(get_turf(D), VAPOR)
			puff_reagent_left -= 1

		if(puff_reagent_left <= 0) // we used all the puff so we delete it.
			qdel(D)
			return
	qdel(D)

/obj/item/weapon/reagent_containers/spray/attack_self(mob/user)
	stream_mode = !stream_mode
	if(stream_mode)
		amount_per_transfer_from_this = stream_amount
		current_range = stream_range
	else
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
		current_range = spray_range
	to_chat(user, "<span class='notice'>You switch the nozzle setting to [stream_mode ? "\"stream\"":"\"spray\""]. You'll now use [amount_per_transfer_from_this] units per use.</span>")

/obj/item/weapon/reagent_containers/spray/verb/empty()
	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc) && src.loc == usr)
		to_chat(usr, "<span class='notice'>You empty \the [src] onto the floor.</span>")
		reagents.reaction(usr.loc)
		src.reagents.clear_reagents()

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	list_reagents = list("cleaner" = 250)

//spray tan
/obj/item/weapon/reagent_containers/spray/spraytan
	name = "spray tan"
	volume = 50
	desc = "Gyaro brand spray tan. Do not spray near eyes or other orifices."
	list_reagents = list("spraytan" = 50)


/obj/item/weapon/reagent_containers/spray/medical
	name = "medical spray"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "medspray"
	volume = 100


/obj/item/weapon/reagent_containers/spray/medical/sterilizer
	name = "sterilizer spray"
	desc = "Spray bottle loaded with non-toxic sterilizer. Useful in preparation for surgery."
	list_reagents = list("sterilizine" = 100)


//pepperspray
/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	volume = 40
	stream_range = 4
	amount_per_transfer_from_this = 5
	list_reagents = list("condensedcapsaicin" = 40)

// Fix pepperspraying yourself
/obj/item/weapon/reagent_containers/spray/pepper/afterattack(atom/A as mob|obj, mob/user)
	if (A.loc == user)
		return
	..()

//water flower
/obj/item/weapon/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	volume = 10
	list_reagents = list("water" = 10)

/obj/item/weapon/reagent_containers/spray/waterflower/attack_self(mob/user) //Don't allow changing how much the flower sprays
	return

//chemsprayer
/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagents in a given area."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	stream_mode = 1
	current_range = 7
	spray_range = 4
	stream_range = 7
	amount_per_transfer_from_this = 10
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"

/obj/item/weapon/reagent_containers/spray/chemsprayer/afterattack(atom/A as mob|obj, mob/user)
	// Make it so the bioterror spray doesn't spray yourself when you click your inventory items
	if (A.loc == user)
		return
	..()

/obj/item/weapon/reagent_containers/spray/chemsprayer/spray(atom/A)
	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=3, i++) // intialize sprays
		if(reagents.total_volume < 1)
			return
		..(the_targets[i])

/obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror
	list_reagents = list("sodium_thiopental" = 100, "coniine" = 100, "venom" = 100, "condensedcapsaicin" = 100, "initropidril" = 100, "polonium" = 100)

// Plant-B-Gone
/obj/item/weapon/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list("plantbgone" = 100)
