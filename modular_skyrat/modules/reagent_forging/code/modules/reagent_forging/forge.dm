#define DEFAULT_TIMED 5 SECONDS
#define MASTER_TIMED 2 SECONDS

#define DEFAULT_HEATED 25 SECONDS
#define MASTER_HEATED 50 SECONDS

/obj/structure/reagent_forge
	name = "forge"
	desc = "A structure built out of bricks, with the intended purpose of heating up metal."
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_structures.dmi'
	icon_state = "forge_empty"

	anchored = TRUE
	density = TRUE

	///the temperature of the forge
	//temperature reached by wood is not enough, requires billows. As long as fuel is in, temperature can be raised.
	var/forge_temperature = 0
	//what temperature the forge is trying to reach
	var/target_temperature = 0
	///the chance that the forges temperature will not lower; max of 100 sinew_lower_chance.
	//normal forges are 0; to increase value, use watcher sinew to increase by 10, to a max of 100.
	var/sinew_lower_chance = 0
	var/current_sinew = 0
	///the number of extra sheets an ore will produce, up to 3
	var/goliath_ore_improvement = 0
	///the fuel amount (in seconds) that the forge has (wood)
	var/forge_fuel_weak = 0
	///the fuel amount (in seconds) that the forge has (stronger than wood)
	var/forge_fuel_strong = 0
	///whether the forge is capable of allowing reagent forging of the forged item.
	//normal forges are false; to turn into true, use 3 (active) legion cores.
	var/reagent_forging = FALSE
	//counting how many cores used to turn forge into a reagent forging forge.
	var/current_core = 0
	//the variable for the process checking to the world time
	var/world_check = 0
	//the variable that stops spamming
	var/in_use = FALSE
	var/primitive = FALSE

/obj/structure/reagent_forge/examine(mob/user)
	. = ..()
	. += span_notice("The forge has [goliath_ore_improvement]/3 goliath hides.")
	. += span_notice("The forge has [current_sinew]/10 watcher sinews.")
	. += span_notice("The forge has [current_core]/3 regenerative cores.")
	. += span_notice("The forge is currently [forge_temperature] degrees hot, going towards [target_temperature] degrees.")
	if(reagent_forging)
		. += span_notice("The forge has a red tinge, it is ready to imbue chemicals into reagent objects.")

/obj/structure/reagent_forge/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	if(is_mining_level(z))
		primitive = TRUE
		icon_state = "primitive_forge_empty"

/obj/structure/reagent_forge/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/reagent_forge/proc/check_fuel()
	if(forge_fuel_strong) //use strong fuel first
		forge_fuel_strong -= 5
		target_temperature = 100
		return
	if(forge_fuel_weak) //then weak fuel second
		forge_fuel_weak -=5
		target_temperature = 50
		return
	target_temperature = 0 //if no fuel, slowly go back down to zero

/obj/structure/reagent_forge/proc/check_temp()
	if(forge_temperature > target_temperature) //above temp needs to lower slowly
		if(sinew_lower_chance && prob(sinew_lower_chance))//chance to not lower the temp, up to 100 from 10 sinew
			return
		forge_temperature -= 5
		return
	else if(forge_temperature < target_temperature && (forge_fuel_weak || forge_fuel_strong)) //below temp with fuel needs to rise
		forge_temperature += 5

	if(forge_temperature > 0)
		if(primitive)
			icon_state = "primitive_forge_full"
		else
			icon_state = "forge_full"
		light_range = 3
	else if(forge_temperature <= 0)
		if(primitive)
			icon_state = "primitive_forge_empty"
		else
			icon_state = "forge_empty"
		light_range = 0

/obj/structure/reagent_forge/proc/check_in_use()
	if(!in_use)
		return
	for(var/mob/living/living_mob in range(1,src))
		if(!living_mob)
			in_use = FALSE

/obj/structure/reagent_forge/proc/spawn_coal()
	new /obj/item/stack/sheet/mineral/coal(get_turf(src))

/obj/structure/reagent_forge/process()
	if(world_check >= world.time) //to make it not too intensive, every 5 seconds
		return
	world_check += 5 SECONDS
	check_fuel()
	check_temp()
	check_in_use() //plenty of weird bugs, this should hopefully fix the in_use bugs

/obj/structure/reagent_forge/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/wood)) //used for weak fuel
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_fuel_weak >= 300) //cannot insert too much
			to_chat(user, span_warning("You only need one to two pieces of wood at a time! You have [forge_fuel_weak] seconds remaining!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to throw the fuel into the forge..."))
		if(!do_after(user, 3 SECONDS, target = src)) //need 3 seconds to fuel the forge
			to_chat(user, span_warning("You abandon fueling the forge."))
			in_use = FALSE
			return
		var/obj/item/stack/sheet/stack_sheet = I
		if(!stack_sheet.use(1)) //you need to be able to use the item, so no glue.
			to_chat(user, span_warning("You abandon fueling the forge."))
			in_use = FALSE
			return
		forge_fuel_weak += 300 //5 minutes
		in_use = FALSE
		to_chat(user, span_notice("You successfully fuel the forge."))
		if(prob(30))
			to_chat(user, span_notice("The forge's fuel lights interestingly..."))
			addtimer(CALLBACK(src, .proc/spawn_coal), 2 MINUTES)
		return

	if(istype(I, /obj/item/stack/sheet/mineral/coal)) //used for strong fuel
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_fuel_strong >= 300) //cannot insert too much
			to_chat(user, span_warning("You only need one to two pieces of coal at a time! You have [forge_fuel_strong] seconds remaining!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to throw the fuel into the forge..."))
		if(!do_after(user, 3 SECONDS, target = src)) //need 3 seconds to fuel the forge
			to_chat(user, span_warning("You abandon fueling the forge."))
			in_use = FALSE
			return
		var/obj/item/stack/sheet/stack_sheet = I
		if(!stack_sheet.use(1)) //need to be able to use the item, so no glue
			to_chat(user, span_warning("You abandon fueling the forge."))
			in_use = FALSE
			return
		forge_fuel_strong += 300 //5 minutes
		in_use = FALSE
		to_chat(user, span_notice("You successfully fuel the forge."))
		return

	if(istype(I, /obj/item/forging/billow))
		var/obj/item/forging/forge_item = I
		if(in_use) //no spamming the billows
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(!forge_fuel_strong && !forge_fuel_weak) //if there isnt any fuel, no billow use
			to_chat(user, span_warning("You cannot use the billow without some sort of fuel in the forge!"))
			in_use = FALSE
			return
		if(forge_temperature >= 100) //we don't want the "temp" to overflow or something somehow
			to_chat(user, span_warning("You do not need to use a billow at this moment, the forge is already hot enough!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to pump the billow into the forge..."))
		if(!do_after(user, forge_item.work_time, target = src)) //wait 3 seconds to upgrade (6 for primitive)
			to_chat(user, span_warning("You abandon billowing the forge."))
			in_use = FALSE
			return
		forge_temperature += 10
		in_use = FALSE
		to_chat(user, span_notice("You successfully increase the temperature inside the forge."))
		return

	if(istype(I, /obj/item/stack/sheet/sinew))
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(sinew_lower_chance >= 100) //max is 100
			to_chat(user, span_warning("You cannot insert any more sinew!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start lining the forge with sinew..."))
		if(!do_after(user, 3 SECONDS, target = src)) //wait 3 seconds to upgrade
			to_chat(user, span_warning("You abandon lining the forge with sinew."))
			in_use = FALSE
			return
		var/obj/item/stack/sheet/stack_sheet = I
		if(!stack_sheet.use(1)) //need to be able to use the item, so no glue
			to_chat(user, span_warning("You abandon lining the forge with sinew."))
			in_use = FALSE
			return
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		sinew_lower_chance += 10
		current_sinew++
		in_use = FALSE
		to_chat(user, span_notice("You successfully line the forge with sinew."))
		return

	if(istype(I, /obj/item/organ/regenerative_core))
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(reagent_forging) //if its already able to reagent forge, why continue wasting?
			to_chat(user, span_warning("This forge is already upgraded."))
			in_use = FALSE
			return
		var/obj/item/organ/regenerative_core/used_core = I
		if(used_core.inert) //no inert cores allowed
			to_chat(user, span_warning("You cannot use an inert regenerative core."))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to sacrifice the regenerative core to the forge..."))
		if(!do_after(user, 3 SECONDS, target = src)) //wait 3 seconds to upgrade
			to_chat(user, span_warning("You abandon sacrificing the regenerative core to the forge."))
			in_use = FALSE
			return
		to_chat(user, span_notice("You successfully sacrifice the regenerative core to the forge."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(I)
		current_core++
		in_use = FALSE
		if(current_core >= 3) //use three regenerative cores to get reagent forging capabilities on the forge
			reagent_forging = TRUE
			to_chat(user, span_notice("You feel the forge has upgraded."))
			color = "#ff5151"
			name = "reagent forge"
			desc = "A structure built out of metal, with the intended purpose of heating up metal. It has the ability to imbue!"
		return

	if(istype(I, /obj/item/stack/sheet/animalhide/goliath_hide))
		var/obj/item/stack/sheet/animalhide/goliath_hide/goliath_hide = I
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(goliath_ore_improvement >= 3)
			to_chat(user, span_warning("You have applied the max amount of [goliath_hide]!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to improve the forge with [goliath_hide]..."))
		if(!do_after(user, 6 SECONDS, target = src)) //wait 6 seconds to upgrade
			to_chat(user, span_warning("You abandon improving the forge."))
			in_use = FALSE
			return
		var/obj/item/stack/sheet/stack_sheet = I
		if(!stack_sheet.use(1)) //need to be able to use the item, so no glue
			to_chat(user, span_warning("You abandon improving the forge."))
			in_use = FALSE
			return
		goliath_ore_improvement++
		in_use = FALSE
		to_chat(user, span_notice("You successfully upgrade the forge with [goliath_hide]."))
		return

	if(istype(I, /obj/item/stack/ore))
		var/obj/item/stack/ore/ore_stack = I
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating [ore_stack]."))
			in_use = FALSE
			return
		if(!ore_stack.refined_type)
			to_chat(user, span_warning("It is impossible to smelt [ore_stack]."))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to smelt [ore_stack]..."))
		if(!do_after(user, 3 SECONDS, target = src)) //wait 3 seconds to upgrade
			to_chat(user, span_warning("You abandon smelting [ore_stack]."))
			in_use = FALSE
			return
		var/src_turf = get_turf(src)
		var/spawning_item = ore_stack.refined_type
		var/spawning_amount = max(1, (1 + goliath_ore_improvement) * ore_stack.amount)
		for(var/spawn_ore in 1 to spawning_amount)
			new spawning_item(src_turf)
		in_use = FALSE
		to_chat(user, span_notice("You successfully smelt [ore_stack]."))
		qdel(I)
		return

	if(istype(I, /obj/item/forging/tongs))
		var/obj/item/forging/forge_item = I
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating the metal."))
			in_use = FALSE
			return
		var/obj/item/forging/incomplete/search_incomplete = locate(/obj/item/forging/incomplete) in I.contents
		if(search_incomplete)
			to_chat(user, span_warning("You start to heat up the metal..."))
			if(!do_after(user, forge_item.work_time, target = src)) //wait 3 seconds to upgrade (6 for primitive)
				to_chat(user, span_warning("You abandon heating up the metal, breaking the metal."))
				in_use = FALSE
				return
			search_incomplete.heat_world_compare = world.time + 1 MINUTES
			in_use = FALSE
			to_chat(user, span_notice("You successfully heat up the metal."))
			return
		var/obj/item/stack/rods/search_rods = locate(/obj/item/stack/rods) in I.contents
		if(search_rods)
			var/user_choice = input(user, "What would you like to work on?", "Forge Selection") as null|anything in list("Chain", "Sword", "Staff", "Spear", "Plate")
			if(!user_choice)
				to_chat(user, span_warning("You decide against continuing to forge."))
				in_use = FALSE
				return
			if(!search_rods.use(1))
				to_chat(user, span_warning("You cannot use the rods!"))
				in_use = FALSE
				return
			to_chat(user, span_warning("You start to heat up the metal..."))
			if(!do_after(user, forge_item.work_time, target = src)) //wait 3 seconds to upgrade (6 for primitive)
				to_chat(user, span_warning("You abandon heating up the metal, breaking the metal."))
				in_use = FALSE
				return
			var/obj/item/forging/incomplete/incomplete_item
			switch(user_choice)
				if("Chain")
					incomplete_item = new /obj/item/forging/incomplete/chain(get_turf(src))
				if("Sword")
					incomplete_item = new /obj/item/forging/incomplete/sword(get_turf(src))
				if("Staff")
					incomplete_item = new /obj/item/forging/incomplete/staff(get_turf(src))
				if("Spear")
					incomplete_item = new /obj/item/forging/incomplete/spear(get_turf(src))
				if("Plate")
					incomplete_item = new /obj/item/forging/incomplete/plate(get_turf(src))
			incomplete_item.heat_world_compare = world.time + 1 MINUTES
			in_use = FALSE
			to_chat(user, span_notice("You successfully heat up the metal, ready to forge a [user_choice]."))
			return
		in_use = FALSE
		return

	if(I.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/iron/ten(get_turf(src))
		for(var/loopone in 1 to current_core)
			new /obj/item/organ/regenerative_core(get_turf(src))
		for(var/looptwo in 1 to current_sinew)
			new /obj/item/stack/sheet/sinew(get_turf(src))
		for(var/loopthree in 1 to goliath_ore_improvement)
			new /obj/item/stack/sheet/animalhide/goliath_hide(get_turf(src))
		qdel(src)

	if(istype(I, /obj/item/forging/reagent_weapon) && reagent_forging)
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		var/obj/item/forging/reagent_weapon/reagent_weapon = I
		if(reagent_weapon.imbued_reagent.len > 0 || reagent_weapon.has_imbued)
			to_chat(user, span_warning("This weapon has already been imbued!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to imbue the weapon..."))
		if(!do_after(user, 10 SECONDS, target = src)) //wait 10 seconds to upgrade
			to_chat(user, span_warning("You abandon imbueing the weapon."))
			in_use = FALSE
			return
		for(var/datum/reagent/weapon_reagent in reagent_weapon.reagents.reagent_list)
			if(weapon_reagent.volume < 200)
				continue
			reagent_weapon.imbued_reagent += weapon_reagent.type
			reagent_weapon.name = "[weapon_reagent.name] [reagent_weapon.name]"
		reagent_weapon.color = mix_color_from_reagents(reagent_weapon.reagents.reagent_list)
		reagent_weapon.has_imbued = TRUE
		to_chat(user, span_notice("You finish imbueing the weapon..."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		in_use = FALSE
		return

	if(istype(I, /obj/item/clothing/suit/armor/reagent_clothing) && reagent_forging)
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		var/obj/item/clothing/suit/armor/reagent_clothing/reagent_clothing = I
		if(reagent_clothing.imbued_reagent.len > 0 || reagent_clothing.has_imbued)
			to_chat(user, span_warning("This clothing has already been imbued!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to imbue the clothing..."))
		if(!do_after(user, 10 SECONDS, target = src)) //wait 10 seconds to upgrade
			to_chat(user, span_warning("You abandon imbueing the clothing."))
			in_use = FALSE
			return
		for(var/datum/reagent/clothing_reagent in reagent_clothing.reagents.reagent_list)
			if(clothing_reagent.volume < 200)
				continue
			reagent_clothing.imbued_reagent += clothing_reagent.type
			reagent_clothing.name = "[clothing_reagent.name] [reagent_clothing.name]"
		reagent_clothing.color = mix_color_from_reagents(reagent_clothing.reagents.reagent_list)
		reagent_clothing.has_imbued = TRUE
		to_chat(user, span_notice("You finish imbueing the clothing..."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		in_use = FALSE
		return

	if(istype(I, /obj/item/clothing/gloves/reagent_clothing) && reagent_forging)
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		var/obj/item/clothing/gloves/reagent_clothing/reagent_clothing = I
		if(reagent_clothing.imbued_reagent.len > 0 || reagent_clothing.has_imbued)
			to_chat(user, span_warning("This clothing has already been imbued!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to imbue the clothing..."))
		if(!do_after(user, 10 SECONDS, target = src)) //wait 10 seconds to upgrade
			to_chat(user, span_warning("You abandon imbueing the clothing."))
			in_use = FALSE
			return
		for(var/datum/reagent/clothing_reagent in reagent_clothing.reagents.reagent_list)
			if(clothing_reagent.volume < 200)
				continue
			reagent_clothing.imbued_reagent += clothing_reagent.type
			reagent_clothing.name = "[clothing_reagent.name] [reagent_clothing.name]"
		reagent_clothing.color = mix_color_from_reagents(reagent_clothing.reagents.reagent_list)
		reagent_clothing.has_imbued = TRUE
		to_chat(user, span_notice("You finish imbueing the clothing..."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		in_use = FALSE
		return

	if(istype(I, /obj/item/clothing/head/helmet/reagent_clothing) && reagent_forging)
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		var/obj/item/clothing/head/helmet/reagent_clothing/reagent_clothing = I
		if(reagent_clothing.imbued_reagent.len > 0 || reagent_clothing.has_imbued)
			to_chat(user, span_warning("This clothing has already been imbued!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to imbue the clothing..."))
		if(!do_after(user, 10 SECONDS, target = src)) //wait 10 seconds to upgrade
			to_chat(user, span_warning("You abandon imbueing the clothing."))
			in_use = FALSE
			return
		for(var/datum/reagent/clothing_reagent in reagent_clothing.reagents.reagent_list)
			if(clothing_reagent.volume < 200)
				continue
			reagent_clothing.imbued_reagent += clothing_reagent.type
			reagent_clothing.name = "[clothing_reagent.name] [reagent_clothing.name]"
		reagent_clothing.color = mix_color_from_reagents(reagent_clothing.reagents.reagent_list)
		to_chat(user, span_notice("You finish imbueing the clothing..."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		in_use = FALSE
		return

	if(istype(I, /obj/item/forging/reagent_tile) && reagent_forging)
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		var/obj/item/forging/reagent_tile/reagent_tile = I
		if(reagent_tile.imbued_reagent.len > 0 || reagent_tile.has_imbued)
			to_chat(user, span_warning("This tiling has already been imbued!"))
			in_use = FALSE
			return
		to_chat(user, span_warning("You start to imbue the tiling..."))
		if(!do_after(user, 10 SECONDS, target = src)) //wait 10 seconds to upgrade
			to_chat(user, span_warning("You abandon imbueing the tiling."))
			in_use = FALSE
			return
		for(var/datum/reagent/tile_reagent in reagent_tile.reagents.reagent_list)
			if(tile_reagent.volume < 200)
				continue
			reagent_tile.imbued_reagent += tile_reagent.type
			reagent_tile.name = "[tile_reagent.name] [reagent_tile.name]"
		reagent_tile.color = mix_color_from_reagents(reagent_tile.reagents.reagent_list)
		reagent_tile.has_imbued = TRUE
		to_chat(user, span_notice("You finish imbueing the tile..."))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		in_use = FALSE
		return

	if(istype(I, /obj/item/ceramic))
		var/obj/item/ceramic/ceramic_item = I
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating [ceramic_item]."))
			return
		if(!ceramic_item.forge_item)
			to_chat(user, span_warning("You feel that setting [ceramic_item] would not yield anything useful!"))
			return
		to_chat(user, span_notice("You start setting [ceramic_item]..."))
		if(!do_after(user, 5 SECONDS, target = src))
			to_chat(user, span_warning("You stop setting [ceramic_item]!"))
			return
		to_chat(user, span_notice("You finish setting [ceramic_item]..."))
		var/obj/item/ceramic/spawned_ceramic = new ceramic_item.forge_item(get_turf(src))
		spawned_ceramic.color = ceramic_item.color
		qdel(ceramic_item)
		return

	if(istype(I, /obj/item/glassblowing/blowing_rod))
		var/obj/item/glassblowing/blowing_rod/blowing_item = I
		var/actioning_speed = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_TIMED : DEFAULT_TIMED
		var/actioning_amount = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_HEATED : DEFAULT_HEATED
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating [blowing_item]."))
			in_use = FALSE
			return
		var/obj/item/glassblowing/molten_glass/find_glass = locate() in blowing_item.contents
		if(!find_glass)
			to_chat(user, span_warning("[blowing_item] does not have any glass to heat up."))
			in_use = FALSE
			return
		to_chat(user, span_notice("You begin heating up [blowing_item]."))
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("[blowing_item] is interrupted in its heating process."))
			in_use = FALSE
			return
		find_glass.world_molten = world.time + actioning_amount
		to_chat(user, span_notice("You finish heating up [blowing_item]."))
		in_use = FALSE
		return

	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass_item = I
		var/actioning_speed = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_TIMED : DEFAULT_TIMED
		var/actioning_amount = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_HEATED : DEFAULT_HEATED
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating [glass_item]."))
			in_use = FALSE
			return
		if(!glass_item.use(1))
			to_chat(user, span_warning("You need to be able to use [glass_item]!"))
			in_use = FALSE
			return
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("You stop heating up [glass_item]!"))
			in_use = FALSE
			return
		in_use = FALSE
		var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
		spawned_glass.world_molten = world.time + actioning_amount
		return

	if(istype(I, /obj/item/glassblowing/metal_cup))
		var/obj/item/glassblowing/metal_cup/metal_item = I
		var/actioning_speed = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_TIMED : DEFAULT_TIMED
		var/actioning_amount = HAS_TRAIT(user, TRAIT_GLASSBLOWING_MASTER) ? MASTER_HEATED : DEFAULT_HEATED
		if(in_use) //only insert one at a time
			to_chat(user, span_warning("You cannot do multiple things at the same time!"))
			return
		in_use = TRUE
		if(forge_temperature <= 50)
			to_chat(user, span_warning("The temperature is not hot enough to start heating [metal_item]!"))
			in_use = FALSE
			return
		if(!metal_item.has_sand)
			to_chat(user, span_warning("There is no sand within [metal_item]!"))
			in_use = FALSE
			return
		if(!do_after(user, actioning_speed, target = src))
			to_chat(user, span_warning("You stop heating up [metal_item]!"))
			in_use = FALSE
			return
		in_use = FALSE
		metal_item.has_sand = FALSE
		metal_item.icon_state = "metal_cup_empty"
		var/obj/item/glassblowing/molten_glass/spawned_glass = new /obj/item/glassblowing/molten_glass(get_turf(src))
		spawned_glass.world_molten = world.time + actioning_amount
		return

	return ..()

/obj/structure/reagent_forge/ready
	current_core = 3
	reagent_forging = TRUE
	sinew_lower_chance = 100
	forge_temperature = 1000

#undef DEFAULT_TIMED
#undef MASTER_TIMED

#undef DEFAULT_HEATED
#undef MASTER_HEATED
