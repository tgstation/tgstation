/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	inhand_icon_state = "magboots"
	var/magboot_state = "magboots"
	var/magpulse = FALSE
	var/slowdown_active = 2
	armor_type = /datum/armor/shoes_magboots
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF

/datum/armor/shoes_magboots
	bio = 90

/obj/item/clothing/shoes/magboots/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		update_gravity_trait(user)
	else
		REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)

/obj/item/clothing/shoes/magboots/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, span_notice("You [magpulse ? "enable" : "disable"] the mag-pulse traction system."))
	update_gravity_trait(user)
	user.update_worn_shoes() //so our mob-overlays update
	user.update_gravity(user.has_gravity())
	user.update_equipment_speed_mods() //we want to update our speed so we arent running at max speed in regular magboots
	update_item_action_buttons()

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."

///Adds/removes the gravity negation trait from the wearer depending on if the magpulse system is turned on.
/obj/item/clothing/shoes/magboots/proc/update_gravity_trait(mob/user)
	if(magpulse)
		ADD_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)
	else
		REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)

/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
