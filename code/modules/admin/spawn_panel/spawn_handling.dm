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

/*
	Handles spawning an atom. See the call examples for the proper spawn parameters fetching.
*/
/datum/spawnpanel/proc/spawn_atom(list/spawn_params, mob/user)
	if(!check_rights(R_SPAWN) || !spawn_params)
		return

	var/atom/atom_to_spawn = spawn_params["selected_atom"]

	if(!atom_to_spawn || (!ispath(atom_to_spawn, /obj) && !ispath(atom_to_spawn, /turf) && !ispath(atom_to_spawn, /mob)))
		return

	var/amount = clamp(text2num(spawn_params["atom_amount"]), 1, ADMIN_SPAWN_CAP)

	var/list/offset_data
	if(islist(spawn_params["offset"]))
		offset_data = spawn_params["offset"]
	else if(istext(spawn_params["offset"]))
		var/list/parsed = splittext(spawn_params["offset"], ",")
		if(length(parsed) >= 3)
			offset_data = list("X" = text2num(parsed[1]), "Y" = text2num(parsed[2]), "Z" = text2num(parsed[3]))
		else
			offset_data = list("X" = 0, "Y" = 0, "Z" = 0)
	else
		offset_data = list("X" = 0, "Y" = 0, "Z" = 0)


	var/X = offset_data["X"] || 0
	var/Y = offset_data["Y"] || 0
	var/Z = offset_data["Z"] || 0

	var/atom_dir = text2num(spawn_params["atom_dir"]) || 1
	var/atom_name = sanitize(spawn_params["atom_name"])

	var/where_target_type = spawn_params["where_target_type"]
	var/atom/target = null

	if(where_target_type == WHERE_MOB_HAND || where_target_type == WHERE_TARGETED_MOB_HAND)
		target = (where_target_type == WHERE_TARGETED_MOB_HAND ? spawn_params["target"] : user)

		if(!target)
			to_chat(user, span_warning("No target specified."))
			return

		if(!ismob(target))
			to_chat(user, span_warning("The targeted atom is not a mob."))
			return

		if(!iscarbon(target) && !iscyborg(target))
			to_chat(user, span_warning("Can only spawn in hand when the target is a carbon mob or a cyborg."))
			where_target_type = WHERE_FLOOR_BELOW_MOB

	else if(where_target_type == WHERE_MARKED_OBJECT || where_target_type == WHERE_IN_MARKED_OBJECT)
		if(!user.client.holder.marked_datum)
			to_chat(user, span_warning("You don't have any object marked."))
			return
		else if(!istype(user.client.holder.marked_datum, /atom))
			to_chat(user, span_warning("The object you have marked cannot be used as a target. Target must be of type /atom."))
			return
		else
			target = (where_target_type == WHERE_MARKED_OBJECT ? get_turf(user.client.holder.marked_datum) : user.client.holder.marked_datum)

	else if(where_target_type == WHERE_TARGETED_LOCATION || where_target_type == WHERE_TARGETED_LOCATION_POD)
		target = spawn_params["target"]
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

	var/use_droppod = where_target_type == WHERE_SUPPLY_BELOW_MOB || where_target_type == WHERE_TARGETED_LOCATION_POD

	var/obj/structure/closet/supplypod/centcompod/pod
	if(use_droppod)
		pod = new()

	for(var/i in 1 to amount)
		if(istype(atom_to_spawn, /turf))
			var/turf/original_turf = target
			var/turf/created_turf = original_turf.ChangeTurf(atom_to_spawn.type)
			if(created_turf && atom_name)
				created_turf.name = atom_name
			continue

		var/atom/created_atom = new atom_to_spawn(use_droppod ? pod : target)

		if(QDELETED(created_atom))
			return

		created_atom.flags_1 |= ADMIN_SPAWNED_1

		if(spawn_params["apply_icon_override"])
			if(spawn_params["selected_atom_icon"])
				created_atom.icon = file(spawn_params["selected_atom_icon"])

			if(spawn_params["selected_atom_icon_state"])
				created_atom.icon_state = spawn_params["selected_atom_icon_state"]

		if(spawn_params["atom_icon_size"])
			if(ismob(created_atom))
				var/mob/living/created_mob = created_atom
				created_mob.current_size = spawn_params["atom_icon_size"] / 100

		if(atom_dir)
			created_atom.setDir(atom_dir)

		if(atom_name)
			created_atom.name = atom_name
			if(ismob(created_atom))
				var/mob/created_mob = created_atom
				created_mob.real_name = atom_name

		if((where_target_type == WHERE_MOB_HAND || where_target_type == WHERE_TARGETED_MOB_HAND) && isliving(target) && isitem(created_atom))
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

	log_admin("[key_name(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [atom_to_spawn.type]")
	if(istype(atom_to_spawn, /mob))
		message_admins("[key_name_admin(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [atom_to_spawn.type]")

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
