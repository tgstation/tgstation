/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	school = "transmutation"
	charge_max = 200
	spell_flags = Z2NOCAST | INCLUDEUSER
	invocation = "none"
	invocation_type = "none"
	range = -1
	duration = 50 //in deciseconds

/spell/targeted/ethereal_jaunt/shift/jaunt_disappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon_state = "phase_shift"
	animation.dir = target.dir
	flick("phase_shift",animation)

/spell/targeted/ethereal_jaunt/shift/jaunt_reappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon_state = "phase_shift2"
	animation.dir = target.dir
	flick("phase_shift2",animation)

/spell/targeted/ethereal_jaunt/shift/jaunt_steam(var/mobloc)
	return