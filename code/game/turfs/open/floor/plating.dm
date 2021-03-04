/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 * Foam plating
 */

/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	base_icon_state = "plating"
	intact = FALSE
	baseturfs = /turf/baseturf_bottom
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	var/attachment_holes = TRUE

/turf/open/floor/plating/setup_broken_states()
	return list("platingdmg1", "platingdmg2", "platingdmg3")

/turf/open/floor/plating/setup_burnt_states()
	return list("panelscorched")

/turf/open/floor/plating/examine(mob/user)
	. = ..()
	if(broken || burnt)
		. += "<span class='notice'>It looks like the dents could be <i>welded</i> smooth.</span>"
		return
	if(attachment_holes)
		. += "<span class='notice'>There are a few attachment holes for a new <i>tile</i> or reinforcement <i>rods</i>.</span>"
	else
		. += "<span class='notice'>You might be able to build ontop of it with some <i>tiles</i>...</span>"


/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods) && attachment_holes)
		if(broken || burnt)
			if(!iscyborg(user))
				to_chat(user, "<span class='warning'>Repair the plating first! Use a welding tool to fix the damage.</span>")
			else
				to_chat(user, "<span class='warning'>Repair the plating first! Use a welding tool or a plating repair tool to fix the damage.</span>") //we don't need to confuse humans by giving them a message about plating repair tools, since only janiborgs should have access to them outside of Christmas presents or admin intervention
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two rods to make a reinforced floor!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/open/floor/engine))
					PlaceOnTop(/turf/open/floor/engine, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return
	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			for(var/obj/O in src)
				for(var/M in O.buckled_mobs)
					to_chat(user, "<span class='warning'>Someone is buckled to \the [O]! Unbuckle [M] to move \him out of the way.</span>")
					return
			var/obj/item/stack/tile/tile = C
			tile.place_tile(src)
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		else
			if(!iscyborg(user))
				to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welding tool to fix the damage.</span>")
			else
				to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welding tool or a plating repair tool to fix the damage.</span>")
	else if(istype(C, /obj/item/cautery/prt)) //plating repair tool
		if((broken || burnt) && C.use_tool(src, user, 0, volume=80))
			to_chat(user, "<span class='danger'>You fix some dents on the broken plating.</span>")
			icon_state = base_icon_state
			burnt = FALSE
			broken = FALSE


/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	..()
	if((broken || burnt) && I.use_tool(src, user, 0, volume=80))
		to_chat(user, "<span class='danger'>You fix some dents on the broken plating.</span>")
		icon_state = base_icon_state
		burnt = FALSE
		broken = FALSE

	return TRUE

/turf/open/floor/plating/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/open/floor/plating/rust)

/turf/open/floor/plating/make_plating(force = FALSE)
	return

/turf/open/floor/plating/foam
	name = "metal foam plating"
	desc = "Thin, fragile flooring created with metal foam."
	icon_state = "foam_plating"

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
			to_chat(user, "<span class='notice'>You reinforce the foamed plating with tiling.</span>")
			playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	else
		playsound(src, 'sound/weapons/tap.ogg', 100, TRUE) //The attack sound is muffled by the foam itself
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(I.force * 20 - 25))
			user.visible_message("<span class='danger'>[user] smashes through [src]!</span>", \
							"<span class='danger'>You smash through [src] with [I]!</span>")
			ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else
			to_chat(user, "<span class='danger'>You hit [src], to no effect!</span>")

/turf/open/floor/plating/foam/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)

/turf/open/floor/plating/foam/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, "<span class='notice'>You build a floor.</span>")
		ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/floor/plating/foam/ex_act()
	..()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/plating/foam/tool_act(mob/living/user, obj/item/I, tool_type)
	return
