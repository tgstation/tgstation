/datum/atom_skin/cap_sheath
	abstract_type = /datum/atom_skin/cap_sheath
	change_base_icon_state = TRUE
	new_icon = 'modular_bandastation/objects/icons/obj/clothing/belts.dmi'
	new_worn_icon = 'modular_bandastation/objects/icons/obj/clothing/belts/sheath.dmi'
	new_lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	new_righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'

/datum/atom_skin/cap_sheath/default
	preview_name = "Default"
	new_icon_state = "sheath_default"
	new_inhand_icon_state = "sheath_default"

/datum/atom_skin/cap_sheath/classic
	preview_name = "Classic"
	new_icon_state = "sheath_classic"
	new_inhand_icon_state = "sheath_classic"

/datum/atom_skin/cap_sheath/ceremonial
	preview_name = "Ceremonial"
	new_icon_state = "sheath_ceremonial"
	new_inhand_icon_state = "sheath_ceremonial"

/datum/atom_skin/cap_sheath/cossack
	preview_name = "Cossack"
	new_icon_state = "sheath_cossack"
	new_inhand_icon_state = "sheath_cossack"

/datum/atom_skin/cap_sheath/katana
	preview_name = "Katana"
	new_icon_state = "sheath_katana"
	new_inhand_icon_state = "sheath_katana"

/obj/item/storage/belt/sheath/sabre
	base_icon_state = "sheath"

/obj/item/storage/belt/sheath/sabre/setup_reskins()
	AddComponent(/datum/component/reskinable_item/sabre, /datum/atom_skin/cap_sheath)

/datum/component/reskinable_item/sabre/on_click_alt_reskin(obj/item/melee/sabre/source, mob/user)
	if(!source.contents.len)
		to_chat(user, span_warning("You need to have a sabre in the sheath to reskin it."))
		return NONE
	if(!istype(source.contents[1], /obj/item/melee/sabre))
		to_chat(user, span_warning("You need to have a sabre in the sheath to reskin it."))
		return NONE

	if(!user.can_perform_action(parent, NEED_DEXTERITY))
		return NONE
	else
		INVOKE_ASYNC(src, PROC_REF(reskin_obj), user)
		return CLICK_ACTION_SUCCESS

/datum/component/reskinable_item/sabre/reskin_obj(mob/user)
	var/obj/item/storage/belt/sheath/sabre/atom_parent = parent
	var/list/items = list()
	var/list/atom_skins = get_atom_skins()
	for(var/reskin_name, reskin_typepath in get_skins_by_name())
		var/datum/atom_skin/reskin = atom_skins[reskin_typepath]
		items[reskin_name] = image(icon = reskin.new_icon || atom_parent.icon, icon_state = reskin.new_icon_state || atom_parent.icon_state)

	sort_list(items)
	var/pick = show_radial_menu(user, parent, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick || !items[pick])
		return

	set_skin_by_name(pick, user)
	var/list/components = atom_parent.contents[1].GetComponents(/datum/component/reskinable_item)
	for(var/datum/component/reskinable_item/component in components)
		component.set_skin_by_name(pick, user)
		qdel(component)
	to_chat(user, span_info("[parent] is now skinned as '[pick].'"))

	if(!infinite_reskin)
		qdel(src)

/obj/item/storage/belt/sheath/sabre/update_icon_state()
	. = ..()
	icon_state = base_icon_state
	inhand_icon_state = base_icon_state
	worn_icon_state = base_icon_state
	if(contents.len)
		icon_state += "-full"
		inhand_icon_state += "-full"
		worn_icon_state += "-full"
	return
