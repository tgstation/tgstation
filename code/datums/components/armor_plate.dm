/datum/component/armor_plate
	/// Current amount of upgrades
	var/amount = 0
	/// Maximum amount of upgrades
	var/max_amount = 3
	/// Item we use to upgrade the armor
	var/obj/item/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	/// Armor modification we apply
	var/datum/armor/armor_mod = /datum/armor/armor_plate

/datum/armor/armor_plate
	melee = 10

/datum/component/armor_plate/Initialize(max_amount = 3, obj/item/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide, datum/armor/added_armor = /datum/armor/armor_plate)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.max_amount = max_amount
	src.upgrade_item = upgrade_item
	src.armor_mod = added_armor

/datum/component/armor_plate/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_atom_destruction))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	if(istype(parent, /obj/vehicle/sealed/mecha/ripley))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_ripley_overlays))

/datum/component/armor_plate/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_DESTRUCTION)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	if(istype(parent, /obj/vehicle/sealed/mecha/ripley))
		UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)

/datum/component/armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/upgrade_name = initial(upgrade_item.name)
	if(ismecha(parent))
		if(amount)
			if(amount < max_amount)
				examine_list += span_notice("[parent.p_their(TRUE)] armor is enhanced with [amount] [upgrade_name].")
			else
				examine_list += span_notice("[parent.p_theyre(TRUE)] wearing a fearsome carapace entirely composed of [upgrade_name] - [parent.p_their(TRUE)] pilot must be an experienced monster hunter.")
		else
			examine_list += span_notice("[parent.p_they(TRUE)] [parent.p_have()] attachment points for strapping [upgrade_name] on for added protection.")
	else
		if(amount)
			examine_list += span_notice("[parent.p_they(TRUE)] [parent.p_have()] been strengthened with [amount]/[max_amount] [upgrade_name].")
		else
			examine_list += span_notice("[parent.p_they(TRUE)] can be strengthened with up to [max_amount] [upgrade_name].")

/datum/component/armor_plate/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(attacking_item, upgrade_item))
		return

	if(amount >= max_amount)
		to_chat(user, span_warning("You can't improve [parent] any further!"))
		return

	if(isstack(attacking_item))
		var/obj/item/stack/stack_item = attacking_item
		stack_item.use(1)
	else
		qdel(attacking_item)

	amount++
	var/atom/atom_parent = parent
	atom_parent.set_armor(atom_parent.get_armor().add_other_armor(armor_mod))
	var/datum/armor/armor_datum = get_armor_by_type(armor_mod)
	//how did this happen?
	if(!armor_datum)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	var/list/improvements = list()
	for(var/rating in armor_datum.get_rating_list())
		improvements += lowertext(rating)
	var/improvements_text = english_list(improvements)
	to_chat(user, span_info("You strengthen [atom_parent], improving [atom_parent.p_their()] resistance against [improvements_text]."))
	if(istype(atom_parent, /obj/vehicle/sealed/mecha/ripley))
		atom_parent.update_appearance()
	SEND_SIGNAL(atom_parent, COMSIG_ARMOR_PLATED, amount, max_amount)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/armor_plate/proc/on_atom_destruction(atom/source, damage_flag)
	SIGNAL_HANDLER

	//items didn't drop the plates before and it causes erroneous behavior with collapsible helmets
	if(!ismecha(parent))
		return

	for(var/i in 1 to amount)
		new upgrade_item(get_turf(parent))

/datum/component/armor_plate/proc/apply_ripley_overlays(obj/vehicle/sealed/mecha/ripley/ripley, list/overlays)
	SIGNAL_HANDLER

	if(!amount)
		return
	var/overlay_string = "ripley-g"
	if(amount >= 3)
		overlay_string += "-full"
	if(!LAZYLEN(mech.occupants))
		overlay_string += "-open"
	overlays += overlay_string
