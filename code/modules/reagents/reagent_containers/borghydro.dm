

/obj/item/weapon/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = FPRINT
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()

	process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				if(mode == 1 && reagents.total_volume < 30) 	//Don't recharge reagents and drain power if the storage is full.
					R.cell.use(charge_cost) 					//Take power from borg...
					reagents.add_reagent("tricordrazine",5)		//And fill hypo with reagent.
				if(mode == 2 && reagents.total_volume < 30)
					R.cell.use(charge_cost)
					reagents.add_reagent("inaprovaline", 5)
				if(mode == 3 && reagents.total_volume < 30)
					R.cell.use(charge_cost)
					reagents.add_reagent("spaceacillin", 5)
		//update_icon()
		return 1

/obj/item/weapon/reagent_containers/borghypo/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		user << "\red The injector is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		user << "\blue You inject [M] with the injector."
		M << "\red You feel a tiny prick!"

		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected.  [reagents.total_volume] units remaining."
	return

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)		//Change the mode
	if(mode == 1)
		mode = 2
		charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
		reagents.clear_reagents() //Flushes whatever was in the storage previously, so you don't get chems all mixed up.
		user << "\blue Synthesizer is now producing 'Inaprovaline'."
		return
	if(mode == 2)
		mode = 3
		charge_tick = 0
		reagents.clear_reagents()
		user << "\blue Synthesizer is now producing 'Spaceacillin'."
		return
	if(mode == 3)
		mode = 1
		charge_tick = 0
		reagents.clear_reagents()
		user << "\blue Synthesizer is now producing 'Tricordrazine'."
		return

/obj/item/weapon/reagent_containers/borghypo/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return

	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue It currently has [R.volume] units of [R.name] stored."
	else
		usr << "\blue It is currently empty. Allow some time for the internal syntheszier to produce more."