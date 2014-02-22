/////AUGMENTATION\\\\\


/obj/item/augment
	name = "cyberlimb"
	desc = "You should never be seeing this!"
	icon = 'icons/mob/augments.dmi'
	var/limb_part = null
	var/list/construction_cost = list("metal"=1000)
	var/construction_time = 75

/obj/item/augment/chest
	name = "chest"
	desc = "A Robotic chest"
	icon_state = "chest_m_s"
	limb_part = CHEST
	construction_cost = list("metal"=2000) //Limbs are cheaper than Heads/chests
	construction_time = 100

/obj/item/augment/head
	name = "head"
	desc = "A Robotic head"
	icon_state = "head_s"
	limb_part = HEAD
	construction_cost = list("metal"=1500)
	construction_time = 100

/obj/item/augment/l_arm
	name = "left arm"
	desc = "A Robotic arm"
	icon_state = "l_arm_s"
	limb_part = ARM_LEFT

/obj/item/augment/l_leg
	name = "left leg"
	desc = "A Robotic leg"
	icon_state = "l_leg_s"
	limb_part = LEG_LEFT

/obj/item/augment/r_arm
	name = "right arm"
	desc = "A Robotic arm"
	icon_state = "r_arm_s"
	limb_part = ARM_RIGHT

/obj/item/augment/r_leg
	name = "right leg"
	desc = "A Robotic leg"
	icon_state = "r_leg_s"
	limb_part = LEG_RIGHT

