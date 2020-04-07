/turf/closed/wall/sh_wall
	name = "shielded wall"
	desc = "A huge chunk of reinforced and shielded metal used to separate rooms and provide insulation from heat when powered."
	icon = 'icons/turf/walls/shielded_wall.dmi'
	icon_state = "sh_wall"
	turf_heat_resistance = 100
	turf_max_heat_resistance = 100
	heat_capacity = 25000
	thermal_conductivity = 0.0
	opacity = 1
	density = TRUE

	var/d_state = INTACT
	var/powered = FALSE
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/cabled
	explosion_block = 2
	rad_insulation = RAD_EXTREME_INSULATION

/turf/closed/wall/sh_wall/Initialize()
	. = ..()
	check_power()

/turf/closed/wall/sh_wall/examine(mob/user)
	. = ..()
	if(powered == TRUE)
		. += "<span class='notice'>The shield is powered and functional.</span>"
	else
		. += "<span class='notice'>The shield has no power.</span>"

/turf/closed/wall/sh_wall/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return "<span class='notice'>The outer <b>grille</b> is fully intact.</span>"
		if(SUPPORT_LINES)
			return "<span class='notice'>The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.</span>"
		if(COVER)
			return "<span class='notice'>The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.</span>"
		if(CUT_COVER)
			return "<span class='notice'>The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.</span>"
		if(ANCHOR_BOLTS)
			return "<span class='notice'>The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.</span>"
		if(SUPPORT_RODS)
			return "<span class='notice'>The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.</span>"
		if(SHEATH)
			return "<span class='notice'>The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.</span>"

/turf/closed/wall/sh_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src, 2)

/turf/closed/wall/sh_wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!M.environment_smash)
		return
	if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		to_chat(M, "<span class='warning'>This wall is far too strong for you to destroy.</span>")

/turf/closed/wall/sh_wall/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = SUPPORT_LINES
				powered = FALSE
				thermal_conductivity = 0.1
				var/area/a = get_area(src)
				a.addStaticPower(-25, STATIC_ENVIRON)
				update_icon()
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return 1

		if(SUPPORT_LINES)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You begin unsecuring the support lines...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != SUPPORT_LINES)
						return 1
					d_state = COVER
					update_icon()
					to_chat(user, "<span class='notice'>You unsecure the support lines.</span>")
				return 1

			else if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = INTACT
				check_power()
				update_icon()
				to_chat(user, "<span class='notice'>You repair the outer grille.</span>")
				return 1

		if(COVER)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != COVER)
						return 1
					d_state = CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return 1

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You begin securing the support lines...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return 1
					d_state = SUPPORT_LINES
					update_icon()
					to_chat(user, "<span class='notice'>The support lines have been secured.</span>")
				return 1

		if(CUT_COVER)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You struggle to pry off the cover...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != CUT_COVER)
						return 1
					d_state = ANCHOR_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return 1

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin welding the metal cover back to the frame...</span>")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = COVER
					update_icon()
					to_chat(user, "<span class='notice'>The metal cover has been welded securely to the frame.</span>")
				return 1

		if(ANCHOR_BOLTS)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != ANCHOR_BOLTS)
						return 1
					d_state = SUPPORT_RODS
					update_icon()
					to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return 1

			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You start to pry the cover back into place...</span>")
				if(W.use_tool(src, user, 20, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != ANCHOR_BOLTS)
						return 1
					d_state = CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>The metal cover has been pried back into place.</span>")
				return 1

		if(SUPPORT_RODS)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != SUPPORT_RODS)
						return 1
					d_state = SHEATH
					update_icon()
					to_chat(user, "<span class='notice'>You slice through the support rods.</span>")
				return 1

			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start tightening the bolts which secure the support rods to their frame...</span>")
				W.play_tool_sound(src, 100)
				if(W.use_tool(src, user, 40))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != SUPPORT_RODS)
						return 1
					d_state = ANCHOR_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You tighten the bolts anchoring the support rods.</span>")
				return 1

		if(SHEATH)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != SHEATH)
						return 1
					to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
					dismantle_wall()
				return 1

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin welding the support rods back together...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/sh_wall) || d_state != SHEATH)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					to_chat(user, "<span class='notice'>You weld the support rods back together.</span>")
				return 1
	return 0

/turf/closed/wall/sh_wall/update_icon()
	. = ..()
	if(d_state != INTACT)
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
		update_overlays()
	else
		update_overlays()

/turf/closed/wall/sh_wall/update_overlays()
	. = ..()
	if(powered == TRUE && d_state == INTACT)
		overlays += image('icons/effects/effects.dmi', icon_state = "wave2")
	else
		overlays = image('icons/effects/effects.dmi', icon_state = "nothing")

/turf/closed/wall/sh_wall/check_power()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	var/area/a = get_area(src)
	if(C && d_state == INTACT)
		powered = TRUE
		thermal_conductivity = 0.0
		update_overlays()
		a.addStaticPower(25, STATIC_ENVIRON)
	else
		powered = FALSE
		thermal_conductivity = 0.1
		update_overlays()
		a.addStaticPower(-25, STATIC_ENVIRON)

/turf/closed/wall/sh_wall/update_icon_state()
	if(d_state != INTACT)
		icon_state = "sh_wall-[d_state]"
	else
		icon_state = "sh_wall"

/turf/closed/wall/sh_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/sh_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/closed/wall/sh_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()
