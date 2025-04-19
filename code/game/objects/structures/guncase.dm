//GUNCASES//
/obj/structure/guncase
	name = "gun locker"
	desc = "A locker that holds guns."
	icon = 'icons/obj/storage/closet.dmi'
	icon_state = "shotguncase"
	anchored = FALSE
	density = TRUE
	opacity = FALSE
	var/case_type = ""
	var/gun_category = /obj/item/gun
	var/open = TRUE
	var/capacity = 4

/obj/structure/guncase/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc.contents)
			if(istype(I, gun_category))
				I.forceMove(src)
			if(contents.len >= capacity)
				break
	update_appearance()

/obj/structure/guncase/update_overlays()
	. = ..()
	if(case_type && LAZYLEN(contents))
		var/mutable_appearance/gun_overlay = mutable_appearance(icon, case_type)
		for(var/i in 1 to contents.len)
			gun_overlay.pixel_w = 3 * (i - 1)
			. += new /mutable_appearance(gun_overlay)
	. += "[icon_state]_[open ? "open" : "door"]"

/obj/structure/guncase/attackby(obj/item/I, mob/living/user, params)
	if(iscyborg(user) || isalien(user))
		return
	if(istype(I, gun_category) && open)
		if(LAZYLEN(contents) < capacity)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, span_notice("You place [I] in [src]."))
			update_appearance()
		else
			to_chat(user, span_warning("[src] is full."))
		return

	else if(!user.combat_mode)
		open = !open
		update_appearance()
	else
		return ..()

/obj/structure/guncase/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(contents.len && open)
		show_menu(user)
	else
		open = !open
		update_appearance()

/**
 * show_menu: Shows a radial menu to a user consisting of an available weaponry for taking
 *
 * Arguments:
 * * user The mob to which we are showing the radial menu
 */
/obj/structure/guncase/proc/show_menu(mob/user)
	if(!LAZYLEN(contents))
		return

	var/list/display_names = list()
	var/list/items = list()
	for(var/i in 1 to length(contents))
		var/obj/item/thing = contents[i]
		display_names["[thing.name] ([i])"] = REF(thing)
		var/image/item_image = image(icon = thing.icon, icon_state = thing.icon_state)
		if(length(thing.overlays))
			item_image.copy_overlays(thing)
		items += list("[thing.name] ([i])" = item_image)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!pick)
		return

	var/weapon_reference = display_names[pick]
	var/obj/item/weapon = locate(weapon_reference) in contents
	if(!istype(weapon))
		return
	if(!user.put_in_hands(weapon))
		weapon.forceMove(get_turf(src))

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/structure/guncase/proc/check_menu(mob/living/carbon/human/user)
	if(!open)
		return FALSE
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/obj/structure/guncase/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()

/obj/structure/guncase/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/structure/guncase/shotgun
	name = "shotgun locker"
	desc = "A locker that holds shotguns."
	case_type = "shotgun"
	gun_category = /obj/item/gun/ballistic/shotgun

/obj/structure/guncase/ecase
	name = "energy gun locker"
	desc = "A locker that holds energy guns."
	case_type = "egun"
	gun_category = /obj/item/gun/energy/e_gun

/obj/structure/guncase/wt550
	name = "WT-550 gun locker"
	desc = "A locker that holds WT-550 rifles."
	case_type = "wt550"
