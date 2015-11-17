// These only serve to represent the groin and mouth target zones

/datum/organ/abstract/

/datum/organ/abstract/remove(var/dism_type, var/newloc)
	return null

/datum/organ/abstract/groin
	name = "groin"
	organitem_type = /obj/item/organ/abstract/groin

/datum/organ/abstract/mouth
	name = "mouth"
	organitem_type = /obj/item/organ/abstract/mouth

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

/datum/organ/limb/chest/remove()	//DO NOT REMOVE CORE ORGANITEMS
	return null

/datum/organ/limb/chest/switch_organitem(var/obj/item/organ/neworgan)
	var/obj/item/oldorgan = ..(neworgan)
	if(oldorgan)
		if(owner && owner.organsystem.coreitem == oldorgan)
			owner.organsystem.coreitem = organitem
		qdel(neworgan)	//dont' want any extra chests around. They're pointless anyway due to being core items that can't be placed anywhere

/datum/organ/limb/head
	name = "head"
	body_part = HEAD
	destroyed_dam = 200
	organitem_type = /obj/item/organ/limb/head
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/head/regenerate_organitem()	//Fucks with suborgans
	return null

/datum/organ/limb/arm/l_arm
	name = "l_arm"
	body_part = ARM_LEFT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/arm/l_arm
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/leg/l_leg
	name = "l_leg"
	body_part = LEG_LEFT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/leg/l_leg
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/arm/r_arm
	name = "r_arm"
	body_part = ARM_RIGHT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/arm/r_arm
	healthdoll = 1
	can_be_damaged = 1

/datum/organ/limb/leg/r_leg
	name = "r_leg"
	body_part = LEG_RIGHT
	destroyed_dam = 40
	organitem_type = /obj/item/organ/limb/leg/r_leg
	healthdoll = 1
	can_be_damaged = 1