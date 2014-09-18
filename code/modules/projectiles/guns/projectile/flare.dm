/* Flare gun. Shoots a flare type of shotgun ammo, creating a glowing projectile that produces a flare when it dies
   Useful in emergencies to signal and to light up corridors. Syndicate version is deadly and sets people on fire, and likely going to atmos techs */

/obj/item/weapon/gun/projectile/flare
	name = "flare gun"
	desc = "Light (people on fire), now at a distance."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "flaregun"
	item_state = "flaregun"
	max_shells = 1
	empty_casings = 1
	w_class = 3.0
	m_amt = 15000
	g_amt = 7500
	w_type = RECYK_METAL
	force = 4
	recoil = 1
	fire_delay = 10
	empty_casings = 0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	caliber = list("flare" = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = /obj/item/ammo_casing/shotgun/flare

/obj/item/weapon/gun/projectile/flare/syndicate
	desc = "An illegal flare gun with a modified hammer, allowing it to fire shotgun shells and flares at dangerous velocities."
	force = 4
	recoil = 3
	fire_delay = 5 //faster, because it's also meant to be a weapon
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	caliber = list("flare" = 1, "shotgun" = 1)
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = /obj/item/ammo_casing/shotgun/flare