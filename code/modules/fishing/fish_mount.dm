/obj/item/wallframe/fish
	name = "fish mount"
	desc = "The frame of a mount for trophy fish, to show off your proudest catch."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fish_mount_item"
	result_path = /obj/structure/fish_mount
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 31
	///Reference to the persistent_id of the mount this was spawned from.
	var/persistence_id

/obj/item/wallframe/fish/after_attach(obj/structure/fish_mount/mount)
	. = ..()
	mount.persistence_id = persistence_id

///A wallmounted structure on which a fish can be attached to be used as room decoration.
/obj/structure/fish_mount
	name = "fish mount"
	desc = "A mount for trophy fish, to show off your proudest catch."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "fish_mount"
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 100
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	armor_type = /datum/armor/structure_sign
	resistance_flags = FLAMMABLE
	/// The instance of the fish mounted on this.
	var/obj/item/fish/mounted_fish
	/// The identifier for mounts that carry the trophy between rounds.
	var/persistence_id
	/// Trophies from persistence are dusted if removed to be safe.
	var/persistence_loaded_fish = FALSE
	/// String containing the name of whoever caught the fish
	var/catcher_name
	/// The date of when the fish was mounted (which should coincide with the day when it was actually caught)
	var/catch_date

/obj/structure/fish_mount/Initialize(mapload, floor_to_wall_dir)
	. = ..()
	//Mounted fish shouldn't flop. It should also show size and weight to everyone.
	add_traits(list(TRAIT_STOP_FISH_FLOPPING, TRAIT_EXAMINE_FISH), INNATE_TRAIT)
	if(floor_to_wall_dir)
		setDir(floor_to_wall_dir)
	find_and_hang_on_wall()
	if(!persistence_id)
		return
	SSpersistence.load_trophy_fish(src)
	if(!mounted_fish)
		add_first_fish()

/obj/structure/fish_mount/screwdriver_act(mob/living/user, obj/item/item)
	. = ..()
	balloon_alert(user, "removing mount...")
	if(!item.use_tool(src, user, 3 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	balloon_alert_to_viewers("fish mount removed")
	deconstruct()
	return ITEM_INTERACT_SUCCESS

/obj/structure/fish_mount/proc/add_first_fish()
	var/obj/item/fish/fish_path = pick(subtypesof(/obj/item/fish) - typesof(/obj/item/fish/holo))
	if(fish_path.fish_id_redirect_path)
		fish_path = fish_path.fish_id_redirect_path
	add_fish(new fish_path(src), from_persistence = TRUE)
	mounted_fish.randomize_size_and_weight()
	catcher_name = pick("John Trasen III", "a nameless intern", "Pun Pun", AQUARIUM_COMPANY, "Unknown", "Central Command")
	catch_date = "[time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR]"
	mounted_fish.set_status(FISH_DEAD)
	SSpersistence.save_trophy_fish(src)

/obj/structure/fish_mount/atom_deconstruct(disassembled = TRUE)
	. = ..()
	if(disassembled)
		var/obj/item/wallframe/fish/frame = new (loc)
		frame.persistence_id = persistence_id
	mounted_fish?.forceMove(loc)

/obj/structure/fish_mount/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if(!isfish(item) || user.combat_mode)
		return ..()
	if(mounted_fish)
		balloon_alert(user, "remove other fish first!")
		return ITEM_INTERACT_BLOCKING
	if(item.flags_1 & HOLOGRAM_1)
		balloon_alert(user, "fish not mountable!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "mounting fish...")
	if(!do_after(user, 3 SECONDS, src) || mounted_fish)
		return ITEM_INTERACT_BLOCKING
	add_fish(item)
	catcher_name = user.name
	catch_date = "[time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR]"
	balloon_alert_to_viewers("fish mounted")
	playsound(loc, 'sound/machines/click.ogg', 30, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/fish_mount/proc/add_fish(obj/item/fish/fish, from_persistence = FALSE)
	if(mounted_fish)
		mounted_fish.forceMove(loc)
	fish.forceMove(src)
	vis_contents += fish
	fish.flags_1 |= IS_ONTOP_1
	fish.vis_flags |= VIS_INHERIT_PLANE
	mounted_fish = fish

	AddElement(/datum/element/beauty, get_fish_beauty())
	RegisterSignal(fish, COMSIG_ATOM_EXAMINE, PROC_REF(on_fish_examined))
	RegisterSignal(fish, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_fish_attack_hand))
	rotate_fish(dir)
	if(from_persistence)
		persistence_loaded_fish = TRUE
		fish.remove_fillet_type()
		fish.fillet_type = null
	else if(persistence_id)
		SSpersistence.save_trophy_fish(src)

/obj/structure/fish_mount/proc/get_fish_beauty()
	var/beauty = 100 + mounted_fish.beauty * 1.2
	var/datum/material/main_material = mounted_fish.get_master_material()
	if(main_material)
		beauty += main_material.beauty_modifier * mounted_fish.weight
	return round(beauty)

/obj/structure/fish_mount/proc/rotate_fish(direction, old_direction)
	var/rotation = angle2dir(REVERSE_DIR(direction))
	if(old_direction)
		rotation -= angle2dir(REVERSE_DIR(old_direction))

	if(!rotation)
		return
	mounted_fish.transform = mounted_fish.transform.Turn(rotation)

/obj/structure/fish_mount/setDir(newdir)
	var/old_dir = dir
	. = ..()
	rotate_fish(dir, old_dir)

/obj/structure/fish_mount/proc/on_fish_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_greentext("Caught by [catcher_name] on [catch_date].")

/obj/structure/fish_mount/proc/on_fish_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(remove_fish), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fish_mount/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!mounted_fish)
		balloon_alert(user, "no fish mounted!")
	else
		remove_fish(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/fish_mount/proc/remove_fish(mob/living/user)
	balloon_alert(user, "removing fish...")
	if(!do_after(user, 3 SECONDS, src) && mounted_fish)
		return
	var/obj/item/fish/fish_reference = mounted_fish
	user.put_in_hands(mounted_fish)
	if(QDELETED(fish_reference))
		var/ash_type = /obj/effect/decal/cleanable/ash
		if(fish_reference.w_class >= WEIGHT_CLASS_BULKY)
			ash_type = /obj/effect/decal/cleanable/ash/large
		new ash_type(loc)
		visible_message("[fish_reference] turns into dust as [fish_reference.p_theyre()] removed from [src].")
	balloon_alert_to_viewers("fish removed")

/obj/structure/fish_mount/Exited(atom/movable/gone)
	if(gone != mounted_fish)
		return ..()
	RemoveElement(/datum/element/beauty, get_fish_beauty())
	if(persistence_loaded_fish)
		if(!QDELETED(gone))
			qdel(gone)
	else
		rotate_fish(0, dir)
		persistence_loaded_fish = FALSE
		UnregisterSignal(gone, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACK_HAND))
		gone.flags_1 &= ~IS_ONTOP_1
		gone.vis_flags &= ~VIS_INHERIT_PLANE
	catcher_name = null
	catch_date = null
	mounted_fish = null
	return ..()

/obj/structure/fish_mount/bar
	persistence_id = "Bar"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/fish_mount/bar, /obj/item/wallframe/fish::pixel_shift)
