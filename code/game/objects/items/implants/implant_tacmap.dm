/obj/item/implant/tacmap
	name = "tactical map implant"
	desc = "provides you with a map"
	actions_types = null
	/// The type of minimap this gives access to
	var/datum/action/minimap/minimap_type = /datum/action/minimap
	/// Reference to the minimap datum
	var/datum/tactical_map/my_map

/obj/item/implant/tacmap/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!my_map)
		my_map = new
		my_map.initialize_tacmap()
	add_minimap(target)

/obj/item/implant/tacmap/removed(mob/living/source, silent, special)
	remove_minimap(source)
	return ..()

/obj/item/implant/tacmap/Destroy()
	QDEL_NULL(my_map)
	return ..()


/// Adds a minimap to the mob, starts the subsystem if it hasnt already
/obj/item/implant/tacmap/proc/add_minimap(mob/user)
	remove_minimap(user)
	var/datum/action/minimap/mini = new minimap_type(tactical_map = my_map)
	mini.Grant(user)
	addtimer(CALLBACK(src, PROC_REF(update_minimap_icon), user), 0.1 SECONDS) //Mobs are spawned inside nullspace sometimes so this is to avoid that hijinks

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/implant/tacmap/proc/remove_minimap(mob/user)
	my_map?.remove_marker(user)
	for(var/datum/action/action as anything in user.actions)
		if(istype(action, /datum/action/minimap))
			action.Remove(user)

///Updates the wearer's minimap icon
/obj/item/implant/tacmap/proc/update_minimap_icon(mob/wearer)
	SIGNAL_HANDLER
	my_map.remove_marker(wearer)

	if(!get_minimap_marker(wearer))
		return

/// Gets the icon to show us on the map
/obj/item/implant/tacmap/proc/get_minimap_marker(mob/wearer)
	var/marker_flags = initial(minimap_type.marker_flags)
	if(istype(wearer, /mob/living/basic/carp/pet/cayenne))
		my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "cayenne", MINIMAP_BLIPS_LAYER))
		return
	if(IS_NUKE_OP(wearer))
		my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "syndicate", MINIMAP_BLIPS_LAYER))
		return
	return

/* XANTODO Conditional map markers
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags = initial(minimap_type.marker_flags)
	if(wearer.stat == DEAD)
		if(HAS_TRAIT(wearer, TRAIT_UNDEFIBBABLE))
			my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
			return
		if(!wearer.mind && !wearer.has_ai())
			var/mob/dead/observer/ghost = wearer.get_ghost(TRUE)
			if(!ghost?.can_reenter_corpse)
				my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
				return
		my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "defibbable", MINIMAP_LABELS_LAYER))
		return
	if(wearer.assigned_squad)
		var/image/underlay = image('icons/ui_icons/minimap/map_blips.dmi', null, "squad_underlay", MINIMAP_BLIPS_LAYER)
		var/image/overlay = image('icons/ui_icons/minimap/map_blips.dmi', null, wearer.job.minimap_icon)
		overlay.color = wearer.assigned_squad.color
		underlay.overlays += overlay

		if(wearer.assigned_squad?.squad_leader == wearer)
			var/image/leader_trim = image('icons/ui_icons/minimap/map_blips.dmi', null, "leader_trim")
			underlay.overlays += leader_trim

		my_map.add_marker(wearer, marker_flags, underlay)
		return
	my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, wearer.job.minimap_icon), MINIMAP_BLIPS_LAYER)
*/


/obj/item/implant/tacmap/nuclear // Nukie subtype, map shows you nuke disk, operatives, cayenne and the nuke
	minimap_type = /datum/action/minimap/nuclear

/obj/item/implant/tacmap/nuclear/implant(mob/living/target, mob/user, silent, force)
	if(istype(target, /mob/living/basic/carp/pet/cayenne))
		return ..()

	var/datum/antagonist/nukeop/nukie = IS_NUKE_OP(target)
	if(isnull(nukie))
		return ..()
	var/datum/team/nuclear/nukie_team = nukie.get_team()
	my_map = nukie_team.nuclear_tacmap // Specify that we are using the nukeop map before calling parent
	my_map.minimap_flags |= MINIMAP_FLAG_NUCLEAR
	return ..()

/obj/item/implant/tacmap/nuclear/leader // Leader subtype lets him draw on the map

/obj/item/implant/tacmap/nuclear/leader/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	var/datum/action/map_drawing/draw_action = new(implant_map = my_map)
	draw_action.Grant(target)

/obj/item/implanter/tacmap
	name = "implanter (minimap)"
	imp_type = /obj/item/implant/tacmap

/obj/item/implantcase/tacmap
	name = "implant case - 'Tactical Map'"
	desc = "A glass case containing an implant with a virtual map."
	imp_type = /obj/item/implant/tacmap
