/obj/item/gun/energy/recharge/kinetic_accelerator/glock
	name = "proto-kinetic pistol"
	desc = "During the pizza party for the Mining Research and Development team, one special snowflake researcher wanted a mini murphy instead of a regular \
	pizza slice, so reluctantly the Director bought him his mini murphy, which the dumbass immedietly dropped ontop of a PKA. Suddenly the idea to create \
	a 'build your own PKA' design was created. The proto-kinetic pistol is arguably worse than the base PKA, sporting lower damage and range. But this lack \
	of base efficiency allows room for nearly double the mods, making it truely 'your own PKA'."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticpistol"
	base_icon_state = "kineticpistol"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/glock)
	can_bayonet = FALSE
	max_mod_capacity = 200

/obj/item/ammo_casing/energy/kinetic/glock
	projectile_type = /obj/projectile/kinetic/glock

/obj/projectile/kinetic/glock
	name = "light kinetic force"
	damage = 10
