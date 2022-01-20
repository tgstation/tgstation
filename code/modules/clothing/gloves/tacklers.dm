/obj/item/clothing/gloves/tackler
	name = "gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon_state = "tackle"
	inhand_icon_state = "tackle"
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	custom_premium_price = PAYCHECK_COMMAND * 3.5
	/// For storing our tackler datum so we can remove it after
	var/datum/component/tackler
	/// See: [/datum/component/tackler/var/stamina_cost]
	var/tackle_stam_cost = 25
	/// See: [/datum/component/tackler/var/base_knockdown]
	var/base_knockdown = 1 SECONDS
	/// See: [/datum/component/tackler/var/range]
	var/tackle_range = 4
	/// See: [/datum/component/tackler/var/min_distance]
	var/min_distance = 0
	/// See: [/datum/component/tackler/var/speed]
	var/tackle_speed = 1
	/// See: [/datum/component/tackler/var/skill_mod]
	var/skill_mod = 0

/obj/item/clothing/gloves/tackler/Destroy()
	tackler = null
	return ..()

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
		QDEL_NULL(tackler)

/obj/item/clothing/gloves/tackler/dolphin
	name = "dolphin gloves"
	desc = "Sleek, aerodynamic gripper gloves that are less effective at actually performing takedowns, but more effective at letting the user sail through the hallways and cause accidents."
	icon_state = "tackledolphin"
	inhand_icon_state = "tackledolphin"

	tackle_stam_cost = 15
	base_knockdown = 0.5 SECONDS
	tackle_range = 5
	tackle_speed = 2
	min_distance = 2
	skill_mod = -2

/obj/item/clothing/gloves/tackler/combat
	name = "gorilla gloves"
	desc = "Premium quality combative gloves, heavily reinforced to give the user an edge in close combat tackles, though they are more taxing to use than normal gripper gloves. Fireproof to boot!"
	icon_state = "black"
	inhand_icon_state = "blackgloves"

	tackle_stam_cost = 30
	base_knockdown = 1.25 SECONDS
	tackle_range = 5
	skill_mod = 2

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/tackler/combat/insulated
	name = "guerrilla gloves"
	desc = "Superior quality combative gloves, good for performing tackle takedowns as well as absorbing electrical shocks."
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/tackler/rocket
	name = "rocket gloves"
	desc = "The ultimate in high risk, high reward, perfect for when you need to stop a criminal from fifty feet away or die trying. Banned in most Spinward gridiron football and rugby leagues."
	icon_state = "tacklerocket"
	inhand_icon_state = "tacklerocket"

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
	inhand_icon_state = "fingerless"

	tackle_stam_cost = 30
	base_knockdown = 1.75 SECONDS
	min_distance = 2
	skill_mod = -1

/obj/item/clothing/gloves/tackler/football
	name = "football gloves"
	desc = "Gloves for football players! Teaches them how to tackle like a pro."
	icon_state = "tackle_gloves"
	inhand_icon_state = "tackle_gloves"
