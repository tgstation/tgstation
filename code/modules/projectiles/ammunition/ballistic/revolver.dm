// .357 (Syndie Revolver)

/obj/item/ammo_casing/a357
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = CALIBER_357
	projectile_type = /obj/projectile/bullet/a357

/obj/item/ammo_casing/a357/match
	name = ".357 match bullet casing"
	desc = "A .357 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/a357/match

// 7.62x38mmR (Nagant Revolver)

/obj/item/ammo_casing/n762
	name = "7.62x38mmR bullet casing"
	desc = "A 7.62x38mmR bullet casing."
	caliber = CALIBER_N762
	projectile_type = /obj/projectile/bullet/n762

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

/obj/item/ammo_casing/pea
	name = "pea bullet casing"
	desc = "A pea bullet casing. Yummy."
	caliber = CALIBER_PEA
	icon_state = "pea"
	projectile_type = /obj/projectile/bullet/pea

/obj/item/ammo_casing/pea/attack_self(mob/user)
	qdel(src)
	var/obj/item/food/grown/peas/peas = new (user.drop_location())
	user.put_in_hands(peas)
	to_chat(user, span_notice("You crush the pea in your hand, and it explodes into a small bundle of edible peas."))
