/**
 * # Energy case
 *
 * The space ninja's energy case.
 *
 * The energy case that only space ninja spawns with. on attack self give show weapon menu where you can pick one of 4 weapons.
 *
 */
/obj/item/energy_case
	name = "energy case"
	desc = "Black case contains energy weapon"
	icon = 'icons/obj/storage/case.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	icon_state = "energy_case"
	base_icon_state = "energy_case"
	inhand_icon_state = "energy_case"
	worn_icon_state = "energy_case"
	w_class = WEIGHT_CLASS_BULKY
	/// When we choise weapon we auto try to link it with mod weapon recall
	var/obj/item/link_weapon

/obj/item/energy_case/attack_self(mob/user, modifiers)
	. = ..()
	var/list/weapons = list(
		"Energy Katana" = image(icon = 'icons/obj/weapons/sword.dmi', icon_state = "energy_katana"),
		"Energy Glaive" = image(icon = 'icons/obj/weapons/sword.dmi', icon_state = "glaive"),
		"Energy Kusarigama" = image(icon = 'icons/obj/weapons/thrown.dmi', icon_state = "energy_kama"),
		"Energy Hankyu" = image(icon = 'icons/obj/weapons/bows/bows.dmi', icon_state = "hankyu")
		)
	var/choise_weapon = show_radial_menu(user, src, weapons, tooltips = TRUE)
	if(isnull(choise_weapon))
		return
	switch(choise_weapon)
		if("Energy Katana")
			link_weapon = new /obj/item/energy_katana(get_turf(user))
		if("Energy Glaive")
			link_weapon = new /obj/item/energy_glaive(get_turf(user))
		if("Energy Kusarigama")
			link_weapon = new /obj/item/energy_kusarigama_kama(get_turf(user))
		if("Energy Hankyu")
			link_weapon = new /obj/item/gun/ballistic/bow/energy_hankyu(get_turf(user))
	if(!link_weapon)
		return
	qdel(src)
	user.put_in_active_hand(link_weapon)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/case_man = user
	var/obj/item/mod/control/mod = case_man.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/weapon_recall/recall = locate(/obj/item/mod/module/weapon_recall) in mod.modules
	if(!is_type_in_list(link_weapon, recall.accepted_types))
		return
	recall.set_weapon(link_weapon)
