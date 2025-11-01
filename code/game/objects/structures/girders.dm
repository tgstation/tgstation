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
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20 // percentage chance that a projectile passes through the girder.
	var/can_displace = TRUE //If the girder can be moved around by wrenching it
	var/next_beep = 0 //Prevents spamming of the construction sound
	/// The material cost to construct something on the girder
	var/static/list/construction_cost = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 5,
		/obj/item/stack/sheet/plasteel = 2,
		/obj/item/stack/sheet/bronze = 2,
		/obj/item/stack/sheet/runed_metal = 1,
		/obj/item/stack/sheet/titaniumglass = 2,
		exotic_material = 2 // this needs to be refactored properly
	)

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
		if(GIRDER_DISASSEMBLED)
			. += span_notice("[src] is disassembled! You probably shouldn't be able to see this examine message.")
		if(GIRDER_TRAM)
			. += span_notice("[src] is designed for tram usage. Deconstructed with a screwdriver!")

/obj/structure/girder/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)

	add_fingerprint(user)

	if(istype(W, /obj/item/gun/energy/plasmacutter))
		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=100))
			if(state == GIRDER_TRAM)
				var/obj/item/stack/sheet/mineral/titanium/M = new (user.loc, 2)
				if(!QDELETED(M))
					M.add_fingerprint(user)
			else
				var/obj/item/stack/sheet/iron/M = new (loc, 2)
				if(!QDELETED(M))
					M.add_fingerprint(user)
			qdel(src)
		return

	if(isstack(W))
		var/obj/item/stack/stack = W
		if(!stack.usable_for_construction)
			balloon_alert(user, "can't make walls with it!")
			return

		if(iswallturf(loc) || (locate(/obj/structure/falsewall) in src.loc.contents))
			balloon_alert(user, "wall already present!")
			return
		if(!isfloorturf(src.loc) && state != GIRDER_TRAM)
			balloon_alert(user, "need floor!")
			return
		if(state == GIRDER_TRAM)
			if(!locate(/obj/structure/transport/linear/tram) in src.loc.contents)
				balloon_alert(user, "need tram floors!")
				return

		make_wall(stack, user)
		return

	if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if (P.pipe_type in list(0, 1, 5)) //simple pipes, simple bends, and simple manifolds.
			if(!user.transfer_item_to_turf(P, drop_location()))
				return
			balloon_alert(user, "inserted pipe")
		return

	return ..()

/obj/structure/girder/proc/make_wall(obj/item/stack/stack, mob/user)
	var/speed_modifier = 1
	if(HAS_TRAIT(user, TRAIT_QUICK_BUILD))
		speed_modifier = 0.7
		if(next_beep <= world.time)
			next_beep = world.time + 10
			playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)

	if(istype(stack, /obj/item/stack/rods))
		var/obj/item/stack/rods/rod = stack
		var/amount = construction_cost[rod.type]
		if(state == GIRDER_DISPLACED)
			if(rod.get_amount() < amount)
				balloon_alert(user, "need [amount] rods!")
				return
			balloon_alert(user, "concealing entrance...")
			if(do_after(user, 2 SECONDS, target = src))
				if(rod.get_amount() < amount)
					return
				rod.use(amount)
				var/obj/structure/falsewall/iron/FW = new (loc)
				transfer_fingerprints_to(FW)
				qdel(src)
			return

		if(state == GIRDER_REINF)
			balloon_alert(user, "need plasteel sheet!")
			return

		if(rod.get_amount() < amount)
			balloon_alert(user, "need [amount] rods!")
			return
		balloon_alert(user, "adding rods...")
		if(do_after(user, 4 SECONDS, target = src))
			if(rod.get_amount() < amount)
				return
			rod.use(amount)
			var/turf/T = get_turf(src)
			T.place_on_top(/turf/closed/wall/mineral/iron)
			transfer_fingerprints_to(T)
			qdel(src)
		return

	if(istype(stack, /obj/item/stack/sheet/iron))
		var/amount = construction_cost[/obj/item/stack/sheet/iron]
		if(state == GIRDER_DISPLACED)
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "concealing entrance...")
			if(do_after(user, 20 * speed_modifier, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/obj/structure/falsewall/F = new (loc)
				transfer_fingerprints_to(F)
				qdel(src)
				return
		else if(state == GIRDER_REINF)
			balloon_alert(user, "need plasteel sheet!")
			return
		else if(state == GIRDER_TRAM)
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "adding plating...")
			if (do_after(user, 4 SECONDS, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/obj/structure/tram/alt/iron/tram_wall = new(loc)
				transfer_fingerprints_to(tram_wall)
				qdel(src)
			return
		else
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "adding plating...")
			if (do_after(user, 40 * speed_modifier, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/turf/T = get_turf(src)
				T.place_on_top(/turf/closed/wall)
				transfer_fingerprints_to(T)
				qdel(src)
			return

	if(istype(stack, /obj/item/stack/sheet/titaniumglass) && state == GIRDER_TRAM)
		var/amount = construction_cost[/obj/item/stack/sheet/titaniumglass]
		if(stack.get_amount() < amount)
			balloon_alert(user, "need [amount] sheets!")
			return
		balloon_alert(user, "adding panel...")
		if (do_after(user, 2 SECONDS, target = src))
			if(stack.get_amount() < amount)
				return
			stack.use(amount)
			var/obj/structure/tram/tram_wall = new(loc)
			transfer_fingerprints_to(tram_wall)
			qdel(src)
		return

	if(istype(stack, /obj/item/stack/sheet/plasteel))
		var/amount = construction_cost[/obj/item/stack/sheet/plasteel]
		if(state == GIRDER_DISPLACED)
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "concealing entrance...")
			if(do_after(user, 2 SECONDS, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/obj/structure/falsewall/reinforced/FW = new (loc)
				transfer_fingerprints_to(FW)
				qdel(src)
				return
		else if(state == GIRDER_REINF)
			amount = 1 // hur dur let's make plasteel have different construction amounts 4norasin
			if(stack.get_amount() < amount)
				return
			balloon_alert(user, "adding plating...")
			if(do_after(user, 50 * speed_modifier, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/turf/T = get_turf(src)
				T.place_on_top(/turf/closed/wall/r_wall)
				transfer_fingerprints_to(T)
				qdel(src)
			return
		else
			amount = 1 // hur dur x2
			if(stack.get_amount() < amount)
				return
			balloon_alert(user, "reinforcing frame...")
			if(do_after(user, 60 * speed_modifier, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/obj/structure/girder/reinforced/R = new (loc)
				transfer_fingerprints_to(R)
				qdel(src)
			return

	if(istype(stack, /obj/item/stack/sheet/mineral/plastitanium))
		if(state == GIRDER_REINF)
			if(stack.get_amount() < 1)
				return
			balloon_alert(user, "adding plating...")
			if(do_after(user, 50 * speed_modifier, target = src))
				if(stack.get_amount() < 1)
					return
				stack.use(1)
				var/turf/T = get_turf(src)
				T.place_on_top(/turf/closed/wall/r_wall/plastitanium)
				transfer_fingerprints_to(T)
				qdel(src)
			return
		// No return here because generic material construction handles making normal plastitanium walls

	if(!stack.has_unique_girder && stack.material_type)
		if(istype(src, /obj/structure/girder/reinforced))
			balloon_alert(user, "need plasteel or plastitanium!")
			return

		var/material
		if(istype(stack, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/sheet = stack
			material = sheet.construction_path_type
		var/amount = construction_cost["exotic_material"]
		if(state == GIRDER_TRAM)
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			var/tram_wall_type = text2path("/obj/structure/tram/alt/[material]")
			if(!tram_wall_type)
				balloon_alert(user, "need titanium glass or mineral!")
				return
			balloon_alert(user, "adding plating...")
			if (do_after(user, 4 SECONDS, target = src))
				if(stack.get_amount() < amount)
					return
				var/obj/structure/tram/tram_wall
				tram_wall = new tram_wall_type(loc)
				stack.use(amount)
				transfer_fingerprints_to(tram_wall)
				qdel(src)
			return
		if(state == GIRDER_DISPLACED)
			var/falsewall_type = text2path("/obj/structure/falsewall/[material]")
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "concealing entrance...")
			if(do_after(user, 2 SECONDS, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/obj/structure/falsewall/falsewall
				if(falsewall_type)
					falsewall = new falsewall_type (loc)
				else
					var/obj/structure/falsewall/material/mat_falsewall = new(loc)
					var/list/material_list = list()
					material_list[GET_MATERIAL_REF(stack.material_type)] = SHEET_MATERIAL_AMOUNT * 2
					if(material_list)
						mat_falsewall.set_custom_materials(material_list)
					falsewall = mat_falsewall
				transfer_fingerprints_to(falsewall)
				qdel(src)
				return
		else
			if(stack.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "adding plating...")
			if (do_after(user, 4 SECONDS, target = src))
				if(stack.get_amount() < amount)
					return
				stack.use(amount)
				var/turf/T = get_turf(src)
				if(stack.walltype)
					T.place_on_top(stack.walltype)
				else
					var/turf/newturf = T.place_on_top(/turf/closed/wall/material)
					var/list/material_list = list()
					material_list[GET_MATERIAL_REF(stack.material_type)] = SHEET_MATERIAL_AMOUNT * 2
					if(material_list)
						newturf.set_custom_materials(material_list)

				transfer_fingerprints_to(T)
				qdel(src)
			return

// Screwdriver behavior for girders
/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE

	. = FALSE
	if(state == GIRDER_TRAM)
		balloon_alert(user, "disassembling frame...")
		if(tool.use_tool(src, user, 4 SECONDS, volume=100))
			if(state != GIRDER_TRAM)
				return
			state = GIRDER_DISASSEMBLED
			var/obj/item/stack/sheet/mineral/titanium/material = new (user.loc, 2)
			if (!QDELETED(material))
				material.add_fingerprint(user)
			qdel(src)
		return TRUE

	if(state == GIRDER_DISPLACED)
		balloon_alert(user, "disassembling frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			var/obj/item/stack/sheet/iron/M = new (loc, 2)
			if (!QDELETED(M))
				M.add_fingerprint(user)
			qdel(src)
		return TRUE

	else if(state == GIRDER_REINF)
		balloon_alert(user, "unsecuring support struts...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF)
				return
			state = GIRDER_REINF_STRUTS
		return TRUE

	else if(state == GIRDER_REINF_STRUTS)
		balloon_alert(user, "securing support struts...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF_STRUTS)
				return
			state = GIRDER_REINF
		return TRUE

// Wirecutter behavior for girders
/obj/structure/girder/wirecutter_act(mob/user, obj/item/tool)
	. = ..()
	if(state == GIRDER_REINF_STRUTS)
		balloon_alert(user, "removing inner grille...")
		if(tool.use_tool(src, user, 40, volume=100))
			new /obj/item/stack/sheet/plasteel(get_turf(src))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	. = ..()
	if(state == GIRDER_DISPLACED)
		if(!isfloorturf(loc))
			balloon_alert(user, "needs floor!")

		balloon_alert(user, "securing frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE
	else if(state == GIRDER_NORMAL && can_displace)
		balloon_alert(user, "unsecuring frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			var/obj/structure/girder/displaced/D = new (loc)
			transfer_fingerprints_to(D)
			qdel(src)
		return TRUE

/obj/structure/girder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if((mover.pass_flags & PASSGRILLE) || isprojectile(mover))
		return prob(girderpasschance)

/obj/structure/girder/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags & PASSGRILLE)
		return TRUE
	return FALSE

/obj/structure/girder/atom_deconstruct(disassembled = TRUE)
	var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/iron)
	new remains(loc)

/obj/structure/girder/narsie_act()
	new /obj/structure/girder/cult(loc)
	qdel(src)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced"
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
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
	girderpasschance = 0
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

/obj/structure/girder/cult/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=1))
			return

		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=50))
			var/obj/item/stack/sheet/runed_metal/R = new(drop_location(), 1)
			transfer_fingerprints_to(R)
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		var/amount = construction_cost[R.type]
		if(R.get_amount() < amount)
			balloon_alert(user, "need [amount] sheet!")
			return
		balloon_alert(user, "adding plating...")
		if(do_after(user, 5 SECONDS, target = src))
			if(R.get_amount() < amount)
				return
			R.use(amount)
			var/turf/T = get_turf(src)
			T.place_on_top(/turf/closed/wall/mineral/cult)
			qdel(src)

	else
		return ..()

/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/cult/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/runed_metal(drop_location())

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
	switch(rcd_data["[RCD_DESIGN_MODE]"])
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

/obj/structure/girder/bronze/attackby(obj/item/W, mob/living/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount = 0, heat_required = HIGH_TEMPERATURE_REQUIRED))
			return
		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=50))
			var/obj/item/stack/sheet/bronze/B = new(drop_location(), 2)
			transfer_fingerprints_to(B)
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet/bronze))
		var/obj/item/stack/sheet/bronze/B = W
		var/amount = construction_cost[B.type]
		if(B.get_amount() < amount)
			balloon_alert(user, "need [amount] sheets!")
			return
		balloon_alert(user, "adding plating...")
		if(do_after(user, 5 SECONDS, target = src))
			if(B.get_amount() < amount)
				return
			B.use(amount)
			var/turf/T = get_turf(src)
			T.place_on_top(/turf/closed/wall/mineral/bronze)
			qdel(src)

	else
		return ..()
