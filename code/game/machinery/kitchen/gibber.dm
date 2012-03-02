
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/occupant // Mob who has been put inside
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

/obj/machinery/gibber/New()
	..()
	src.overlays += image('kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays = null
	if (dirty)
		src.overlays += image('kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('kitchen.dmi', "gruse")
	else
		src.overlays += image('kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "\red It's locked and running"
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(istype(G,/obj/item/weapon/card/emag))
		var/obj/item/weapon/card/emag/E = G
		if(E.uses)
			E.uses--
		else
			return
		user.visible_message( \
			"\red [user] swipes a strange card through \the [src]'s control panel!", \
			"\red You swipe a strange card through \the [src]'s control panel!", \
			"You hear a scratchy sound.")
		emagged = 1
		return

	if(src.occupant)
		user << "\red \The [src] is full, empty it first!"
		return
	if (!istype(G, /obj/item/weapon/grab))
		user << "\red This item is not suitable for \the [src]!"
		return
	if(istype(G.affecting, /mob/living/carbon/human))
		if(!emagged)
			user << "\red \The [src] buzzes and spits [G.affecting] back out."
			return
		if(G.affecting.abiotic(1))
			user << "\red Subject may not have abiotic items on."
			return
	else if(istype(G.affecting, /mob/living/carbon/monkey) || istype(G.affecting, /mob/living/carbon/alien) || istype(G.affecting, /mob/living/simple_animal))
		// do nothing special
	else
		user << "\red This item is not suitable for \the [src]!"

	user.visible_message("\red [user] starts to put [G.affecting] into \the [src]!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] stuffs [G.affecting] into \the [src]!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		for(var/mob/M in viewers(src, null))
			M.show_message("\red You hear a loud metallic grinding sound.", 1)
		return
	use_power(1000)
	for(var/mob/M in viewers(src, null))
		M.show_message("\red You hear a loud squelchy grinding sound.", 1)
	src.operating = 1
	update_icon()

	var/list/obj/item/weapon/reagent_containers/food/snacks/allmeat = new()

	if(istype(occupant,/mob/living/carbon/human))
		var/sourcename = src.occupant.real_name
		var/sourcejob = src.occupant.job
		var/sourcenutriment = src.occupant.nutrition / 15
		var/sourcetotalreagents = src.occupant.reagents.total_volume
		var/totalslabs = 8

		for (var/i=1 to totalslabs)
			var/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/human/newmeat = new()
			newmeat.name = sourcename + newmeat.name
			newmeat.subjectname = sourcename
			newmeat.subjectjob = sourcejob
			newmeat.reagents.add_reagent("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
			src.occupant.reagents.trans_to(newmeat, round(sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
			allmeat += newmeat
	else if(istype(occupant,/mob/living/carbon/monkey))
		var/sourcename = src.occupant.real_name
		var/sourcenutriment = src.occupant.nutrition / 15
		var/sourcetotalreagents = src.occupant.reagents.total_volume
		var/totalslabs = 5

		for (var/i=1 to totalslabs)
			var/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/monkey/newmeat = new()
			newmeat.name = sourcename + newmeat.name
			newmeat.reagents.add_reagent("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
			src.occupant.reagents.trans_to(newmeat, round(sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
			allmeat += newmeat
	else if(istype(occupant,/mob/living/carbon/alien))
		var/sourcename = src.occupant.real_name
		var/sourcenutriment = src.occupant.nutrition / 15
		var/sourcetotalreagents = src.occupant.reagents.total_volume
		var/totalslabs = 5

		for (var/i=1 to totalslabs)
			var/obj/item/weapon/reagent_containers/food/snacks/xenomeat/newmeat = new()
			newmeat.name = sourcename + newmeat.name
			newmeat.reagents.add_reagent("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
			src.occupant.reagents.trans_to(newmeat, round(sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
			allmeat += newmeat
	else if(istype(occupant,/mob/living/simple_animal))
		var/sourcenutriment = src.occupant.nutrition / 15
		var/totalslabs = occupant:meat_amount

		for (var/i=1 to totalslabs)
			var/obj/item/weapon/reagent_containers/food/snacks/newmeat = new occupant:meat_type()
			newmeat.reagents.add_reagent("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
			allmeat += newmeat

	for (var/mob/M in world)
		if (M.client && M.client.holder && (M.client.holder.level != -3))
			M << "\red [user.name]/[user.ckey] has gibbed [src.occupant.name]/[src.occupant.ckey]"
	src.occupant.death(1)
	src.occupant.ghostize()
	del(src.occupant)
	spawn(src.gibtime)
		playsound(src.loc, 'splat.ogg', 50, 1)
		operating = 0
		var/iterator = 0
		for (var/i=1 to allmeat.len)
			var/obj/item/meatslab = allmeat[i]
			var/turf/Tx = locate(src.x - i + iterator, src.y, src.z)
			if(Tx.density)
				iterator += 1
				Tx = locate(src.x - i + iterator, src.y, src.z)
			meatslab.loc = src.loc
			meatslab.throw_at(Tx,i,3)
			if (!Tx.density)
				new /obj/effect/decal/cleanable/blood/gibs(Tx,i + iterator)
		src.operating = 0
		update_icon()
