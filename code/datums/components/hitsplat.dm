/**
 * Component to display hitsplats
 */
/datum/component/hitsplat
	///positions of all hitsplats
	var/list/hitsplat_positions = list(
		list(0, -2) = null,
		list(0, 10) = null,
		list(10, 0) = null,
		list(-10, 0) = null,
	)
	///all our current active hitsplats
	var/list/current_hitsplats = list()

/datum/component/hitsplat/Initialize(datum/callback/post_retaliate_callback)
	if(!ismob(parent))
		return ELEMENT_INCOMPATIBLE

/datum/component/hitsplat/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_attacked))
	RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(after_attackby))

/datum/component/hitsplat/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_ATOM_AFTER_ATTACKEDBY))

/datum/component/hitsplat/proc/after_attackby(atom/target, obj/item/weapon)
	SIGNAL_HANDLER
	if(weapon.force) //will be handled by on_attacked
		return NONE
	var/obj/effect/overlay/vis/hitsplat/new_hitsplat = new
	new_hitsplat.set_damage_amount(0)
	add_hitsplat(new_hitsplat)

/// Add an attacking atom to a blackboard list of things which attacked us
/datum/component/hitsplat/proc/on_attacked(mob/source, damage_amount, damagetype, def_zone, blocked)
	SIGNAL_HANDLER

	if(damagetype == STAMINA || damage_amount < 0)
		return NONE
	var/obj/effect/overlay/vis/hitsplat/new_hitsplat = new
	new_hitsplat.set_damage_amount(damage_amount, damagetype)
	add_hitsplat(new_hitsplat)

/datum/component/hitsplat/proc/add_hitsplat(obj/effect/new_hitsplat)

	RegisterSignal(new_hitsplat, COMSIG_QDELETING, PROC_REF(on_hitsplat_delete))
	var/mob/living_parent = parent
	living_parent.vis_contents += new_hitsplat

	for(var/list/hitsplat in hitsplat_positions)
		if(!isnull(hitsplat_positions[hitsplat]))
			continue
		hitsplat_positions[hitsplat] = new_hitsplat
		new_hitsplat.pixel_x = hitsplat[1]
		new_hitsplat.pixel_y = hitsplat[2]
		return

	var/list/first_hitsplat = hitsplat_positions[1]
	qdel(hitsplat_positions[first_hitsplat])
	hitsplat_positions[first_hitsplat] = new_hitsplat
	new_hitsplat.pixel_x = first_hitsplat[1]
	new_hitsplat.pixel_y = first_hitsplat[2]

/datum/component/hitsplat/proc/on_hitsplat_delete(datum/source)
	SIGNAL_HANDLER

	for(var/list/hitsplat in hitsplat_positions)
		if(hitsplat_positions[hitsplat] == source)
			hitsplat_positions[hitsplat] = null

/obj/effect/overlay/vis/hitsplat
	icon = 'icons/effects/hitsplats.dmi'
	icon_state = "hitsplat_default"
	base_icon_state = "hitsplat"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	///the damage amount we're displaying
	var/damage_amount = 0

/obj/effect/overlay/vis/hitsplat/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 2 SECONDS)

/obj/effect/overlay/vis/hitsplat/proc/set_damage_amount(damage_number, damage_type)
	damage_amount = damage_number

	if(damage_amount == 0)
		icon_state = "[base_icon_state]_blocked"
	else if(damage_type == TOX)
		icon_state = "[base_icon_state]_poison"

	update_appearance()

/obj/effect/overlay/vis/hitsplat/update_overlays()
	. = ..()
	var/image/hitsplat_text = image(loc = src, layer = layer + 0.1, pixel_y = 10, pixel_x = 1)
	hitsplat_text.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005'>[damage_amount]</span>")
	. += hitsplat_text
