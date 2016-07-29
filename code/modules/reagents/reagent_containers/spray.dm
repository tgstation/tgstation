<<<<<<< HEAD
/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 7
	var/stream_mode = 0 //whether we use the more focused mode
	var/current_range = 3 //the range of tiles the sprayer will reach.
	var/spray_range = 3 //the range of tiles the sprayer will reach when in spray mode.
	var/stream_range = 1 //the range of tiles the sprayer will reach when in stream mode.
	var/stream_amount = 10 //the amount of reagents transfered when in stream mode.
	amount_per_transfer_from_this = 5
	volume = 250
	possible_transfer_amounts = list()


/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user)
	if(istype(A, /obj/item/weapon/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/machinery/hydroponics))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			user << "<span class='notice'>\The [A] is empty.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='notice'>\The [src] is full.</span>"
			return

		var/trans = A.reagents.trans_to(src, 50) //transfer 50u , using the spray's transfer amount would take too long to refill
		user << "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [A].</span>"
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		user << "<span class='warning'>\The [src] is empty!</span>"
		return

	spray(A)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	user.changeNext_move(CLICK_CD_RANGE*2)
	user.newtonian_move(get_dir(A, user))
	var/turf/T = get_turf(src)
	if(reagents.has_reagent("sacid"))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src] at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[get_area(src)] ([T.x], [T.y], [T.z])</a>).")
		log_game("[key_name(user)] fired sulphuric acid from \a [src] at [get_area(src)] ([T.x], [T.y], [T.z]).")
	if(reagents.has_reagent("facid"))
		message_admins("[key_name_admin(user)] fired Fluacid from \a [src] at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[get_area(src)] ([T.x], [T.y], [T.z])</a>).")
		log_game("[key_name(user)] fired Fluacid from \a [src] at [get_area(src)] ([T.x], [T.y], [T.z]).")
	if(reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src] at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[get_area(src)] ([T.x], [T.y], [T.z])</a>).")
		log_game("[key_name(user)] fired Space lube from \a [src] at [get_area(src)] ([T.x], [T.y], [T.z]).")
	return


/obj/item/weapon/reagent_containers/spray/proc/spray(atom/A)
	var/range = max(min(spray_range, get_dist(src, A)), 1)
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
	spawn(0)
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
	user << "<span class='notice'>You switch the nozzle setting to [stream_mode ? "\"stream\"":"\"spray\""]. You'll now use [amount_per_transfer_from_this] units per use.</span>"

/obj/item/weapon/reagent_containers/spray/verb/empty()
	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr
	if(usr.incapacitated())
		return
	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc) && src.loc == usr)
		usr << "<span class='notice'>You empty \the [src] onto the floor.</span>"
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
	volume = 40
	stream_range = 4
	amount_per_transfer_from_this = 5
	list_reagents = list("condensedcapsaicin" = 40)

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
	w_class = 3
	stream_mode = 1
	current_range = 7
	spray_range = 4
	stream_range = 7
	amount_per_transfer_from_this = 10
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


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
	volume = 100
	list_reagents = list("plantbgone" = 100)
=======
// Reagents to log when sprayed
var/global/list/logged_sprayed_reagents = list(SACID, PACID, LUBE, FUEL)

/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER|FPRINT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	volume = 250
	possible_transfer_amounts = null
	var/melted = 0

	var/delay_spraying = TRUE // Whether to delay the next attack after using it

	//! List of things to avoid spraying on close range. TODO Remove snowflake, handle this in every attackby() properly.
	var/list/ignore_spray_types = list(/obj/item/weapon/storage, /obj/structure/table, /obj/structure/rack, /obj/structure/closet, /obj/structure/sink)

/obj/item/weapon/reagent_containers/spray/attackby(obj/item/weapon/W, mob/user)
	if(!melted)
		if(W.is_hot())
			to_chat(user, "You slightly melt the plastic on the top of \the [src] with \the [W].")
			melted = 1
	if(melted)
		if(istype(W, /obj/item/stack/rods))
			to_chat(user, "You press \the [W] into the melted plastic on the top of \the [src].")
			var/obj/item/stack/rods/R = W
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/gun_assembly/I = new (get_turf(user), "spraybottle_assembly")
				user.put_in_hands(I)
			else
				new /obj/item/weapon/gun_assembly(get_turf(src.loc), "spraybottle_assembly")
			R.use(1)
			qdel(src)


/obj/item/weapon/reagent_containers/spray/afterattack(atom/A as mob|obj, mob/user as mob, var/adjacency_flag, var/click_params)
	if (adjacency_flag && is_type_in_list(A, ignore_spray_types))
		return

	if (delay_spraying)
		user.delayNextAttack(8)

	if (istype(A, /obj/structure/reagent_dispensers) && adjacency_flag)
		transfer(A, user, can_send = FALSE, can_receive = TRUE)
		return

	if (is_empty()) //If empty, checks for a nonempty chempack on the user.
		var/mob/living/M = user
		if (M && M.back && istype(M.back,/obj/item/weapon/reagent_containers/chempack))
			var/obj/item/weapon/reagent_containers/chempack/P = M.back
			if (!P.safety)
				if (!P.is_empty())
					if (istype(src,/obj/item/weapon/reagent_containers/spray/chemsprayer)) //The chemsprayer uses three times its amount_per_transfer_from_this per spray.
						transfer_sub(P, src, amount_per_transfer_from_this*3, user)
					else
						transfer_sub(P, src, amount_per_transfer_from_this, user)
				else
					to_chat(user, "<span class='notice'>\The [P] is empty!</span>")
					return
			else
				to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
				return
		else
			to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
			return

	// Log reagents
	var/list/log_reagent_list = list()

	for (var/reagent_id in logged_sprayed_reagents)
		if (reagents.has_reagent(reagent_id))
			log_reagent_list += "'[reagent_id]'"

	if (log_reagent_list.len > 0)
		add_gamelogs(user, "sprayed {[english_list(log_reagent_list, and_text = ", ")]} with \the [src]", admin = TRUE, tp_link = TRUE)

	user.investigation_log(I_CHEMS, "sprayed [amount_per_transfer_from_this]u from \a [src] \ref[src] containing [reagents.get_reagent_ids(1)] towards [A] ([A.x], [A.y], [A.z]).")

	// Override for your custom puff behaviour
	make_puff(A, user)

/obj/item/weapon/reagent_containers/spray/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You switched [amount_per_transfer_from_this == 10 ? "on" : "off"] the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

/obj/item/weapon/reagent_containers/spray/restock()
	if(name == "Polyacid spray")
		reagents.add_reagent(PACID, 2)
	else if(name == "Lube spray")
		reagents.add_reagent(LUBE, 2)

/obj/item/weapon/reagent_containers/spray/proc/make_puff(var/atom/target, var/mob/user)
	// Create the chemical puff
	var/transfer_amount = amount_per_transfer_from_this
	if (!can_transfer_an_APTFT() && !is_empty()) //If it doesn't contain enough reagents to fulfill its amount_per_transfer_from_this, but also isn't empty, it'll spray whatever it has left.
		transfer_amount = reagents.total_volume
	var/mix_color = mix_color_from_reagents(reagents.reagent_list)
	var/obj/effect/decal/chemical_puff/D = getFromPool(/obj/effect/decal/chemical_puff, get_turf(src), mix_color, amount_per_transfer_from_this)
	reagents.trans_to(D, transfer_amount, 1/3)

	// Move the puff toward the target
	spawn(0)
		for (var/i = 0, i < 3, i++)
			step_towards(D, target)
			D.react()
			sleep(3)

		returnToPool(D)

	playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, 1, -6)

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"


/obj/item/weapon/reagent_containers/spray/cleaner/New()
	..()
	reagents.add_reagent(CLEANER, 250)

//pepperspray
/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	volume = 40
	amount_per_transfer_from_this = 10


/obj/item/weapon/reagent_containers/spray/pepper/New()
	..()
	reagents.add_reagent(CONDENSEDCAPSAICIN, 40)

// Plant-B-Gone
/obj/item/weapon/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100

/obj/item/weapon/reagent_containers/spray/plantbgone/New()
	..()
	reagents.add_reagent(PLANTBGONE, 100)


//chemsprayer
/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = W_CLASS_MEDIUM
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3;syndicate=5"

	delay_spraying = FALSE

/obj/item/weapon/reagent_containers/spray/chemsprayer/make_puff(var/atom/target, var/mob/user)
	// Create the chemical puffs
	var/mix_color = mix_color_from_reagents(reagents.reagent_list)
	var/Sprays[3]

	for (var/i = 1, i <= 3, i++)
		if (src.reagents.total_volume < 1)
			break

		var/obj/effect/decal/chemical_puff/D = getFromPool(/obj/effect/decal/chemical_puff, get_turf(src), mix_color, amount_per_transfer_from_this)
		reagents.trans_to(D, amount_per_transfer_from_this)
		Sprays[i] = D

	// Move the puffs towards the target
	var/direction = get_dir(src, target)
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T, turn(direction, 90))
	var/turf/T2 = get_step(T, turn(direction, -90))
	var/list/the_targets = list(T, T1, T2)

	for (var/i = 1, i <= Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chemical_puff/D = Sprays[i]
			if (!D)
				continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for (var/j = 1, j <= rand(6, 8), j++)
				step_towards(D, my_target)
				D.react(iteration_delay = 0)
				sleep(2)

			returnToPool(D)

	playsound(get_turf(src), 'sound/effects/spray2.ogg', 50, 1, -6)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
