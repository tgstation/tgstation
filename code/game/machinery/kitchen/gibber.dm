
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/occupant // Mob who has been put inside
	var/opened = 0.0
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
obj/machinery/gibber/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/gibber,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high
	)

	RefreshParts()

/obj/machinery/gibber/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(operating)
		user << "<span class='notice'>[src] is currently gibbing something!</span>"
		return
	if(istype(O,/obj/item/weapon/wrench))
		if(!anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 1
				user << "You wrench [src] in place."
			return
		else
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 30))
				anchored = 0
				user << "You unwrench [src]."
			return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if (istype(O, /obj/item/weapon/screwdriver))
		if (!opened)
			user << "You open the maintenance hatch of [src]."
			//src.icon_state = "autolathe_t"
		else
			user << "You close the maintenance hatch of [src]."
			//src.icon_state = "autolathe"
		opened = !opened
		return 1
	else if(istype(O, /obj/item/weapon/crowbar))
		if (opened)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			del(src)
			return 1
	if(istype(O,/obj/item/weapon/grab))
		return handleGrab(O,user)
	else
		user << "\red This item is not suitable for the gibber!"

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/list/allowedTypes=list(
		/mob/living/carbon/human,
		/mob/living/carbon/alien,
		/mob/living/carbon/monkey,
		/mob/living/simple_animal/corgi
	)
	var/turf/input_plate

	New()
		..()
		spawn(5)
			for(var/i in cardinal)
				var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
				if(input_obj)
					if(isturf(input_obj.loc))
						input_plate = input_obj.loc
						del(input_obj)
						break

			if(!input_plate)
				diary << "a [src] didn't find an input plate."
				return

/obj/machinery/gibber/autogibber/process()
	if(!input_plate) return
	if(stat & (BROKEN | NOPOWER))
		return
	use_power(100)

	var/affecting = input_plate.contents		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		for(var/atom/movable/A in affecting)
			if(ismob(A))
				var/mob/M = A

				if(M.loc == input_plate)
					//var/found=0
					for(var/t in allowedTypes)
						if(istype(M,t))
							//found=1
							M.loc = src
							startautogibbing(M)
							break


/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(operating)
		user << "<span class='warning'>[src] is locked and running</span>"
		return
	if(!(src.occupant))
		user << "<span class='warning'>[src] is empty!</span>"
		return
	else
		src.startgibbing(user)

// OLD /obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
/obj/machinery/gibber/proc/handleGrab(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(src.occupant)
		user << "<span class='warning'>[src] is full! Empty it first.</span>"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "<span class='warning'>This item is not suitable for [src]!</span>"
		return
	if(G.affecting.abiotic(1))
		user << "<span class='warning'>Subject may not have abiotic items on.</span>"
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the gibber!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] stuffs [G.affecting] into the gibber!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()

/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(target != user || !istype(user, /mob/living/carbon/human) || user.stat || user.weakened || user.stunned || user.paralysis || user.buckled || get_dist(user, src) > 1)
		return
	if(!anchored)
		user << "<span class='warning'>[src] must be anchored first!</span>"
		return
	if(src.occupant)
		user << "<span class='warning'>[src] is full! Empty it first.</span>"
		return
	if(user.abiotic(1))
		user << "<span class='warning'>Subject may not have abiotic items on.</span>"
		return

	src.add_fingerprint(user)
	user.visible_message("\red [user.name] starts climbing into the [src].", "\red You start climbing into the [src].")

	if(do_after(user, 30) && user && !occupant)
		user.visible_message("\red [user] climbs into the [src]", "\red You climb into the [src].")
		if(user.client)
			user.client.perspective = EYE_PERSPECTIVE
			user.client.eye = src
		user.loc = src
		src.occupant = user
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
		visible_message("\red You hear a loud metallic grinding sound.")
		return
	use_power(1000)
	visible_message("\red You hear a loud squelchy grinding sound.")
	src.operating = 1
	update_icon()
	var/sourcename = src.occupant.real_name
	var/sourcejob = src.occupant.job
	var/sourcenutriment = src.occupant.nutrition / 15
	var/sourcetotalreagents = src.occupant.reagents.total_volume
	var/totalslabs = 3

	var/obj/item/weapon/reagent_containers/food/snacks/meat/human/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
		newmeat.name = sourcename + newmeat.name
		newmeat.subjectname = sourcename
		newmeat.subjectjob = sourcejob
		newmeat.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		src.occupant.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
		allmeat[i] = newmeat

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
	log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> gibbed <b>[src.occupant]/[src.occupant.ckey]</b>")

	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user

	src.occupant.death(1)
	src.occupant.ghostize()
	del(src.occupant)
	spawn(src.gibtime)
		operating = 0
		for (var/i=1 to totalslabs)
			var/obj/item/meatslab = allmeat[i]
			var/turf/Tx = locate(src.x - i, src.y, src.z)
			meatslab.loc = src.loc
			meatslab.throw_at(Tx,i,3)
			if (!Tx.density)
				new /obj/effect/decal/cleanable/blood/gibs(Tx,i)
		src.operating = 0
		update_icon()

/obj/machinery/gibber/proc/startautogibbing(mob/victim as mob)
	if(src.operating)
		return
	if(!victim)
		visible_message("\red You hear a loud metallic grinding sound.")
		return
	use_power(1000)
	visible_message("\red You hear a loud squelchy grinding sound.")
	src.operating = 1
	update_icon()
	var/sourcename = victim.real_name
	var/sourcejob = victim.job
	var/sourcenutriment = victim.nutrition / 15
	var/sourcetotalreagents = victim.reagents.total_volume
	var/totalslabs = 3

	var/obj/item/weapon/reagent_containers/food/snacks/meat/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/newmeat = null
		if(istype(victim, /mob/living/carbon/human))
			newmeat = new/obj/item/weapon/reagent_containers/food/snacks/meat/human
			newmeat.name = sourcename + newmeat.name
			newmeat:subjectname = sourcename
			newmeat:subjectjob = sourcejob
		if(istype(victim, /mob/living/carbon/alien))
			newmeat = new/obj/item/weapon/reagent_containers/food/snacks/xenomeat
		if(istype(victim, /mob/living/carbon/monkey))
			newmeat = new/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
		if(istype(victim, /mob/living/simple_animal))
			var/mob/living/simple_animal/SA = victim
			newmeat = new SA.meat_type

		if(newmeat==null)
			return
		newmeat.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		victim.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
		allmeat[i] = newmeat

	victim.attack_log += "\[[time_stamp()]\] Was auto-gibbed by <b>[src]</b>" //One shall not simply gib a mob unnoticed!
	log_attack("\[[time_stamp()]\] <b>[src]</b> auto-gibbed <b>[victim]/[victim.ckey]</b>")
	victim.death(1)
	if(ishuman(victim) || ismonkey(victim) || isalien(victim))
		var/obj/item/brain/B = new(src.loc)
		B.transfer_identity(victim)
		var/turf/Tx = locate(src.x - 2, src.y, src.z)
		B.loc = src.loc
		B.throw_at(Tx,2,3)
		if(isalien(victim))
			new /obj/effect/decal/cleanable/blood/gibs/xeno(Tx,2)
		else
			new /obj/effect/decal/cleanable/blood/gibs(Tx,2)
	del(victim)
	spawn(src.gibtime)
		playsound(get_turf(src), 'sound/effects/gib2.ogg', 50, 1)
		operating = 0
		for (var/i=1 to totalslabs)
			var/obj/item/meatslab = allmeat[i]
			var/turf/Tx = locate(src.x - i, src.y, src.z)
			meatslab.loc = src.loc
			meatslab.throw_at(Tx,i,3)
			if (!Tx.density)
				new /obj/effect/decal/cleanable/blood/gibs(Tx,i)
		src.operating = 0
		update_icon()

