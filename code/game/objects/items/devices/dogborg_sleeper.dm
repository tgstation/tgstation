// Dogborg Sleeper units

/obj/item/dogborg/sleeper
	name = "hound sleeper"
	desc = "nothing should see this."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "sleeper"
	w_class = WEIGHT_CLASS_TINY
	var/mob/living/carbon/patient = null
	var/mob/living/silicon/robot/hound = null
	var/inject_amount = 10
	var/min_health = -100
	var/cleaning = FALSE
	var/cleaning_cycles = 10
	var/patient_laststat = null
	var/list/injection_chems = list("antitoxin", "epinephrine", "morphine", "salbutamol", "bicaridine", "kelotane")
	var/eject_port = "ingestion"
	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	var/list/items_preserved = list()
	var/static/list/important_items = typecacheof(list(
		/obj/item/hand_tele,
		/obj/item/card/id,
		/obj/item/aicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/suit/armor,
		/obj/item/documents,
		/obj/item/nuke_core,
		/obj/item/nuke_core_container,
		/obj/item/areaeditor/blueprints,
		/obj/item/documents/syndicate,
		/obj/item/disk/nuclear,
		/obj/item/bombcore,
		/obj/item/grenade,
		/obj/item/storage
		))

// Bags are prohibited from this due to the potential explotation of objects, same with brought

/obj/item/dogborg/sleeper/New()
	..()
	update_icon()
	item_flags |= NOBLUDGEON //No more attack messages

/obj/item/dogborg/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/dogborg/sleeper/afterattack(mob/living/carbon/target, mob/living/silicon/user, proximity)
	hound = loc
	if(!proximity)
		return
	if(!iscarbon(target))
		return
	if(!(target.client && target.client.prefs && target.client.prefs.toggles && (target.client.prefs.toggles & MEDIHOUND_SLEEPER)))
		to_chat(user, "<span class='warning'>This person is incompatible with our equipment.</span>")
		return
	if(target.buckled)
		to_chat(user, "<span class='warning'>The user is buckled and can not be put into your [src].</span>")
		return
	if(patient)
		to_chat(user, "<span class='warning'>Your [src] is already occupied.</span>")
		return
	user.visible_message("<span class='warning'>[hound.name] is carefully inserting [target.name] into their [src].</span>", "<span class='notice'>You start placing [target] into your [src]...</span>")
	if(!patient && iscarbon(target) && !target.buckled && do_after (user, 50, target = target))

		if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
			return //If they moved away, you can't eat them.

		if(patient) return //If you try to eat two people at once, you can only eat one.

		else //If you don't have someone in you, proceed.
			if(!isjellyperson(target) && ("toxin" in injection_chems))
				injection_chems -= "toxin"
				injection_chems += "antitoxin"
			if(isjellyperson(target) && !("toxin" in injection_chems))
				injection_chems -= "antitoxin"
				injection_chems += "toxin"
			target.forceMove(src)
			target.reset_perspective(src)
			update_gut()
			START_PROCESSING(SSobj, src)
			user.visible_message("<span class='warning'>[hound.name]'s medical pod lights up and expands as [target.name] slips inside into their [src.name].</span>", "<span class='notice'>Your medical pod lights up as [target] slips into your [src]. Life support functions engaged.</span>")
			message_admins("[key_name(hound)] has sleeper'd [key_name(patient)] as a dogborg. [ADMIN_JMP(src)]")
			playsound(hound, 'sound/effects/bin_close.ogg', 100, 1)

/obj/item/dogborg/sleeper/container_resist(mob/living/user)
	hound = loc
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	if(user.a_intent == INTENT_HELP)
		return
	user.visible_message("<span class='notice'>You see [user] kicking against the expanded material of [hound.name]'s gut!</span>", \
		"<span class='notice'>You struggle inside [src], kicking the release with your foot... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a thump from [hound.name].</span>")
	if(do_after(user, breakout_time, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [hound.name]!</span>", \
			"<span class='notice'>You successfully break out of [hound.name]!</span>")
		go_out()

/obj/item/dogborg/sleeper/proc/go_out(var/target)
	hound = loc
	hound.setClickCooldown(50)
	if(length(contents) > 0)
		hound.visible_message("<span class='warning'>[hound.name] empties out their contents via their release port.</span>", "<span class='notice'>You empty your contents via your release port.</span>")
		if(target)
			if(iscarbon(target))
				var/mob/living/carbon/person = target
				person.forceMove(get_turf(src))
				person.reset_perspective()
			else
				var/obj/T = target
				T.loc = hound.loc
		else
			for(var/C in contents)
				if(iscarbon(C))
					var/mob/living/carbon/person = C
					person.forceMove(get_turf(src))
					person.reset_perspective()
				else
					var/obj/T = C
					T.loc = hound.loc
		items_preserved.Cut()
		update_gut()
		cleaning = FALSE
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	else //You clicked eject with nothing in you, let's just reset stuff to be sure.
		items_preserved.Cut()
		cleaning = FALSE
		update_gut()

/obj/item/dogborg/sleeper/attack_self(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/item/dogborg/sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "dogborg_sleeper", name, 375, 550, master_ui, state)
		ui.open()

/obj/item/dogborg/sleeper/ui_data()
	var/list/data = list()
	data["occupied"] = patient ? 1 : 0

	if(cleaning && length(contents - items_preserved))
		data["items"] = "Self-cleaning mode active: [length(contents - items_preserved)] object(s) remaining."
	data["cleaning"] = cleaning
	if(injection_chems != null)
		data["chem"] = list()
		for(var/chem in injection_chems)
			var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
			data["chem"] += list(list("name" = R.name, "id" = R.id))

	data["occupant"] = list()
	var/mob/living/mob_occupant = patient
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = mob_occupant.health
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
		data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
		data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
		data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.getBrainLoss()
		data["occupant"]["reagents"] = list()
		if(mob_occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/item/dogborg/sleeper/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("eject")
			go_out()
			. = TRUE
		if("inject")
			var/chem = params["chem"]
			if(!patient)
				return
			inject_chem(chem)
			. = TRUE
		if("cleaning")
			if(!contents)
				to_chat(src, "Your [src] is already cleaned.")
				return
			if(patient)
				to_chat(patient, "<span class='danger'>[hound.name]'s [src] fills with caustic enzymes around you!</span>")
			to_chat(src, "<span class='danger'>Cleaning process enabled.</span>")
			clean_cycle()
			. = TRUE

/obj/item/dogborg/sleeper/proc/update_gut()
	//Well, we HAD one, what happened to them?
	if(patient in contents)
		if(patient_laststat != patient.stat)
			if(patient.stat & DEAD)
				hound.sleeper_r = 1
				hound.sleeper_g = 0
				patient_laststat = patient.stat
			else
				hound.sleeper_r = 0
				hound.sleeper_g = 1
				patient_laststat = patient.stat
			//Update icon
			hound.update_icons()
		//Return original patient
		return(patient)
	//Check for a new patient
	else
		for(var/mob/living/carbon/human/C in contents)
			patient = C
			if(patient.stat & DEAD)
				hound.sleeper_r = 1
				hound.sleeper_g = 0
				patient_laststat = patient.stat
			else
				hound.sleeper_r = 0
				hound.sleeper_g = 1
				patient_laststat = patient.stat
			//Update icon and return new patient
			hound.update_icons()
			return(C)

	//Cleaning looks better with red on, even with nobody in it
	if(cleaning && !patient)
		hound.sleeper_r = 1
		hound.sleeper_g = 0
	//Couldn't find anyone, and not cleaning
	else if(!cleaning && !patient)
		hound.sleeper_r = 0
		hound.sleeper_g = 0

	patient_laststat = null
	patient = null
	hound.update_icons()
	return

//Gurgleborg process
/obj/item/dogborg/sleeper/proc/clean_cycle()
	//Sanity
	for(var/I in items_preserved)
		if(!(I in contents))
			items_preserved -= I
	var/list/touchable_items = contents - items_preserved
	if(cleaning_cycles)
		cleaning_cycles--
		cleaning = TRUE
		for(var/mob/living/carbon/human/T in (touchable_items))
			if((T.status_flags & GODMODE) || !T.digestable)
				items_preserved += T
			else
				T.adjustBruteLoss(2)
				T.adjustFireLoss(3)
				update_gut()
		if(contents)
			var/atom/target = pick(touchable_items)
			if(iscarbon(target)) //Handle the target being a mob
				var/mob/living/carbon/T = target
				if(T.stat == DEAD && T.digestable)	//Mob is now dead
					message_admins("[key_name(hound)] has digested [key_name(T)] as a dogborg. ([hound ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[hound.x];Y=[hound.y];Z=[hound.z]'>JMP</a>" : "null"])")
					to_chat(hound,"<span class='notice'>You feel your belly slowly churn around [T], breaking them down into a soft slurry to be used as power for your systems.</span>")
					to_chat(T,"<span class='notice'>You feel [hound]'s belly slowly churn around your form, breaking you down into a soft slurry to be used as power for [hound]'s systems.</span>")
					hound.cell.give(30000) //Fueeeeellll
					T.stop_sound_channel(CHANNEL_PRED)
					playsound(get_turf(hound),"death_pred",50,0,-6,0,channel=CHANNEL_PRED,ignore_walls = FALSE)
					T.stop_sound_channel(CHANNEL_PRED)
					T.playsound_local("death_prey",60)
					for(var/belly in T.vore_organs)
						var/obj/belly/B = belly
						for(var/atom/movable/thing in B)
							thing.forceMove(src)
							if(ismob(thing))
								to_chat(thing, "As [T] melts away around you, you find yourself in [hound]'s [name]")
					for(var/obj/item/W in T)
						if(!T.dropItemToGround(W))
							qdel(W)
					qdel(T)
					update_gut()
		//Handle the target being anything but a mob
			else if(isobj(target))
				var/obj/T = target
				if(T.type in important_items) //If the object is in the items_preserved global list
					items_preserved += T
				//If the object is not one to preserve
				else
					qdel(T)
					update_gut()
					hound.cell.give(10)
	else
		cleaning_cycles = initial(cleaning_cycles)
		cleaning = FALSE
		to_chat(hound, "<span class='notice'>Your [src] chimes it ends its self-cleaning cycle.</span>")//Belly is entirely empty
		update_gut()

	if(!length(contents))
		to_chat(hound, "<span class='notice'>Your [src] is now clean. Ending self-cleaning cycle.</span>")
		cleaning = FALSE
		update_gut()
		return

//sound effects
	for(var/mob/living/M in contents)
		if(prob(50))
			M.stop_sound_channel(CHANNEL_PRED)
			playsound(get_turf(hound),"digest_pred",35,0,-6,0,channel=CHANNEL_PRED,ignore_walls = FALSE)
			M.stop_sound_channel(CHANNEL_PRED)
			M.playsound_local("digest_prey",60)

	if(cleaning)
		addtimer(CALLBACK(src, .proc/clean_cycle), 50)

/obj/item/dogborg/sleeper/proc/CheckAccepted(obj/item/I)
	return is_type_in_typecache(I, important_items)

/obj/item/dogborg/sleeper/proc/inject_chem(chem)
	if(hound.cell.charge <= 800) //This is so borgs don't kill themselves with it. Remember, 750 charge used every injection.
		to_chat(hound, "<span class='notice'>You don't have enough power to synthesize fluids.</span>")
		return
	if(patient.reagents.get_reagent_amount(chem) + 10 >= 20) //Preventing people from accidentally killing themselves by trying to inject too many chemicals!
		to_chat(hound, "<span class='notice'>Your stomach is currently too full of fluids to secrete more fluids of this kind.</span>")
		return
	patient.reagents.add_reagent(chem, 10)
	hound.cell.use(750) //-750 charge per injection
	var/units = round(patient.reagents.get_reagent_amount(chem))
	to_chat(hound, "<span class='notice'>Injecting [units] unit\s of [chem] into occupant.</span>") //If they were immersed, the reagents wouldn't leave with them.

/obj/item/dogborg/sleeper/medihound //Medihound sleeper
	name = "Mobile Sleeper"
	desc = "Equipment for medical hound. A mounted sleeper that stabilizes patients and can inject reagents in the borg's reserves."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "sleeper"

/obj/item/dogborg/sleeper/K9 //The K9 portabrig
	name = "Mobile Brig"
	desc = "Equipment for a K9 unit. A mounted portable-brig that holds criminals."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "sleeperb"
	inject_amount = 0
	min_health = -100
	injection_chems = null //So they don't have all the same chems as the medihound!

/obj/item/storage/attackby(obj/item/dogborg/sleeper/K9, mob/user, proximity)
	if(istype(K9))
		K9.afterattack(src, user ,1)
	else
		. = ..()

/obj/item/dogborg/sleeper/K9/afterattack(var/atom/movable/target, mob/living/silicon/user, proximity)
	hound = loc

	if(!istype(target))
		return
	if(!proximity)
		return
	if(target.anchored)
		return
	if(isobj(target))
		to_chat(user, "You are above putting such trash inside of yourself.")
		return
	if(iscarbon(target))
		var/mob/living/carbon/brigman = target
		if (!brigman.devourable)
			to_chat(user, "The target registers an error code. Unable to insert into [src].")
			return
		if(patient)
			to_chat(user,"<span class='warning'>Your [src] is already occupied.</span>")
			return
		if(brigman.buckled)
			to_chat(user,"<span class='warning'>[brigman] is buckled and can not be put into your [src].</span>")
			return
		user.visible_message("<span class='warning'>[hound.name] is ingesting [brigman] into their [src].</span>", "<span class='notice'>You start ingesting [brigman] into your [src.name]...</span>")
		if(do_after(user, 30, target = brigman) && !patient && !brigman.buckled)
			if(!in_range(src, brigman)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't eat them.
			brigman.forceMove(src)
			brigman.reset_perspective(src)
			update_gut()
			START_PROCESSING(SSobj, src)
			user.visible_message("<span class='warning'>[hound.name]'s mobile brig clunks in series as [brigman] slips inside.</span>", "<span class='notice'>Your mobile brig groans lightly as [brigman] slips inside.</span>")
			playsound(hound, 'sound/effects/bin_close.ogg', 80, 1) // Really don't need ERP sound effects for robots
		return
	return

/obj/item/dogborg/sleeper/compactor //Janihound gut.
	name = "garbage processor"
	desc = "A mounted garbage compactor unit with fuel processor."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "compactor"
	inject_amount = 0
	min_health = -100
	injection_chems = null //So they don't have all the same chems as the medihound!
	var/max_item_count = 30

/obj/item/storage/attackby(obj/item/dogborg/sleeper/compactor, mob/user, proximity) //GIT CIRCUMVENTED YO!
	if(istype(compactor))
		compactor.afterattack(src, user ,1)
	else
		. = ..()

/obj/item/dogborg/sleeper/compactor/afterattack(var/atom/movable/target, mob/living/silicon/user, proximity)//GARBO NOMS
	hound = loc
	var/obj/item/target_obj = target
	if(!istype(target))
		return
	if(!proximity)
		return
	if(target.anchored)
		return
	if(length(contents) > (max_item_count - 1))
		to_chat(user,"<span class='warning'>Your [src] is full. Eject or process contents to continue.</span>")
		return
	if(isobj(target))
		if(CheckAccepted(target))
			to_chat(user,"<span class='warning'>\The [target] registers an error code to your [src]</span>")
			return
		if(target_obj.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user,"<span class='warning'>\The [target] is too large to fit into your [src]</span>")
			return
		user.visible_message("<span class='warning'>[hound.name] is ingesting [target.name] into their [src.name].</span>", "<span class='notice'>You start ingesting [target] into your [src.name]...</span>")
		if(do_after(user, 15, target = target) && length(contents) < max_item_count)
			if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't eat them. This still applies to items, don't magically eat things I picked up already.
			target.forceMove(src)
			user.visible_message("<span class='warning'>[hound.name]'s garbage processor groans lightly as [target.name] slips inside.</span>", "<span class='notice'>Your garbage compactor groans lightly as [target] slips inside.</span>")
			playsound(hound, 'sound/machines/disposalflush.ogg', 50, 1)
			if(length(contents) > 11) //grow that tum after a certain junk amount
				hound.sleeper_r = 1
				hound.update_icons()
			else
				hound.sleeper_r = 0
				hound.update_icons()
		return

	else if(iscarbon(target))
		var/mob/living/carbon/trashman = target
		if (!trashman.devourable)
			to_chat(user, "<span class='warning'>[target] registers an error code to your [src]</span>")
			return
		if(patient)
			to_chat(user,"<span class='warning'>Your [src] is already occupied.</span>")
			return
		if(trashman.buckled)
			to_chat(user,"<span class='warning'>[trashman] is buckled and can not be put into your [src].</span>")
			return
		user.visible_message("<span class='warning'>[hound.name] is ingesting [trashman] into their [src].</span>", "<span class='notice'>You start ingesting [trashman] into your [src.name]...</span>")
		if(do_after(user, 30, target = trashman) && !patient && !trashman.buckled && length(contents) < max_item_count)
			if(!in_range(src, trashman)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't eat them.
			trashman.forceMove(src)
			trashman.reset_perspective(src)
			update_gut()
			START_PROCESSING(SSobj, src)
			user.visible_message("<span class='warning'>[hound.name]'s garbage processor groans lightly as [trashman] slips inside.</span>", "<span class='notice'>Your garbage compactor groans lightly as [trashman] slips inside.</span>")
			playsound(hound, 'sound/effects/bin_close.ogg', 80, 1)
		return
	return
