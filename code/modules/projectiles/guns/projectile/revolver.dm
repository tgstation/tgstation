/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	caliber = "357"
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_casing/c38"


	special_check(var/mob/living/carbon/human/M)
/*		if(ishuman(M))
			if(istype(M.w_uniform, /obj/item/clothing/under/det) && istype(M.head, /obj/item/clothing/head/det_hat) && istype(M.wear_suit, /obj/item/clothing/suit/storage/det_suit))
				return 1
			M << "\red You just don't feel cool enough to use this gun looking like that."
		return 0	*/
		return 1


	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			M << "\red You don't feel cool enough to name this gun, chump."
			return 0

		var/input = input("What do you want to name the gun?",,"")
		input = sanitize(input)

		if(src && input && !M.stat && in_range(M,src))
			name = input
			M << "You name the gun [input]. Say hello to your new friend."
			return 1




/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"