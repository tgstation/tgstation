<<<<<<< HEAD
/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BACK
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	actions_types = list(/datum/action/item_action/set_internals)
=======
#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
<<<<<<< HEAD

/obj/item/weapon/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/weapon/tank/proc/toggle_internals(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return

	if(H.internal == src)
		H << "<span class='notice'>You close [src] valve.</span>"
		H.internal = null
		H.update_internals_hud_icon(0)
	else
		if(!H.getorganslot("breathing_tube"))
			if(!H.wear_mask)
				H << "<span class='warning'>You need a mask!</span>"
				return
			if(H.wear_mask.mask_adjusted)
				H.wear_mask.adjustmask(H)
			if(!(H.wear_mask.flags & MASKINTERNALS))
				H << "<span class='warning'>[H.wear_mask] can't use [src]!</span>"
				return

		if(H.internal)
			H << "<span class='notice'>You switch your internals to [src].</span>"
		else
			H << "<span class='notice'>You open [src] valve.</span>"
		H.internal = src
		H.update_internals_hud_icon(1)
	H.update_action_buttons_icon()


/obj/item/weapon/tank/New()
	..()

	air_contents = new(volume) //liters
	air_contents.temperature = T20C

	START_PROCESSING(SSobj, src)
=======
	var/manipulated_by = null		//Used by _onclick/hud/screen_objects.dm internals to determine if someone has messed with our tank or not.
						//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.
/obj/item/weapon/tank/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C

	processing_objects.Add(src)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/tank/Destroy()
	if(air_contents)
		qdel(air_contents)
<<<<<<< HEAD

	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/tank/examine(mob/user)
	var/obj/icon = src
	..()
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user))
		if (icon == src) user << "<span class='notice'>If you want any more information you'll need to get closer.</span>"
		return

	user << "<span class='notice'>The pressure gauge reads [src.air_contents.return_pressure()] kPa.</span>"

=======
		air_contents = null

	if(istype(loc, /obj/machinery/portable_atmospherics))
		var/obj/machinery/portable_atmospherics/holder = loc
		holder.holding = null

	processing_objects.Remove(src)

	..()

/obj/item/weapon/tank/examine(mob/user)
	..()
	var/obj/icon = src
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if (!in_range(src, user))
		if (icon == src) to_chat(user, "<span class='notice'>It's \a [bicon(icon)][src]! If you want any more information you'll need to get closer.</span>")
		return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/celsius_temperature = src.air_contents.temperature-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

<<<<<<< HEAD
	user << "<span class='notice'>It feels [descriptive].</span>"

/obj/item/weapon/tank/blob_act(obj/effect/blob/B)
=======
	to_chat(user, "<span class='info'>\The [bicon(icon)][src] feels [descriptive]</span>")

	if(air_contents.volume * 10 < volume)
		to_chat(user, "<span class='danger'>The meter on the [src.name] indicates you are almost out of gas!</span>")
		playsound(user, 'sound/effects/alert.ogg', 50, 1)

/obj/item/weapon/tank/blob_act()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(prob(50))
		var/turf/location = src.loc
		if (!( istype(location, /turf) ))
			qdel(src)

		if(src.air_contents)
			location.assume_air(air_contents)

		qdel(src)

<<<<<<< HEAD
/obj/item/weapon/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is putting the [src]'s valve to their lips! I don't think they're gonna stop!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (H && !qdeleted(H))
		for(var/obj/item/W in H)
			H.unEquip(W)
			if(prob(50))
				step(W, pick(alldirs))
		H.hair_style = "Bald"
		H.update_hair()
		H.bleed_rate = 5
		gibs(H.loc, H.viruses, H.dna)
		H.adjustBruteLoss(1000) //to make the body super-bloody

	return (BRUTELOSS)

/obj/item/weapon/tank/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	if((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)

	else if(istype(W, /obj/item/device/assembly_holder))
		bomb_assemble(W,user)
	else
		. = ..()

/obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "tanks", name, 420, 200, master_ui, state)
		ui.open()

/obj/item/weapon/tank/ui_data(mob/user)
	var/list/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(TANK_MIN_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)

	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(!istype(C))
		return data

	if(C.internal == src)
		data["connected"] = TRUE

	return data

/obj/item/weapon/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = TANK_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([TANK_MIN_RELEASE_PRESSURE]-[TANK_MAX_RELEASE_PRESSURE] kPa):", name, distribute_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = Clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)
=======
/obj/item/weapon/tank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	var/obj/icon = src

	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc

	if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on [bicon(icon)] [src]</span>", "<span class='attack'>You use \the [W] on [bicon(icon)] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(src.air_contents, src, 0), 1)
		src.add_fingerprint(user)
	else if (istype(W,/obj/item/latexballon))
		var/obj/item/latexballon/LB = W
		LB.blow(src)
		src.add_fingerprint(user)
	else if (istype(W, /obj/item/clothing/gloves/latex))
		if(air_contents.return_pressure())
			to_chat(user, "You inflate \the [W] using \the [src].")
			qdel(W)
			var/obj/item/latexballon/LB1 = new (get_turf(user))
			LB1.blow(src)
			user.put_in_hands(LB1)
			var/obj/item/latexballon/LB2 = new (get_turf(user))
			LB2.blow(src)
			user.put_in_hands(LB2)
		else
			to_chat(user, "<span class='warning'>There's no gas in the tank.</span>")


	if(istype(W, /obj/item/device/assembly_holder))
		bomb_assemble(W,user)

/obj/item/weapon/tank/attack_self(mob/user as mob)
	if (!(src.air_contents))
		return

	ui_interact(user)

/obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)

	var/using_internal
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal==src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0

	data["maskConnected"] = 0
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal == src || (location.wear_mask && (location.wear_mask.flags & MASKINTERNALS)))
			data["maskConnected"] = 1

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1
	if (usr.stat|| usr.restrained())
		return 0
	if (src.loc != usr)
		return 0

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
		src.distribute_pressure = min(max(round(src.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
	if (href_list["stat"])
		if(istype(loc,/mob/living/carbon))
			var/mob/living/carbon/location = loc
			if(location.internal == src)
				location.internal = null
				location.internals.icon_state = "internal0"
				to_chat(usr, "<span class='notice'>You close the tank release valve.</span>")
				if (location.internals)
					location.internals.icon_state = "internal0"
			else
				if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
					location.internal = src
					to_chat(usr, "<span class='notice'>You open \the [src] valve.</span>")
					if (location.internals)
						location.internals.icon_state = "internal1"
				else
					to_chat(usr, "<span class='notice'>You need something to connect to \the [src].</span>")

	src.add_fingerprint(usr)
	return 1

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/weapon/tank/return_air()
	return air_contents

/obj/item/weapon/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/weapon/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/weapon/tank/process()
	//Allow for reactions
<<<<<<< HEAD
	air_contents.react()
=======
	if(air_contents)
		air_contents.react()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	check_status()


/obj/item/weapon/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank
<<<<<<< HEAD

=======
	if(timestopped) return

	var/cap = 0
	var/uncapped = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc,/obj/item/device/transfer_valve))
<<<<<<< HEAD
			message_admins("Explosive tank rupture! Last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! Last key to touch the tank was [src.fingerprintslast].")
		//world << "\blue[x],[y] tank is exploding: [pressure] kPa"
=======
			message_admins("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
//		to_chat(world, "<span class='warning'>[x],[y] tank is exploding: [pressure] kPa</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
<<<<<<< HEAD
		var/turf/epicenter = get_turf(loc)

		//world << "\blue Exploding Pressure: [pressure] kPa, intensity: [range]"

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(src.loc,/obj/item/device/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE)
		//world << "\blue[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)
=======
		if(range > MAX_EXPLOSION_RANGE)
			cap = 1
			uncapped = range
		range = min(range, MAX_EXPLOSION_RANGE)		// was 8 - - - Changed to a configurable define -- TLE
		var/turf/epicenter = get_turf(loc)

//		to_chat(world, "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>")

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5), 1, cap)
		if(cap)
			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
				if(bhangmeter)
					bhangmeter.sense_explosion(epicenter.x,epicenter.y,epicenter.z,round(uncapped*0.25), round(uncapped*0.5), round(uncapped),"???", cap)

		if(istype(src.loc,/obj/item/device/transfer_valve))
			var/obj/item/device/transfer_valve/TV = src.loc
			TV.child_ruptured(src, range)

		qdel(src)

		return

	else if(pressure > TANK_RUPTURE_PRESSURE)
//		to_chat(world, "<span class='warning'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(get_turf(src), 'sound/effects/spray.ogg', 10, 1, -3)

			qdel(src)

			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
<<<<<<< HEAD
		//world << "\blue[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			var/turf/T = get_turf(src)
=======
//		to_chat(world, "<span class='warning'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>")
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
