/*!
 * Contains crusher trophies that are not obtained from fauna
 */
/// Cosmetic items for changing the crusher's look
/obj/item/crusher_trophy/retool_kit
	name = "crusher retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit

	/// Currently picked crusher reskin
	var/datum/crusher_skin/active_skin = /datum/crusher_skin/sword
	/// If this kit forces some specific skin, or can pick between subtypes
	var/forced_skin

/obj/item/crusher_trophy/retool_kit/Destroy(force)
	if (istype(active_skin))
		QDEL_NULL(active_skin)
	return ..()

/obj/item/crusher_trophy/retool_kit/effect_desc()
	return "the crusher to have the appearance of \a [active_skin::name]"

/obj/item/crusher_trophy/retool_kit/add_to(obj/item/kinetic_crusher/pkc, mob/user)
	if (!forced_skin)
		var/list/choices = list()
		for (var/datum/crusher_skin/skin as anything in subtypesof(/datum/crusher_skin))
			if (skin::normal_skin)
				choices[skin] = icon(skin::retool_icon || 'icons/obj/mining.dmi', skin::retool_icon_state)
		var/datum/crusher_skin/chosen_skin = show_radial_menu(user, src, choices, tooltips = TRUE, require_near = TRUE)
		if (!chosen_skin)
			return
		active_skin = chosen_skin
	else
		active_skin = forced_skin
	. = ..()
	if(!.)
		return
	active_skin = new active_skin(pkc)
	if (active_skin.retool_icon)
		pkc.icon = active_skin.retool_icon
	pkc.icon_state = active_skin.retool_icon_state
	pkc.current_inhand_icon_state = active_skin.retool_inhand_icon
	if (active_skin.retool_projectile_icon)
		pkc.projectile_icon = active_skin.retool_projectile_icon
	// Should either have both, or neither
	if (active_skin.retool_lefthand_file)
		pkc.lefthand_file = active_skin.retool_lefthand_file
		pkc.righthand_file = active_skin.retool_righthand_file
	if (active_skin.retool_inhand_x)
		pkc.inhand_x_dimension = active_skin.retool_inhand_x
	if (active_skin.retool_inhand_y)
		pkc.inhand_y_dimension = active_skin.retool_inhand_y
	pkc.update_appearance()
	pkc.update_slot_icon()

/obj/item/crusher_trophy/retool_kit/remove_from(obj/item/kinetic_crusher/pkc)
	var/skin_type = active_skin.type
	qdel(active_skin)
	active_skin = skin_type
	pkc.icon = initial(pkc.icon)
	pkc.icon_state = initial(pkc.icon_state)
	pkc.current_inhand_icon_state = initial(pkc.current_inhand_icon_state)
	pkc.projectile_icon = initial(pkc.projectile_icon)
	pkc.lefthand_file = initial(pkc.lefthand_file)
	pkc.righthand_file = initial(pkc.righthand_file)
	pkc.inhand_x_dimension = initial(pkc.inhand_x_dimension)
	pkc.inhand_y_dimension = initial(pkc.inhand_y_dimension)
	pkc.update_appearance()
	pkc.update_slot_icon()
	return ..()

/// Alternate PKC skins
/datum/crusher_skin
	/// Name of the modification
	var/name = "error that should be reported to coders"
	/// Specifies the icon file in which the crusher's new state is stored.
	var/retool_icon = null
	///Specifies the sprite/icon state which the crusher is changed to as an item. Should appear in the icons/obj/mining.dmi file with accompanying "lit" and "recharging" sprites
	var/retool_icon_state = "ipickaxe"
	///Specifies the icon state for the crusher's appearance in hand. Should appear in both retool_lefthand_file and retool_righthand_file.
	var/retool_inhand_icon = "ipickaxe"
	///For if the retool kit changes the projectile's appearance. The sprite should be in icons/obj/weapons/guns/projectiles.dmi.
	var/retool_projectile_icon = null
	/// Specifies the left hand inhand icon file. Don't forget to set the right hand file as well.
	var/retool_lefthand_file = null
	/// Specifies the right hand inhand icon file. Don't forget to set the left hand file as well.
	var/retool_righthand_file = null
	/// Specifies the X dimensions of the new inhand, only relevant with different inhand files.
	var/retool_inhand_x = null
	/// Specifies the Y dimensions of the new inhand, only relevant with different inhand files.
	var/retool_inhand_y = null
	/// Can this skin be normally selected by a generic retool kit?
	var/normal_skin = TRUE
	/// Crusher this skin is attached to
	var/obj/item/kinetic_crusher/crusher

/datum/crusher_skin/New(obj/item/kinetic_crusher/new_crusher)
	. = ..()
	crusher = new_crusher

/datum/crusher_skin/Destroy(force)
	crusher = null
	return ..()

/datum/crusher_skin/sword
	name = "sword"
	retool_icon_state = "crusher_sword"
	retool_inhand_icon = "crusher_sword"

/datum/crusher_skin/harpoon
	name = "harpoon"
	retool_icon_state = "crusher_harpoon"
	retool_inhand_icon = "crusher_harpoon"
	retool_projectile_icon = "pulse_harpoon"

/datum/crusher_skin/harpoon/New(obj/item/kinetic_crusher/new_crusher)
	. = ..()
	RegisterSignal(crusher, COMSIG_ITEM_ATTACK_ANIMATION, PROC_REF(on_attack_animation))

/datum/crusher_skin/harpoon/Destroy(force)
	UnregisterSignal(crusher, COMSIG_ITEM_ATTACK_ANIMATION)
	return ..()

/datum/crusher_skin/harpoon/proc/on_attack_animation(obj/item/source, atom/movable/attacker, atom/attacked_atom, animation_type, list/image_override, list/animation_override)
	SIGNAL_HANDLER

	// If nothing is forcing an animation type, attack with a piercing animation because we're a harpoon
	if (!animation_type)
		animation_override += ATTACK_ANIMATION_PIERCE

/datum/crusher_skin/dagger
	name = "dual dagger and blaster"
	retool_icon_state = "crusher_dagger"
	retool_inhand_icon = "crusher_dagger"
	/// Are we doing a blaster animation right now?
	var/blaster_strike = FALSE

/datum/crusher_skin/dagger/New(obj/item/kinetic_crusher/new_crusher)
	. = ..()
	RegisterSignal(crusher, COMSIG_ITEM_ATTACK_ANIMATION, PROC_REF(on_attack_animation))
	RegisterSignal(crusher, COMSIG_CRUSHER_FIRED_BLAST, PROC_REF(on_fired_blast))

/datum/crusher_skin/dagger/Destroy(force)
	UnregisterSignal(crusher, list(COMSIG_ITEM_ATTACK_ANIMATION, COMSIG_CRUSHER_FIRED_BLAST))
	return ..()

/datum/crusher_skin/dagger/proc/on_attack_animation(obj/item/kinetic_crusher/source, atom/movable/attacker, atom/attacked_atom, animation_type, list/image_override, list/animation_override, list/angle_override)
	SIGNAL_HANDLER

	// If we've been forcefully assigned an animation type already, we shouldn't do the custom attack animation logic
	if (animation_type)
		return

	if (isliving(attacked_atom))
		var/mob/living/target = attacked_atom
		if (blaster_strike)
			image_override += image(icon = 'icons/obj/mining.dmi', icon_state = "crusher_dagger_blaster")
			angle_override += 0
			animation_override += ATTACK_ANIMATION_PIERCE
			blaster_strike = FALSE
			return

		if (target.has_status_effect(/datum/status_effect/crusher_mark))
			animation_override += ATTACK_ANIMATION_PIERCE

	image_override += image(icon = 'icons/obj/mining.dmi', icon_state = "crusher_dagger_melee")

/datum/crusher_skin/dagger/proc/on_fired_blast(obj/item/kinetic_crusher/source, atom/target, mob/living/user, obj/projectile/destabilizer/destabilizer)
	SIGNAL_HANDLER

	if (isliving(target) && get_dist(target, user) <= 1)
		blaster_strike = TRUE
		user.do_item_attack_animation(target, used_item = source)

/datum/crusher_skin/glaive
	name = "glaive"
	retool_icon_state = "crusher_glaive"
	retool_inhand_icon = "crusher_glaive"
	retool_lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	retool_righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	retool_inhand_x = 64
	retool_inhand_y = 64

/obj/item/crusher_trophy/retool_kit/ashenskull
	name = "ashen skull"
	desc = "It burns with the flame of the necropolis, whispering in your ear. It demands to be bound to a suitable weapon."
	icon_state = "retool_kit_skull"
	forced_skin = /datum/crusher_skin/ashen_skull

/obj/item/crusher_trophy/retool_kit/ashenskull/effect_desc()
	return "the crusher to appear corrupted by infernal powers"

/datum/crusher_skin/ashen_skull
	retool_icon_state = "crusher_skull"
	retool_inhand_icon = "crusher_skull"
	retool_projectile_icon = "pulse_skull"
	normal_skin = FALSE
