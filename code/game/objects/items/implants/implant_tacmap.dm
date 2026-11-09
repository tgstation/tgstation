/obj/item/implant/tacmap
	name = "tactical map implant"
	desc = "provides you with a map"
	actions_types = list(/datum/action/minimap)
	var/wearer_icon_state = null
	/// Optional z-trait that resolves to the first z-level and locks the minimap there.
	var/minimap_fixed_z_trait
	/// Whether this implant allows drawing/labeling on the personal minimap HUD.
	var/can_draw_on_personal_minimap = FALSE
	var/static/list/minimap_refresh_signals = list(
		COMSIG_MOB_STATCHANGE,
		COMSIG_LIVING_REVIVE,
		COMSIG_MOB_GHOSTIZED,
	)

/obj/item/implant/tacmap/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		configure_minimap_action()
		RegisterSignals(target, minimap_refresh_signals, PROC_REF(refresh_minimap_icon))
		addtimer(CALLBACK(src, PROC_REF(update_minimap_icon), target), 0.1 SECONDS) // Mobs are spawned inside nullspace sometimes so this avoids that hijinks.

/obj/item/implant/tacmap/removed(mob/living/source, silent, special)
	UnregisterSignal(source, minimap_refresh_signals)
	remove_minimap(source)
	return ..()

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/implant/tacmap/proc/remove_minimap(mob/user)
	remove_minimap_blip(MINIMAP_NUKEOP_BLIP, user)

/obj/item/implant/tacmap/proc/refresh_minimap_icon()
	SIGNAL_HANDLER
	if(imp_in)
		update_minimap_icon(imp_in)

/obj/item/implant/tacmap/proc/resolve_fixed_minimap_z_level()
	if(!isnull(minimap_fixed_z_trait))
		var/list/trait_levels = SSmapping.levels_by_trait(minimap_fixed_z_trait)
		if(length(trait_levels))
			return trait_levels[1]
	return null

/obj/item/implant/tacmap/proc/configure_minimap_action()
	var/datum/action/minimap/minimap_action = locate(/datum/action/minimap) in actions
	if(isnull(minimap_action))
		return
	minimap_action.fixed_z_level = resolve_fixed_minimap_z_level()
	minimap_action.can_draw = can_draw_on_personal_minimap

/obj/item/implant/tacmap/proc/get_minimap_icon_state(mob/living/wearer)
	return wearer_icon_state

///Updates the wearer's minimap icon
/obj/item/implant/tacmap/proc/update_minimap_icon(mob/wearer)
	SIGNAL_HANDLER
	remove_minimap_blip(MINIMAP_NUKEOP_BLIP, wearer)
	add_minimap_blip(wearer, MINIMAP_NUKEOP_BLIP, get_minimap_icon_state(wearer))

/obj/item/implant/tacmap/nuclear // Nukie subtype, map shows you nuke disk, operatives, cayenne and the nuke
	actions_types = list(/datum/action/minimap/nuclear)
	wearer_icon_state = "syndicate"

/obj/item/implant/tacmap/nuclear/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MINIMAP_ACTION_TRIGGER, PROC_REF(deny_nukie_base_open))

/obj/item/implant/tacmap/nuclear/get_minimap_icon_state(mob/living/wearer)
	if(wearer.stat != DEAD && istype(wearer, /mob/living/basic/carp/pet/cayenne))
		return "cayenne"
	. = ..()

/obj/item/implant/tacmap/nuclear/removed(mob/living/source, silent, special)
	UnregisterSignal(source, COMSIG_MINIMAP_ACTION_TRIGGER)
	return ..()

/obj/item/implant/tacmap/nuclear/proc/deny_nukie_base_open(mob/living/user)
	var/turf/user_turf = get_turf(user)
	if(user_turf.onSyndieBase())
		user.balloon_alert(user, "can't use implant in the base, go to the holotable!")
		return COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL

/obj/item/implant/tacmap/nuclear/cayenne // subtype used for cayenne and syndie sentience potions in general
	wearer_icon_state = "cayenne"

/obj/item/implant/tacmap/nuclear/leader // Leader subtype lets him draw on the map
	actions_types = list(/datum/action/minimap/nuclear)
	can_draw_on_personal_minimap = TRUE
	wearer_icon_state = "syndicate_leader"

/obj/item/implant/tacmap/nuclear/leader/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		ADD_TRAIT(target, TRAIT_MINIMAP_TABLE_DRAW, REF(src))

/obj/item/implant/tacmap/nuclear/leader/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_MINIMAP_TABLE_DRAW, REF(src))
	return ..()

// Subtype that just lets them open it off-base.
/obj/item/implant/tacmap/nuclear/offbase
	minimap_fixed_z_trait = ZTRAIT_STATION
	can_draw_on_personal_minimap = TRUE

/obj/item/implant/tacmap/nuclear/offbase/deny_nukie_base_open(mob/living/user)
	return

/obj/item/implanter/tacmap
	name = "implanter (minimap)"
	imp_type = /obj/item/implant/tacmap

/obj/item/implanter/tacmap/nuclear
	name = "implanter (operative minimap)"
	imp_type = /obj/item/implant/tacmap/nuclear

/obj/item/implantcase/tacmap
	name = "implant case - 'Tactical Map'"
	desc = "A glass case containing an implant with a virtual map."
	imp_type = /obj/item/implant/tacmap
