/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "Массивный блок укреплённого металла, используемый для разделения отсеков."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	opacity = TRUE
	density = TRUE
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	girder_state = GIRDER_REINF
	make_delay = 5 SECONDS
	explosive_resistance = 2
	rad_insulation = RAD_HEAVY_INSULATION
	rust_resistance = RUST_RESISTANCE_REINFORCED
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall. also indicates the temperature at wich the wall will melt (currently only able to melt with H/E pipes)
	///Dismantled state, related to deconstruction.
	var/d_state = INTACT
	///Base icon state to use for deconstruction
	var/base_decon_state = "r_wall"

/turf/closed/wall/r_wall/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return span_notice("Внешняя <b>решётка</b> выглядит нетронутой.")
		if(SUPPORT_LINES)
			return span_notice("Внешняя <i>решётка</i> была разрезана, но поддержки всё ещё надежно <b>привинчены</b> к внешней обшивке.")
		if(COVER)
			return span_notice("Поддержки были <i>откручены</i>. Внешняя обшивка накрепко <b>приварена</b> к балке.")
		if(CUT_COVER)
			return span_notice("Внешняя обшивка была <i>срезана</i> и едва держится на <b>паре заклёпок</b>.")
		if(ANCHOR_BOLTS)
			return span_notice("Внешняя обшивка была <i>отодрана</i>. Болты, крепящие опорные стержни, плотно <b>затянуты</b>.")
		if(SUPPORT_RODS)
			return span_notice("Болты, крепящие опорные стержни, были <i>ослаблены</i>, но они всё ещё <b>приварены</b> к балке.")
		if(SHEATH)
			return span_notice("Опорные стержни были <i>перерезаны</i> и внутренний слой обшивки <b>вот-вот отвалится</b> от балки.")

/turf/closed/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/iron(src, 2)

/turf/closed/wall/r_wall/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	return ..()

/turf/closed/wall/r_wall/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = SUPPORT_LINES
				update_appearance()
				to_chat(user, span_notice("Вы перекусываете внешнюю решётку."))
				return TRUE

		if(SUPPORT_LINES)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("Вы начинаете откручивать поддержки..."))
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_LINES)
						return TRUE
					d_state = COVER
					update_appearance()
					to_chat(user, span_notice("Вы откручиваете болтики, крепящие поддержки."))
				return TRUE

			else if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = INTACT
				update_appearance()
				to_chat(user, span_notice("Вы чините внешнюю решётку."))
				return TRUE

		if(COVER)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=2, heat_required = HIGH_TEMPERATURE_REQUIRED))
					return
				to_chat(user, span_notice("Вы начинаете резать внешнюю обшивку..."))
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = CUT_COVER
					update_appearance()
					to_chat(user, span_notice("Вы сильно нажимаете на лист обшивки, отцепляя его от крепления."))
				return TRUE

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("Вы начинаете закреплять поддержки..."))
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = SUPPORT_LINES
					update_appearance()
					to_chat(user, span_notice("Поддержки закреплены."))
				return TRUE

		if(CUT_COVER)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("Вы с трудом отдираете лист внешней обшивки..."))
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_appearance()
					to_chat(user, span_notice("Лист обшивки с треском отходит от каркаса."))
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=2, heat_required = HIGH_TEMPERATURE_REQUIRED))
					return
				to_chat(user, span_notice("Вы начинаете приваривать лист обшивки обратно к каркасу..."))
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = COVER
					update_appearance()
					to_chat(user, span_notice("Лист обшивки накрепко приварен."))
				return TRUE

		if(ANCHOR_BOLTS)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("Вы начинаете ослаблять болты, фиксирующие опорные стержни на каркасе..."))
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = SUPPORT_RODS
					update_appearance()
					to_chat(user, span_notice("Вы откручиваете болты опорных стержней."))
				return TRUE

			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("Вы поддеваете лист обшивки, вправляя его на место..."))
				if(W.use_tool(src, user, 20, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = CUT_COVER
					update_appearance()
					to_chat(user, span_notice("Лист обшивки встаёт в свой паз."))
				return TRUE

		if(SUPPORT_RODS)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=2, heat_required = HIGH_TEMPERATURE_REQUIRED))
					return
				to_chat(user, span_notice("Вы начинаете разрезать опорные стержни..."))
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = SHEATH
					update_appearance()
					to_chat(user, span_notice("Опорные стержни разрезаны."))
				return TRUE

			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("Вы начинаете затягивать болты, удерживающие опорные стержни..."))
				W.play_tool_sound(src, 100)
				if(W.use_tool(src, user, 40))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_appearance()
					to_chat(user, span_notice("Болты опорных стержней подтянуты."))
				return TRUE

		if(SHEATH)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("Вы просовываете монтировку в щель с краю внутренней обшивки..."))
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					to_chat(user, span_notice("Вы отдираете внутреннюю обшивку."))
					dismantle_wall()
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0, heat_required = HIGH_TEMPERATURE_REQUIRED))
					return
				to_chat(user, span_notice("Вы начинаете сваривать опорные стержни друг с другом..."))
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					d_state = SUPPORT_RODS
					update_appearance()
					to_chat(user, span_notice("Опорные стержни зафиксированы."))
				return TRUE
	return FALSE

/turf/closed/wall/r_wall/update_icon(updates=ALL)
	. = ..()
	if(d_state != INTACT)
		smoothing_flags = NONE
		return
	if (!(updates & UPDATE_SMOOTHING))
		return
	smoothing_flags = SMOOTH_BITMASK
	QUEUE_SMOOTH_NEIGHBORS(src)
	QUEUE_SMOOTH(src)

// We don't react to smoothing changing here because this else exists only to "revert" intact changes
/turf/closed/wall/r_wall/update_icon_state()
	if(d_state != INTACT)
		icon = 'modular_bandastation/aesthetics/walls/icons/reinforced_states.dmi' // BANDASTATION EDIT - AESTHETICS
		icon_state = "[base_decon_state]-[d_state]"
	else
		icon = 'icons/bandastation/walls/reinforced_wall.dmi' // BANDASTATION EDIT - AESTHETICS
		icon_state = "[base_icon_state]-[smoothing_junction]"
	return ..()

/turf/closed/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/r_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if (the_rcd.construction_mode == RCD_WALLFRAME)
		return ..()
	if(!the_rcd.canRturf)
		return
	. = ..()
	if (.)
		.["delay"] *= RCD_RWALL_DELAY_MULT

/turf/closed/wall/r_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(the_rcd.canRturf || rcd_data[RCD_DESIGN_MODE] == RCD_WALLFRAME)
		return ..()

/turf/closed/wall/r_wall/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/turf/closed/wall/r_wall/plastitanium
	name = /turf/closed/wall/mineral/plastitanium::name
	desc = "Особо прочная стена из сплава плазмы и титана, укреплённая пласталевыми стержнями."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	hardness = 25 //plastitanium
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_SYNDICATE_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_SYNDICATE_WALLS
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/r_wall/plastitanium/nodiagonal
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_nd")
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/r_wall/plastitanium/overspace
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_overspace")
	fixed_underlay = list("space" = TRUE)

/turf/closed/wall/r_wall/plastitanium/syndicate
	name = "hull"
	desc = "Бронированная обшивка зловеще выглядящего корабля."
	explosive_resistance = 20

/turf/closed/wall/r_wall/plastitanium/syndicate/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/turf/closed/wall/r_wall/plastitanium/syndicate/nodiagonal
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_nd")
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/r_wall/plastitanium/syndicate/overspace
	icon = MAP_SWITCH('icons/turf/walls/plastitanium_wall.dmi', 'icons/turf/walls/misc_wall.dmi')
	icon_state = MAP_SWITCH("plastitanium_wall-0", "plastitanium_overspace")
	fixed_underlay = list("space" = TRUE)
