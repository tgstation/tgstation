/datum/component/armor_plate
	var/amount = 0
	var/maxamount = 3
	///What item is currently applied for upgrades
	var/atom/current_upgrade_item
	///What items can be used for upgrading
	var/list/atom/possible_upgrade_items
	var/datum/armor/armor_mod = /datum/armor/armor_plate

/datum/armor/armor_plate
	melee = 10

/datum/component/armor_plate/Initialize(_maxamount, list/atom/upgrades, datum/armor/_added_armor)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(applyplate))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(dropplates))
	if(istype(parent, /obj/vehicle/sealed/mecha/ripley))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_mech_overlays))

	if(_maxamount)
		maxamount = _maxamount
	if(upgrades)
		if(upgrades.len == 1)	//May as well assign it if there is only one possible upgrade
			current_upgrade_item = upgrades[1]
		possible_upgrade_items = upgrades
	else
		current_upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide	//Default upgrade item
	if(_added_armor)
		armor_mod = _added_armor

/datum/component/armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(ismecha(parent))
		if(amount)
			if(amount < maxamount)
				examine_list += span_notice("Its armor is enhanced with [amount] [current_upgrade_item::name].")
			else
				examine_list += span_notice("It's wearing a fearsome carapace entirely composed of [current_upgrade_item::name] - its pilot must be an experienced monster hunter.")
		else
			//Flavor text is pretty nice so not changing it like the one for non-mechs; should be changed if mechs ever get more upgrade items
			examine_list += span_notice("It has attachment points for strapping monster hide on for added protection.")
	else
		if(current_upgrade_item)
			if(amount)
				examine_list += span_notice("It has been strengthened with [amount]/[maxamount] [current_upgrade_item::name].")
			else
				examine_list += span_notice("It can be strengthened with up to [maxamount] [current_upgrade_item::name].")
		else
			examine_list += span_notice("It can be strengthened with the following: [english_list(possible_upgrade_items, final_comma_text = ",")]")

/datum/component/armor_plate/proc/applyplate(datum/source, obj/item/I, mob/user, params)
	SIGNAL_HANDLER

	//If an item has already been applied to upgrade the armor, check the type for a match; otherwise check if the item is in the list of possible upgrades
	if(current_upgrade_item)
		if(!istype(I, current_upgrade_item))
			return
	else
		if(!(I.type in possible_upgrade_items))
			return
		current_upgrade_item = I.type

	if(amount >= maxamount)
		to_chat(user, span_warning("You can't improve [parent] any further!"))
		return

	if(istype(I,/obj/item/stack))
		I.use(1)
	else
		if(length(I.contents))
			to_chat(user, span_warning("[I] cannot be used for armoring while there's something inside!"))
			return
		qdel(I)

	var/obj/O = parent
	amount++
	O.set_armor(O.get_armor().add_other_armor(armor_mod))

	if(ismecha(O))
		var/obj/vehicle/sealed/mecha/R = O
		R.update_appearance()
		to_chat(user, span_info("You strengthen [R], improving its resistance against melee, bullet and laser damage."))
	else
		SEND_SIGNAL(O, COMSIG_ARMOR_PLATED, amount, maxamount)
		to_chat(user, span_info("You strengthen [O], improving its resistance against melee attacks."))


/datum/component/armor_plate/proc/dropplates(datum/source, force)
	SIGNAL_HANDLER

	if(ismecha(parent)) //items didn't drop the plates before and it causes erroneous behavior for the time being with collapsible helmets
		for(var/i in 1 to amount)
			new current_upgrade_item(get_turf(parent))

/datum/component/armor_plate/proc/apply_mech_overlays(obj/vehicle/sealed/mecha/mech, list/overlays)
	SIGNAL_HANDLER

	if(!current_upgrade_item)
		return

	if(!amount)
		return

	var/overlay_name
	switch(current_upgrade_item)
		if(/obj/item/stack/sheet/animalhide/goliath_hide)
			overlay_name = "ripley-g"
		if(/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide)
			overlay_name = "ripley-p"
		else
			return

	if(amount >= 3)
		overlay_name += "-full"
	if(!LAZYLEN(mech.occupants))
		overlay_name += "-open"
	overlays += overlay_name
