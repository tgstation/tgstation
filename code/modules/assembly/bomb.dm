/// The amount of thermal energy per litre the spark has upon ignition.
#define IGNITION_THERMAL_ENERGY_DENSITY 7500
/// The heat capacity per litre of the spark upon ignition.
#define IGNITION_HEAT_CAPACITY_DENSITY 7.5
/// The heat capacity per litre of the spark upon ignition when the igniter is a condenser.
#define IGNITION_CONDENSER_HEAT_CAPACITY_DENSITY 2500
/// The maximum volume the oxygen tank can be before the bomb is considered bulky.
#define MAXIMUM_NORMAL_WEIGHT_VOLUME 6

/obj/item/onetankbomb
	name = "singletank grenade"
	icon = 'icons/obj/atmospherics/tank.dmi'
	inhand_icon_state = "assembly"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4
	flags_1 = CONDUCT_1
	var/status = FALSE   //0 - not readied //1 - bomb finished with welder
	var/obj/item/assembly_holder/bombassembly = null   //The first part of the bomb is an assembly holder, holding an igniter+some device
	var/obj/item/tank/bombtank = null //the second part of the bomb is a plasma tank
	/// The heat capacity of the spark. A higher heat capacity will release a colder spark with the same thermal energy.
	var/ignition_heat_capacity

/obj/item/onetankbomb/Initialize(mapload, heat_capacity, volume, is_condenser)
	. = ..()
	ignition_heat_capacity = heat_capacity
	if(volume > MAXIMUM_NORMAL_WEIGHT_VOLUME)
		w_class = WEIGHT_CLASS_BULKY
		name = "singletank bomb"
	desc = "[is_condenser ? "Cools" : "Heats"] the gases in the tank."

/obj/item/onetankbomb/Destroy()
	bombassembly = null
	bombtank = null
	return ..()

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
	bombtank.ignite(ignition_heat_capacity) //if its not a dud, boom (or not boom if you made shitty mix) the ignite proc is below, in this file
	if(!status)
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
	var/igniter_count = 0
	var/obj/item/assembly/igniter/igniter
	for(var/obj/item/assembly/attached_assembly as anything in assembly.assemblies)
		if(isigniter(attached_assembly))
			if(igniter_count > 1)
				balloon_alert(user, "Too many igniters!")
				return
			igniter_count += 1
			igniter = attached_assembly
	if(LAZYLEN(assembly.assemblies) == igniter_count)
		return

	if((src in user.get_equipped_items(TRUE)) && !user.canUnEquip(src))
		balloon_alert(user, "[src] is stuck to you!")
		return

	if(!user.canUnEquip(assembly))
		balloon_alert(user, "[assembly] is stuck to your hand!")
		return

	if(!igniter)
		balloon_alert(user, "The [src] has no igniters in it!")
		return

	var/volume = src.volume
	var/igniter_heat_capacity_density = IGNITION_HEAT_CAPACITY_DENSITY
	var/is_condenser_assembly = FALSE
	if(istype(igniter, /obj/item/assembly/igniter/condenser))
		igniter_heat_capacity_density = IGNITION_CONDENSER_HEAT_CAPACITY_DENSITY
		is_condenser_assembly = TRUE

	var/obj/item/onetankbomb/bomb = new(src, igniter_heat_capacity_density * volume, volume, is_condenser_assembly)
	user.transferItemToLoc(src, bomb)
	user.transferItemToLoc(assembly, bomb)

	bomb.bombassembly = assembly //Tell the bomb about its assembly part
	assembly.master = bomb //Tell the assembly about its new owner

	bomb.bombtank = src //Same for tank
	master = bomb

	bomb.update_appearance()

	user.put_in_hands(bomb) //Equips the bomb if possible, or puts it on the floor.
	to_chat(user, span_notice("You attach [assembly] to [src]."))
	forceMove(bomb)
	return

/obj/item/tank/proc/ignite(ignition_heat_capacity) //This happens when a bomb is told to explode
	START_PROCESSING(SSobj, src)
	var/datum/gas_mixture/our_mix = return_air()
	var/temperature = our_mix.temperature
	var/heat_capacity = our_mix.heat_capacity()
	var/volume = our_mix.volume
	our_mix.temperature = (temperature * heat_capacity + IGNITION_THERMAL_ENERGY_DENSITY * volume) / (heat_capacity + ignition_heat_capacity)

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

#undef IGNITION_THERMAL_ENERGY_DENSITY
#undef IGNITION_HEAT_CAPACITY_DENSITY
#undef IGNITION_CONDENSER_HEAT_CAPACITY_DENSITY
#undef MAXIMUM_NORMAL_WEIGHT_VOLUME
