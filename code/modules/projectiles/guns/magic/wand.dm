/obj/item/weapon/gun/magic/wand/
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	projectile_type = "/obj/item/projectile/magic"
	icon_state = "wand6"
	item_state = "wand"
	w_class = 2
	can_charge = 0
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = 1

/obj/item/weapon/gun/magic/wand/New()
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = Ceiling(max_charges / 3)
		else
			max_charges = Ceiling(max_charges / 2)
	..()

/obj/item/weapon/gun/magic/wand/examine()
	..()
	usr << "Has [charges] charge\s remaining."
	return

/obj/item/weapon/gun/magic/wand/attack_self(mob/living/user as mob)
	if(charges)
		zap_self(user)
	else
		user << "<span class='warning'>The [name] whizzles quietly.<span>"
	..()

/obj/item/weapon/gun/magic/wand/proc/zap_self(mob/living/user as mob)
	user.visible_message("\blue [user] zaps \himself with [src]!")

/obj/item/weapon/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	projectile_type = "/obj/item/projectile/magic/death"
	icon_state = "wand4"
	max_charges = 3 //3, 2, 2, 1

/obj/item/weapon/gun/magic/wand/death/zap_self(mob/living/user as mob)
	if(alert(user, "You really want to zap yourself with the wand of death?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		var/message ="\red You irradiate yourself with pure energy! "
		message += pick("Do not pass go. Do not collect 200 zorkmids.","You feel more confident in your spell casting skills.","You Die...","Do you want your possessions identified?")
		user << message
		user.adjustOxyLoss(500)
		charges--
		..()

/obj/item/weapon/gun/magic/wand/resurrection
	name = "wand of resurrection"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	projectile_type = "/obj/item/projectile/magic/resurrection"
	icon_state = "wand1"
	max_charges = 3 //3, 2, 2, 1

/obj/item/weapon/gun/magic/wand/resurrection/zap_self(mob/living/user as mob)
	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss())
	user.reagents.clear_reagents()
	user << "<span class='notice'>You feel great!</span>"
	charges--
	..()

/obj/item/weapon/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand inflicts is attuned to chaos and will radically alter the victim's form."
	projectile_type = "/obj/item/projectile/magic/change"
	icon_state = "wand5"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/polymorph/zap_self(mob/living/user as mob)
	if(alert(user, "Your new form might not have arms to zap with... Continue?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		if(user.monkeyizing)	return
		user.monkeyizing = 1
		user.canmove = 0
		user.icon = null
		user.overlays.Cut()
		user.invisibility = 101
		for(var/obj/item/W in user)
			if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
				del(W)
				continue
			W.layer = initial(W.layer)
			W.loc = user.loc
			W.dropped(user)

		var/mob/living/new_mob

		var/randomize = pick("monkey","robot","slime","xeno","human","animal")
		switch(randomize)
			if("monkey")
				new_mob = new /mob/living/carbon/monkey(user.loc)
				new_mob.universal_speak = 1
			if("robot")
				new_mob = new /mob/living/silicon/robot(user.loc)
				new_mob.gender = user.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/device/mmi(new_mob)
				Robot.mmi.transfer_identity(user)	//Does not transfer key/client.
			if("slime")
				if(prob(50))		new_mob = new /mob/living/carbon/slime/adult(user.loc)
				else				new_mob = new /mob/living/carbon/slime(user.loc)
				new_mob.universal_speak = 1
			if("xeno")
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(user.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(user.loc)
				new_mob.universal_speak = 1
			if("animal")
				var/animal = pick("parrot","corgi","crab","pug","cat","carp","bear","mushroom","tomato","mouse","chicken","cow","lizard","chick")
				switch(animal)
					if("parrot")	new_mob = new /mob/living/simple_animal/parrot(user.loc)
					if("corgi")		new_mob = new /mob/living/simple_animal/corgi(user.loc)
					if("crab")		new_mob = new /mob/living/simple_animal/crab(user.loc)
					if("pug")		new_mob = new /mob/living/simple_animal/pug(user.loc)
					if("cat")		new_mob = new /mob/living/simple_animal/cat(user.loc)
					if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(user.loc)
					if("bear")		new_mob = new /mob/living/simple_animal/hostile/bear(user.loc)
					if("mushroom")	new_mob = new /mob/living/simple_animal/mushroom(user.loc)
					if("tomato")	new_mob = new /mob/living/simple_animal/tomato(user.loc)
					if("mouse")		new_mob = new /mob/living/simple_animal/mouse(user.loc)
					if("chicken")	new_mob = new /mob/living/simple_animal/chicken(user.loc)
					if("cow")		new_mob = new /mob/living/simple_animal/cow(user.loc)
					if("lizard")	new_mob = new /mob/living/simple_animal/lizard(user.loc)
					else			new_mob = new /mob/living/simple_animal/chick(user.loc)
					new_mob.universal_speak = 1
			if("human")
				new_mob = new /mob/living/carbon/human(user.loc)

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.copy_to(new_mob)

				var/mob/living/carbon/human/H = new_mob
				ready_dna(H)
				if(H.dna)
					H.dna.mutantrace = pick("lizard","golem","slime","plant","fly","shadow","adamantine","skeleton",8;"")
					H.update_body()
			else
				return

		for (var/obj/effect/proc_holder/spell/S in user.spell_list)
			new_mob.spell_list += new S.type

		new_mob.a_intent = "harm"
		if(user.mind)
			user.mind.transfer_to(new_mob)
		else
			new_mob.key = user.key

		new_mob << "<B>Your form morphs into that of a [randomize].</B>"

		del(user)
		return new_mob
		charges--
		..()

/obj/item/weapon/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	projectile_type = "/obj/item/projectile/magic/teleport"
	icon_state = "wand3"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/teleport/zap_self(mob/living/user as mob)
	var/list/turfs = new/list()
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6
	for(var/turf/T in range(user,outer_tele_radius))
		if(T in range(user,inner_tele_radius)) continue
		if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)	continue
		if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)	continue
		turfs += T

	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in orange(user,outer_tele_radius))
			if(!(T in orange(user,inner_tele_radius)))
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)

	var/turf/picked = pick(turfs)

	if(!picked || !isturf(picked))
		return
	user.loc = picked
	charges--
	..()

/obj/item/weapon/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	projectile_type = "/obj/item/projectile/magic/door"
	icon_state = "wand0"
	max_charges = 20 //20, 10, 10, 7

/obj/item/weapon/gun/magic/wand/door/zap_self()
	return

/obj/item/weapon/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	projectile_type = "/obj/item/projectile/magic/fireball"
	icon_state = "wand2"
	max_charges = 8 //8, 4, 4, 3

/obj/item/weapon/gun/magic/wand/fireball/zap_self(mob/living/user as mob)
	if(alert(user, "Zapping yourself with a wand of fireball is probably a bad idea, do it anyway?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
		charges--
		..()