
///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Protection"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 12 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle ...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand times and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 700
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/effects/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, span_warning("The clothing that was chosen for the rite is no longer on the altar!"))
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Burning Offering"
	desc = "Sacrifice a buckled burning or husked corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 15 SECONDS
	ritual_invocations = list("Burning body ...",
	"... cleansed by the flame ...",
	"... we were all created from fire ...",
	"... and to it ...")
	invoke_msg = "... WE RETURN! "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, span_warning("Only carbon lifeforms can be properly burned for the sacrifice!"))
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, span_warning("You can only sacrifice dead bodies, this one is still alive!"))
			return FALSE
		if(!chosen_sacrifice.on_fire && !HAS_TRAIT_FROM(chosen_sacrifice, TRAIT_HUSK, BURN))
			to_chat(user, span_warning("This corpse needs to be on fire or husked to be sacrificed!"))
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The right sacrifice is no longer on the altar!"))
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire && !HAS_TRAIT_FROM(chosen_sacrifice, TRAIT_HUSK, BURN))
		to_chat(user, span_warning("The sacrifice has to be on fire or husked to finish the end of the rite!"))
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, span_warning("The sacrifice has to stay dead for the rite to work!"))
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect.adjust_favor(favor_gained, user)
	to_chat(user, span_notice("[GLOB.deity] absorbs the charred corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor."))
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE

/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "Burn bright, little candles, for you will only extinguish along with the universe."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/flashlight/flare/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/effects/magic/fireball.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/blazing_star
	name = "Blazing Star"
	desc = "Enchants a holy arrow to set someone on fire on hit, or if the victim is already on fire... note, this consumes the arrow."
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"And so to keep the Ever-Burning candle protected ...",
		"... grant this feeble bolt your blessing ...",
		"... make it burn bright ...",
	)
	invoke_msg = "... a blazing star is born!"
	favor_cost = 1500
	///arrow to enchant
	var/obj/item/ammo_casing/arrow/holy/enchant_target

/datum/religion_rites/blazing_star/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/ammo_casing/arrow/holy/can_enchant in get_turf(religious_tool))
		if(istype(can_enchant, /obj/item/ammo_casing/arrow/holy/blazing))
			continue
		enchant_target = can_enchant
		return ..()
	to_chat(user, span_warning("You need to place a holy arrow on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/blazing_star/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/ammo_casing/arrow/holy/enchanting = enchant_target
	var/turf/tool_turf = get_turf(religious_tool)
	enchant_target = null
	if(QDELETED(enchanting) || !(tool_turf == enchanting.loc)) //check if the arrow is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	enchanting.visible_message(span_notice("[enchant_target] is blessed by holy fire!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	new /obj/item/ammo_casing/arrow/holy/blazing(tool_turf)
	qdel(enchanting)
	return TRUE
