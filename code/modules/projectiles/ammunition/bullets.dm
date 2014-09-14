/obj/item/ammo_casing/a357
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/a50
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL

/obj/item/ammo_casing/a418
	desc = "A .418 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/suffocationbullet"
	w_type = RECYK_METAL


/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	projectile_type = "/obj/item/projectile/bullet/gyro"
	w_type = RECYK_METAL


/obj/item/ammo_casing/a666
	desc = "A .666 bullet casing."
	caliber = "357"
	projectile_type = "/obj/item/projectile/bullet/cyanideround"
	w_type = RECYK_METAL


/obj/item/ammo_casing/c38
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = "/obj/item/projectile/bullet/weakbullet"
	w_type = RECYK_METAL

/* Not entirely ready to be implemented yet. Get a server vote on bringing these in
/obj/item/ammo_casing/c38/lethal
	desc = "A .38 bullet casing. This is the lethal variant."
	caliber = "38"
	projectile_type = "/obj/item/projectile/bullet" //HAHA, why is this a good idea
	w_type = RECYK_METAL
*/

/obj/item/ammo_casing/c9mm
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet2"
	w_type = RECYK_METAL


/obj/item/ammo_casing/c45
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = "/obj/item/projectile/bullet/midbullet"
	w_type = RECYK_METAL


/obj/item/ammo_casing/a12mm
	desc = "A 12mm bullet casing."
	caliber = "12mm"
	projectile_type = "/obj/item/projectile/bullet/midbullet"
	w_type = RECYK_METAL


/obj/item/ammo_casing/shotgun
	name = "shotgun shell"
	desc = "A 12 gauge shell."
	icon_state = "gshell"
	caliber = "shotgun"
	projectile_type = "/obj/item/projectile/bullet"
	m_amt = 12500
	w_type = RECYK_METAL


/obj/item/ammo_casing/shotgun/blank
	name = "shotgun shell"
	desc = "A blank shell."
	icon_state = "blshell"
	projectile_type = ""
	m_amt = 250
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/empty
	name = "shotgun shell"
	desc = "This one has been spent."
	icon_state = "emptyshell"
	projectile_type = ""
	m_amt = 250
	spent = 1 //just to stop people loading a gun with it. This should never go to 0 on the empty
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet"
	m_amt = 500
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/fakebeanbag
	name = "beanbag shell"
	desc = "A weak beanbag shell."
	icon_state = "bshell"
	projectile_type = "/obj/item/projectile/bullet/weakbullet/booze"
	m_amt = 12500
	w_type = RECYK_METAL

/obj/item/ammo_casing/shotgun/stunshell
	name = "stun shell"
	desc = "A stunning shell."
	icon_state = "stunshell"
	projectile_type = "/obj/item/projectile/bullet/stunshot"
	m_amt = 2500
	w_type = RECYK_METAL


/obj/item/ammo_casing/shotgun/dart
	name = "shotgun darts"
	desc = "A dart for use in shotguns."
	icon_state = "blshell"
	projectile_type = "/obj/item/projectile/energy/dart"
	m_amt = 12500
	w_type = RECYK_METAL

/obj/item/ammo_casing/a762
	desc = "A 7.62 bullet casing."
	caliber = "a762"
	projectile_type = "/obj/item/projectile/bullet"
	w_type = RECYK_METAL


/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/bullet
	//select_name = "kinetic"
	//e_cost = 500
	//fire_sound = 'sound/weapons/Gunshot4.ogg'
	w_type = RECYK_METAL