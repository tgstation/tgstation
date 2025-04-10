/// Subtype for bloodsucker lighting structures (candelabrum and blazier)

/obj/structure/bloodsucker/lighting
	name = "NONDESCRIPT BLOODSUCKER LIGHTING FIXTURE THAT SHOULDN'T EXIST"
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 1
	light_range = 0
	density = FALSE
	anchored = FALSE
	interaction_flags_click = BYPASS_ADJACENCY // Needed for the Ctrl+Click ranged interaction.
	var/lit = FALSE 						  //I'm sure it will have no unforeseen consequences, none whatsoever
	var/active_light_range = 3

/obj/structure/bloodsucker/lighting/Initialize()
	. = ..()
	register_context()
	update_appearance()
	desc = "Its proportions seem... <i>off</i>."

/obj/structure/bloodsucker/lighting/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/bloodsucker/lighting/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!anchored)
		return
	if(in_range(source, user))
		if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
			context[SCREENTIP_CONTEXT_LMB] = "[lit ? "Extinguish":"Ignite"]"
			return CONTEXTUAL_SCREENTIP_SET
	else
		if(IS_BLOODSUCKER(user))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "[lit ? "Extinguish":"Ignite"]"
			return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bloodsucker/lighting/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][lit ? "_lit" : ""]"

/obj/structure/bloodsucker/lighting/bolt()
	. = ..()
	set_anchored(TRUE)
	density = TRUE

/obj/structure/bloodsucker/lighting/unbolt()
	. = ..()
	set_anchored(FALSE)
	density = FALSE
	if(lit)
		toggle()

/obj/structure/bloodsucker/lighting/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(anchored && (IS_VASSAL(user) || IS_BLOODSUCKER(user)))
		toggle()
	return ..()

/obj/structure/bloodsucker/lighting/click_ctrl(mob/user)
	if(!in_range(src, user) && anchored && IS_BLOODSUCKER(user))
		toggle()
		user.visible_message(span_danger("The [lit ? "[src.name] suddenly crackles to life" : "[src.name] is abruptly extinguished"]!"),
		span_danger("<i>With a subtle hand motion you [lit ? "ignite [src]" : "snuff out [src]"].</i>"))
		return CLICK_ACTION_SUCCESS
	return

/obj/structure/bloodsucker/lighting/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		desc = initial(desc)
		set_light(active_light_range, light_power, light_color)
		playsound(loc, 'sound/items/match_strike.ogg', 25)
		START_PROCESSING(SSobj, src)
	else
		desc = "Its proportions seem... <i>off</i>."
		set_light(0)
		playsound(loc, 'sound/effects/bamf.ogg', 20, FALSE, 0, 2)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/lighting/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Candelabrum - Drains the sanity of non-bloodsuckers/non-vassals near it, has the brightness of a lightbulb
/obj/structure/bloodsucker/lighting/candelabrum
	name = "candelabrum"
	desc = "It burns slowly and doesn't radiate heat."
	icon_state = "candelabrum_lit"
	base_icon_state = "candelabrum"
	active_light_range = 3
	ghost_desc = "This magical candle causes hallucinations and negatively affects the mood of those who are neither bloodsuckers nor vassals."
	vamp_desc = "This magical candle drains the sanity of unvassalized mortals while active.\n\
		You alone can toggle it from afar by <b>ctrl-clicking</b> it."
	vassal_desc = "This magical candle drains the sanity of those fools who havent yet accepted your master while active."

/obj/structure/bloodsucker/lighting/cendelabrum/process()
	. = ..()
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people))
			continue
		nearly_people.adjust_hallucinations(5 SECONDS)
		nearly_people.add_mood_event("vampcandle", /datum/mood_event/vampcandle)

// Brazier - Currently nothing more than an aesthetic light with roughly the brightness of a bonfire
/obj/structure/bloodsucker/lighting/brazier
	name = "brazier"
	desc = "It's bright and crackling, yet there's a hint of constraint to its somber flame."
	icon_state = "brazier_lit"
	base_icon_state = "brazier"
	light_power = 1.125
	active_light_range = 6
	vamp_desc = "You alone can toggle this from afar by <b>ctrl-clicking</b> it."
	vassal_desc = "You can toggle this by <b>clicking</b> it."

	/// Our slightly quieter looping burn sound effect; copied over from 'bonfire.dm'
	var/datum/looping_sound/burning/brazier/burning_loop

/obj/structure/bloodsucker/lighting/brazier/Initialize()
	. = ..()
	burning_loop = new(src)

/obj/structure/bloodsucker/lighting/brazier/toggle(mob/user)
	. = ..()
	if(lit)
		particles = new /particles/brazier
		burning_loop.start()
	else
		QDEL_NULL(particles)
		burning_loop.stop()

//Quieter burning sound loop based off of 'code\datums\looping_sounds\burning.dm'
/datum/looping_sound/burning/brazier
	volume = 15
	ignore_walls = FALSE
