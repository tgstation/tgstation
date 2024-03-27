/obj/item/gun/energy/recharge/kinetic_accelerator/shotgun
	name = "proto-kinetic shotgun"
	desc = "During the crusher design pizza party, one member of the Mining Research and Development team brought out a real riot shotgun, and killed three \
	other research members with one blast. The MR&D Director immedietly thought of a genuis idea, creating the proto-kinetic shotgun moments later, which he \
	immedietly used to execute the research member who brought the real shotgun. The proto-kinetic shotgun trades off some mod capacity and cooldown in favor \
	of firing three shots at once with reduce range and power. The total damage of all three shots is higher than a regular PKA but the individual shots are weaker."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticshotgun"
	base_icon_state = "kineticshotgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shotgun)
	max_mod_capacity = 60

/obj/item/ammo_casing/energy/kinetic/shotgun
	projectile_type = /obj/projectile/kinetic/shotgun
	pellets = 3
	variance = 50

/obj/projectile/kinetic/shotgun
	name = "split kinetic force"
	damage = 20
