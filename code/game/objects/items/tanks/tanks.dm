/obj/item/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	icon_state = "generic"
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	worn_icon = 'icons/mob/clothing/back.dmi' //since these can also get thrown into suit storage slots. if something goes on the belt, set this to null.
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	custom_materials = list(/datum/material/iron = 500)
	actions_types = list(/datum/action/item_action/set_internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 80, ACID = 30)
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	/// Icon state when in a tank holder. Null makes it incompatible with tank holder.
	var/tank_holder_icon_state = "holder_generic"

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/proc/toggle_internals(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return

	if(H.internal == src)
		to_chat(H, "<span class='notice'>You close [src] valve.</span>")
		H.internal = null
		H.update_internals_hud_icon(0)
	else
		if(!H.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(!H.wear_mask)
				to_chat(H, "<span class='warning'>You need a mask!</span>")
				return
			var/is_clothing = isclothing(H.wear_mask)
			if(is_clothing && H.wear_mask.mask_adjusted)
				H.wear_mask.adjustmask(H)
			if(!is_clothing || !(H.wear_mask.clothing_flags & MASKINTERNALS))
				to_chat(H, "<span class='warning'>[H.wear_mask] can't use [src]!</span>")
				return

		if(H.internal)
			to_chat(H, "<span class='notice'>You switch your internals to [src].</span>")
		else
			to_chat(H, "<span class='notice'>You open [src] valve.</span>")
		H.internal = src
		H.update_internals_hud_icon(1)
	H.update_action_buttons_icon()


/obj/item/tank/Initialize()
	. = ..()

	air_contents = new(volume) //liters
	air_contents.temperature = T20C

	populate_gas()

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/Destroy()
	if(air_contents)
		QDEL_NULL(air_contents)

	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/tank/ComponentInitialize()
	. = ..()
	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += "<span class='notice'>If you want any more information you'll need to get closer.</span>"
		return

	. += "<span class='notice'>The pressure gauge reads [round(src.air_contents.return_pressure(),0.01)] kPa.</span>"

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

	. += "<span class='notice'>It feels [descriptive].</span>"

/obj/item/tank/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		var/turf/location = get_turf(src)
		if(!location)
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(air_contents)
			air_update_turf()
		playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	qdel(src)

/obj/item/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	if(!QDELETED(H) && air_contents && air_contents.return_pressure() >= 1000)
		ADD_TRAIT(H, TRAIT_DISFIGURED, TRAIT_GENERIC)
		H.inflate_gib()
		return MANUAL_SUICIDE
	else
		to_chat(user, "<span class='warning'>There isn't enough pressure in [src] to commit suicide with...</span>")
	return SHAME

/obj/item/tank/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/assembly_holder))
		bomb_assemble(W,user)
	else
		. = ..()

/obj/item/tank/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()

/obj/item/tank/ui_data(mob/user)
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

/obj/item/tank/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)

/obj/item/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/tank/return_air()
	return air_contents

/obj/item/tank/return_analyzable_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	var/actual_distribute_pressure = clamp(tank_pressure, 0, distribute_pressure)

	var/moles_needed = actual_distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()

/obj/item/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()

	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc, /obj/item/transfer_valve))
			log_bomber(get_mob_by_key(fingerprintslast), "was last key to touch", src, "which ruptured explosively")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react(src)
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)


		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(src.loc, /obj/item/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE || temperature > TANK_MELT_TEMPERATURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
		
/obj/item/tank/attack_hand(mob/living/carbon/human/user)
	var/celsius_temperature = air_contents.temperature-T0C					//i know i could make the above one public but im too afraid to mess with it

	//recycled code from light bulbs because im too dumb myself
	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits (recycled comment as it still fits)
	if(celsius_temperature >= 50)
		var/prot = 0
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.max_heat_protection_temperature)
				prot = (G.max_heat_protection_temperature > 360)
		if(prot > 0 || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
			to_chat(user, "<span class='notice'>The tank feels very hot.</span>")
		else if(istype(user) && user.dna.check_mutation(TK))
			to_chat(user, "<span class='notice'>You can feel the searing heat in your mind.</span>")
		else
			var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if (celsius_temperature >= 1000)
				affecting.force_wound_upwards(/datum/wound/burn/critical)
				affecting.receive_damage( 0, 5 )					//5 burn damage
				return
			else if (celsius_temperature >= 250 && celsius_temperature < 1000)			//checks how high the temp is and gives wounds according to that
				affecting.force_wound_upwards(/datum/wound/burn/severe)
				affecting.receive_damage( 0, 5 )
				return
			else if (celsius_temperature >= 80 && celsius_temperature < 250) 		//according to google 80°C will give you first degree burns pretty quickly, the other values are just pulled out of my ass
				affecting.force_wound_upwards(/datum/wound/burn/moderate)
				affecting.receive_damage( 0, 5 )					//i repeated it 3 times because it wouldnt work otherwise
				return
			to_chat(user, "<span class='warning'>You burn your hand on the tank!</span>")
	return ..()
