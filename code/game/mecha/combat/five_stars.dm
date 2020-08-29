/obj/mecha/combat/five_stars
	desc = "A state of the art tank deployed by the Spinward Stellar Coalition National Guard."
	name = "\improper Tank"
	icon = 'icons/mecha/mecha_96x96.dmi'
	icon_state = "five_stars"
	armor = list(MELEE = 100, BULLET = 50, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	exit_delay = 40
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 800
	pixel_x = -32
	pixel_y = -32

/obj/mecha/combat/five_stars/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/spacecops(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay(src)
	ME.attach(src)
	max_ammo()
