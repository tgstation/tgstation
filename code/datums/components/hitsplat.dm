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
		list(10, 12) = null,
		list(-10, 12) = null,
		list(0, 22) = null,
	)
	///all our current active hitsplats
	var/list/current_hitsplats = list()

	/// If we are as faithful as possible to runescape or tweak some stuff for better feedback ingame
	var/lore_accurate = FALSE
	// Alot less spammy and more useable as a smite or ingame feature. Off for ALL the health adjustments
	var/only_attacks = FALSE

/datum/component/hitsplat/Initialize(lore_accurate, only_attacks)
	src.lore_accurate = lore_accurate
	src.only_attacks = only_attacks
	if(!ismob(parent))
		return ELEMENT_INCOMPATIBLE

/datum/component/hitsplat/RegisterWithParent()
	if(only_attacks)
		RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_attacked))
		RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(after_attackby))
	else
		RegisterSignals(parent, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_damage_adjusted))
		RegisterSignal(parent, COMSIG_CARBON_LIMB_DAMAGED, PROC_REF(on_limb_damage))

/datum/component/hitsplat/UnregisterFromParent()
	if(only_attacks)
		UnregisterSignal(parent, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_ATOM_AFTER_ATTACKEDBY))
	else
		UnregisterSignal(parent, list(COMSIG_CARBON_LIMB_DAMAGED) + COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)


/datum/component/hitsplat/proc/after_attackby(atom/target, obj/item/weapon)
	SIGNAL_HANDLER
	if(weapon.force) //will be handled by on_attacked
		return NONE
	spawn_hitsplat(0)

/datum/component/hitsplat/proc/on_attacked(mob/source, damage_amount, damagetype, def_zone, blocked)
	SIGNAL_HANDLER

	if(damagetype == STAMINA || damage_amount < 0)
		return NONE
	spawn_hitsplat(damage_amount, damagetype)

/datum/component/hitsplat/proc/on_damage_adjusted(mob/source, type, amount)
	SIGNAL_HANDLER

	if(type == STAMINA)
		return NONE
	spawn_hitsplat(amount, type)

/datum/component/hitsplat/proc/on_limb_damage(mob/living/our_mob, limb, brute, burn)
	SIGNAL_HANDLER

	if(brute)
		spawn_hitsplat(brute, BRUTE)
	if(burn)
		spawn_hitsplat(burn, BURN)

/datum/component/hitsplat/proc/spawn_hitsplat(amount, type)
	var/obj/effect/overlay/vis/hitsplat/new_hitsplat = new(null, lore_accurate)
	new_hitsplat.set_damage_amount(amount, type)
	add_hitsplat(new_hitsplat)

/datum/component/hitsplat/proc/add_hitsplat(obj/effect/new_hitsplat)

	RegisterSignal(new_hitsplat, COMSIG_QDELETING, PROC_REF(on_hitsplat_delete))
	var/mob/living_parent = parent
	living_parent.vis_contents += new_hitsplat

	for(var/list/hitsplat in hitsplat_positions)
		if(!isnull(hitsplat_positions[hitsplat]))
			continue
		hitsplat_positions[hitsplat] = new_hitsplat
		new_hitsplat.pixel_w = hitsplat[1]
		new_hitsplat.pixel_z = hitsplat[2]
		return

	var/list/first_hitsplat = hitsplat_positions[1]
	qdel(hitsplat_positions[first_hitsplat])
	hitsplat_positions[first_hitsplat] = new_hitsplat
	new_hitsplat.pixel_w = first_hitsplat[1]
	new_hitsplat.pixel_z = first_hitsplat[2]

/datum/component/hitsplat/proc/on_hitsplat_delete(datum/source)
	SIGNAL_HANDLER

	for(var/list/hitsplat in hitsplat_positions)
		if(hitsplat_positions[hitsplat] == source)
			hitsplat_positions[hitsplat] = null

/obj/effect/overlay/vis/hitsplat
	name = "hitsplat"
	icon = 'icons/effects/hitsplats.dmi'
	icon_state = "hitsplat_default"
	base_icon_state = "hitsplat"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	///the damage amount we're displaying
	var/damage_amount = 0
	/// If we are as faithful as possible to runescape or tweak some stuff for better feedback ingame
	var/lore_accurate = FALSE

/obj/effect/overlay/vis/hitsplat/Initialize(mapload, lore_accurate)
	. = ..()
	src.lore_accurate = lore_accurate
	if(!lore_accurate)
		alpha = 128
	QDEL_IN(src, 2 SECONDS)

/obj/effect/overlay/vis/hitsplat/proc/set_damage_amount(damage_number, damage_type)
	damage_amount = damage_number

	if(damage_amount < 0)
		icon_state = "[base_icon_state]_heal"
	else if(damage_amount == 0)
		icon_state = "[base_icon_state]_blocked"
	else if(damage_type == TOX)
		icon_state = "[base_icon_state]_poison"
	else if(damage_type == BURN)
		icon_state = "[base_icon_state]_burn"

	update_appearance()

/obj/effect/overlay/vis/hitsplat/update_overlays()
	. = ..()
	var/hitsplat_num = CEILING(abs(damage_amount), lore_accurate ? 1 : 0.1)
	var/image/hitsplat_text = image(loc = src, layer = layer + 0.1)
	hitsplat_text.pixel_w = 1
	hitsplat_text.pixel_z = 10
	hitsplat_text.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005'>[hitsplat_num]</span>")
	. += hitsplat_text
