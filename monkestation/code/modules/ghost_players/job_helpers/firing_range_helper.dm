/obj/structure/gun_and_ammo_creator
	name = "firing range fabrication device"
	desc = "Able to print most guns and ammo your heart could ever desire.(not liable for any damages)"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	blacklisted_items = list(
		/obj/item/gun/blastcannon,
		/obj/item/gun/medbeam,
		/obj/item/gun/energy/e_gun/dragnet,
		/obj/item/gun/energy/laser/instakill,
		/obj/item/gun/energy/meteorgun,
		/obj/item/gun/energy/minigun, //might runtime
		/obj/item/gun/energy/pulse/prize, //dont spam ghosts
		/obj/item/gun/energy/shrink_ray,
		/obj/item/gun/energy/xray,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/magic/bloodchill,
		/obj/item/gun/magic/wand/safety,
		/obj/item/gun/magic/wand/teleport,
		/obj/item/gun/magic/wand/polymorph,
		/obj/item/gun/magic/wand/death,
		/obj/item/gun/magic/tentacle,
		/obj/item/gun/magic/wand/door,
		/obj/item/gun/magic/staff/change,
		/obj/item/gun/magic/staff/chaos,
		/obj/item/gun/magic/staff/door,
		/obj/item/gun/magic/staff/flying,
		/obj/item/gun/magic/staff/honk,
		/obj/item/gun/magic/staff/necropotence,
		/obj/item/gun/magic/staff/wipe,
		/obj/item/ammo_box/magazine/internal,
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/magazine/m556/phasic,
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	)
/obj/item/ammo_box/magazine
/obj/item/ammo_box/magazine/toy
//blocks passage if you have a gun
/obj/effect/gun_check_blocker
	name = "anti gun barrier"
	desc = "\"No guns outside the designated area\" is printed below it."
	icon = 'goon/icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"
	color = COLOR_RED
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/gun_check_blocker/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/item/gun))
		return FALSE
	for(var/object in mover.get_all_contents())
		if(istype(object, /obj/item/gun))
			return FALSE
	return ..()

