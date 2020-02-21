/obj/item/clothing/gloves/tackler
	name = "gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon_state = "fingerless"
	item_state = "fingerless"
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	var/datum/component/tackler
	var/tackle_stam_cost = 25
	var/base_knockdown = 1 SECONDS
	var/tackle_range = 4
	var/min_distance = 0
	var/tackle_speed = 1
	var/skill_mod = 0

/obj/item/clothing/gloves/tackler/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		tackler = H.AddComponent(/datum/component/tackler, stam=tackle_stam_cost, base_knockdown = base_knockdown, range = tackle_range, speed = tackle_speed, skill_mod = skill_mod, min_distance = min_distance)

/obj/item/clothing/gloves/tackler/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		qdel(tackler)

/obj/item/clothing/gloves/tackler/dolphin
	name = "dolphin gloves"
	desc = "Sleek, aerodynamic gripper gloves that are less effective at actually performing takedowns, but more effective at letting the user sail through the hallways and cause accidents."

	tackle_stam_cost = 15
	base_knockdown = 0.5 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = -2

/obj/item/clothing/gloves/tackler/bruiser
	name = "bruiser gloves"
	desc = "Heavily padded gripper gloves that weigh the user down while in mid-air, but are ."

	tackle_stam_cost = 35
	base_knockdown = 1.5 SECONDS
	tackle_range = 5
	skill_mod = 2

/obj/item/clothing/gloves/tackler/rocket
	name = "rocket gloves"
	desc = "The ultimate in high risk, high reward, perfect for when you need to stop a criminal from fifty feet away or die trying. Banned in most Spinward gridiron football and rugby leagues."

	tackle_stam_cost = 50
	base_knockdown = 2 SECONDS
	tackle_range = 10
	min_distance = 7
	tackle_speed = 6
	skill_mod = 7
