/obj/item/clothing/gloves/tackler
	name = "gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon_state = "tackle"
	item_state = "tackle"
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	var/datum/component/tackler
	// I already covered these vars in components/tackle.dm, but I'll be nice and give you the rundown here too
	/// How much stamina does it cost to tackle?
	var/tackle_stam_cost = 25
	/// How long does the tackle put us down for if we don't hit anything (like a cooldown)
	var/base_knockdown = 1 SECONDS
	/// How far do we fly?
	var/tackle_range = 4
	/// How far do we have to fly?
	var/min_distance = 0
	/// How fast do we throw ourselves? For each increment above 1, you put yourself in more danger when slamming into obstacles
	var/tackle_speed = 1
	/// How good at tackling does this make us? Higher values give us better modifiers for tackles, negatives make us worse
	var/skill_mod = 0
	custom_premium_price = 350

/obj/item/clothing/gloves/tackler/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		tackler = H.AddComponent(/datum/component/tackler, stamina_cost=tackle_stam_cost, base_knockdown = base_knockdown, range = tackle_range, speed = tackle_speed, skill_mod = skill_mod, min_distance = min_distance)

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
	icon_state = "tackledolphin"
	item_state = "tackledolphin"

	tackle_stam_cost = 15
	base_knockdown = 0.5 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = -2

/obj/item/clothing/gloves/tackler/combat
	name = "gorilla gloves"
	desc = "Premium quality combative gloves, heavily reinforced to give the user an edge in close combat tackles, though they are more taxing to use than normal gripper gloves. Fireproof to boot!"

	tackle_stam_cost = 35
	base_knockdown = 1.5 SECONDS
	tackle_range = 5
	skill_mod = 2

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE


/obj/item/clothing/gloves/tackler/combat/insulated
	name = "guerilla gloves"
	desc = "Superior quality combative gloves, good for performing tackle takedowns as well as absorbing electrical shocks."
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/tackler/rocket
	name = "rocket gloves"
	desc = "The ultimate in high risk, high reward, perfect for when you need to stop a criminal from fifty feet away or die trying. Banned in most Spinward gridiron football and rugby leagues."
	icon_state = "tacklerocket"
	item_state = "tacklerocket"

	tackle_stam_cost = 50
	base_knockdown = 2 SECONDS
	tackle_range = 10
	min_distance = 7
	tackle_speed = 6
	skill_mod = 7

/obj/item/clothing/gloves/tackler/offbrand
	name = "improvised gripper gloves"
	desc = "Ratty looking fingerless gloves wrapped with sticky tape. Beware anyone wearing these, for they clearly have no shame and nothing to lose."
	icon_state = "fingerless"
	item_state = "fingerless"

	tackle_stam_cost = 30
	base_knockdown = 1.75 SECONDS
	min_distance = 2
	skill_mod = -1
