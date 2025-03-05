// Old arm computer for mobile surgical operation

/obj/item/surgical_processor/doppler_implant
	name = "wrist surgical processor"
	desc = "A complex wrist computer that allows you to process advanced surgeries without assistance of a bulkier computer."
	loaded_surgeries = list(
		/datum/surgery/healing/brute/upgraded/femto,
		/datum/surgery/healing/burn/upgraded/femto,
		/datum/surgery/healing/combo/upgraded/femto,
		/datum/surgery/advanced/wing_reconstruction,
		/datum/surgery/advanced/experimental_dissection,
		/datum/surgery/advanced/lobotomy,
		/datum/surgery/advanced/lobotomy/mechanic,
	)

/obj/item/organ/cyberimp/arm/arm_surgery_computer
	name = "implanted wrist surgical processor"
	desc = "An integrated surgical processor implanted within the user's wrist. \
		Allows mobile operation of more advanced medical surgery."
	items_to_create = list(/obj/item/surgical_processor/doppler_implant)
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "hackerman"

/obj/item/organ/cyberimp/arm/arm_surgery_computer/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	ADD_TRAIT(owner, TRAIT_FASTMED, IMPLANT_TRAIT)
	return ..()

/obj/item/organ/cyberimp/arm/arm_surgery_computer/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	if(arm_owner)
		REMOVE_TRAIT(arm_owner, TRAIT_FASTMED, IMPLANT_TRAIT)

/obj/item/autosurgeon/syndicate/arm_surgery_computer
	name = "surgical processor autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/arm/arm_surgery_computer

// Razorwire implant, long reach whip made of extremely thin wire, ouch!

/obj/item/melee/razorwire
	name = "implanted razorwire"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble. \
		Results against anything more durable will heavily vary, however."
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "razorwire_weapon"
	righthand_file = 'modular_doppler/cool_implants/icons/inhands/lefthand.dmi'
	lefthand_file = 'modular_doppler/cool_implants/icons/inhands/righthand.dmi'
	inhand_icon_state = "razorwire"
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	force = 20
	demolition_mod = 0.25 // This thing sucks at destroying stuff
	wound_bonus = 10
	bare_wound_bonus = 20
	weak_against_armour = TRUE
	hitsound = 'sound/items/weapons/whip.ogg'
	attack_verb_continuous = list("slashes", "whips", "lashes", "lacerates")
	attack_verb_simple = list("slash", "whip", "lash", "lacerate")
	obj_flags = UNIQUE_RENAME | INFINITE_RESKIN
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Evil Red" = list(
			RESKIN_ICON_STATE = "razorwire_weapon",
			RESKIN_INHAND_STATE = "razorwire"
		),
		"Teal I Think?" = list(
			RESKIN_ICON_STATE = "razorwire_weapon_teal",
			RESKIN_INHAND_STATE = "razorwire_teal"
		),
		"Yellow" = list(
			RESKIN_ICON_STATE = "razorwire_weapon_yellow",
			RESKIN_INHAND_STATE = "razorwire_yellow"
		),
		"Ourple" = list(
			RESKIN_ICON_STATE = "razorwire_weapon_ourple",
			RESKIN_INHAND_STATE = "razorwire_ourple"
		),
		"Green" = list(
			RESKIN_ICON_STATE = "razorwire_weapon_green",
			RESKIN_INHAND_STATE = "razorwire_green"
		),
	)

/obj/item/organ/cyberimp/arm/razorwire
	name = "razorwire spool implant"
	desc = "An integrated spool of razorwire, capable of being used as a weapon when whipped at your foes. \
		Built into the back of your hand, try your best to not get it tangled."
	items_to_create = list(/obj/item/melee/razorwire)
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "razorwire"

/obj/item/autosurgeon/syndicate/razorwire
	name = "razorwire autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/arm/razorwire

// Shell launch system, an arm mounted single-shot shotgun/.980 grenade launcher that comes out of your arm

/obj/item/gun/ballistic/shotgun/shell_launcher
	name = "shell launch system"
	desc = "A mounted cannon seated comfortably in a forearm compartment. Comes with a seemingly endless stock of \
		proprietary shells within that the user can switch between with some concentration."
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "shell_cannon_weapon"
	righthand_file = 'modular_doppler/cool_implants/icons/inhands/lefthand.dmi'
	lefthand_file = 'modular_doppler/cool_implants/icons/inhands/righthand.dmi'
	inhand_icon_state = "shell_cannon"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_LIGHT
	force = 10
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/shell_cannon
	obj_flags = UNIQUE_RENAME
	rack_sound = 'sound/items/weapons/gun/general/chunkyrack.ogg'
	semi_auto = TRUE
	can_be_sawn_off = FALSE
	pb_knockback = 2
	recoil = 4
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	fire_delay = 5 SECONDS
	casing_ejector = TRUE
	/// What type of shells can you select to be made and shot by this thing
	var/list/selectable_shells = list(
		"Flechette" = /obj/item/ammo_casing/c980grenade/flechette,
		"Sabot" = /obj/item/ammo_casing/c980grenade/sabot,
		"Smoke" = /obj/item/ammo_casing/c980grenade/smoke,
		"ECM Chaff" = /obj/item/ammo_casing/c980grenade/ecm,
		"Shrapnel" = /obj/item/ammo_casing/c980grenade/shrapnel,
	)
	/// What shell is currently selected
	var/obj/item/ammo_casing/current_selected_shell = /obj/item/ammo_casing/c980grenade/ecm
	/// The currently stored range to detonate shells at
	var/target_range = 14
	/// The maximum range we can set grenades to detonate at, just to be safe
	var/maximum_target_range = 14

/obj/item/gun/ballistic/shotgun/shell_launcher/examine(mob/user)
	. = ..()
	. += span_notice("<b>Right Click</b> anywhere to set the range the launcher's shells with fuze at.")
	. += span_notice("<b>Control + Click</b> the launcher to select the next shell type to load.")
	. += span_notice("The launcher does not need to be manually reloaded. It will create it's own shells each time it is racked.")

/obj/item/gun/ballistic/shotgun/shell_launcher/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with || !user)
		return ITEM_INTERACT_BLOCKING
	var/distance_ranged = get_dist(user, interacting_with)
	if(distance_ranged > maximum_target_range)
		user.balloon_alert(user, "out of range")
		return ITEM_INTERACT_BLOCKING
	target_range = distance_ranged
	user.balloon_alert(user, "range set: [target_range]")
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/shotgun/shell_launcher/item_ctrl_click(mob/user)
	var/next_shell_choice = tgui_input_list(user, "Select next shell load type." , "Shell Selector", selectable_shells)
	if(!next_shell_choice)
		return NONE
	current_selected_shell = selectable_shells[next_shell_choice]
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/shotgun/shell_launcher/handle_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(!semi_auto && from_firing)
		return
	var/obj/item/ammo_casing/casing = chambered //Find chambered round
	if(!chambered)
		magazine.give_round(new current_selected_shell)
	if(istype(casing)) //there's a chambered round
		if(QDELING(casing))
			stack_trace("Trying to move a qdeleted casing of type [casing.type]!")
			chambered = null
		else if(casing_ejector || !from_firing)
			casing.forceMove(drop_location()) //Eject casing onto ground.
			if(!QDELETED(casing))
				casing.bounce_away(TRUE)
				SEND_SIGNAL(casing, COMSIG_CASING_EJECTED)
		else if(empty_chamber)
			clear_chambered()
	if(chamber_next_round)
		chamber_round()

/obj/item/ammo_box/magazine/internal/shot/shell_cannon
	name = "shell launch system internal magazine"
	ammo_type = /obj/item/ammo_casing/c980grenade/ecm
	caliber = CALIBER_980TYDHOUER
	max_ammo = 1
	multiload = FALSE

/obj/item/organ/cyberimp/arm/shell_launcher
	name = "shell launch system implant"
	desc = "A mounted, single-shot housing for a shell launch cannon; capable of firing .980 Tydhouer grenades."
	items_to_create = list(/obj/item/gun/ballistic/shotgun/shell_launcher)
	icon = 'modular_doppler/cool_implants/icons/implants.dmi'
	icon_state = "shell_cannon"

/obj/item/autosurgeon/syndicate/shell_launcher
	name = "shell launcher autosurgeon"
	starting_organ = /obj/item/organ/cyberimp/arm/shell_launcher
