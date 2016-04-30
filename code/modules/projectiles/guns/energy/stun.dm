/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

/obj/item/weapon/gun/energy/shock_revolver
	name = "tesla revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	icon_state = "stunrevolver"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/shock_revolver)
	can_flashlight = 0
	pin = null
	ammo_x_offset = 1


/obj/item/ammo_casing/energy/shock_revolver
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 200
	select_name = "stun"
	projectile_type = /obj/item/projectile/energy/shock_revolver


/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	var/chain

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/hook/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)


/obj/item/weapon/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = null
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = 0
	can_charge = 0

/obj/item/weapon/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

/obj/item/weapon/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 3

/obj/item/weapon/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = 0

/obj/item/weapon/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()
