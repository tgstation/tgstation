/////AUGMENTATION\\\\\
//This is for ghetto augments like chainsaw arms.
/obj/item/proc/is_valid_augment()
	return 0
/obj/item/weapon/is_valid_augment()
	world << "[augmenttype]"
	if(augmenttype)
		return 1
	else
		return 0

/obj/item/organ/limb/arm/l_arm/weapon
	desc = "You shouldn't be seeing this!"
	organtype = ORGAN_WEAPON
	max_damage = 0
	var/obj/item/weapon/augweapon

/obj/item/organ/limb/arm/r_arm/weapon
	desc = "You shouldn't be seeing this!"
	organtype = ORGAN_WEAPON
	max_damage = 0
	var/obj/item/weapon/augweapon

/obj/item/organ/limb/arm/l_arm/weapon/New(obj/item/weapon/augmentweapon)
	augweapon = augmentweapon
	desc = augweapon.desc
	name = augweapon.name
	icon_state = augweapon.icon_state

/obj/item/organ/limb/arm/r_arm/weapon/New(obj/item/weapon/augmentweapon)
	augweapon = augmentweapon
	desc = augweapon.desc
	name = augweapon.name
	icon_state = augweapon.icon_state

/obj/item/organ/limb/arm/l_arm/weapon/on_insertion()
	owner.put_in_l_hand(augweapon)
	augweapon.flags |= NODROP
	..()

/obj/item/organ/limb/arm/r_arm/weapon/on_insertion()
	owner.put_in_r_hand(augweapon)
	augweapon.flags |= NODROP
	..()

/obj/item/organ/limb/arm/l_arm/weapon/Remove()
	augweapon.flags &= ~NODROP
	owner.unEquip(augweapon)
	augweapon.loc = src
	..()

/obj/item/organ/limb/arm/l_arm/weapon/Remove()
	augweapon.flags &= ~NODROP
	owner.unEquip(augweapon)
	augweapon.loc = src
	..()