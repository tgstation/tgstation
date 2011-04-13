/obj/machinery/gibber/New()
	..()
	src.overlays += image('kitchen.dmi', "grindnotinuse")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(operating)
		user << "\red It's locked and running"
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "\red The gibber is full, empty it first!"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "\red This item is not suitable for the gibber!"
		return
	if(G.affecting.abiotic())
		user << "\red Subject may not have abiotic items on."
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the gibber!")
	src.add_fingerprint(user)
	sleep(30)
	if(G)
		if(G.affecting)
			user.visible_message("\red [user] stuffs [G.affecting] into the gibber!")
			var/mob/M = G.affecting
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.occupant = M
			del(G)

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
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		for(var/mob/M in viewers(src, null))
			M.show_message("\red You hear a loud metallic grinding sound.", 1)
		return
	else
		for(var/mob/M in viewers(src, null))
			M.show_message("\red You hear a loud squelchy grinding sound.", 1)
		src.operating = 1
		src.dirty += 1
		var/sourcename = src.occupant.real_name
		var/sourcejob = src.occupant.job
		var/sourcenutriment = src.occupant.nutrition / 15
		var/sourcetotalreagents = src.occupant.reagents.total_volume
		var/totalslabs = 3

		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat1 = new
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat2 = new
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat3 = new

		newmeat1.name = sourcename + newmeat1.name
		newmeat1.subjectname = sourcename
		newmeat1.subjectjob = sourcejob
		newmeat1.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		src.occupant.reagents.trans_to (newmeat1, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the body to meat
		newmeat2.name = sourcename + newmeat2.name
		newmeat2.subjectname = sourcename
		newmeat2.subjectjob = sourcejob
		newmeat2.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs)
		src.occupant.reagents.trans_to (newmeat2, round (sourcetotalreagents / totalslabs, 1))
		newmeat3.name = sourcename + newmeat3.name
		newmeat3.subjectname = sourcename
		newmeat3.subjectjob = sourcejob
		newmeat3.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs)
		src.occupant.reagents.trans_to (newmeat3, round (sourcetotalreagents / totalslabs, 1))
		if(src.occupant.client)
			var/mob/dead/observer/newmob
			newmob = new/mob/dead/observer(src.occupant)
			src.occupant:client:mob = newmob
			newmob:client:eye = newmob
			del(src.occupant)
		else
			del(src.occupant)
		spawn(src.gibtime)
			playsound(src.loc, 'splat.ogg', 50, 1)
			operating = 0
			var/turf/Tx1 = locate(src.x - 1, src.y, src.z)
			var/turf/Tx2 = locate(src.x - 2, src.y, src.z)
			var/turf/Tx3 = locate(src.x - 3, src.y, src.z)
			if(istype(Tx1, /turf/simulated/floor/)) // Make it so the blood that flies out only appears on the freezer floor
				new /obj/decal/cleanable/blood/gibs(Tx1)
				newmeat1.loc = get_turf(Tx1)
			if(istype(Tx2, /turf/simulated/floor/))
				new /obj/decal/cleanable/blood/gibs(Tx2)
				newmeat2.loc = get_turf(Tx2)
			if(istype(Tx3, /turf/simulated/floor/))
				new /obj/decal/cleanable/blood/gibs(Tx3)
				newmeat3.loc = get_turf(Tx3)
			if(src.dirty == 1)
				src.overlays += image('kitchen.dmi', "grindbloody")
		src.operating = 0


