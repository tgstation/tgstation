/obj/item/storage/hypospraykit
	name = "hypospray kit"
	desc = "A hypospray kit with foam insets for hypovials and a mounting point on the bottom."
	icon = 'modular_doppler/modular_items/hyposprays/icons/hypokits.dmi'
	icon_state = "firstaid-mini"
	worn_icon_state = "healthanalyzer" // Get a better sprite later
	inhand_icon_state = "medkit"
	greyscale_config = /datum/greyscale_config/hypokit
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	// Small hypokits can be pocketed, but don't have much storage.
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	storage_type = /datum/storage/hypospray_kit
	var/empty = FALSE
	var/current_case = "firstaid"
	var/static/list/case_designs
	var/static/list/case_designs_xl
	var/is_xl = FALSE

	/// Tracks if a hypospray is attached to the case or not.
	var/obj/item/hypospray/mkii/attached_hypo

//Code to give hypospray kits selectable paterns.
/obj/item/storage/hypospraykit/examine(mob/living/user)
	. = ..()
	. += span_notice("Ctrl-Shift-Click to reskin this")
	if(attached_hypo)
		. += span_notice("[attached_hypo] is mounted on the bottom. Alt-Right-Click to take it off.")
	else
		. += span_notice("Right-Click with a hypospray to mount it.")

/obj/item/storage/hypospraykit/Initialize(mapload)
	. = ..()
	if(!length(case_designs))
		populate_case_designs()
	update_icon_state()
	update_icon()


/obj/item/storage/hypospraykit/Destroy()
	// a large block to stop the CI Gods smiting us & taking extra steps to try and force the CMO hypo to drop smartly
	var/atom/drop_loc = drop_location(src)
	if(QDELETED(drop_loc))
		drop_loc = get_turf(src)
	if(QDELETED(drop_loc))
		QDEL_NULL(attached_hypo)
		return ..()
	// so long as it found a place to drop, run through and try to drop any indestructible items we contain
	for(var/obj/item in contents)
		if(item.resistance_flags & INDESTRUCTIBLE)
			atom_storage.remove_single(null, item, drop_loc, TRUE)
	// this also includes attached hypos - if indestructible, shunt it out, otherwise qdel it, and in all cases make sure we drop the ref & unregister the signal
	if(attached_hypo)
		if(attached_hypo.resistance_flags & INDESTRUCTIBLE)
			attached_hypo.forceMove(drop_loc)
		else
			QDEL_NULL(attached_hypo)
		attached_hypo = null
		UnregisterSignal(attached_hypo, COMSIG_QDELETING)
	return ..()


/obj/item/storage/hypospraykit/proc/populate_case_designs()
	case_designs = list(
		"firstaid" = image(icon = src.icon, icon_state = "firstaid-mini"),
		"brute" = image(icon = src.icon, icon_state = "brute-mini"),
		"burn" = image(icon = src.icon, icon_state = "burn-mini"),
		"toxin" = image(icon = src.icon, icon_state = "toxin-mini"),
		"oxy" = image(icon = src.icon, icon_state = "oxy-mini"),
		"advanced" = image(icon = src.icon, icon_state = "advanced-mini"),
		"buffs" = image(icon = src.icon, icon_state = "buffs-mini"),
		"custom" = image(icon = src.icon, icon_state = "standard-gags-mini"))
	case_designs_xl = list(
		"cmo" = image(icon = src.icon, icon_state = "cmo-mini"),
		"emt" = image(icon = src.icon, icon_state = "emt-mini"),
		"tactical" = image(icon = src.icon, icon_state = "tactical-mini"),
		"deluxe-custom" = image(icon = src.icon, icon_state = "deluxe-gags-normal-mini"),
		"tactical-custom" = image(icon = src.icon, icon_state = "deluxe-gags-tactical-mini"))

/obj/item/storage/hypospraykit/update_overlays()
	. = ..()
	if(attached_hypo)
		if(attached_hypo.greyscale_colors != null) //it's one of the GAGS variants
			var/mutable_appearance/hypo_overlay = mutable_appearance(initial(icon), attached_hypo.icon_state)
			. += hypo_overlay
			var/list/split_colors = splittext(attached_hypo.greyscale_colors, "#")
			var/mutable_appearance/hypo_overlay_acc1 = mutable_appearance(initial(icon), "hypo2_accent1")
			hypo_overlay_acc1.color = "#[split_colors[2]]"
			. += hypo_overlay_acc1
			var/mutable_appearance/hypo_overlay_acc2 = mutable_appearance(initial(icon), "hypo2_accent2")
			hypo_overlay_acc2.color = "#[split_colors[3]]"
			. += hypo_overlay_acc2
		else
			var/mutable_appearance/hypo_overlay = mutable_appearance(initial(icon), attached_hypo.icon_state)
			. += hypo_overlay

/obj/item/storage/hypospraykit/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/hypospray/mkii) || !LAZYACCESS(modifiers, RIGHT_CLICK))
		return ..()
	if(!isnull(attached_hypo))
		balloon_alert(user, "Mount point full!  Remove [attached_hypo] first!")
		return ITEM_INTERACT_BLOCKING
	tool.moveToNullspace()
	attached_hypo = tool
	RegisterSignal(tool, COMSIG_QDELETING, PROC_REF(on_attached_hypo_qdel))
	balloon_alert(user, "Attached [attached_hypo].")
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/hypospraykit/click_alt_secondary(mob/user)
	if(attached_hypo != null)
		if(user.put_in_hands(attached_hypo))
			balloon_alert(user, "Removed [attached_hypo].")
			UnregisterSignal(attached_hypo, COMSIG_QDELETING)
			attached_hypo = null
			update_appearance()
			// Ditto here.
		else
			balloon_alert(user, "Couldn't pull the hypo!")

/obj/item/storage/hypospraykit/proc/on_attached_hypo_qdel()
	if(attached_hypo)
		attached_hypo = null
		update_appearance()

/obj/item/storage/hypospraykit/update_icon_state()
	. = ..()
	icon_state = "[current_case]-mini"

/obj/item/storage/hypospraykit/proc/case_menu(mob/user)
	if(.)
		return
	var/list/designs = case_designs
	if(is_xl)
		designs = case_designs_xl
	var/choice = show_radial_menu(user, src, designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 42, require_near = TRUE)
	if(!choice)
		return FALSE
	current_case = choice
	update_icon()
	if(findtext(current_case, "custom"))
		var/atom/fake_atom = src
		var/list/allowed_configs = list()
		var/config = initial(fake_atom.greyscale_config)
		allowed_configs += "[config]"
		if(greyscale_colors == null)
			greyscale_colors = "#00AAFF"

		var/datum/greyscale_modify_menu/menu = new(src, usr, allowed_configs)
		menu.ui_interact(usr)
	else //restore normal icon
		icon = initial(icon)
		greyscale_colors = null

/obj/item/storage/hypospraykit/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.is_holding(src))
		return FALSE
	return TRUE


/obj/item/storage/hypospraykit/click_ctrl_shift(mob/user)
	case_menu(user)

//END OF HYPOSPRAY CASE MENU CODE

/obj/item/storage/hypospraykit/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii(src)

/obj/item/storage/hypospraykit/empty
	empty = TRUE

/// Deluxe hypokit: more storage, but you can't pocket it.
/obj/item/storage/hypospraykit/cmo
	name = "deluxe hypospray kit"
	desc = "An extended hypospray kit with foam insets for hypovials & a mounting point on the bottom."
	icon_state = "cmo-mini"
	current_case = "cmo"
	is_xl = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/hypospray_kit/cmo

/obj/item/storage/hypospraykit/cmo/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/deluxe/cmo(src)

/obj/item/storage/hypospraykit/cmo/empty
	desc = "An extended hypospray kit with foam insets for hypovials & a mounting point on the bottom."
	icon_state = "emt-mini"
	current_case = "emt"
	empty = TRUE

/// Preloaded version: this is what goes in the locker.
/obj/item/storage/hypospraykit/cmo/preloaded
	name = "CMO's deluxe hypospray kit"
	desc = "The CMO's precious extended hypospray kit, preloaded with a deluxe hypospray & a handful of vials.  Retains the usual insets and mounting point of smaller hypokits."

/obj/item/storage/hypospraykit/cmo/preloaded/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/deluxe/cmo(src)
	new /obj/item/reagent_containers/cup/hypovial/large/deluxe(src)
	new /obj/item/reagent_containers/cup/hypovial/large/multiver(src)
	new /obj/item/reagent_containers/cup/hypovial/large/salglu(src)
	new /obj/item/reagent_containers/cup/hypovial/large/synthflesh(src)

/obj/structure/closet/secure_closet/chief_medical/populate_contents_immediate()
	. = ..()

	new /obj/item/storage/hypospraykit/cmo/preloaded(src)

/// Combat hypokit
/obj/item/storage/hypospraykit/cmo/combat
	name = "combat hypospray kit"
	desc = "A larger tactical hypospray kit containing a combat-focused deluxe hypospray and vials."
	icon_state = "tactical-mini"
	current_case = "tactical"

/obj/item/storage/hypospraykit/cmo/combat/PopulateContents()
	if(empty)
		return
	new /obj/item/hypospray/mkii/deluxe/cmo/combat(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advbrute(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advburn(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advtox(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advoxy(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advcrit(src)
	new /obj/item/reagent_containers/cup/hypovial/large/advomni(src)
	new /obj/item/reagent_containers/cup/hypovial/large/numbing(src)

/// Boxes of empty hypovials, coming in every style.
/obj/item/storage/box/vials
	name = "box of hypovials"

/obj/item/storage/box/vials/PopulateContents()
	for(var/vialpath in subtypesof(/obj/item/reagent_containers/cup/hypovial/small/style))
		new vialpath(src)

// Ditto, just large vials.
/obj/item/storage/box/vials/deluxe
	name = "box of deluxe hypovials"

/obj/item/storage/box/vials/deluxe/PopulateContents()
	for(var/vialpath in subtypesof(/obj/item/reagent_containers/cup/hypovial/large/style))
		new vialpath(src)

// A box of small hypospray kits, pre-skinned to each variant to remind people what styles are available.
/obj/item/storage/box/hypospray
	name = "box of hypospray kits"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	..()
	new /obj/item/storage/box/hypospray(src)

/obj/item/storage/box/hypospray/PopulateContents()
	var/list/case_designs = list("firstaid", "brute", "burn", "toxin", "oxy", "advanced", "buffs")
	for(var/label in case_designs)
		var/obj/item/storage/hypospraykit/newkit = new /obj/item/storage/hypospraykit(src)
		newkit.current_case = label
		newkit.update_icon_state()

/datum/storage/hypospray_kit
	max_slots = 7

/datum/storage/hypospray_kit/cmo
	max_slots = 21
	max_total_storage = 28 //keeps a wiggle room of 7 just in case size weirdness happens

/datum/storage/hypospray_kit/New(
	atom/parent,
	max_slots = src.max_slots,
	max_specific_storage = src.max_specific_storage,
	max_total_storage = src.max_total_storage,
)
	. = ..()
	var/static/list/hypokit_holdable = typecacheof(list(
		/obj/item/hypospray/mkii,
		/obj/item/reagent_containers/cup/hypovial
	))
	can_hold = hypokit_holdable
