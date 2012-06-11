
/obj/item/weapon/bedsheet/ex_act(severity)
	if (severity <= 2)
		del(src)
		return
	return

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	src.layer = 5
	add_fingerprint(user)
	return




/obj/item/weapon/handcuffs/attack(mob/M as mob, mob/user as mob)
	if(istype(src, /obj/item/weapon/handcuffs/cyborg) && isrobot(user))
		if(!M.handcuffed)
			var/turf/p_loc = user.loc
			var/turf/p_loc_m = M.loc
			playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
			for(var/mob/O in viewers(user, null))
				O.show_message("\red <B>[user] is trying to put handcuffs on [M]!</B>", 1)
			spawn(30)
				if(p_loc == user.loc && p_loc_m == M.loc)
					M.handcuffed = new /obj/item/weapon/handcuffs(M)

	else
		if ((CLUMSY in usr.mutations) && prob(50))
			usr << "\red Uh ... how do those things work?!"
			if (istype(M, /mob/living/carbon/human))
				if(!M.handcuffed)
					var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
					O.source = user
					O.target = user
					O.item = user.equipped()
					O.s_loc = user.loc
					O.t_loc = user.loc
					O.place = "handcuff"
					M.requests += O
					spawn( 0 )
						O.process()
				return
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return
		if (istype(M, /mob/living/carbon/human))
			if(!M.handcuffed)
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been handcuffed (attempt) by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to handcuff [M.name] ([M.ckey])</font>")

				log_admin("ATTACK: [user] ([user.ckey]) handcuffed [M] ([M.ckey]).")
				log_attack("<font color='red'>[user.name] ([user.ckey]) Attempted to handcuff [M.name] ([M.ckey])</font>")

				var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
				O.source = user
				O.target = M
				O.item = user.equipped()
				O.s_loc = user.loc
				O.t_loc = M.loc
				O.place = "handcuff"
				M.requests += O
				spawn( 0 )
					if(istype(src, /obj/item/weapon/handcuffs/cable))
						playsound(src.loc, 'cablecuff.ogg', 30, 1, -2)
					else
						playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
					O.process()
			return
		else
			if(!M.handcuffed)
				var/obj/effect/equip_e/monkey/O = new /obj/effect/equip_e/monkey(  )
				O.source = user
				O.target = M
				O.item = user.equipped()
				O.s_loc = user.loc
				O.t_loc = M.loc
				O.place = "handcuff"
				M.requests += O
				spawn( 0 )
					if(istype(src, /obj/item/weapon/handcuffs/cable))
						playsound(src.loc, 'cablecuff.ogg', 30, 1, -2)
					else
						playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
					O.process()
			return
	return





/obj/item/weapon/extinguisher/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("water", 50)

/obj/item/weapon/extinguisher/mini/New()
	var/datum/reagents/R = new/datum/reagents(30)
	reagents = R
	R.my_atom = src
	R.add_reagent("water", 30)

/obj/item/weapon/extinguisher/examine()
	set src in usr

	usr << text("\icon[] [] contains [] units of water left!", src, src.name, src.reagents.total_volume)
	..()
	return

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user , flag)
	//TODO; Add support for reagents in water.

	if( istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(src,target) <= 1)
		var/obj/o = target
		o.reagents.trans_to(src, 50)
		user << "\blue \The [src] is now refilled"
		playsound(src.loc, 'refill.ogg', 50, 1, -6)
		return

	if (!safety)
		if (src.reagents.total_volume < 1)
			usr << "\red \The [src] is empty."
			return

		if (world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(src.loc, 'extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(usr.buckled && isobj(usr.buckled) && !usr.buckled.anchored )
			spawn(0)
				var/obj/B = usr.buckled
				var/movementdirection = turn(direction,180)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<5, a++)
			spawn(0)
				var/obj/effect/effect/water/W = new /obj/effect/effect/water( get_turf(src) )
				var/turf/my_target = pick(the_targets)
				var/datum/reagents/R = new/datum/reagents(5)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				src.reagents.trans_to(W,1)
				for(var/b=0, b<5, b++)
					step_towards(W,my_target)
					if(!W) return
					W.reagents.reaction(get_turf(W))
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm)
					if(W.loc == my_target) break
					sleep(2)

		if((istype(usr.loc, /turf/space)) || (usr.lastarea.has_gravity == 0))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	/*
		if(istype(usr.loc, /turf/space)|| (user.flags & NOGRAV))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)
	*/
	else
		return ..()
	return

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)
	if (safety)
		src.icon_state = "fire_extinguisher1"
		src.desc = "The safety is off."
		user << "The safety is off."
		safety = 0
	else
		src.icon_state = "fire_extinguisher0"
		src.desc = "The safety is on."
		user << "The safety is on."
		safety = 1
	return

/obj/item/weapon/extinguisher/mini/attack_self(mob/user as mob)
	if (safety)
		src.icon_state = "miniFE1"
		src.desc = "The safety is off."
		user << "The safety is off."
		safety = 0
	else
		src.icon_state = "miniFE0"
		src.desc = "The safety is on."
		user << "The safety is on."
		safety = 1
	return

/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "\red You stab [M] with the pen."
//	M << "\red You feel a tiny prick!" //Removed to make tritor pens stealthier
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [src.name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to stab [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) used [src] on [M] ([M.ckey]).")
	message_admins("ATTACK: [user] ([user.ckey]) used [src] on [M] ([M.ckey]).")
	log_attack("<font color='red'>[user.name] ([user.ckey]) Used the [src.name] to stab [M.name] ([M.ckey])</font>")


	return

/obj/item/weapon/pen/sleepypen
	origin_tech = "syndicate=5"

/obj/item/weapon/pen/sleepypen/attack_paw(mob/user as mob)
	return src.attack_hand(user)
	return

/obj/item/weapon/pen/sleepypen/New()
	var/datum/reagents/R = new/datum/reagents(60) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("stoxin", 60)
	..()
	return

/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 20) //used to be 150
	return

//NEW STYLE PARAPEN
/obj/item/weapon/pen/paralysis/attack_paw(mob/user as mob)
	return src.attack_hand(user)
	return

/obj/item/weapon/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50)
	return

/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("impedrezene", 25)
	R.add_reagent("cryptobiolin", 15)
	..()
	return

/obj/item/weapon/Bump(mob/M as mob)
	spawn(0)
		..()
	return

/obj/effect/manifest/New()

	src.invisibility = 101
	return

/obj/effect/manifest/proc/manifest()
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = "<B>Crew Manifest:</B><BR>" + data_core.get_manifest()
	P.name = "paper - 'Crew Manifest'"
	//SN src = null
	del(src)
	return


//What the fuck is this code  Looks to be the parrying code.  If you're grabbing someone, it might hit them instead... or something.--SkyMarshal
/mob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (user.intent != "harm")
		if (istype(src.l_hand,/obj/item/latexballon) && src.l_hand:air_contents && is_sharp(W))
			return src.l_hand.attackby(W)
		if (istype(src.r_hand,/obj/item/latexballon) && src.r_hand:air_contents && is_sharp(W))
			return src.r_hand.attackby(W)
	var/shielded = 0
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.attackby(W, user)
	if ((!( shielded ) || !( W.flags ) & 32))
		spawn( 0 )
			if (W)
				W.attack(src, user)
				return
	return



/obj/item/weapon/teleportation_scroll/attack_self(mob/user as mob)
	user.machine = src
	var/dat = "<B>Teleportation Scroll:</B><BR>"
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Four uses use them wisely:</B><BR>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/weapon/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["spell_teleport"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.teleportscroll()
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/obj/item/brain/examine() // -- TLE
	set src in oview(12)
	if (!( usr ))
		return
	usr << "This is \icon[src] \an [name]."

	if(brainmob)//if thar be a brain inside... the brain.
		usr << "You can feel the small spark of life still left in this one."
	else
		usr << "This one seems particularly lifeless. Perhaps it will regain some of its luster later. Probably not."

/obj/item/brain/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	add_fingerprint(user)

	if(!(user.zone_sel.selecting == ("head")) || !istype(M, /mob/living/carbon/human))
		return ..()

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove their head cover first."
		return

	var/datum/organ/external/head = H.organs["head"]
	if(head.destroyed)
		user << "\blue Put it where? There's no head."

//since these people will be dead M != usr

	if(M:brain_op_stage == 4.0)
		for(var/mob/O in viewers(M, null))
			if(O == user || O == M)
				continue
			if(M == user)
				O.show_message(text("\red [user] inserts [src] into his head!"), 1)
			else
				O.show_message(text("\red [M] has [src] inserted into his head by [user]."), 1)

		if(M != user)
			M << "\red [user] inserts [src] into your head!"
			user << "\red You insert [src] into [M]'s head!"
		else
			user << "\red You insert [src] into your head!"

		//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
		if(M.key)//Revised. /N
			M.ghostize(1)

		if(brainmob.mind)
			brainmob.mind.transfer_to(M)
		else
			M.key = brainmob.key

		// force re-entering corpse
		if (!M.client)
			for(var/mob/dead/observer/ghost in world)
				if(ghost.corpse == brainmob && ghost.client)
					ghost.cancel_camera()
					ghost.reenter_corpse()
					break

		M:brain_op_stage = 3.0

		del(src)
	else
		..()
	return

/obj/item/weapon/stamp/attack_paw(mob/user as mob)

	return src.attack_hand(user)

/obj/item/weapon/dice/attack_self(mob/user as mob) // Roll the dice -- TLE
	var/temp_sides
	if(src.sides < 1)
		temp_sides = 2
	else
		temp_sides = src.sides
	var/result = rand(1,temp_sides)
	var/comment = ""
	if(temp_sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(temp_sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	user << text("\red You throw a [src]. It lands on a [result]. [comment]")
	icon_state = "[name][result]"
	for(var/mob/O in viewers(user, null))
		if(O == (user))
			continue
		else
			O.show_message(text("\red [user] has thrown a [src]. It lands on [result]. [comment]"), 1)

/obj/item/latexballon
	name = "Latex glove"
	desc = "" //todo
	icon_state = "latexballon"
	item_state = "lgloves"
	force = 0
	throwforce = 0
	w_class = 1.0
	throw_speed = 1
	throw_range = 15
	var/state
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballon/proc/blow(obj/item/weapon/tank/tank)
	if (icon_state == "latexballon_bursted")
		return
	src.air_contents = tank.remove_air_volume(3)
	icon_state = "latexballon_blow"
	item_state = "latexballon"

/obj/item/latexballon/proc/burst()
	if (!air_contents)
		return
	playsound(src, 'Gunshot.ogg', 100, 1)
	icon_state = "latexballon_bursted"
	item_state = "lgloves"
	loc.assume_air(air_contents)

/obj/item/latexballon/ex_act(severity)
	burst()
	switch(severity)
		if (1)
			del(src)
		if (2)
			if (prob(50))
				del(src)

/obj/item/latexballon/bullet_act()
	burst()

/obj/item/latexballon/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(temperature > T0C+100)
		burst()
	return

/obj/item/latexballon/attackby(obj/item/W as obj, mob/user as mob)
	if (is_sharp(W))
		burst()

//Is this even used for anything besides balloons? Yes I took out the W:lit stuff because : really shouldnt be used.
/proc/is_sharp(obj/item/W as obj)		// For the record, WHAT THE HELL IS THIS METHOD OF DOING IT?
	return ( \
		istype(W, /obj/item/weapon/screwdriver)                   || \
		istype(W, /obj/item/weapon/pen)                           || \
		istype(W, /obj/item/weapon/weldingtool)					  || \
		istype(W, /obj/item/weapon/lighter/zippo)				  || \
		istype(W, /obj/item/weapon/match)            		      || \
		istype(W, /obj/item/clothing/mask/cigarette) 		      || \
		istype(W, /obj/item/weapon/wirecutters)                   || \
		istype(W, /obj/item/weapon/circular_saw)                  || \
		istype(W, /obj/item/weapon/melee/energy/sword)            || \
		istype(W, /obj/item/weapon/melee/energy/blade)            || \
		istype(W, /obj/item/weapon/shovel)                        || \
		istype(W, /obj/item/weapon/kitchenknife)                  || \
		istype(W, /obj/item/weapon/butch)						  || \
		istype(W, /obj/item/weapon/scalpel)                       || \
		istype(W, /obj/item/weapon/kitchen/utensil/knife)         || \
		istype(W, /obj/item/weapon/shard)                         || \
		istype(W, /obj/item/weapon/reagent_containers/syringe)    || \
		istype(W, /obj/item/weapon/kitchen/utensil/fork) && W.icon_state != "forkloaded" || \
		istype(W, /obj/item/weapon/twohanded/fireaxe)			  || \
		istype(W,/obj/item/projectile)\
	)

/proc/is_cut(obj/item/W as obj)
	return ( \
		istype(W, /obj/item/weapon/wirecutters)                   || \
		istype(W, /obj/item/weapon/circular_saw)                  || \
		istype(W, /obj/item/weapon/melee/energy/sword)            && W:active  || \
		istype(W, /obj/item/weapon/melee/energy/blade)                         || \
		istype(W, /obj/item/weapon/shovel)                        || \
		istype(W, /obj/item/weapon/kitchenknife)                  || \
		istype(W, /obj/item/weapon/butch)						  || \
		istype(W, /obj/item/weapon/scalpel)                       || \
		istype(W, /obj/item/weapon/kitchen/utensil/knife)         || \
		istype(W, /obj/item/weapon/shard)	|| \
		istype(W,/obj/item/projectile)	\
	)

/proc/is_burn(obj/item/W as obj)
	return ( \
		istype(W, /obj/item/weapon/weldingtool)      && W:welding || \
		istype(W, /obj/item/weapon/lighter/zippo)    && W:lit     || \
		istype(W, /obj/item/weapon/match)            && W:lit     || \
		istype(W, /obj/item/clothing/mask/cigarette) && W:lit	|| \
		istype(W,/obj/item/projectile/beam)\
	)

/obj/item/weapon/paper/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= 373.15)
		for(var/mob/M in viewers(5, src))
			M << "\red \the [src] burns up."
		del(src)

/obj/item/weapon/megaphone/attack_self(mob/user as mob)
	if(!ishuman(user))
		usr << "\red You don't know how to use this!"
		return
	if(cooldown)
		usr << "\red \The [src] needs to recharge!"
		return
	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(message && !cooldown)
		if ((src.loc == user && usr.stat == 0))
			for(var/mob/O in (viewers(user)))
				O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2) // 2 stands for hearable message
			cooldown = 1
			spawn(100)
				cooldown = 0
			return
