/obj/item/clothing/gloves/butchering
	name = "butchering gloves"
	desc = "These gloves allow the user to rip apart bodies with precision and ease."
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/butchering/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 5, 125, null, null, TRUE, TRUE)

/obj/item/clothing/gloves/butchering/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/butcher_target)
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = TRUE

/obj/item/clothing/gloves/butchering/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = FALSE

/obj/item/clothing/gloves/butchering/proc/butcher_target(mob/user, atom/target, proximity)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	return SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target, user)
