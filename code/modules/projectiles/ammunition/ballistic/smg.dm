// 4.6x30mm (Autorifles)

/obj/item/ammo_casing/c46x30mm
	name = "4.6x30mm bullet casing"
	desc = "A 4.6x30mm bullet casing."
	caliber = CALIBER_46X30MM
	projectile_type = /obj/projectile/bullet/c46x30mm

/obj/item/ammo_casing/c46x30mm/ap
	name = "4.6x30mm armor-piercing bullet casing"
	desc = "A 4.6x30mm armor-piercing bullet casing."
	projectile_type = /obj/projectile/bullet/c46x30mm/ap

/obj/item/ammo_casing/c46x30mm/inc
	name = "4.6x30mm incendiary bullet casing"
	desc = "A 4.6x30mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c46x30mm

// .45 (M1911 + C20r)

/obj/item/ammo_casing/c45
	name = ".45 bullet casing"
	desc = "A .45 bullet casing."
	caliber = CALIBER_45
	projectile_type = /obj/projectile/bullet/c45

/obj/item/ammo_casing/c45/spent
	projectile_type = null

/obj/item/ammo_casing/c45/ap
	name = ".45 armor-piercing bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/c45/ap

/obj/item/ammo_casing/c45/hp
	name = ".45 hollow point bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/c45/hp

/obj/item/ammo_casing/c45/inc
	name = ".45 incendiary bullet casing"
	desc = "A .45 bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c45

/obj/item/ammo_casing/caseless/c45/cs
	name = ".45 caseless bullet"
	desc = "Huh? But i thought..."
	caliber = ".45"
	projectile_type = /obj/projectile/bullet/c45/cs

/obj/item/ammo_casing/c45/sp
	name = ".45 soporific bullet casing"
	desc = "A .45 soporific bullet casing."
	projectile_type = /obj/projectile/bullet/c45/sp
	harmful = FALSE

/obj/item/ammo_casing/c45/emp
	name = ".45 EMP bullet casing"
	desc = "A .45 EMP bullet casing."
	projectile_type = /obj/projectile/bullet/c45/emp

/obj/item/ammo_casing/c45/venom
	name = ".45 venom bullet casing"
	desc = "A .45 venom bullet casing."
	projectile_type = /obj/projectile/bullet/c45/venom
