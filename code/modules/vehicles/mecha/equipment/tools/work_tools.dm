
//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Cable layer.


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	tool_behaviour = TOOL_RETRACTOR
	range = MECHA_MELEE
	toolspeed = 0.8
	harmful = TRUE
	mech_flags = EXOSUIT_MODULE_RIPLEY
	///Bool for whether we beat the hell out of things we punch (and tear off their arms)
	var/killer_clamp = FALSE
	///How much base damage this clamp does
	var/clamp_damage = 20
	///Var for the chassis we are attached to, needed to access ripley contents and such
	var/obj/vehicle/sealed/mecha/working/ripley/cargo_holder
	///Audio for using the hydraulic clamp
	var/clampsound = 'sound/mecha/hydraulic.ogg'

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(!.)
		return
	if(!istype(M, /obj/vehicle/sealed/mecha/working/ripley))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	cargo_holder = M

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	. = ..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(mob/source, atom/target, params)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		var/have_ammo
		for(var/obj/item/mecha_ammo/box in cargo_holder.cargo)
			if(istype(box, /obj/item/mecha_ammo) && box.rounds)
				have_ammo = TRUE
				if(M.ammo_resupply(box, source, TRUE))
					return
		if(have_ammo)
			to_chat(source, "No further supplies can be provided to [M].")
		else
			to_chat(source, "No providable supplies found in cargo hold")

	else if(isobj(target))
		var/obj/clamptarget = target
		if(istype(clamptarget, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/targetfiredoor = clamptarget
			playsound(chassis, clampsound, 50, FALSE, -6)
			targetfiredoor.try_to_crowbar(src, source)
			return
		if(istype(clamptarget, /obj/machinery/door/airlock/))
			var/obj/machinery/door/airlock/targetairlock = clamptarget
			playsound(chassis, clampsound, 50, FALSE, -6)
			targetairlock.try_to_crowbar(src, source)
			return
		if(clamptarget.anchored)
			to_chat(source, "[icon2html(src, source)]<span class='warning'>[target] is firmly secured!</span>")
			return
		if(LAZYLEN(cargo_holder.cargo) >= cargo_holder.cargo_capacity)
			to_chat(source, "[icon2html(src, source)]<span class='warning'>Not enough room in cargo compartment!</span>")
			return
		playsound(chassis, clampsound, 50, FALSE, -6)
		chassis.visible_message("<span class='notice'>[chassis] lifts [target] and starts to load it into cargo compartment.</span>")
		clamptarget.set_anchored(TRUE)
		if(!do_after_cooldown(target, source))
			clamptarget.set_anchored(initial(clamptarget.anchored))
			return
		LAZYADD(cargo_holder.cargo, clamptarget)
		clamptarget.forceMove(chassis)
		clamptarget.set_anchored(FALSE)
		if(!cargo_holder.box && istype(clamptarget, /obj/structure/ore_box))
			cargo_holder.box = clamptarget
		to_chat(source, "[icon2html(src, source)]<span class='notice'>[target] successfully loaded.</span>")
		log_message("Loaded [clamptarget]. Cargo compartment capacity: [cargo_holder.cargo_capacity - LAZYLEN(cargo_holder.cargo)]", LOG_MECHA)

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
		if(source.a_intent == INTENT_HELP)
			step_away(M,chassis)
			if(killer_clamp)
				target.visible_message("<span class='danger'>[chassis] tosses [target] like a piece of paper!</span>", \
					"<span class='userdanger'>[chassis] tosses you like a piece of paper!</span>")
			else
				to_chat(source, "[icon2html(src, source)]<span class='notice'>You push [target] out of the way.</span>")
				chassis.visible_message("<span class='notice'>[chassis] pushes [target] out of the way.</span>", \
				"<span class='notice'>[chassis] pushes you aside.</span>")
			return ..()
		else if(source.a_intent == INTENT_DISARM && iscarbon(M))//meme clamp here
			if(!killer_clamp)
				to_chat(source, "<span class='notice'>You longingly wish to tear [M]'s arms off.</span>")
				return
			var/mob/living/carbon/C = target
			var/torn_off = FALSE
			var/obj/item/bodypart/affected = C.get_bodypart(BODY_ZONE_L_ARM)
			if(affected != null)
				affected.dismember(damtype)
				torn_off = TRUE
			affected = C.get_bodypart(BODY_ZONE_R_ARM)
			if(affected != null)
				affected.dismember(damtype)
				torn_off = TRUE
			if(!torn_off)
				to_chat(source, "<span class='notice'>[M]'s arms are already torn off, you must find a challenger worthy of the kill clamp!</span>")
				return
			playsound(src, get_dismember_sound(), 80, TRUE)
			target.visible_message("<span class='danger'>[chassis] rips [target]'s arms off!</span>", \
						   "<span class='userdanger'>[chassis] rips your arms off!</span>")
			log_combat(source, M, "removed both arms with a real clamp,", "[name]", "(INTENT: [uppertext(source.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
			return ..()

		M.take_overall_damage(clamp_damage)
		if(!M) //get gibbed stoopid
			return
		M.adjustOxyLoss(round(clamp_damage/2))
		M.updatehealth()
		target.visible_message("<span class='danger'>[chassis] squeezes [target]!</span>", \
							"<span class='userdanger'>[chassis] squeezes you!</span>",\
							"<span class='hear'>You hear something crack.</span>")
		log_combat(source, M, "attacked", "[name]", "(INTENT: [uppertext(source.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	return ..()



//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them! This time for real!"
	killer_clamp = TRUE


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake//harmless fake for pranks
	desc = "They won't know what clamped them!"
	energy_drain = 0
	clamp_damage = 0
	killer_clamp = FALSE


/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE|MECHA_RANGED
	mech_flags = EXOSUIT_MODULE_WORKING

/obj/item/mecha_parts/mecha_equipment/extinguisher/Initialize()
	. = ..()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 1000)

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(mob/source, atom/target, params)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		to_chat(source, "[icon2html(src, source)]<span class='notice'>Extinguisher refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, TRUE, -6)
		return

	if(reagents.total_volume <= 0)
		return
	playsound(chassis, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
	var/direction = get_dir(chassis,target)
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T,T1,T2)
	INVOKE_ASYNC(src, .proc/do_extinguish, the_targets, source)
	return ..()

///Creates new water effects and moves them, takes a list of turfs as an argument
/obj/item/mecha_parts/mecha_equipment/extinguisher/proc/do_extinguish(list/targets, mob/user)//this could be made slighty better but extinguisher code sucks even more so...
	for(var/a=0 to 5)//generate new water...
		var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(chassis))
		var/turf/my_target = pick(targets)
		var/datum/reagents/R = new/datum/reagents(5)
		W.reagents = R
		R.my_atom = W
		reagents.trans_to(W,1, transfered_by = user)
		for(var/b=0 to 4)//...and move it 4 tiles
			if(!W)
				return
			step_towards(W,my_target)
			if(!W)
				return
			var/turf/W_turf = get_turf(W)
			W.reagents.expose(W_turf)
			for(var/atom/atm in W_turf)
				W.reagents.expose(atm)
			if(W.loc == my_target)
				break
			sleep(2)

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(!.)
		return
	if(!istype(M, /obj/vehicle/sealed/mecha/working))
		return FALSE


#define MODE_DECONSTRUCT 0
#define MODE_WALL 1
#define MODE_AIRLOCK 2

/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE|MECHA_RANGED
	item_flags = NO_MAT_REDEMPTION
	///determines what we'll so when clicking on a turf
	var/mode = MODE_DECONSTRUCT

/obj/item/mecha_parts/mecha_equipment/rcd/Initialize()
	. = ..()
	GLOB.rcd_list += src

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(mob/source, atom/target, params)
	if(!isturf(target) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3 || istype(target, /turf/open/space/transit))
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, TRUE)

	switch(mode)
		if(MODE_DECONSTRUCT)
			to_chat(source, "[icon2html(src, source)]<span class='notice'>Deconstructing [target]...</span>")
			if(iswallturf(target))
				var/turf/closed/wall/W = target
				if(!do_after_cooldown(W, source))
					return
				W.ScrapeAway()
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				if(!do_after_cooldown(target, source))
					return
				F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
			else if (istype(target, /obj/machinery/door/airlock))
				if(!do_after_cooldown(target, source))
					return
				qdel(target)
		if(MODE_WALL)
			if(isspaceturf(target))
				var/turf/open/space/S = target
				to_chat(source, "[icon2html(src, source)]<span class='notice'>Building Floor...</span>")
				if(!do_after_cooldown(S, source))
					return
				S.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				to_chat(source, "[icon2html(src, source)]<span class='notice'>Building Wall...</span>")
				if(!do_after_cooldown(F, source))
					return
				F.PlaceOnTop(/turf/closed/wall)
		if(MODE_AIRLOCK)
			if(isfloorturf(target))
				to_chat(source, "[icon2html(src, source)]<span class='notice'>Building Airlock...</span>")
				if(!do_after_cooldown(target, source))
					return
				var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
				T.autoclose = TRUE
				playsound(target, 'sound/effects/sparks2.ogg', 50, TRUE)
	chassis.spark_system.start()
	playsound(target, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(MODE_DECONSTRUCT)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>Switched RCD to Deconstruct.</span>")
				energy_drain = initial(energy_drain)
			if(MODE_WALL)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>Switched RCD to Construct Walls and Flooring.</span>")
				energy_drain = 2*initial(energy_drain)
			if(MODE_AIRLOCK)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>Switched RCD to Construct Airlock.</span>")
				energy_drain = 2*initial(energy_drain)

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[<a href='?src=[REF(src)];mode=0'>D</a>|<a href='?src=[REF(src)];mode=1'>C</a>|<a href='?src=[REF(src)];mode=2'>A</a>\]"

#undef MODE_DECONSTRUCT
#undef MODE_WALL
#undef MODE_AIRLOCK

//Dunno where else to put this so shrug
/obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	name = "Ripley MK-II Conversion Kit"
	desc = "A pressurized canopy attachment kit for an Autonomous Power Loader Unit \"Ripley\" MK-I mecha, to convert it to the slower, but space-worthy MK-II design. This kit cannot be removed, once applied."
	icon_state = "ripleyupgrade"
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/can_attach(obj/vehicle/sealed/mecha/working/ripley/M)
	if(M.type != /obj/vehicle/sealed/mecha/working/ripley)
		to_chat(loc, "<span class='warning'>This conversion kit can only be applied to APLU MK-I models.</span>")
		return FALSE
	if(LAZYLEN(M.cargo))
		to_chat(loc, "<span class='warning'>[M]'s cargo hold must be empty before this conversion kit can be applied.</span>")
		return FALSE
	if(!(M.mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(loc, "<span class='warning'>[M] must have maintenance protocols active in order to allow this conversion kit.</span>")
		return FALSE
	if(LAZYLEN(M.occupants)) //We're actualy making a new mech and swapping things over, it might get weird if players are involved
		to_chat(loc, "<span class='warning'>[M] must be unoccupied before this conversion kit can be applied.</span>")
		return FALSE
	if(!M.cell) //Turns out things break if the cell is missing
		to_chat(loc, "<span class='warning'>The conversion process requires a cell installed.</span>")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/attach(obj/vehicle/sealed/mecha/markone)
	var/obj/vehicle/sealed/mecha/working/ripley/mk2/marktwo = new (get_turf(markone),1)
	if(!marktwo)
		return
	QDEL_NULL(marktwo.cell)
	if (markone.cell)
		marktwo.cell = markone.cell
		markone.cell.forceMove(marktwo)
		markone.cell = null
	QDEL_NULL(marktwo.scanmod)
	if (markone.scanmod)
		marktwo.scanmod = markone.scanmod
		markone.scanmod.forceMove(marktwo)
		markone.scanmod = null
	QDEL_NULL(marktwo.capacitor)
	if (markone.capacitor)
		marktwo.capacitor = markone.capacitor
		markone.capacitor.forceMove(marktwo)
		markone.capacitor = null
	marktwo.update_part_values()
	for(var/obj/item/mecha_parts/equipment in markone.contents)
		if(istype(equipment, /obj/item/mecha_parts/concealed_weapon_bay)) //why is the bay not just a variable change who did this
			equipment.forceMove(marktwo)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in markone.equipment) //Move the equipment over...
		equipment.detach(marktwo)
		equipment.attach(marktwo)
	marktwo.dna_lock = markone.dna_lock
	marktwo.mecha_flags = markone.mecha_flags
	marktwo.strafe = markone.strafe
	marktwo.obj_integrity = round((markone.obj_integrity / markone.max_integrity) * marktwo.obj_integrity) //Integ set to the same percentage integ as the old mecha, rounded to be whole number
	if(markone.name != initial(markone.name))
		marktwo.name = markone.name
	markone.wreckage = FALSE
	qdel(markone)
	playsound(get_turf(marktwo),'sound/items/ratchet.ogg',50,TRUE)
	return
