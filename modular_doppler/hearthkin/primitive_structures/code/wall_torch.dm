/obj/structure/wall_torch
	name = "mounted torch"
	desc = "A simple torch mounted to the wall, for lighting and such."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/lighting.dmi'
	icon_state = "walltorch"
	base_icon_state = "walltorch"
	anchored = TRUE
	density = FALSE
	light_color = LIGHT_COLOR_FIRE
	/// Torch contained by the wall torch, if it was mounted manually.
	/// Will be `TRUE` if it was intended to spawn in with a torch,
	/// without actually initializing a torch in it to save on memory.
	var/obj/item/flashlight/flare/torch/mounted_torch = TRUE
	/// is the bonfire lit?
	var/burning = FALSE
	/// Does this torch spawn pre-lit?
	var/spawns_lit = FALSE
	/// What this item turns back into when wrenched off the wall.
	var/wallmount_item_type = /obj/item/wallframe/torch_mount

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_torch, 28)

/obj/structure/wall_torch/Initialize(mapload)
	. = ..()
	if(mounted_torch && spawns_lit)
		light_it_up()

	update_appearance(UPDATE_NAME | UPDATE_DESC | UPDATE_ICON_STATE)
	find_and_hang_on_wall()


/obj/structure/wall_torch/Destroy()
	drop_torch() // So it drops on the floor when destroyed.
	return ..()


/obj/structure/wall_torch/update_icon_state()
	icon_state = "[base_icon_state][mounted_torch ? (burning ? "_on" : "") : "_mount"]"
	return ..()


/obj/structure/wall_torch/update_name(updates)
	. = ..()
	name = mounted_torch ? "mounted torch" : "torch mount"


/obj/structure/wall_torch/update_desc(updates)
	. = ..()
	desc = mounted_torch ? "A simple torch mounted to the wall, for lighting and such." : "A simple torch mount, torches go here."


/obj/structure/wall_torch/attackby(obj/item/used_item, mob/living/user, params)
	if(!mounted_torch)
		if(!istype(used_item, /obj/item/flashlight/flare/torch))
			return ..()

		mounted_torch = used_item
		RegisterSignal(used_item, COMSIG_QDELETING, PROC_REF(remove_torch))
		used_item.forceMove(src)
		update_appearance(UPDATE_NAME | UPDATE_DESC)

		if(mounted_torch.light_on)
			light_it_up()
		else
			extinguish()

		mounted_torch.turn_off()

		return

	if(!burning && used_item.get_temperature())
		light_it_up()
	else
		return ..()


/obj/structure/wall_torch/fire_act(exposed_temperature, exposed_volume)
	light_it_up()


/// Sets the torch's icon to burning and sets the light up
/obj/structure/wall_torch/proc/light_it_up()
	burning = TRUE
	set_light(4)
	update_icon_state()
	update_appearance(UPDATE_ICON)


/obj/structure/wall_torch/extinguish()
	. = ..()
	if(!burning)
		return

	burning = FALSE
	set_light(0)
	update_appearance(UPDATE_ICON)


/obj/structure/wall_torch/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	remove_torch(user)


/**
 * Helper proc that handles removing the torch and trying to put it in the user's hand.
 */
/obj/structure/wall_torch/proc/remove_torch(mob/living/user, update_visuals = TRUE)
	if(!mounted_torch)
		return

	if(!istype(mounted_torch))
		mounted_torch = new(src)

	if(burning)
		mounted_torch.toggle_light()

	if(user)
		mounted_torch.attempt_pickup(user)

	else
		mounted_torch.forceMove(drop_location())

	UnregisterSignal(mounted_torch, COMSIG_QDELETING)

	mounted_torch = null
	burning = FALSE
	set_light(0)
	update_appearance(UPDATE_ICON | UPDATE_NAME | UPDATE_DESC)


/obj/structure/wall_torch/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You detach [src] from its place."))

	remove_torch(user)

	var/obj/item/wallframe/torch_mount/mount_item = new /obj/item/wallframe/torch_mount(drop_location())
	transfer_fingerprints_to(mount_item)

	qdel(src)
	return TRUE


/// Simple helper to drop the torch upon the mount being qdel'd.
/obj/structure/wall_torch/proc/drop_torch()
	if(!mounted_torch)
		return

	if(!istype(mounted_torch))
		mounted_torch = new(src)

	if(burning)
		mounted_torch.toggle_light()

	mounted_torch.forceMove(drop_location())

	UnregisterSignal(mounted_torch, COMSIG_QDELETING)

	mounted_torch = null


/obj/structure/wall_torch/mount_only
	name = "torch mount"
	mounted_torch = null

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_torch/mount_only, 28)


/obj/structure/wall_torch/spawns_lit
	spawns_lit = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_torch/spawns_lit, 28)


/obj/item/wallframe/torch_mount
	name = "torch mount"
	desc = "Used to attach torches to walls."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/lighting.dmi'
	icon_state = "walltorch_mount"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	result_path = /obj/structure/wall_torch/mount_only
	pixel_shift = 28


/obj/item/wallframe/torch_mount/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user) > 1)
		balloon_alert(user, "you are too far!")
		return

	var/floor_to_wall = get_dir(user, on_wall)
	if(!(floor_to_wall in GLOB.cardinals))
		balloon_alert(user, "stand in line with wall!")
		return

	var/turf/user_turf = get_turf(user)

	if(check_wall_item(user_turf, floor_to_wall, wall_external))
		balloon_alert(user, "already something here!")
		return

	return TRUE
