
/obj/item/weapon/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual miniature jet engines for flight in a pressurized environment, as well as a set of ion thrusters for operation in EVA. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	icon_state = ""
	item_state = ""
	w_class = 4
	slot_flags = SLOT_BACK
	burn_state = FIRE_PROOF
	strip_delay = 20
	var/locked = 0
	var/locked_strip_delay = 50
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit
	var/requires_suit = 0
	var/slowdown_ground = 1
	var/slowdown_air = -0.5
	var/boost_duration = 30
	var/boost_speed = -3
	var/boost_cooldown = 200
	var/boost_charged = 1


/obj/item/weapon/flightpack/New()
	slowdown = slowdown_ground
	..()

/obj/item/weapon/flightpack/Destroy()
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on the sides. It can also be sealed for use in space, although the user must install a gas tank for propulsion."
	icon_state = ""
	item_state = ""
	w_class = 4
	var/obj/item/weapon/flightpack/pack

/obj/item/clothing/suit/space/hardsuit/flightsuit/New()
	pack = new /obj/item/weapon/flightpack
	pack.requires_suit = 1
	pack.suit = src
	slowdown = pack.slowdown_ground
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/Destroy()
	pack.unEquip()
	qdel(pack)
	..()
