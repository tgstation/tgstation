/obj/effect/proc_holder/spell/targeted/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 250
	cooldown_min = 100
	range = -1
	school = SCHOOL_TRANSMUTATION
	include_user = TRUE
	invocation = "CLANG!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "immrod"

/obj/effect/proc_holder/spell/targeted/rod_form/cast(list/targets, mob/user = usr)
	var/area/our_area = get_area(user)
	if(istype(our_area, /area/wizard_station))
		to_chat(user, span_warning("You know better than to trash Wizard Federation property. Best wait until you leave to use [src]."))
		return
	for(var/mob/living/caster in targets)
		var/turf/start = get_turf(caster)
		var/obj/effect/immovablerod/wizard/wiz_rod = new(start, get_ranged_target_turf(start, caster.dir, (15 + spell_level * 3)))
		wiz_rod.our_wizard = WEAKREF(caster)
		wiz_rod.max_distance += spell_level * 3 //You travel farther when you upgrade the spell
		wiz_rod.damage_bonus += spell_level * 20 //You do more damage when you upgrade the spell
		wiz_rod.start_turf = start

		caster.forceMove(wiz_rod)
		caster.notransform = TRUE
		caster.status_flags |= GODMODE

/// Wizard Version of the Immovable Rod.
/obj/effect/immovablerod/wizard
	notify = FALSE
	dnd_style_level_up = FALSE
	/// The wizard who's piloting our rod.
	var/datum/weakref/our_wizard
	/// The distance the rod will go.
	var/max_distance = 13
	/// The damage bonus of the rod when it smacks people.
	var/damage_bonus = 0
	/// The turf the rod started from, to calcuate distance.
	var/turf/start_turf

/obj/effect/immovablerod/wizard/Destroy(force)
	start_turf = null
	return ..()

/obj/effect/immovablerod/wizard/Moved()
	. = ..()
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		stop_travel()

/obj/effect/immovablerod/wizard/penetrate(mob/living/penetrated)
	if(penetrated.anti_magic_check())
		penetrated.visible_message(
			span_danger("[src] hits [penetrated], but it bounces back, then vanishes!"),
			span_userdanger("[src] hits you... but it bounces back, then vanishes!"),
			span_danger("You hear a weak, sad, CLANG.")
			)
		stop_travel()
		return

	penetrated.visible_message(
		span_danger("[penetrated] is penetrated by an immovable rod!"),
		span_userdanger("The [src] penetrates you!"),
		span_danger("You hear a CLANG!"),
		)
	penetrated.adjustBruteLoss(70 + damage_bonus)

/obj/effect/immovablerod/wizard/suplex_rod(mob/living/strongman)
	var/mob/living/wizard = our_wizard?.resolve()
	if(QDELETED(wizard))
		return ..() // There's no wizard in this rod? It's pretty much a normal rod at this point

	strongman.visible_message(
		span_boldwarning("[src] transforms into [wizard] as [strongman] suplexes them!"),
		span_warning("As you grab [src], it suddenly turns into [wizard] as you suplex them!")
		)
	to_chat(wizard, span_boldwarning("You're suddenly jolted out of rod-form as [strongman] somehow manages to grab you, slamming you into the ground!"))
	stop_travel()
	wizard.Stun(60)
	wizard.apply_damage(25, BRUTE)
	return TRUE

/**
 * Called when the wizard rod reaches it's maximum distance.
 * Dumps out the wizard and deletes.
 */
/obj/effect/immovablerod/wizard/proc/stop_travel()
	var/mob/living/wizard = our_wizard?.resolve()
	if(!QDELETED(wizard))
		wizard.status_flags &= ~GODMODE
		wizard.notransform = FALSE
		wizard.forceMove(get_turf(src))
		wizard = null
	qdel(src)
