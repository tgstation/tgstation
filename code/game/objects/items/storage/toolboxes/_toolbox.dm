/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage/toolbox.dmi'
	icon_state = "toolbox_default"
	inhand_icon_state = "toolbox_default"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 13
	throwforce = 13
	throw_speed = 2
	throw_range = 7
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5)
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	hitsound = 'sound/items/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox/toolbox_pickup.ogg'
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	wound_bonus = 5
	storage_type = /datum/storage/toolbox

	var/latches = "single_latch"
	var/has_latches = TRUE
	/// How many interactions are we currently performing
	var/current_interactions = 0
	/// Items we should not interact with when left clicking
	var/static/list/lmb_exception_typecache = typecacheof(list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/machinery/disposal,
	))

/obj/item/storage/toolbox/Initialize(mapload)
	. = ..()
	if(has_latches)
		if(prob(10))
			latches = "double_latch"
			if(prob(1))
				latches = "triple_latch"
				if(prob(0.1))
					latches = "quad_latch" // like winning the lottery, but worse
	update_appearance()
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/storage/toolbox/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (user.combat_mode || !user.has_hand_for_held_index(user.get_inactive_hand_index()))
		return NONE

	if (is_type_in_typecache(interacting_with, lmb_exception_typecache) && !LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE

	if (current_interactions)
		var/obj/item/other_tool = user.get_inactive_held_item()
		if (!istype(other_tool)) // what even
			return NONE
		INVOKE_ASYNC(src, PROC_REF(use_tool_on), interacting_with, user, modifiers, other_tool)
		return ITEM_INTERACT_SUCCESS

	if (user.get_inactive_held_item())
		user.balloon_alert(user, "hands busy!")
		return ITEM_INTERACT_BLOCKING

	var/list/item_radial = list()
	for (var/obj/item/tool in atom_storage.real_location)
		if(is_type_in_list(tool, GLOB.tool_items))
			item_radial[tool] = tool.appearance

	if (!length(item_radial))
		return NONE

	playsound(user, 'sound/items/handling/toolbox/toolbox_open.ogg', 50)
	var/obj/item/picked_item = show_radial_menu(user, interacting_with, item_radial, require_near = TRUE)
	if (!picked_item)
		return ITEM_INTERACT_BLOCKING

	playsound(user, 'sound/items/handling/toolbox/toolbox_rustle.ogg', 50)
	if (!user.put_in_inactive_hand(picked_item))
		return ITEM_INTERACT_BLOCKING

	atom_storage.animate_parent()
	if (istype(picked_item, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_item
		if (!welder.welding)
			welder.attack_self(user)

	if (istype(picked_item, /obj/item/spess_knife))
		picked_item.attack_self(user)

	INVOKE_ASYNC(src, PROC_REF(use_tool_on), interacting_with, user, modifiers, picked_item)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/toolbox/proc/use_tool_on(atom/interacting_with, mob/living/user, list/modifiers, obj/item/picked_tool)
	current_interactions += 1
	picked_tool.melee_attack_chain(user, interacting_with, modifiers)
	current_interactions -= 1

	if (QDELETED(picked_tool) || picked_tool.loc != user || !user.CanReach(picked_tool))
		current_interactions = 0
		return

	if (current_interactions)
		return

	if (istype(picked_tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_tool
		if (welder.welding)
			welder.attack_self(user)

	atom_storage.attempt_insert(picked_tool, user)

/obj/item/storage/toolbox/update_overlays()
	. = ..()
	if(has_latches)
		. += latches

/obj/item/storage/toolbox/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] robusts [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

//repairbot assembly
/obj/item/storage/toolbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/assembly/prox_sensor))
		return ..()
	var/static/list/allowed_toolbox = list(
		/obj/item/storage/toolbox/artistic,
		/obj/item/storage/toolbox/crafter,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/emergency,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/syndicate,
	)

	if(!is_type_in_list(src, allowed_toolbox) && (type != /obj/item/storage/toolbox))
		return ITEM_INTERACT_BLOCKING
	if(contents.len >= 1)
		balloon_alert(user, "not empty!")
		return ITEM_INTERACT_BLOCKING
	var/static/list/toolbox_colors = list(
		/obj/item/storage/toolbox = "#445eb3",
		/obj/item/storage/toolbox/emergency = "#445eb3",
		/obj/item/storage/toolbox/electrical = "#b77931",
		/obj/item/storage/toolbox/artistic = "#378752",
		/obj/item/storage/toolbox/crafter = "#9D3282",
		/obj/item/storage/toolbox/syndicate = "#3d3d3d",
	)
	var/obj/item/bot_assembly/repairbot/repair = new
	repair.toolbox = type
	var/new_color = toolbox_colors[type] || "#445eb3"
	repair.set_color(new_color)
	user.put_in_hands(repair)
	repair.update_appearance()
	repair.balloon_alert(user, "sensor added!")
	qdel(tool)
	qdel(src)
	return ITEM_INTERACT_SUCCESS
