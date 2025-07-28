#define WHERE_FLOOR_BELOW_MOB "Current location"
#define WHERE_SUPPLY_BELOW_MOB "Current location (droppod)"
#define WHERE_MOB_HAND "In own mob's hand"
#define WHERE_MARKED_OBJECT "At a marked object"
#define WHERE_IN_MARKED_OBJECT "In the marked object"
#define WHERE_TARGETED_LOCATION "Targeted location"
#define WHERE_TARGETED_LOCATION_POD "Targeted location (droppod)"
#define WHERE_TARGETED_MOB_HAND "In targeted mob's hand"

#define OFFSET_ABSOLUTE "Absolute offset"
#define OFFSET_RELATIVE "Relative offset"

/datum/spawnpanel/proc/spawn_item(list/spawn_params, mob/user)
	if(!check_rights(R_SPAWN) || !spawn_params)
		return

	var/path = text2path(spawn_params["object_list"])

	if(!path || (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob)))
		return

	var/amount = clamp(text2num(spawn_params["object_count"]), 1, ADMIN_SPAWN_CAP)

	var/offset_raw = spawn_params["offset"]
	var/list/offset = splittext(offset_raw, ",")
	var/X = 0
	var/Y = 0
	var/Z = 0

	if(spawn_params["X"] && spawn_params["Y"] && spawn_params["Z"])
		X = spawn_params["X"]
		Y = spawn_params["Y"]
		Z = spawn_params["Z"]
	else
		if(offset.len > 0)
			X = text2num(offset[1]) || 0

		if(offset.len > 1)
			Y = text2num(offset[2]) || 0

		if(offset.len > 2)
			Z = text2num(offset[3]) || 0

	var/obj_dir = text2num(spawn_params["object_dir"]) || 1
	var/atom_name = sanitize(spawn_params["object_name"])
	var/where = spawn_params["object_where"]
	var/atom/target

	if(where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND)
		var/atom/target_reference
		switch(where)
			if(WHERE_TARGETED_MOB_HAND)
				target_reference = spawn_params["object_reference"]

			if(WHERE_MOB_HAND)
				target_reference = user

		if(!target_reference)
			to_chat(user, span_warning("No target reference provided."))
			return

		if(!ismob(target_reference))
			to_chat(user, span_warning("The targeted atom is not a mob."))
			return

		if(!iscarbon(target_reference) && !iscyborg(target_reference))
			to_chat(user, span_warning("Can only spawn in hand when the target is a carbon mob or cyborg."))
			where = WHERE_FLOOR_BELOW_MOB
		target = target_reference

	else if(where == WHERE_MARKED_OBJECT || where == WHERE_IN_MARKED_OBJECT)
		if(!user.client.holder.marked_datum)
			to_chat(user, span_warning("You don't have any object marked."))
			return
		else if(!istype(user.client.holder.marked_datum, /atom))
			to_chat(user, span_warning("The object you have marked cannot be used as a target. Target must be of type /atom."))
			return
		else
			target = (where == WHERE_MARKED_OBJECT ? get_turf(user.client.holder.marked_datum) : user.client.holder.marked_datum)

	else
		switch(spawn_params["offset_type"])
			if(OFFSET_ABSOLUTE)
				target = locate(X, Y, Z)

			if(OFFSET_RELATIVE)
				var/turf/relative_turf
				var/atom/user_loc = user.loc

				if (user_loc)
					relative_turf = get_turf(user_loc)

				if (!relative_turf)
					if(isobserver(user))
						var/mob/dead/observer/user_observer = user
						relative_turf = get_turf(user_observer.client?.eye) || get_turf(user_observer)
					if (!relative_turf)
						relative_turf = locate(1, 1, 1)

				if (!relative_turf)
					to_chat(user, span_warning("Could not determine a valid relative location."))
					return

				target = locate(relative_turf.x + X, relative_turf.y + Y, relative_turf.z + Z)

	if(!target)
		return

	var/use_droppod = where == WHERE_SUPPLY_BELOW_MOB || where == WHERE_TARGETED_LOCATION_POD

	var/obj/structure/closet/supplypod/centcompod/pod
	if(use_droppod)
		pod = new()

	for(var/i in 1 to amount)
		if(ispath(path, /turf))
			var/turf/original_turf = target
			var/turf/created_turf = original_turf.ChangeTurf(path)
			if(created_turf && atom_name)
				created_turf.name = atom_name
			continue

		var/atom/created_atom

		if(use_droppod)
			created_atom = new path(pod)
		else
			created_atom = new path(target)

		if(QDELETED(created_atom))
			return

		created_atom.flags_1 |= ADMIN_SPAWNED_1

		if(spawn_params["custom_icon"])
			created_atom.icon = file(spawn_params["custom_icon"])
		if(spawn_params["custom_icon_state"])
			created_atom.icon_state = spawn_params["custom_icon_state"]
		if(spawn_params["custom_icon_size"])
			if(ismob(created_atom))
				var/mob/living/created_mob = created_atom
				created_mob.current_size = spawn_params["custom_icon_size"] / 100

		if(obj_dir)
			created_atom.setDir(obj_dir)

		if(atom_name)
			created_atom.name = atom_name
			if(ismob(created_atom))
				var/mob/created_mob = created_atom
				created_mob.real_name = atom_name

		if((where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND) && isliving(target) && isitem(created_atom))
			var/mob/living/living_target = target
			var/obj/item/created_item = created_atom
			living_target.put_in_hands(created_item)

			if(iscyborg(living_target))
				var/mob/living/silicon/robot/target_robot = living_target
				if(target_robot.model)
					target_robot.model.add_module(created_item, TRUE, TRUE)
					target_robot.activate_module(created_item)

	if(pod)
		new /obj/effect/pod_landingzone(target, pod)

	log_admin("[key_name(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [path]")
	if(ispath(path, /mob))
		message_admins("[key_name_admin(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [path]")

#undef WHERE_FLOOR_BELOW_MOB
#undef WHERE_SUPPLY_BELOW_MOB
#undef WHERE_MOB_HAND
#undef WHERE_MARKED_OBJECT
#undef WHERE_IN_MARKED_OBJECT
#undef WHERE_TARGETED_LOCATION
#undef WHERE_TARGETED_LOCATION_POD
#undef WHERE_TARGETED_MOB_HAND
#undef OFFSET_ABSOLUTE
#undef OFFSET_RELATIVE
