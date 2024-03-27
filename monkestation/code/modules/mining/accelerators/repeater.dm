/obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "During the pizza party celebrating the release of the new crusher designs, the Mining Research and Development team members were only allowed one slice. \
	One member exclaimed 'I wish we could have more than one slice' and another replied 'I wish we could shoot the accelerator more than once' and thus, the repeater \
	on the spot. The repeater trades a bit of power for the ability to fire three shots before becoming empty, while retaining the ability to fully recharge in one \
	go. The extra technology packed inside to make this possible unfortunately reduces mod space meaning you cant carry as many mods compared to a regular accelerator."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticrepeater"
	base_icon_state = "kineticrepeater"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	max_mod_capacity = 60

/obj/item/ammo_casing/energy/kinetic/repeater
	projectile_type = /obj/projectile/kinetic/repeater
	e_cost = 150 //about three shots

/obj/projectile/kinetic/repeater
	name = "rapid kinetic force"
	damage = 20
	range = 4
