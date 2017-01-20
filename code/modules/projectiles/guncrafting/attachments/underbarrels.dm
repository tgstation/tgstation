/obj/item/weapon/gun_attachment/underbarrel
	not_okay = /obj/item/weapon/gun_attachment/underbarrel
	no_revolver = 0

/obj/item/weapon/gun_attachment/underbarrel/bayonet
	name = "Bayonet"
	desc = "Great for stabbing."
	icon_state = "attach_underbarrel_bayonet"

/obj/item/weapon/gun_attachment/underbarrel/bayonet/on_attach(var/obj/item/weapon/gun/owner)
	..()
	owner.force += 10

/obj/item/weapon/gun_attachment/underbarrel/bayonet/on_remove(var/obj/item/weapon/gun/owner)
	..()
	owner.force -= 10