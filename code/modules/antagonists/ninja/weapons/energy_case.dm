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

/obj/item/energy_case/attack_self(mob/user, modifiers)
	. = ..()
	var/list/weapons = list(
		"Energy Katana(Easy)" = image(icon = 'icons/obj/weapons/sword.dmi', icon_state = "energy_katana"),
		"Energy Glaive(Normal)" = image(icon = 'icons/obj/weapons/sword.dmi', icon_state = "glaive"),
		"Energy Kusarigama(Hard)" = image(icon = 'icons/obj/weapons/thrown.dmi', icon_state = "energy_kama")
		)
	var/choice_weapon = show_radial_menu(user, src, weapons, tooltips = TRUE)
	var/obj/item/linked_weapon
	if(isnull(choice_weapon))
		return
	switch(choice_weapon)
		if("Energy Katana")
			linked_weapon = new /obj/item/energy_katana(get_turf(user))
		if("Energy Glaive")
			linked_weapon = new /obj/item/energy_glaive(get_turf(user))
		if("Energy Kusarigama")
			linked_weapon = new /obj/item/energy_kusarigama_kama(get_turf(user))
	if(!linked_weapon)
		return
	qdel(src)
	user.put_in_active_hand(linked_weapon)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/case_man = user
	var/obj/item/mod/control/mod = case_man.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/weapon_recall/recall = locate(/obj/item/mod/module/weapon_recall) in mod.modules
	if(!is_type_in_list(linked_weapon, recall.accepted_types))
		return
	recall.set_weapon(linked_weapon)
