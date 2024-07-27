// .310 Short (Sakhno-Manni Revolver)

/obj/item/ammo_casing/short310
	name = ".310 Short bullet casing"
	desc = "A .310 Short bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder that's been trimmed down."
	icon_state = "310short-casing"
	caliber = CALIBER_SHORT310
	projectile_type = /obj/projectile/bullet/short310

/obj/item/ammo_casing/short310/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/short310/surplus
	name = ".310 Short surplus bullet casing"
	desc = "A surplus .310 Short bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder that's been trimmed down. Damp red powder at that."
	projectile_type = /obj/projectile/bullet/short310/surplus

// .357 (Syndie Revolver)

/obj/item/ammo_casing/a357
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357

/obj/item/ammo_casing/a357/spent
	projectile_type = null

/obj/item/ammo_casing/a357/match
	name = ".357 match bullet casing"
	desc = "A .357 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/a357/match

/obj/item/ammo_casing/a357/phasic
	name = ".357 phasic bullet casing"
	projectile_type = /obj/projectile/bullet/a357/phasic

/obj/item/ammo_casing/a357/heartseeker
	name = ".357 heartseeker bullet casing"
	projectile_type = /obj/projectile/bullet/a357/heartseeker

// .38 (Detective's Gun)

/obj/item/ammo_casing/c38
	name = ".38 bullet casing"
	desc = "A .38 bullet casing."
	caliber = CALIBER_38
	projectile_type = /obj/projectile/bullet/c38

/obj/item/ammo_casing/c38/trac
	name = ".38 TRAC bullet casing"
	desc = "A .38 \"TRAC\" bullet casing."
	projectile_type = /obj/projectile/bullet/c38/trac

/obj/item/ammo_casing/c38/match
	name = ".38 Match bullet casing"
	desc = "A .38 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/c38/match

/obj/item/ammo_casing/c38/match/bouncy
	name = ".38 Rubber bullet casing"
	desc = "A .38 rubber bullet casing, manufactured to exceedingly bouncy standards."
	projectile_type = /obj/projectile/bullet/c38/match/bouncy

/obj/item/ammo_casing/c38/dumdum
	name = ".38 DumDum bullet casing"
	desc = "A .38 DumDum bullet casing."
	projectile_type = /obj/projectile/bullet/c38/dumdum

/obj/item/ammo_casing/c38/hotshot
	name = ".38 Hot Shot bullet casing"
	desc = "A .38 Hot Shot bullet casing."
	projectile_type = /obj/projectile/bullet/c38/hotshot

/obj/item/ammo_casing/c38/iceblox
	name = ".38 Iceblox bullet casing"
	desc = "A .38 Iceblox bullet casing."
	projectile_type = /obj/projectile/bullet/c38/iceblox
