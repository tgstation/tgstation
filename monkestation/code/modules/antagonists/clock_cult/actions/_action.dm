/datum/action/innate/clockcult
	button_icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	background_icon = 'monkestation/icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS


/datum/action/innate/clockcult/quick_bind
	name = "Quick Bind"
	button_icon_state = "telerune"
	desc = "A quick bound spell."
	/// Weakref to the relevant slab
	var/datum/weakref/slab_weakref
	/// Ref to the relevant scripture
	var/datum/scripture/scripture


/datum/action/innate/clockcult/quick_bind/Destroy()
	scripture = null
	return ..()


/datum/action/innate/clockcult/quick_bind/Grant(mob/living/recieving_mob)
	name = scripture.name
	desc = scripture.tip
	button_icon_state = scripture.button_icon_state

	if(scripture.power_cost)
		desc += "<br>Draws <b>[scripture.power_cost]W</b> from the ark per use."

	return ..(recieving_mob)

/datum/action/innate/clockcult/quick_bind/Remove(mob/losing_mob)
	var/obj/item/clockwork/clockwork_slab/activation_slab = slab_weakref.resolve()
	if(activation_slab.invoking_scripture == scripture)
		activation_slab.invoking_scripture = null

	return ..(losing_mob)

/datum/action/innate/clockcult/quick_bind/IsAvailable(feedback)
	if(!IS_CLOCK(owner) || owner.incapacitated())
		return FALSE

	return ..()

/datum/action/innate/clockcult/quick_bind/Activate()
	if(!slab_weakref)
		return

	var/obj/item/clockwork/clockwork_slab/activation_slab = slab_weakref.resolve()

	if(!activation_slab.invoking_scripture)
		scripture.begin_invoke(owner, activation_slab)

	else
		to_chat(owner, span_brass("You fail to invoke [name]."))

/datum/action/item_action/toggle/clock
	button_icon = 'monkestation/icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"

/datum/action/cooldown/eminence
	button_icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	background_icon = 'monkestation/icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"

/datum/action/cooldown/eminence/Activate(atom/target)
	. = ..()
	if(!iseminence(usr))
		to_chat(usr, span_boldwarning("You are not an eminence and should not have this! Please report this as a bug."))
		return FALSE
