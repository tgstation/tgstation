/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags = CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"


/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags = CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")


/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags = CONDUCT
	w_class = 1.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")


/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags = CONDUCT
	force = 15.0
	w_class = 3.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/scalpel/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with [src]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with [src]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his stomach open with [src]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)


/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags = CONDUCT
	force = 15.0
	w_class = 3.0
	throwforce = 9.0
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")


/obj/item/weapon/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = 1.0
	origin_tech = "biotech=1"
	attack_verb = list("slapped")

/obj/item/weapon/surgical_drapes/attack(mob/living/M, mob/user)
	if(!attempt_initiate_surgery(src, M, user))
		..()