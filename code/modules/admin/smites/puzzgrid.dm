/// Turns the user into a puzzgrid
/datum/smite/puzzgrid
	name = "Puzzgrid"

	var/timer
	var/gib_on_loss

/datum/smite/puzzgrid/configure(client/user)
	var/timer = input(user, "How long should other people have to solve the grid? 0 gives infinite time.", "Puzzgrid", 0) as num | null
	if (isnull(timer))
		return FALSE

	var/gib_on_loss = tgui_alert(user, "What should happen to them when they lose?", "Puzzgrid", list("Gib", "New puzzle")) == "Gib"

	src.gib_on_loss = gib_on_loss
	src.timer = timer == 0 ? null : (timer * 1 SECONDS)

	return TRUE

/datum/smite/puzzgrid/effect(client/user, mob/living/target)
	. = ..()

	var/datum/puzzgrid/puzzgrid = create_random_puzzgrid()
	if (isnull(puzzgrid))
		to_chat(user, span_warning("Couldn't create a puzzgrid! Maybe the config isn't setup?"))
		return

	var/obj/structure/puzzgrid_effect/puzzgrid_effect = new(target.loc, target, puzzgrid, timer, gib_on_loss)
	target.forceMove(puzzgrid_effect)
	puzzgrid_effect.visible_message(span_warning("[target] has suddenly transformed into a fiendishly hard puzzle!"))

	playsound(puzzgrid_effect, 'sound/effects/magic.ogg', 70)

/obj/structure/puzzgrid_effect
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"

	var/mob/living/victim
	var/timer
	var/gib_on_loss

/obj/structure/puzzgrid_effect/Initialize(mapload, mob/living/victim, datum/puzzgrid/puzzgrid, timer, gib_on_loss)
	. = ..()

	if (isnull(victim))
		return

	src.victim = victim
	src.timer = timer
	src.gib_on_loss = gib_on_loss

	name = "[victim]'s fiendish curse"

	victim.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILIZED), "[type]")

	add_puzzgrid_component(puzzgrid)

/obj/structure/puzzgrid_effect/Destroy()
	QDEL_NULL(victim)
	return ..()

/obj/structure/puzzgrid_effect/proc/add_puzzgrid_component(datum/puzzgrid/puzzgrid)
	AddComponent( \
		/datum/component/puzzgrid, \
		puzzgrid = puzzgrid, \
		timer = timer, \
		on_victory_callback = CALLBACK(src, PROC_REF(on_victory)), \
		on_fail_callback = CALLBACK(src, gib_on_loss ? PROC_REF(loss_gib) : PROC_REF(loss_restart)), \
	)

/obj/structure/puzzgrid_effect/proc/on_victory()
	victim.forceMove(loc)
	victim.Paralyze(5 SECONDS)
	victim.visible_message(
		span_notice("[victim] is unshackled from their fiendish prison!"),
		span_notice("You are unshackled from your fiendish prison!"),
	)

	victim.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILIZED), "[type]")

	victim = null

	qdel(src)

/obj/structure/puzzgrid_effect/proc/loss_gib()
	victim.forceMove(loc)
	victim.visible_message(
		span_bolddanger("You were unable to free [victim] from their fiendish prison, leaving them as nothing more than a smattering of mush!"),
		span_bolddanger("Your compatriates were unable to free you from your fiendish prison, leaving you as nothing more than a smattering of mush!"),
	)
	victim.gib(DROP_ALL_REMAINS)
	victim = null

	qdel(src)

/obj/structure/puzzgrid_effect/proc/loss_restart()
	var/datum/puzzgrid/puzzgrid = create_random_puzzgrid()
	if (isnull(puzzgrid))
		victim.forceMove(loc)
		victim.Paralyze(5 SECONDS)
		victim.visible_message(span_bolddanger("Despite completely failing the puzzle, through unbelievable luck, [victim] manages to break out anyway!"))
		victim.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILIZED), "[type]")
		qdel(src)
		victim = null
		return

	visible_message(span_danger("The fiendishly hard puzzle shapeshifts into a different, equally as challenging puzzle!"))

	// Defer until after the fail proc finishes, since that will qdel the component.
	addtimer(CALLBACK(src, PROC_REF(add_puzzgrid_component), puzzgrid), 0)
