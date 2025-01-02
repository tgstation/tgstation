/datum/action/item_action/adjust/papermask
	name = "Adjust paper mask"
	desc = "LMB: Change mask face. RMB: Adjust mask."

/datum/action/item_action/adjust/papermask/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/mask/paper/paper_mask = target
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		paper_mask.adjust_mask(usr)
	else
		paper_mask.reskin_obj(usr)

/obj/item/clothing/mask/paper
	name = "paper mask"
	desc = "It's true. Once you wear a mask for so long, you forget about who you are. Wonder if that happens with shitty paper ones."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/papermask.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/papermask.dmi'
	icon_state = "mask_paper"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEFACIALHAIR | HIDESNOUT
	interaction_flags_click = NEED_DEXTERITY
	w_class = WEIGHT_CLASS_SMALL
	supported_bodyshapes = null
	bodyshape_icon_files = null
	actions_types = list(/datum/action/item_action/adjust/papermask)
	unique_reskin = list(
			"Blank" = "mask_paper",
			"Neutral" = "mask_neutral",
			"Eye" = "mask_eye",
			"Sleep" = "mask_sleep",
			"Heart" = "mask_heart",
			"Core" = "mask_core",
			"Plus" = "mask_plus",
			"Square" = "mask_square",
			"Bullseye" = "mask_bullseye",
			"Vertical" = "mask_vertical",
			"Horizontal" = "mask_horizontal",
			"X" = "mask_x",
			"Bug" = "mask_bug",
			"Double" = "mask_double",
			"Mark" = "mask_mark",
			"Line" = "mask_line",
			"Minus" = "mask_minus",
			"Four" = "mask_four",
			"Diamond" = "mask_diamond",
			"Cat" = "mask_cat",
			"Big Eye" = "mask_bigeye",
			"Good" = "mask_good",
			"Bad" = "mask_bad",
			"Happy" = "mask_happy",
			"Sad" = "mask_sad",
	)

	/// Whether or not the mask is currently being layered over (or under!) hair. FALSE/null means the mask is layered over the hair (this is how it starts off).
	var/wear_hair_over
	/// Whether or not the strap is currently hidden or visible
	var/strap_hidden

/obj/item/clothing/mask/paper/Initialize(mapload)
	. = ..()
	if(wear_hair_over)
		alternate_worn_layer = BACK_LAYER

/obj/item/clothing/mask/paper/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!strap_hidden)
		. += mutable_appearance(icon_file, "mask_paper_strap")

/obj/item/clothing/mask/paper/click_alt_secondary(mob/user)
	adjust_mask(user)

/obj/item/clothing/mask/paper/item_ctrl_click(mob/user)
	adjust_strap(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/mask/paper/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Change Mask Face"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Adjust Mask"
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Hide/Show Strap"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/mask/paper/reskin_obj(mob/user)
	if(!user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "must be holding a pen!")
		return

	. = ..()

	var/mob/living/carbon/carbon_user
	if(iscarbon(user))
		carbon_user = user
	if(carbon_user && carbon_user.wear_mask == src)
		carbon_user.update_worn_mask()

	current_skin = null //so we can infinitely reskin

/obj/item/clothing/mask/paper/proc/adjust_mask(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!user.incapacitated)
		var/is_worn = user.wear_mask == src
		wear_hair_over = !wear_hair_over
		if(wear_hair_over)
			alternate_worn_layer = BACK_LAYER
			to_chat(user, "You [is_worn ? "" : "will "]sweep your hair over the mask.")
		else
			alternate_worn_layer = initial(alternate_worn_layer)
			to_chat(user, "You [is_worn ? "" : "will "]sweep your hair under the mask.")

		user.update_worn_mask()

/obj/item/clothing/mask/paper/proc/adjust_strap(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!user.incapacitated)
		var/is_worn = user.wear_mask == src
		strap_hidden = !strap_hidden
		to_chat(user, "You [is_worn ? "" : "will "][strap_hidden ? "hide" : "show"] the mask strap.")

		user.update_worn_mask()

// Because alternate_worn_layer can potentially get reset on unequipping the mask (ex: for 'Top' snouts), let's make sure we don't lose it our settings
/obj/item/clothing/mask/paper/dropped(mob/living/carbon/human/user)
	var/prev_alternate_worn_layer = alternate_worn_layer
	. = ..()
	alternate_worn_layer = prev_alternate_worn_layer

/datum/crafting_recipe/paper_mask
	name = "Paper Mask"
	result = /obj/item/clothing/mask/paper
	time = 30
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/paper = 5)
	category = CAT_CLOTHING
