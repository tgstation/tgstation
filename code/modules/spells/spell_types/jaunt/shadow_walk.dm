#define SHADOW_REGEN_RATE 1.5

/datum/action/cooldown/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	background_icon_state = "bg_alien"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = (SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED|SPELL_REQUIRES_NO_ANTIMAGIC)

/datum/action/cooldown/spell/jaunt/shadow_walk/cast(mob/living/cast_on)
	. = ..()
	if(is_jaunting(cast_on))
		var/obj/effect/dummy/phased_mob/shadow/jaunt_holder = cast_on.loc
		jaunt_holder.end_jaunt(FALSE)
		return

	var/turf/cast_turf = get_turf(cast_on)
	if(cast_turf.get_lumcount() < SHADOW_SPECIES_LIGHT_THRESHOLD)
		playsound(cast_turf, 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
		cast_on.visible_message(span_boldwarning("[cast_on] melts into the shadows!"))
		cast_on.SetAllImmobility(0)
		cast_on.setStaminaLoss(0, FALSE)
		var/obj/effect/dummy/phased_mob/shadow/jaunt_holder = new(cast_turf)
		cast_on.forceMove(jaunt_holder)
		jaunt_holder.jaunter = cast_on

	else
		to_chat(cast_on, span_warning("It isn't dark enough here!"))

/obj/effect/dummy/phased_mob/shadow
	var/mob/living/jaunter

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	jaunter = null
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/phased_mob/shadow/process(delta_time)
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(!jaunter || jaunter.loc != src)
		qdel(src)
	if (light_amount < 0.2 && (!QDELETED(jaunter))) //heal in the dark
		jaunter.heal_overall_damage((SHADOW_REGEN_RATE * delta_time), (SHADOW_REGEN_RATE * delta_time), 0, BODYPART_ORGANIC)
	check_light_level()


/obj/effect/dummy/phased_mob/shadow/relaymove(mob/living/user, direction)
	var/turf/oldloc = loc
	. = ..()
	if(loc != oldloc)
		check_light_level()

/obj/effect/dummy/phased_mob/shadow/phased_check(mob/living/user, direction)
	. = ..()
	if(. && isspaceturf(.))
		to_chat(user, span_warning("It really would not be wise to go into space."))
		return FALSE

/obj/effect/dummy/phased_mob/shadow/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.2) // jaunt ends
		end_jaunt(TRUE)

/obj/effect/dummy/phased_mob/shadow/proc/end_jaunt(forced = FALSE)
	if(jaunter)
		if(forced)
			visible_message(span_boldwarning("[jaunter] is revealed by the light!"))
		else
			visible_message(span_boldwarning("[jaunter] emerges from the darkness!"))
		playsound(loc, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	qdel(src)


#undef SHADOW_REGEN_RATE
