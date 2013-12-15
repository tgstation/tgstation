/obj/item/weapon/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/gun.dmi'
	icon_state = "staffofnothing"
	item_state = "staff"
	fire_sound = 'sound/weapons/emitter.ogg'
	flags =  FPRINT | TABLEPASS | CONDUCT
	w_class = 5
	var/projectile_type = "/obj/item/projectile/magic"
	var/max_charges = 6
	var/charges = 0
	var/recharge_rate = 4
	var/charge_tick = 0
	var/can_charge = 1
	origin_tech = null
	clumsy_check = 0

/obj/item/weapon/gun/magic/process_chambered()
		if(in_chamber)	return 1
		if(!charges)	return 0
		if(!projectile_type)	return 0
		in_chamber = new projectile_type(src)
		return 1

/obj/item/weapon/gun/magic/afterattack(atom/target as mob, mob/living/user as mob, flag)
	..()
	if(charges && !in_chamber && !flag)	charges--

/obj/item/weapon/gun/magic/New()
	..()
	charges = max_charges
	if(can_charge)	processing_objects.Add(src)


/obj/item/weapon/gun/magic/Del()
	if(can_charge)	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/magic/process()
	charge_tick++
	if(charge_tick < recharge_rate || charges >= max_charges) return 0
	charge_tick = 0
	charges++
	return 1

/obj/item/weapon/gun/magic/update_icon()
	return

/obj/item/weapon/gun/magic/shoot_with_empty_chamber(mob/living/user as mob|obj)
	user << "<span class='warning'>The [name] whizzles quietly.<span>"
	return