/datum/organ/limb/
	name = "limb"
	var/icon_position = 0
	var/body_part = null
	organitem_type = /obj/item/organ/limb

	//Only set this variable to 1 if you want the limb to show up on the health doll.
	//Even when set to 1, a limb won't show up if the player does not have it.
	//Also you'll need to add an overlay sprite for the limb to screen_gen.dmi with the same name as the limb.
	var/healthdoll = 0

/datum/organ/limb/proc/counts_for_damage()
	return exists() && can_be_damaged

/datum/organ/limb/chest
	name = "chest"
	body_part = CHEST
	destroyed_dam = 200
	organitem_type = /obj/item/organ/limb/chest
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/head
	name = "head"
	body_part = HEAD
	destroyed_dam = 200
	organitem_type = /obj/item/organ/limb/head
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/head/dismember()
	var/obj/item/organ/limb/head/H = organitem
	H.behead()
	..()

/datum/organ/limb/l_arm
	name = "l_arm"
	body_part = ARM_LEFT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/l_arm
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/l_leg
	name = "l_leg"
	body_part = LEG_LEFT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/l_leg
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/r_arm
	name = "r_arm"
	body_part = ARM_RIGHT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/r_arm
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/r_leg
	name = "r_leg"
	body_part = LEG_RIGHT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/r_leg
	healthdoll = 1
	can_be_damaged = 1