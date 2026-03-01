/obj/structure/girder
	icon = 'icons/obj/smooth_structures/girder.dmi'
	name = "girder"
	base_icon_state = "girder"
	icon_state = "girder-0"
	desc = "A large structural assembly made out of metal; It requires a layer of iron before it can be considered a wall."
	anchored = TRUE
	density = TRUE
	max_integrity = 200
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_GIRDER
	canSmoothWith = SMOOTH_GROUP_GIRDER + SMOOTH_GROUP_WALLS
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2)

	/// The stack type required to construct and dropped upon deconstructing the girder.
	var/stack_type = /obj/item/stack/sheet/iron
	/// The stack amount required to construct and dropped upon deconstructing the girder.
	var/stack_amount = 2
	/// Always drops the stack in full, even when demolished rather than disassembled.
	var/always_drop_stack = FALSE

	/// The current state of the girder. Used for construction.
	var/state = GIRDER_NORMAL
	/// Whether the girder can be unanchored by wrenching it.
	var/can_displace = TRUE
	/// Whether the girder can be welded apart. (for cult and bronze girders)
	var/can_weld_apart = FALSE

	/// The percentage chance (0-100) that a projectile passes through the girder.
	var/projectile_pass_chance = 20

/obj/structure/girder/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/uses_girder_wall_recipes)

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(state)
		if(GIRDER_REINF)
			. += span_notice("The support struts are <b>screwed</b> in place.")
		if(GIRDER_REINF_STRUTS)
			. += span_notice("The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.")
		if(GIRDER_NORMAL)
			if(can_displace)
				. += span_notice("The bolts are <b>wrenched</b> in place.")
		if(GIRDER_DISPLACED)
			. += span_notice("The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.")
		if(GIRDER_TRAM)
			. += span_notice("[src] is designed for tram usage. Deconstructed with a screwdriver!")
	if (can_weld_apart)
		. += span_notice("The frame looks weak enough to be <b>welded</b> apart.")
	else
		. += span_notice("The frame could be sliced apart with a <b>plasmacutter</b>.")

/obj/structure/girder/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (user.combat_mode)
		return
	if (istype(tool, /obj/item/stack/sheet/plasteel))
		if (try_construction_step(user, tool, 5 SECONDS, req_state = GIRDER_NORMAL, start_alert = "reinforcing frame..."))
			replace_girder(/obj/structure/girder/reinforced)
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	switch (state)
		if (GIRDER_TRAM)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_TRAM, start_alert = "disassembling frame..."))
				deconstruct(disassembled = TRUE)
				return ITEM_INTERACT_SUCCESS
		if (GIRDER_DISPLACED)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_DISPLACED, start_alert = "disassembling frame..."))
				deconstruct(disassembled = TRUE)
				return ITEM_INTERACT_SUCCESS
		if (GIRDER_REINF)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_REINF, start_alert = "unsecuring support struts..."))
				state = GIRDER_REINF_STRUTS
				return ITEM_INTERACT_SUCCESS
		if (GIRDER_REINF_STRUTS)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_REINF_STRUTS, start_alert = "securing support struts..."))
				state = GIRDER_REINF
				return ITEM_INTERACT_SUCCESS

/obj/structure/girder/wirecutter_act(mob/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_REINF_STRUTS, start_alert = "removing inner grille..."))
		new /obj/item/stack/sheet/plasteel(get_turf(src))
		replace_girder(/obj/structure/girder)
		return ITEM_INTERACT_SUCCESS

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if (!can_displace)
		balloon_alert(user, "no bolts!")
		return
	switch (state)
		if (GIRDER_NORMAL)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_NORMAL, start_alert = "unsecuring frame..."))
				replace_girder(/obj/structure/girder/displaced)
				return ITEM_INTERACT_SUCCESS
		if (GIRDER_DISPLACED)
			if (try_construction_step(user, tool, 4 SECONDS, req_state = GIRDER_DISPLACED, start_alert = "securing frame..."))
				replace_girder(/obj/structure/girder)
				return ITEM_INTERACT_SUCCESS

/obj/structure/girder/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	// Plasmacutters can always slice apart girders.
	if (!can_weld_apart && !istype(tool, /obj/item/gun/energy/plasmacutter))
		balloon_alert(user, "can't weld apart!")
		return
	if (try_construction_step(user, tool, 4 SECONDS, start_alert = "slicing apart..."))
		deconstruct(disassembled = TRUE)
		return ITEM_INTERACT_SUCCESS

/obj/structure/girder/proc/try_construction_step(mob/living/user, obj/item/tool, delay, req_state, req_floor, start_alert, volume = 100)
	if (!check_state(user, req_state, req_floor))
		return FALSE

	balloon_alert(user, start_alert)

	add_fingerprint(user)
	tool.add_fingerprint(user)

	return tool.use_tool(src, user, delay, volume = volume, extra_checks = CALLBACK(src, PROC_REF(check_state), user, req_state, req_floor))

/obj/structure/girder/proc/check_state(mob/living/user, req_state, req_anchored, req_floor)
	if (!isnull(req_state) && req_state != state)
		return FALSE
	if (req_floor && !isfloorturf(loc))
		balloon_alert(user, "needs a floor!")
		return FALSE
	return TRUE

// We do this instead of state handling because of the large number of variables we would otherwise need to keep track of.
// That said, ultimately, it would be a better solution for all of it to just be [/obj/structure/girder] at base.
// For example right now if you paint a girder and use a wrench on it, it will magically lose that paint.
/obj/structure/girder/proc/replace_girder(girder_type)
	var/obj/structure/girder/new_girder = new girder_type(loc)
	transfer_fingerprints_to(new_girder)
	new_girder.update_integrity(new_girder.max_integrity * (atom_integrity / max_integrity))
	qdel(src)

/obj/structure/girder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if((mover.pass_flags & PASSGRILLE) || isprojectile(mover))
		return prob(projectile_pass_chance)

/obj/structure/girder/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags & PASSGRILLE)
		return TRUE
	return FALSE

/obj/structure/girder/atom_deconstruct(disassembled = TRUE)
	if (disassembled || always_drop_stack)
		new stack_type(drop_location(), stack_amount)
	else
		var/remains = pick(/obj/item/stack/rods, stack_type)
		new remains(drop_location())

/obj/structure/girder/narsie_act()
	replace_girder(/obj/structure/girder/cult)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced"
	anchored = FALSE
	state = GIRDER_DISPLACED
	projectile_pass_chance = 25
	max_integrity = 120
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon = 'icons/obj/smooth_structures/reinforced_girder.dmi'
	icon_state = "reinforced-0"
	base_icon_state = "reinforced"
	state = GIRDER_REINF
	projectile_pass_chance = 0
	max_integrity = 350

/obj/structure/girder/tram
	name = "tram girder"
	desc = "Titanium framework to construct tram walls. Can be plated with <b>titanium glass</b> or other wall materials."
	icon = 'icons/obj/structures.dmi'
	icon_state = "tram"
	state = GIRDER_TRAM
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	stack_type = /obj/item/stack/sheet/mineral/titanium

/obj/structure/girder/tram/corner
	name = "tram frame corner"

//////////////////////////////////////////// cult girder //////////////////////////////////////////////

/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state= "cultgirder"
	can_displace = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	custom_materials = list(/datum/material/runedmetal = SHEET_MATERIAL_AMOUNT)
	stack_type = /obj/item/stack/sheet/runed_metal
	stack_amount = 1
	always_drop_stack = TRUE
	can_weld_apart = TRUE

/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_TURF)
			if(the_rcd.rcd_design_path != /turf/open/floor/plating/rcd)
				return FALSE

			return rcd_result_with_memory(
				list("delay" = 2 SECONDS, "cost" = 8),
				get_turf(src), RCD_MEMORY_WALL,
			)
		if(RCD_DECONSTRUCT)
			return list("delay" = 2 SECONDS, "cost" = 13)
	return FALSE

/obj/structure/girder/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data[RCD_DESIGN_MODE])
		if(RCD_TURF)
			if(the_rcd.rcd_design_path != /turf/open/floor/plating/rcd)
				return FALSE

			var/turf/T = get_turf(src)
			T.place_on_top(/turf/closed/wall)
			qdel(src)
			return TRUE
		if(RCD_DECONSTRUCT)
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/girder/bronze
	name = "wall gear"
	desc = "A girder made out of sturdy bronze, made to resemble a gear."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wall_gear"
	can_displace = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	custom_materials = list(/datum/material/bronze = SHEET_MATERIAL_AMOUNT * 2)
	stack_type = /obj/item/stack/sheet/bronze
	stack_amount = 1
	always_drop_stack = TRUE
	can_weld_apart = TRUE
