/obj/item/clothing/gloves/butchering
	name = "butchering gloves"
	desc = "These gloves allow the user to rip apart bodies with precision and ease."
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	///butchering component added to this object, only used for deletion which is why this is acceptable.
	var/datum/component/butchering/butcher_component

/obj/item/clothing/gloves/butchering/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	//some clarified arguments
	var/speed = 0.5 SECONDS
	var/effectiveness = 125
	var/bonus_modifier = 0
	var/butcher_sound = 'sound/effects/butcher.ogg'
	butcher_component = AddComponent(
		/datum/component/butchering,\
		speed,\
		effectiveness,\
		bonus_modifier,\
		butcher_sound\
	)
	RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/butcher_target)

/obj/item/clothing/gloves/butchering/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	qdel(butcher_component)

/obj/item/clothing/gloves/butchering/proc/butcher_target(mob/user, atom/target, proximity)
	if(!isliving(target))
		return
	return SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target, user)
