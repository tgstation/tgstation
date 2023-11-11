/obj/item/gun/energy/laser/musket/syndicate
	name = "syndicate laser musket"
	desc = "A powerful laser(?) weapon, its 4 tetradimensional capacitors can hold 2 shots each, totaling to 8 shots. \
	Putting your hand on the control panel gives you a strange tingling feeling, this is probably how you charge it."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "musket_syndie"
	inhand_icon_state = "musket_syndie"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	worn_icon_state = "las_musket_syndie"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/musket/syndicate)
	w_class = WEIGHT_CLASS_NORMAL
/obj/item/gun/energy/laser/musket/syndicate/Initialize(mapload) //it takes two hand slots and costs 12 tc, they deserve fast recharging
	. = ..()
	AddComponent( \
		/datum/component/gun_crank, \
		charging_cell = get_cell(), \
		charge_amount = 250, \
		cooldown_time = 1.5 SECONDS, \
		charge_sound = 'sound/weapons/laser_crank.ogg', \
		charge_sound_cooldown_time = 1.3 SECONDS, \
		)

/obj/projectile/beam/laser/musket
	damage = 30
	stamina = 45

/obj/projectile/beam/laser/musket/prime
	damage = 35
	stamina = 60

/obj/projectile/beam/disabler/smoothbore/prime
	stamina = 65

/obj/item/ammo_casing/energy/laser/musket
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/musket/syndicate
	projectile_type = /obj/projectile/beam/laser/musket/syndicate
	e_cost = 125
	fire_sound = 'sound/weapons/laser2.ogg'

/obj/projectile/beam/laser/musket/syndicate
	name = "resonant laser"
	damage = 30
	stamina = 65
	weak_against_armour = FALSE
	armour_penetration = 25 //less powerful than armor piercing rounds
	wound_bonus = 10
