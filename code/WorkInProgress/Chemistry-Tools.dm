// Bottles transfer 50 units
// Beakers transfer 30 units
// Syringes transfer 15 units
// Droppers transfer 5 units

//BUG!!!: reactions on splashing etc cause errors because stuff gets deleted before it executes.
//		  Bandaid fix using spawn - very ugly, need to fix this.

///////////////////////////////Grenades
/obj/item/weapon/chem_grenade
	name = "metal casing"
	icon_state = "chemg1"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/list/beakers = new/list()
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/assembly/time_ignite) && !stage)
			user << "\blue You add [W] to the metal casing."
			playsound(src.loc, 'Screwdriver2.ogg', 25, -3)
			del(W) //Okay so we're not really adding anything here. cheating.
			icon_state = "chemg2"
			name = "unsecured grenade"
			stage = 1
		else if(istype(W,/obj/item/weapon/screwdriver) && stage == 1)
			if(beakers.len)
				user << "\blue You lock the assembly."
				playsound(src.loc, 'Screwdriver.ogg', 25, -3)
				name = "grenade"
				icon_state = "chemg3"
				stage = 2
			else
				user << "\red You need to add at least one beaker before locking the assembly."
		else if (istype(W,/obj/item/weapon/reagent_containers/glass) && stage == 1)
			if(beakers.len == 2)
				user << "\red The grenade can not hold more containers."
				return
			else
				if(W.reagents.total_volume)
					user << "\blue You add \the [W] to the assembly."
					user.drop_item()
					W.loc = src
					beakers += W
				else
					user << "\red \the [W] is empty."

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..()
		if (!src.state && stage == 2)
			user << "\red You prime the grenade! 3 seconds!"
			src.state = 1
			src.icon_state = "chemg4"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(30)
				explode()
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)

	attack_self(mob/user as mob)
		if (!src.state && stage == 2)
			user << "\red You prime the grenade! 3 seconds!"
			src.state = 1
			src.icon_state = "chemg4"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(30)
				explode()

	attack_hand()
		walk(src,0)
		return ..()
	attack_paw()
		return attack_hand()

	proc
		explode()
			var/has_reagents = 0
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				if(G.reagents.total_volume) has_reagents = 1

			if(!has_reagents)
				playsound(src.loc, 'Screwdriver2.ogg', 50, 1)
				state = 0
				return

			playsound(src.loc, 'bamf.ogg', 50, 1)

			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(src, G.reagents.total_volume)

			if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
				var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread()
				steam.set_up(10, 0, get_turf(src))
				steam.attach(src)
				steam.start()

				for(var/atom/A in view(3, src.loc))
					if( A == src ) continue
					src.reagents.reaction(A, 1, 10)


			invisibility = 100 //Why am i doing this?
			spawn(50)		   //To make sure all reagents can work
				del(src)	   //correctly before deleting the grenade.


/obj/item/weapon/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("aluminium", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers += B1
		beakers += B2

/obj/item/weapon/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 30)
		B2.reagents.add_reagent("water", 10)
		B2.reagents.add_reagent("cleaner", 10)

		beakers += B1
		beakers += B2
/*
/obj/item/weapon/chem_grenade/poo
	name = "poo grenade"
	desc = "A ShiTastic! brand biological warfare charge. Not very effective unless the target is squeamish."
	icon_state = "chemg3"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/B2 = new(src)

		B1.reagents.add_reagent("poo", 30)
		B2.reagents.add_reagent("poo", 30)

		beakers += B1
		beakers += B2
*/
///////////////////////////////Grenades

/obj/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	icon = 'gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

	examine()
		set src in view(2)
		..()
		usr << "\icon [src] Syringe gun:"
		usr << "\blue [syringes] / [max_syringes] Syringes."

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				user << "\blue You put the syringe in the syringe gun."
				user << "\blue [syringes.len] / [max_syringes] Syringes."
			else
				usr << "\red The syringe gun cannot hold more syringes."

	afterattack(obj/target, mob/user , flag)
		if(!isturf(target.loc) || target == user) return

		if(syringes.len)
			spawn(0) fire_syringe(target,user)
		else
			usr << "\red The syringe gun is empty."

	proc
		fire_syringe(atom/target, mob/user)
			if (locate (/obj/table, src.loc))
				return
			else
				var/turf/trg = get_turf(target)
				var/obj/syringe_gun_dummy/D = new/obj/syringe_gun_dummy(get_turf(src))
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				S.reagents.trans_to(D, S.reagents.total_volume)
				syringes -= S
				del(S)
				D.icon_state = "syringeproj"
				D.name = "syringe"
				playsound(user.loc, 'syringeproj.ogg', 50, 1)

				for(var/i=0, i<6, i++)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/carbon/M in D.loc)
						if(!istype(M,/mob/living/carbon)) continue
						if(M == user) continue
						D.reagents.trans_to(M, 15)
						M.bruteloss += 5
						for(var/mob/O in viewers(world.view, D))
							O.show_message(text("\red [] was hit by the syringe!", M), 1)

						del(D)

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density) del(D)

					sleep(1)

				spawn(10) del(D)

				return



/obj/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					new /obj/effects/water(src.loc)
					del(src)
					return
			if(3.0)
				if (prob(5))
					new /obj/effects/water(src.loc)
					del(src)
					return
			else
		return

	blob_act()
		if(prob(25))
			new /obj/effects/water(src.loc)
			del(src)



/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		return
	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass/
	name = " "
	desc = " "
	icon = 'chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	examine()
		set src in view(2)
		..()
		usr << "\blue It contains:"
		if(!reagents) return
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)

		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, 10)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		else if(reagents.total_volume  && !istype(target,/obj/machinery/chem_master/) && !istype(target,/obj/table) && !istype(target,/obj/secure_closet) && !istype(target,/obj/closet) && !istype(target,/obj/item/weapon/storage) && !istype(target, /obj/machinery/atmospherics/unary/cryo_cell) && !istype(target, /obj/item/weapon/chem_grenade) && !istype(target, /obj/machinery/bot/medbot))
			user << "\blue You splash the solution onto [target]."
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	var/filled = 0

	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "\red You cannot directly fill this object."
				return

			if(ismob(target))
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] drips something onto []!</B>", user, target), 1)
				src.reagents.reaction(target, TOUCH)

			spawn(5) src.reagents.trans_to(target, 5)
			user << "\blue You transfer 5 units of the solution."
			filled = 0
			icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
				user << "\red You cannot directly remove reagents from [target]."
				return

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			target.reagents.trans_to(src, 5)

			user << "\blue You fill the dropper with 5 units of the solution."

			filled = 1
			icon_state = "dropper[filled]"

		return
////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	var/mode = "d"

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
		switch(mode)
			if("d")
				mode = "i"
			if("i")
				mode = "d"
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if("d")
				if(ismob(target)) return //Blood?

				if(!target.reagents.total_volume)
					user << "\red [target] is empty."
					return

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(!target.is_open_container() && !istype(target,/obj/reagent_dispensers))
					user << "\red You cannot directly remove reagents from this object."
					return

				target.reagents.trans_to(src, 5)

				user << "\blue You fill the syringe with 5 units of the solution."

			if("i")
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food))
					user << "\red You cannot directly fill this object."
					return

				if(ismob(target) && target != user)
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
					if(!do_mob(user, target)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)

				spawn(5)
					src.reagents.trans_to(target, 5)
					user << "\blue You inject 5 units of the solution. The syringe now contains [src.reagents.total_volume] units."
		return

	proc
		update_icon()
			var/rounded_vol = round(reagents.total_volume,5)
			if(ismob(loc))
				icon_state = "[mode][rounded_vol]"
			else
				icon_state = "[rounded_vol]"
			item_state = "syringe_[rounded_vol]"

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/// Snacks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	var/heal_amt = 0
	proc
		heal(var/mob/M)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				for(var/A in H.organs)
					var/datum/organ/external/affecting = null
					if(!H.organs[A])	continue
					affecting = H.organs[A]
					if(!istype(affecting, /datum/organ/external))	continue
					if(affecting.heal_damage(src.heal_amt, src.heal_amt))
						H.UpdateDamageIcon()
					else
						H.UpdateDamage()
			else
				M.bruteloss = max(0, M.bruteloss - src.heal_amt)
				M.fireloss = max(0, M.fireloss - src.heal_amt)
			M.updatehealth()

/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'food.dmi'
	icon_state = null
	var/amount = 3
	heal_amt = 1

	New()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(!src.amount)
			user << "\red None of [src] left, oh no!"
			del(src)
			return 0
		if(istype(M, /mob/living/carbon/human))
			if(M == user)
				M << "\blue You take a bite of [src]."
				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						reagents.trans_to(M, reagents.total_volume)
				src.amount--
				M.nutrition += src.heal_amt * 10
				M.poo += 0.1
				src.heal(M)
				playsound(M.loc,'eatfood.ogg', rand(10,50), 1)
				if(!src.amount)
					user << "\red You finish eating [src]."
					del(src)
				return 1
			else
				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] attempts to feed [M] [src].", 1)
				if(!do_mob(user, M)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] feeds [M] [src].", 1)

				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						reagents.trans_to(M, reagents.total_volume)
				src.amount--
				M.nutrition += src.heal_amt * 10
				M.poo += 0.1
				src.heal(M)
				playsound(M.loc, 'eatfood.ogg', rand(10,50), 1)
				if(!src.amount)
					user << "\red [M] finishes eating [src]."
					del(src)
				return 1


		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

////////////////////////////////////////////////////////////////////////////////
/// Snacks. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'food.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		update_gulp_size()

	proc
		update_gulp_size()
			gulp_size = round(reagents.total_volume / 5)
			if (gulp_size < 5) gulp_size = 5

	on_reagent_change()
		update_gulp_size()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			M.urine += 0.1
			return 1

		else if( istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			M.urine += 0.1
			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(istype(target, /obj/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, 10)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, 10)
			user << "\blue You transfer [trans] units of the solution to [target]."

		return
////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'chemical.dmi'
	icon_state = null
	item_state = "pill"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		icon_state = "pill[rand(1,20)]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(M == user)
			M << "\blue You swallow [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to force [M] to swallow [src].", 1)

			if(!do_mob(user, M)) return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] forces [M] to swallow [src].", 1)

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)

			return 1

		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return

	afterattack(obj/target, mob/user , flag)

		if(target.is_open_container() == 1 && target.reagents)
			if(!target.reagents.total_volume)
				user << "\red [target] is empty. Cant dissolve pill."
				return
			user << "\blue You dissolve the pill in [target]"
			reagents.trans_to(target, reagents.total_volume)
			for(var/mob/O in viewers(2, user))
				O.show_message("\red [user] puts something in [target].", 1)
			spawn(5)
				del(src)

		return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Subtypes.
////////////////////////////////////////////////////////////////////////////////

//Glasses
/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0

	amount_per_transfer_from_this = 10
	flags = FPRINT | OPENCONTAINER
	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src

	attackby(var/obj/D, mob/user as mob)
		if(istype(D, /obj/item/device/prox_sensor))
			var/obj/item/weapon/bucket_sensor/B = new /obj/item/weapon/bucket_sensor
			B.loc = user
			if (user.r_hand == D)
				user.u_equip(D)
				user.r_hand = B
			else
				user.u_equip(D)
				user.l_hand = B
			B.layer = 20
			user << "You add the sensor to the bucket"
			del(D)
			del(src)

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER


/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent("fluorosurfactant", 20)


/obj/item/weapon/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beakerlarge"
	item_state = "beaker"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

/obj/item/weapon/reagent_containers/glass/bottle/
	name = "bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		icon_state = "bottle[rand(1,20)]"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle12"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle20"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle17"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 30)



/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 30 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	on_reagent_change()
		if(reagents.total_volume)
			icon_state = "beaker1"
		else
			icon_state = "beaker0"

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	name = "beaker"
	desc = "A beaker. Can hold up to 30 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("cryoxadone", 30)


//Syringes
/obj/item/weapon/reagent_containers/syringe/robot
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 7)
		R.add_reagent("anti_toxin", 8)
		mode = "i"
		update_icon()

/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("inaprovaline", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("anti_toxin", 15)
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.maximum_volume = 15
		R.my_atom = src
		R.add_reagent("spaceacillin", 15)
		update_icon()

//Snacks
/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that shit looks good. I bet it's got nougat. Fuck."
	icon_state = "candy"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	heal_amt = 1
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "frosted donut"
			src.heal_amt = 2
	heal(var/mob/M)
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	amount = 1
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/humanmeat
	name = "-meat"
	desc = "A slab of meat"
	icon_state = "meat"
	var/subjectname = ""
	var/subjectjob = null
	amount = 1


/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "This burger gives off an air of awkwardness."
	icon_state = "assburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round."
	icon_state = "faggot"
	amount = 1
	heal_amt = 2
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	heal_amt = 1
	amount = 1
	var/warm = 0
	heal(var/mob/M)
		if(src.warm && M.reagents)
			M.reagents.add_reagent("tricordrazine",15)
		else
			M << "\red It's just not good enough cold.."
		..()

	proc/cooltime()
		if (src.warm)
			spawn( 4200 )
				src.warm = 0
				src.name = "donk-pocket"
		return

/obj/item/weapon/reagent_containers/food/snacks/humanburger
	name = "-burger"
	var/hname = ""
	var/job = null
	desc = "A bloody burger."
	icon_state = "hburger"
	amount = 5
	heal_amt = 2
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "mburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	amount = 30
	heal_amt = 5
/*	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		R.add_reagent("cholesterol", 20)*/
	heal(var/mob/M)
		..()


/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	amount = 5
	heal_amt = 6
	New()
/*		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src
		R.add_reagent("cholesterol", 10)*/
	heal(var/mob/M)
		..()


/obj/item/weapon/reagent_containers/food/snacks/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	amount = 25
	heal_amt = 3
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	amount = 4
	heal_amt = 4
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	amount = 15
	heal_amt = 3
	heal(var/mob/M)
		..()
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
			W.icon = 'kitchen.dmi'
			W.icon_state = "forkloaded"
			world << "[user] takes a piece of omelette with his fork!"

/obj/item/weapon/reagent_containers/food/snacks/omeletteforkload
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	amount = 1
	heal_amt = 4
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	amount = 4
	heal_amt = 6
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("nanites", 5)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("xenomicrobes", 5)

/obj/item/weapon/reagent_containers/food/snacks/monkeymeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	amount = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	amount = 5
	heal_amt = 2

//Drinks
/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("coffee", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola
	name = "space cola"
	desc = "Cola. in space."
	icon_state = "cola"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. in space."
	icon_state = "beer"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("beer", 30)

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "Milk. By Cows. Cows in space."
	icon_state = "milk"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("milk", 50)

//Pills
/obj/item/weapon/reagent_containers/pill/antitox
	name = "Anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("anti_toxin", 50)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill11"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("kelotane", 30)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill20"

	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("inaprovaline", 30)

//Dispensers
/obj/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("water",1000)

/obj/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("fuel",1000)

/obj/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("beer",1000)

///////////////////////////////////////////////////////////////////////////////////////////////////// Meatbread slicing RIGHT BELOW*************
/////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/meatbread/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/kitchenknife /*|| /obj/item/weapon/scalpel*/))
		world << "[usr] slices the meatbread!"
		new /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice (src.loc)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/cheesewheel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/kitchenknife /* || /obj/item/weapon/scalpel*/))
		world << "[usr] slices the cheese wheel!"
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge (src.loc)
		del(src)
		return
