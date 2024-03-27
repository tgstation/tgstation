/obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "Before the nice streamlined and modern day Proto-Kinetic Accelerator was created, multiple designs were drafted by the Mining Research and Development \
	team. Many were failures, including this one, which came out too bulky and too ineffective. Well recently the MR&D Team got drunk and said 'fuck it we ball' and \
	went back to the bulky design, overclocked it, and made it functional, turning it into what is essentially a literal man portable particle accelerator. \
	The design results in a massive hard to control blast of kinetic energy, with the power to punch right through creatures and cause massive damage. The \
	only problem with the design is that it is so bulky you need to carry it with two hands, and the technology has been outfitted with a special firing pin \
	that denies use near or on the station, due to its destructive nature."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	w_class = WEIGHT_CLASS_HUGE
	pin = /obj/item/firing_pin/wastes
	recharge_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	weapon_weight = WEAPON_HEAVY
	can_bayonet = FALSE
	max_mod_capacity = 0 // Fuck off
	recoil = 3 // Railgun go brrrrr
	disablemodification = TRUE

/obj/item/ammo_casing/energy/kinetic/railgun
	projectile_type = /obj/projectile/kinetic/railgun
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/projectile/kinetic/railgun
	name = "hyper kinetic force"
	damage = 100
	range = 7
	pressure_decrease = 0.10 // Pressured enviorments are a no go for the railgun
	speed = 0.1 // NYOOM
	projectile_piercing = PASSMOB
