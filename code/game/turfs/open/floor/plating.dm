/**
 * PLATINGS
 *
 * Handle interaction with tiles and lets you put stuff on top of it.
 */
/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	base_icon_state = "plating"
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	baseturfs = /turf/baseturf_bottom
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	var/attachment_holes = TRUE //Can this plating have reinforced floors placed ontop of it

	var/upgradable = TRUE //Used for upgrading this into R-Plating

	/// If true, will allow tiles to replace us if the tile [wants to] [/obj/item/stack/tile/var/replace_plating].
	/// And if our baseturfs are compatible.
	/// See [/obj/item/stack/tile/proc/place_tile].
	var/allow_replacement = TRUE

/turf/open/floor/plating/setup_broken_states()
	return list("damaged1", "damaged2", "damaged4")

/turf/open/floor/plating/setup_burnt_states()
	return list("floorscorched1", "floorscorched2")

/turf/open/floor/plating/examine(mob/user)
	. = ..()
	if(broken || burnt)
		. += span_notice("It looks like the dents could be <i>welded</i> smooth.")
		return
	if(attachment_holes)
		. += span_notice("There are a few attachment holes for a new <i>tile</i> or reinforcement <i>rods</i>.")
	else
		. += span_notice("You might be able to build ontop of it with some <i>tiles</i>...")
	if(upgradable)
		. += span_notice("You could probably make this plating more resilient with some plasteel.")


/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods) && attachment_holes)
		if(broken || burnt)
			if(!iscyborg(user))
				to_chat(user, span_warning("Repair the plating first! Use a welding tool to fix the damage."))
			else
				to_chat(user, span_warning("Repair the plating first! Use a welding tool or a plating repair tool to fix the damage.")) //we don't need to confuse humans by giving them a message about plating repair tools, since only janiborgs should have access to them outside of Christmas presents or admin intervention
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			to_chat(user, span_warning("You need two rods to make a reinforced floor!"))
			return
		else
			to_chat(user, span_notice("You begin reinforcing the floor..."))
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/open/floor/engine))
					PlaceOnTop(/turf/open/floor/engine, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, span_notice("You reinforce the floor."))
				return
	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			for(var/obj/O in src)
				for(var/M in O.buckled_mobs)
					to_chat(user, span_warning("Someone is buckled to \the [O]! Unbuckle [M] to move \him out of the way."))
					return
			var/obj/item/stack/tile/tile = C
			tile.place_tile(src, user)
		else
			if(!iscyborg(user))
				to_chat(user, span_warning("This section is too damaged to support a tile! Use a welding tool to fix the damage."))
			else
				to_chat(user, span_warning("This section is too damaged to support a tile! Use a welding tool or a plating repair tool to fix the damage."))
	else if(istype(C, /obj/item/cautery/prt)) //plating repair tool
		if((broken || burnt) && C.use_tool(src, user, 0, volume=80))
			to_chat(user, span_danger("You fix some dents on the broken plating."))
			icon_state = base_icon_state
			burnt = FALSE
			broken = FALSE
			update_appearance()
	else if(istype(C, /obj/item/stack/sheet/plasteel) && upgradable) //Reinforcement!
		if(!broken && !burnt)
			var/obj/item/stack/sheet/sheets = C
			if(sheets.get_amount() < 2)
				return
			balloon_alert(user, "reinforcing plating...")
			if(do_after(user, 12 SECONDS, target = src))
				if(sheets.get_amount() < 2)
					return
				sheets.use(2)
				playsound(src, 'sound/machines/creak.ogg', 100, TRUE)
				src.PlaceOnTop(/turf/open/floor/plating/r_plate)
		else
			if(!iscyborg(user))
				to_chat(user, span_warning("This section is too damaged to support a tile! Use a welding tool to fix the damage."))
			else
				to_chat(user, span_warning("This section is too damaged to support a tile! Use a welding tool or a plating repair tool to fix the damage."))


/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	..()
	if((broken || burnt) && I.use_tool(src, user, 0, volume=80))
		to_chat(user, span_danger("You fix some dents on the broken plating."))
		icon_state = base_icon_state
		burnt = FALSE
		broken = FALSE
		update_appearance()

	return TRUE

/turf/open/floor/plating/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	return ..()

/turf/open/floor/plating/make_plating(force = FALSE)
	return

/turf/open/floor/plating/foam
	name = "metal foam plating"
	desc = "Thin, fragile flooring created with metal foam."
	icon_state = "foam_plating"
	upgradable = FALSE

/turf/open/floor/plating/foam/burn_tile()
	return //jetfuel can't melt steel foam

/turf/open/floor/plating/foam/break_tile()
	return //jetfuel can't break steel foam...

/turf/open/floor/plating/foam/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tile/iron))
		var/obj/item/stack/tile/iron/P = I
		if(P.use(1))
			var/obj/L = locate(/obj/structure/lattice) in src
			if(L)
				qdel(L)
			to_chat(user, span_notice("You reinforce the foamed plating with tiling."))
			playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	else
		playsound(src, 'sound/weapons/tap.ogg', 100, TRUE) //The attack sound is muffled by the foam itself
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(I.force * 20 - 25))
			user.visible_message(span_danger("[user] smashes through [src]!"), \
							span_danger("You smash through [src] with [I]!"))
			ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else
			to_chat(user, span_danger("You hit [src], to no effect!"))

/turf/open/floor/plating/foam/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)

/turf/open/floor/plating/foam/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, span_notice("You build a floor."))
		ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/floor/plating/foam/ex_act()
	. = ..()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/plating/foam/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/plating/r_plate
	name = "reinforced plating"
	desc = "Thick, tough flooring created with multiple layers of metal."
	icon_state = "r_plate-0"

	thermal_conductivity = 0.025
	heat_capacity = INFINITY

	baseturfs = /turf/open/floor/plating
	allow_replacement = FALSE
	RCD_proof = TRUE
	upgradable = FALSE

	var/d_state = PLATE_INTACT

/turf/open/floor/plating/r_plate/examine(mob/user)
	. += ..()
	. += deconstruction_hints(user)

/turf/open/floor/plating/r_plate/proc/deconstruction_hints(mob/user)
	switch(d_state)
		if(PLATE_INTACT)
			return span_notice("The plating reinforcements are securely <b>bolted</b> in place.")
		if(PLATE_BOLTS_LOSENED)
			return span_notice("The plating reinforcement is <i>unscrewed</i> but <b>welded</b> firmly to the plating.")
		if(PLATE_CUT)
			return span_notice("The plating reinforcements have been <i>sliced through</i> but is still <b>loosly</b> held in place.")

/turf/open/floor/plating/r_plate/update_icon_state()
	icon_state = "r_plate-[d_state]"
	return ..()

/turf/open/floor/plating/r_plate/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	//get the user's location
	if(!isturf(user.loc))
		return //can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	var/turf/T = user.loc
	if(try_decon(W, user, T))
		return
	return ..()

/turf/open/floor/plating/r_plate/proc/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(PLATE_INTACT)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start loosening the bolts which secure the reinforcing plate in place..."))
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/open/floor/plating/r_plate) || d_state != PLATE_INTACT)
						return TRUE
					d_state = PLATE_BOLTS_LOSENED
					update_appearance()
					drop_screws()
					to_chat(user, span_notice("You remove the bolts securing the reinforced plating."))
				return TRUE

		if(PLATE_BOLTS_LOSENED)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, span_notice("You begin slicing through the reinforced plating..."))
				if(W.use_tool(src, user, 150, volume=100))
					if(!istype(src, /turf/open/floor/plating/r_plate) || d_state != PLATE_BOLTS_LOSENED)
						return TRUE
					d_state = PLATE_CUT
					update_appearance()
					to_chat(user, span_notice("You press firmly on the plating, dislodging it."))
				return TRUE

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("You begin securing the bolts that hold the reinforced plate in place..."))
				if(W.use_tool(src, user, 150, volume=100))
					if(!istype(src, /turf/open/floor/plating/r_plate) || d_state != PLATE_BOLTS_LOSENED)
						return TRUE
					d_state = PLATE_INTACT
					update_appearance()
					to_chat(user, span_notice("The bolts have been tightly secured."))
				return TRUE

		if(PLATE_CUT)
			if(W.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("You struggle to pry off the reinforced plating..."))
				if(W.use_tool(src, user, 200, volume=100))
					if(!istype(src,  /turf/open/floor/plating/r_plate) || d_state != PLATE_CUT)
						return TRUE
					to_chat(user, span_notice("You pry off the plating reinforcements."))
					new /obj/item/stack/sheet/plasteel(src, 2)
					ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				to_chat(user, span_notice("You begin welding the reinforcements back onto the plating..."))
				if(W.use_tool(src, user, 150, volume=100))
					if(!istype(src,  /turf/open/floor/plating/r_plate) || d_state != PLATE_CUT)
						return TRUE
					d_state = PLATE_BOLTS_LOSENED
					update_appearance()
					to_chat(user, span_notice("The reinfoced cover has been welded securely to the plating."))
				return TRUE
	return FALSE

/turf/open/floor/plating/r_plate/proc/drop_screws() //When you start dismantling R-Plates they'll drop their bolts on the Z-level below, a little visible warning.
	var/turf/below_turf = get_step_multiz(src, DOWN)
	while(istype(below_turf, /turf/open/openspace))
		below_turf = get_step_multiz(below_turf, DOWN)
	if(!isnull(below_turf) && !isspaceturf(below_turf))
		new /obj/effect/decal/cleanable/glass/plastitanium/screws(below_turf)
		playsound(src, 'sound/effects/structure_stress/pop3.ogg', 100, TRUE)
