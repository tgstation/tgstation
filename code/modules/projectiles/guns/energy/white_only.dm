/obj/item/weapon/gun/energy/white_only/heatgun
	name = "Syndicate Heat gun"
	desc = "A  energy-based heat laser gun that fires concentrated beams of very hot light which pass through glass and thin metal."
	icon = 'icons/obj/guns/white_only.dmi'
	icon_state = "heatgun"
	item_state = "heatgun"
	lefthand_file = 'icons/mob/inhands/white_only_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/white_only_righthand.dmi'
	fire_sound = 'sound/weapons/laser3.ogg'
	w_class = 3
	materials = list(MAT_METAL=5000)
	origin_tech = "combat=6;magnets=6;syndicate=5"
	ammo_type = list(/obj/item/ammo_casing/energy/white_only/heatgun)
	selfcharge = 1
	charge_delay = 2