/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	body_part = UPPER_TORSO

/datum/organ/external/groin
	name = "groin"
	icon_name = "diaper"
	max_damage = 115
	min_broken_damage = 70
	body_part = LOWER_TORSO

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	max_damage = 125
	min_broken_damage = 70
	body_part = HEAD
	var/disfigured = 0

/datum/organ/external/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_LEFT

/datum/organ/external/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_LEFT

/datum/organ/external/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_RIGHT

/datum/organ/external/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_RIGHT

/datum/organ/external/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_LEFT

/datum/organ/external/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_RIGHT

/datum/organ/external/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_RIGHT

/datum/organ/external/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_LEFT

obj/item/weapon/organ/
	icon = 'human.dmi'
obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_l"
obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "arm_left_l"
obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "foot_left_l"
obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "hand_left_l"
obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "leg_left_l"
obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "arm_right_l"
obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "foot_right_l"
obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "hand_right_l"
obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "leg_right_l"
