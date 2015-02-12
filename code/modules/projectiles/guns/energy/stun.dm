
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)

/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires internal, reusable stun cartidges in a revolving cylinder. Holds twice as many electrodes as a standard taser."
	icon_state = "stunrevolver"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/gun)
	can_flashlight = 0
	pin = null

/obj/item/weapon/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = null