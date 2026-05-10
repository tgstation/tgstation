/obj/item/implant/tacmap
	name = "tactical map implant"
	desc = "provides you with a map"
	actions_types = list(/datum/action/minimap_new)

/obj/item/implant/tacmap/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		addtimer(CALLBACK(src, PROC_REF(update_minimap_icon), target), 0.1 SECONDS) // Mobs are spawned inside nullspace sometimes so this avoids that hijinks.

/obj/item/implant/tacmap/removed(mob/living/source, silent, special)
	remove_minimap(source)
	return ..()

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/implant/tacmap/proc/remove_minimap(mob/user)
	remove_minimap_blip(MINIMAP_NUKEOP_BLIP, user)

///Updates the wearer's minimap icon
/obj/item/implant/tacmap/proc/update_minimap_icon(mob/wearer)
	SIGNAL_HANDLER
	remove_minimap_blip(MINIMAP_NUKEOP_BLIP, wearer)
	if(IS_NUKE_OP(wearer))
		add_minimap_blip(wearer, MINIMAP_NUKEOP_BLIP, "syndicate")


/obj/item/implant/tacmap/nuclear // Nukie subtype, map shows you nuke disk, operatives, cayenne and the nuke
	actions_types = list(/datum/action/minimap_new/nuclear)

/obj/item/implant/tacmap/nuclear/implant(mob/living/target, mob/user, silent, force)
	if(istype(target, /mob/living/basic/carp/pet/cayenne))
		return ..()

	var/datum/antagonist/nukeop/nukie = IS_NUKE_OP(target)
	if(isnull(nukie))
		return ..()
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MINIMAP_ACTION_TRIGGER, PROC_REF(deny_nukie_base_open))

/obj/item/implant/tacmap/nuclear/removed(mob/living/source, silent, special)
	UnregisterSignal(source, COMSIG_MINIMAP_ACTION_TRIGGER)
	return ..()

/obj/item/implant/tacmap/nuclear/proc/deny_nukie_base_open(mob/living/user)
	var/turf/user_turf = get_turf(user)
	if(user_turf.onSyndieBase())
		user.balloon_alert(user, "cannot use implant on base, use holotable!")
		return COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL

/obj/item/implant/tacmap/nuclear/leader // Leader subtype lets him draw on the map
	actions_types = list(/datum/action/minimap_new/nuclear)

/obj/item/implant/tacmap/drawing
	actions_types = list(/datum/action/minimap_new)

// Subtype that just lets them open it off-base.
/obj/item/implant/tacmap/nuclear/offbase

/obj/item/implant/tacmap/nuclear/offbase/deny_nukie_base_open(mob/living/user)
	return

/obj/item/implanter/tacmap
	name = "implanter (minimap)"
	imp_type = /obj/item/implant/tacmap

/obj/item/implantcase/tacmap
	name = "implant case - 'Tactical Map'"
	desc = "A glass case containing an implant with a virtual map."
	imp_type = /obj/item/implant/tacmap
