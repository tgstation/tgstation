/obj/item/onetankbomb
	name = "bomb"
	icon = 'icons/obj/tank.dmi'
	inhand_icon_state = "assembly"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4
	flags_1 = CONDUCT_1
	var/status = FALSE   //0 - not readied //1 - bomb finished with welder
	var/obj/item/assembly_holder/bombassembly = null   //The first part of the bomb is an assembly holder, holding an igniter+some device
	var/obj/item/tank/bombtank = null //the second part of the bomb is a plasma tank

/obj/item/onetankbomb/IsSpecialAssembly()
	return TRUE

/obj/item/onetankbomb/examine(mob/user)
	return bombtank.examine(user)

/obj/item/onetankbomb/update_icon(updates)
	icon = bombtank?.icon || initial(icon)
	return ..()

/obj/item/onetankbomb/update_icon_state()
	icon_state = bombtank?.icon_state || initial(icon_state)
	return ..()

/obj/item/onetankbomb/update_overlays()
	. = ..()
	if(bombassembly)
		. += bombassembly.icon_state
		. += bombassembly.overlays
		. += "bomb_assembly"

/obj/item/onetankbomb/wrench_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You disassemble [src]!"))
	if(bombassembly)
		bombassembly.forceMove(drop_location())
		bombassembly.master = null
		bombassembly = null
	if(bombtank)
		bombtank.forceMove(drop_location())
		bombtank.master = null
		bombtank = null
	qdel(src)
	return TRUE

/obj/item/onetankbomb/welder_act(mob/living/user, obj/item/I)
	..()
	. = FALSE
	if(status)
		to_chat(user, span_warning("[bombtank] already has a pressure hole!"))
		return
	if(!I.tool_start_check(user, amount=0))
		return
	if(I.use_tool(src, user, 0, volume=40))
		status = TRUE
		var/datum/gas_mixture/bomb_mix = bombtank.return_air()
		log_bomber(user, "welded a single tank bomb,", src, "| Temp: [bomb_mix.temperature]")
		to_chat(user, span_notice("A pressure hole has been bored to [bombtank] valve. \The [bombtank] can now be ignited."))
		add_fingerprint(user)
		return TRUE

/obj/item/onetankbomb/attack_self(mob/user) //pressing the bomb accesses its assembly
	bombassembly.attack_self(user, TRUE)
	add_fingerprint(user)
	return

/obj/item/onetankbomb/receive_signal() //This is mainly called by the sensor through sense() to the holder, and from the holder to here.
	audible_message(span_warning("[icon2html(src, hearers(src))] *beep* *beep* *beep*"))
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	sleep(10)
	if(QDELETED(src))
		return
	if(status)
		bombtank.ignite() //if its not a dud, boom (or not boom if you made shitty mix) the ignite proc is below, in this file
	else
		bombtank.release()

/obj/item/onetankbomb/on_found(mob/finder) //for mousetraps
	if(bombassembly)
		bombassembly.on_found(finder)

/obj/item/onetankbomb/attack_hand(mob/user, list/modifiers) //also for mousetraps
	. = ..()
	if(.)
		return
	if(bombassembly)
		bombassembly.attack_hand()

/obj/item/onetankbomb/Move()
	. = ..()
	if(bombassembly)
		bombassembly.setDir(dir)
		bombassembly.Move()

/obj/item/onetankbomb/dropped()
	. = ..()
	if(bombassembly)
		bombassembly.dropped()




// ---------- Procs below are for tanks that are used exclusively in 1-tank bombs ----------

//Bomb assembly proc. This turns assembly+tank into a bomb
/obj/item/tank/proc/bomb_assemble(obj/item/assembly_holder/assembly, mob/living/user)
	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
	if(isigniter(assembly.a_left) == isigniter(assembly.a_right))
		return

	if((src in user.get_equipped_items(TRUE)) && !user.canUnEquip(src))
		to_chat(user, span_warning("[src] is stuck to you!"))
		return

	if(!user.canUnEquip(assembly))
		to_chat(user, span_warning("[assembly] is stuck to your hand!"))
		return

	var/obj/item/onetankbomb/bomb = new
	user.transferItemToLoc(src, bomb)
	user.transferItemToLoc(assembly, bomb)

	bomb.bombassembly = assembly //Tell the bomb about its assembly part
	assembly.master = bomb //Tell the assembly about its new owner

	bomb.bombtank = src //Same for tank
	master = bomb

	forceMove(bomb)
	bomb.update_appearance()

	user.put_in_hands(bomb) //Equips the bomb if possible, or puts it on the floor.
	to_chat(user, span_notice("You attach [assembly] to [src]."))
	return

/obj/item/tank/proc/ignite() //This happens when a bomb is told to explode
	START_PROCESSING(SSobj, src)
	///The list of fuel gases.
	var/list/fuel_gases = list(
		/datum/gas/plasma,
		/datum/gas/hydrogen,
		/datum/gas/tritium,
		/datum/gas/antinoblium,
	)
	///The list of oxi gases.
	var/list/oxi_gases = list(
		/datum/gas/oxygen,
		/datum/gas/nitrous_oxide,
		/datum/gas/nitryl,
	)
	///All gases that have an interaction.
	var/list/combined_gases = list(
		/datum/gas/plasma,
		/datum/gas/hydrogen,
		/datum/gas/tritium,
		/datum/gas/antinoblium,
		/datum/gas/oxygen,
		/datum/gas/nitrous_oxide,
		/datum/gas/nitryl,
	)
	//Base modifier multiplies the strength. Devastation, high_impact, low_impact, and flash multiply their respective impact ranges in the explosion. Weight determines what the most efficient oxi to fuel ratio would be. The weight applies for oxi or fuel depending on the gas. Effective temperature determines what would be the most efficient temperature for the gas.
	//Do not set the value for weight too high, as a variable will be used by a calculation that can generate really massive numbers. Check gas_efficiency to see what values would be appropriate.
	///The modifiers of the gases. [1: base modifier, 2: devastation, 3: high_impact, 4: low_impact, 5: flash, 6: weight, 7: effective temperature].
	var/list/gas_modifiers = list(
		/datum/gas/oxygen = list(1, 0.1, 0.2, 1.5, 1.5, 2, T0C),
		/datum/gas/nitrous_oxide = list(0.9, 1.2, 1, 0.4, 0.4, 4, 3 * T0C),
		/datum/gas/nitryl = list(2, 0.1, 0.125, 0.15, 0.175, 1, 4 * TCMB),
		/datum/gas/plasma = list(0.6, 1.2, 1, 0.9, 0.9, 1, T0C + 100),
		/datum/gas/hydrogen = list(0.9, 7.5, 7.5, 20, 20, 0.2, 8 * TCMB),
		/datum/gas/tritium = list(1, 10, 10, 10, 10, 0.24, 4 * TCMB),
		/datum/gas/antinoblium = list(1.2, 8, 0, 0, 0, 8, TCMB),
	)
	///The composition of gases relative to oxi.
	var/list/oxi_comp = list(
		/datum/gas/oxygen = 0,
		/datum/gas/nitrous_oxide = 0,
		/datum/gas/nitryl = 0,
	)
	///The composition of gases relative to fuel.
	var/list/fuel_comp = list(
		/datum/gas/plasma = 0,
		/datum/gas/hydrogen = 0,
		/datum/gas/tritium = 0,
		/datum/gas/antinoblium = 0,
	)
	///The composition of gases.
	var/list/gas_comp = list(
		/datum/gas/oxygen = 0,
		/datum/gas/nitrous_oxide = 0,
		/datum/gas/nitryl = 0,
		/datum/gas/plasma = 0,
		/datum/gas/hydrogen = 0,
		/datum/gas/tritium = 0,
		/datum/gas/antinoblium = 0,
	)
	var/datum/gas_mixture/our_mix = return_air()
	///The modifier of the explosion. [1: base modifier, 2: devastation, 3: high_impact, 4: low_impact, 5: flash, 6: weight, 7: effective temperature].
	var/explosion_modifier = list(0, 0, 0, 0, 0, 0, 0)
	for(var/gas_id in combined_gases)
		our_mix.assert_gas(gas_id)

	///Total moles of fuel.
	var/fuel_moles = 0
	///Total moles of oxi.
	var/oxi_moles = 0
	///Total moles of fuel and oxi.
	var/combined_moles = 0
	for(var/gas_id in fuel_gases)
		fuel_moles += our_mix.gases[gas_id][MOLES]
	for(var/gas_id in oxi_gases)
		oxi_moles += our_mix.gases[gas_id][MOLES]
	combined_moles = fuel_moles + oxi_moles
	if(fuel_moles == 0 || oxi_moles == 0)
		return
	for(var/gas_id in fuel_gases)
		fuel_comp[gas_id] = clamp(our_mix.gases[gas_id][MOLES] / fuel_moles, 0, 1) //Composition of fuels.
	for(var/gas_id in oxi_gases)
		oxi_comp[gas_id] = clamp(our_mix.gases[gas_id][MOLES] / oxi_moles, 0, 1) //Composition of oxi gases.
	for(var/gas_id in combined_gases)
		gas_comp[gas_id] = clamp(our_mix.gases[gas_id][MOLES] / combined_moles, 0, 1) //Composition of gases.
	for(var/gas_id in gas_modifiers)
		for(var/i = 1 to 7)
			explosion_modifier[i] += gas_modifiers[gas_id][i] * gas_comp[gas_id] //Calculate modifiers.
	///Composition of oxi.
	var/oxi_gas_comp = oxi_moles / combined_moles
	///Composition of fuel.
	var/fuel_gas_comp = fuel_moles / combined_moles
	///Weight of oxi.
	var/oxi_weight = 0
	///Weight of fuel.
	var/fuel_weight = 0
	for(var/gas_id in oxi_gases)
		oxi_weight += gas_modifiers[gas_id][6] * oxi_comp[gas_id]
	for(var/gas_id in fuel_gases)
		fuel_weight += gas_modifiers[gas_id][6] * fuel_comp[gas_id]
	our_mix.garbage_collect()
	var/datum/gas_mixture/bomb_mixture = our_mix.copy()
	///Efficiency of reaction. Maximum possible efficiency is 1. Temperature or oxi/fuel compositions going off their target will lower this.
	var/gas_efficiency = oxi_gas_comp ** oxi_weight * fuel_gas_comp ** fuel_weight * ((oxi_weight + fuel_weight) ** (oxi_weight + fuel_weight)) / (oxi_weight ** oxi_weight * fuel_weight ** fuel_weight) * bomb_mixture.temperature / (bomb_mixture.temperature + (bomb_mixture.temperature * sqrt(INVERSE(explosion_modifier[7])) - sqrt(explosion_modifier[7])) ** 2)
	///Increases range of the explosion.
	var/strength = gas_efficiency * explosion_modifier[1] * combined_moles * bomb_mixture.temperature / 5000
	///Location of explosion.
	var/turf/ground_zero = get_turf(loc)

	if(strength >= 0.2)
		explosion(ground_zero, devastation_range = round(sqrt(strength * explosion_modifier[2]), 1), heavy_impact_range = round(sqrt(strength * explosion_modifier[3]) * 2, 1), light_impact_range = round(sqrt(strength * explosion_modifier[4]) * 4, 1), flash_range = round(sqrt(strength * explosion_modifier[5]) * 8, 1), ignorecap = TRUE, explosion_cause = src)
	else
		ground_zero.assume_air(bomb_mixture)
		ground_zero.hotspot_expose(1000, 125)

	if(master)
		qdel(master)
	qdel(src)

/obj/item/tank/proc/release() //This happens when the bomb is not welded. Tank contents are just spat out.
	var/datum/gas_mixture/our_mix = return_air()
	var/datum/gas_mixture/removed = remove_air(our_mix.total_moles())
	var/turf/T = get_turf(src)
	if(!T)
		return
	T.assume_air(removed)

/obj/item/onetankbomb/return_analyzable_air()
	if(bombtank)
		return bombtank.return_analyzable_air()
	else
		return null
