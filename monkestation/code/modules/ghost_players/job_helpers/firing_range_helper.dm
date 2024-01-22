/obj/structure/centcom_item_spawner/gun_and_ammo_creator
	name = "firing range fabrication device"
	desc = "Able to print most guns and ammo your heart could ever desire.(not liable for any damages)"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	blacklisted_items = list(
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/magazine/m556/phasic,
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator,
		/obj/item/ammo_box/magazine,
		/obj/item/ammo_box/magazine/toy,
		/obj/item/gun/ballistic,
		/obj/item/gun/ballistic/automatic,
		/obj/item/gun/ballistic/shotgun/doublebarrel/brazil/death,
		/obj/item/gun/blastcannon,
		/obj/item/gun/energy,
		/obj/item/gun/energy/minigun, //might runtime
		/obj/item/gun/energy/pulse/prize, //dont spam ghosts
		/obj/item/gun/energy/shrink_ray,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/energy/recharge,
		/obj/item/gun/energy/wiremod_gun,
		/obj/item/gun/energy/xray,
		/obj/item/gun/magic,
		/obj/item/gun/magic/bloodchill,
		/obj/item/gun/magic/staff,
		/obj/item/gun/magic/staff/animate,
		/obj/item/gun/magic/staff/change,
		/obj/item/gun/magic/staff/chaos,
		/obj/item/gun/magic/staff/door,
		/obj/item/gun/magic/staff/flying,
		/obj/item/gun/magic/staff/honk,
		/obj/item/gun/magic/staff/necropotence,
		/obj/item/gun/magic/staff/wipe,
		/obj/item/gun/magic/tentacle,
		/obj/item/gun/magic/wand,
		/obj/item/gun/magic/wand/door,
		/obj/item/gun/magic/wand/polymorph,
		/obj/item/gun/magic/wand/teleport,
		/obj/item/microfusion_gun_attachment/barrel/xray,
	)
	blacklisted_types = list(
		/obj/item/ammo_box/magazine/internal,
		/obj/item/gun/energy/e_gun/dragnet,
		/obj/item/gun/energy/ionrifle,
		/obj/item/gun/energy/laser/instakill,
		/obj/item/gun/energy/meteorgun,
		/obj/item/gun/energy/wormhole_projector,
		/obj/item/gun/magic/staff/chaos,
		/obj/item/gun/magic/wand/death,
		/obj/item/gun/magic/wand/safety,
		/obj/item/gun/medbeam,
		/obj/item/gun/energy/recharge/kinetic_accelerator/meme,
	)

/obj/structure/centcom_item_spawner/gun_and_ammo_creator/spawn_chosen_item(type_to_spawn)
	var/obj/spawned_obj = new type_to_spawn(get_turf(src))
	spawned_obj.AddElement(/datum/element/area_locked, list(/area/centcom/central_command_areas/firing_range))

/obj/structure/centcom_item_spawner/gun_and_ammo_creator/build_items_to_spawn()
	items_to_spawn["Ballistic"] = subtypesof(/obj/item/gun/ballistic)
	items_to_spawn["Energy"] = subtypesof(/obj/item/gun/energy)
	items_to_spawn["Magic"] = subtypesof(/obj/item/gun/magic)
	items_to_spawn["Microfusion"] = subtypesof(/obj/item/gun/microfusion) + subtypesof(/obj/item/microfusion_cell_attachment) \
									+ subtypesof(/obj/item/microfusion_gun_attachment) + typesof(/obj/item/stock_parts/cell/microfusion) + typesof(/obj/item/microfusion_phase_emitter)
	items_to_spawn["Ammo"] = subtypesof(/obj/item/ammo_box)
	items_to_spawn["Other"] = list(
		/obj/item/gun/chem,
		/obj/item/gun/grenadelauncher,
		/obj/structure/training_machine,
		/mob/living/carbon/human) + typesof(/obj/item/gun/syringe, /obj/item/target)
	. = ..()

//blocks passage if you have a gun
/obj/effect/gun_check_blocker
	name = "anti gun barrier"
	desc = "\"No guns outside the designated area\" is printed below it."
	icon = 'goon/icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"
	color = COLOR_RED
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/effect/gun_check_blocker/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/item/gun))
		return FALSE
	for(var/object in mover.get_all_contents())
		if(istype(object, /obj/item/gun))
			return FALSE
	return ..()
