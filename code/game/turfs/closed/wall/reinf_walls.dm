/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	opacity = TRUE
	density = TRUE
	smoothing_flags = SMOOTH_BITMASK
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	explosion_block = 2
	rad_insulation = RAD_HEAVY_INSULATION
	///Dismantled state, related to deconstruction.
	var/d_state = INTACT


/turf/closed/wall/r_wall/deconstruction_hints(mob/user)
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

/turf/closed/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/iron(src, 2)

/turf/closed/wall/r_wall/attack_animal(mob/living/simple_animal/user, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!user.environment_smash)
		return
	if(user.environment_smash & ENVIRONMENT_SMASH_RWALLS)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		to_chat(user, "<span class='warning'>This wall is far too strong for you to destroy.</span>")

/turf/closed/wall/r_wall/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	return ..()

/turf/closed/wall/r_wall/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = SUPPORT_LINES
				update_icon()
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return TRUE

		if(SUPPORT_LINES)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You begin unsecuring the support lines...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_LINES)
						return TRUE
					d_state = COVER
					update_icon()
					to_chat(user, "<span class='notice'>You unsecure the support lines.</span>")
				return TRUE

			else if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = INTACT
				update_icon()
				to_chat(user, "<span class='notice'>You repair the outer grille.</span>")
				return TRUE

		if(COVER)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return TRUE

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You begin securing the support lines...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = SUPPORT_LINES
					update_icon()
					to_chat(user, "<span class='notice'>The support lines have been secured.</span>")
				return TRUE

		if(CUT_COVER)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You struggle to pry off the cover...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin welding the metal cover back to the frame...</span>")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = COVER
					update_icon()
					to_chat(user, "<span class='notice'>The metal cover has been welded securely to the frame.</span>")
				return TRUE

		if(ANCHOR_BOLTS)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return TRUE

			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You start to pry the cover back into place...</span>")
				if(W.use_tool(src, user, 20, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					to_chat(user, "<span class='notice'>The metal cover has been pried back into place.</span>")
				return TRUE

		if(SUPPORT_RODS)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = SHEATH
					update_icon()
					to_chat(user, "<span class='notice'>You slice through the support rods.</span>")
				return TRUE

			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start tightening the bolts which secure the support rods to their frame...</span>")
				W.play_tool_sound(src, 100)
				if(W.use_tool(src, user, 40))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					to_chat(user, "<span class='notice'>You tighten the bolts anchoring the support rods.</span>")
				return TRUE

		if(SHEATH)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
					dismantle_wall()
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, "<span class='notice'>You begin welding the support rods back together...</span>")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					to_chat(user, "<span class='notice'>You weld the support rods back together.</span>")
				return TRUE
	return FALSE

/turf/closed/wall/r_wall/update_icon()
	. = ..()
	if(d_state != INTACT)
		smoothing_flags = NONE
	else
		smoothing_flags = SMOOTH_BITMASK
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/turf/closed/wall/r_wall/update_icon_state()
	if(d_state != INTACT)
		icon_state = "r_wall-[d_state]"
	else
		icon_state = "[base_icon_state]-[smoothing_junction]"

/turf/closed/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/r_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/closed/wall/r_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/closed/wall/r_wall/rust_heretic_act()
	if(prob(50))
		return
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/closed/wall/r_wall/rust)

/turf/closed/wall/r_wall/syndicate
	name = "hull"
	desc = "The armored hull of an ominous looking ship."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	explosion_block = 20
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SYNDICATE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/wall/r_wall/syndicate/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/turf/closed/wall/r_wall/syndicate/nodiagonal
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle_nd"
	base_icon_state = "plastitanium_wall"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/r_wall/syndicate/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smoothing_flags = NONE

/turf/closed/wall/r_wall/syndicate/overspace
	icon_state = "map-overspace"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	fixed_underlay = list("space" = TRUE)
