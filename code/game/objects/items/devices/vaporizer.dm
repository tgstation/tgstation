/*
 *	Device to let water breathers breathe. TRAIT_WET_FOR_LONGER is required for it to actually function
 *	Because this is a Cerulean device, after all, intended to be used on fish scales
*/
/obj/item/clothing/accessory/vaporizer
	name = "hydro-vaporizer"
	desc = "An ingenious little device manufactured for supporting an alternative method for respiration. \
			Relying on a removable cell, the coil mechanism synthesizes a hydrogen oxygen mixture, \
			which can then be used to moisturize the wearer's gills. \n\
			The rate at which liquid is applied seems to be intended for skin which exceeds at retaining moisture. \n\n\
			<i>A label on its back warns about the potential dangers of electro-magnetic pulses.</i>"
	icon_state = "vaporizer"
	worn_icon_state = "vaporizer"
	base_icon_state = "vaporizer"
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*4.5, /datum/material/gold = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/diamond = SMALL_MATERIAL_AMOUNT*1.8)
	/// visual which shows how much charge is left in the cell
	var/datum/progressbar/charge_bar
	/// the cell which will be used to power the item
	var/obj/item/stock_parts/power_store/cell/cell
	/// how much will be drawn from the cell every time it applies wet stacks
	var/power_cost = 45 JOULES

/obj/item/clothing/accessory/vaporizer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER && !isnull(cell))
		context[SCREENTIP_CONTEXT_LMB] = "Remove [cell.name]"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/accessory/vaporizer/examine(mob/user)
	. = ..()
	if(isnull(cell))
		return
	if(!in_range(src, user) && !isobserver(user))
		. += span_notice("If you want any more information you'll need to get closer.")
		return
	. += span_notice("The LED display reads its [cell.percent()]% charged.")

/obj/item/clothing/accessory/vaporizer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_stacks_clothing, CALLBACK(src, PROC_REF(use_cell)), must_be_worn = FALSE)

/obj/item/clothing/accessory/vaporizer/with_cell/Initialize(mapload)
	. = ..()
	cell = new (src)

/obj/item/clothing/accessory/vaporizer/Destroy()
	. = ..()
	QDEL_NULL(cell)
	qdel(GetComponent(/datum/component/wet_stacks_clothing))

/obj/item/clothing/accessory/vaporizer/equipped(mob/living/user, slot)
	. = ..()
	create_charge_bar(user)

/obj/item/clothing/accessory/vaporizer/dropped(mob/living/user)
	. = ..()
	destroy_charge_bar()

/// create a visual for how much power is left in the cell of the item
/obj/item/clothing/accessory/vaporizer/proc/create_charge_bar(mob/living/user)
	if(!cell || charge_bar)
		return
	var/charge_bar_target = loc == user ? src : loc
	charge_bar = new(user, 100/*%*/, charge_bar_target, cell.percent())

/obj/item/clothing/accessory/vaporizer/proc/destroy_charge_bar()
	if(!charge_bar)
		return
	QDEL_NULL(charge_bar)

// remove the cell with a screwdriver
/obj/item/clothing/accessory/vaporizer/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cell)
		return FALSE
	tool.play_tool_sound(src)
	destroy_charge_bar()
	balloon_alert(user, "removed [cell]")
	cell.forceMove(get_turf(src))
	cell = null
	return TRUE

// proc to feed the machine a new cell
/obj/item/clothing/accessory/vaporizer/item_interaction(mob/living/user, obj/item/stock_parts/power_store/cell/new_cell, list/modifiers)
	if(!istype(new_cell))
		return NONE
	if(!isnull(cell))
		balloon_alert(user, "slot occupied!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_cell, src))
		return NONE
	cell = new_cell
	balloon_alert(user, "installed [new_cell]")
	create_charge_bar(user)
	return ITEM_INTERACT_SUCCESS

/// proc we forward to the callback the wet stack component uses every time it ticks
/obj/item/clothing/accessory/vaporizer/proc/use_cell()
	if(!cell || !cell?.use(power_cost, TRUE))
		return FALSE
	charge_bar?.update(cell.percent())
	return TRUE

/// overload and spew hot steam on EMP
/obj/item/clothing/accessory/vaporizer/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell?.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	var/turf/tile = get_turf(src)
	if(isclosedturf(tile))
		return
	to_chat(src, span_warning("[src] overloads, spewing out a cloud of hot steam!"))
	playsound(src, 'sound/effects/spray.ogg', rand(50, 80), TRUE)
	tile.atmos_spawn_air("[GAS_WATER_VAPOR]=[clamp(cell.maxcharge * 0.1, 1, 100)];[TURF_TEMPERATURE(1000)]")
	for(var/mob/living/nearby_mob in range(4, tile))
		nearby_mob.set_jitter_if_lower(rand(5 SECONDS, 15 SECONDS))
		nearby_mob.set_eye_blur_if_lower(rand(3 SECONDS, 7 SECONDS))
	forceMove(drop_location())
	particles = new /particles/smoke/steam
	addtimer(CALLBACK(src, PROC_REF(remove_particles)), 5 SECONDS, TIMER_DELETE_ME)

/obj/item/clothing/accessory/vaporizer/proc/remove_particles()
	if(isnull(particles))
		return
	particles.spawning = 0
	QDEL_IN(particles, 3 SECONDS)
