/////AUGMENTATION\\\\\
//This is for ghetto augments like chainsaw arms.
/obj/item/proc/is_valid_augment()
	return 0
/obj/item/weapon/is_valid_augment()
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
	..()
	augweapon = augmentweapon
	desc = augweapon.desc
	name = augweapon.name
	augweapon.flags |= ABSTRACT
	augweapon.flags |= NODROP
	augweapon.slot_flags = 0

/obj/item/organ/limb/arm/r_arm/weapon/New(obj/item/weapon/augmentweapon)
	..()
	augweapon = augmentweapon
	desc = augweapon.desc
	name = augweapon.name
	augweapon.flags |= ABSTRACT
	augweapon.flags |= NODROP
	augweapon.slot_flags = 0

/obj/item/organ/limb/arm/l_arm/weapon/on_insertion()
	owner.put_in_l_hand(augweapon)
	..()

/obj/item/organ/limb/arm/r_arm/weapon/on_insertion()
	owner.put_in_r_hand(augweapon)
	..()

/obj/item/organ/limb/arm/l_arm/weapon/Remove()
	var/obj/item/weapon/newweapon = new augweapon.augmenttype(owner.loc)
	newweapon.loc = owner.loc
	qdel(augweapon)
	..()
	spawn(10)	//Ghetto as fuck solution to dismemberment not showing name properly
		qdel(src)

/obj/item/organ/limb/arm/r_arm/weapon/Remove()
	var/obj/item/weapon/newweapon = new augweapon.augmenttype(owner.loc)
	newweapon.loc = owner.loc
	qdel(augweapon)
	..()
	spawn(10)
		qdel(src)