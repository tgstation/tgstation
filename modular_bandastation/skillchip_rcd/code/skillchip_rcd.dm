/// Whitelist of mobs that can use the tool without a chip
/proc/can_inherently_use_rcd(mob/user)
	return issilicon(user) || isdrone(user) || istype(user, /mob/living/basic/bot/repairbot)

/datum/design/rcd_loaded
	name = "Rapid Construction Device (RCD)"

/datum/outfit/job/atmos
	skillchips = list(/obj/item/skillchip/job/engineer)

/obj/item/skillchip/job/engineer/Initialize(mapload, is_removable)
	. = ..()
	auto_traits |= TRAIT_ADVANCED_RCD_KNOWLEDGE

/obj/item/construction/rcd
	var/list/categories_requiring_advanced_rcd_knowledge = list("Airlock Access")
	var/list/modes_requiring_advanced_rcd_knowledge = list(RCD_DECONSTRUCT)

/obj/item/construction/rcd/proc/check_engineer_skillchip(mob/user, alert = TRUE)
	if(!HAS_TRAIT(user, TRAIT_ADVANCED_RCD_KNOWLEDGE) && !can_inherently_use_rcd(user))
		if(alert)
			balloon_alert(user, "нет скиллчипа!")
		return FALSE

	return TRUE

/obj/item/construction/rcd/exosuit/check_engineer_skillchip(mob/user, alert = TRUE)
	return TRUE

/obj/item/construction/rcd/combat/admin/check_engineer_skillchip(mob/user, alert = TRUE)
	return TRUE

/obj/item/construction/rcd/arcd/check_engineer_skillchip(mob/user, alert = TRUE)
	return TRUE

/obj/item/construction/rcd/examine(mob/user)
	. = ..()
	. += "Для полноценного использования требуется скиллчип инженера."
