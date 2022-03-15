/datum/action/cooldown/spell/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through."
	action_icon_state = "shield"

	sound = 'sound/magic/forcewall.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS
	spell_requirements = NONE

	invocation = "TARCOL MINTI ZHERI"
	invocation_type = INVOCATION_SHOUT
	range = -1

	/// The typepath to the wall we create on cast.
	var/wall_type = /obj/effect/forcefield/wizard

/datum/action/cooldown/spell/cast(atom/cast_on)

	new wall_type(get_turf(owner), owner)

	if(owner.dir == SOUTH || owner.dir == NORTH)
		new wall_type(get_step(owner, EAST), owner)
		new wall_type(get_step(owner, WEST), owner)

	else
		new wall_type(get_step(owner, NORTH), owner)
		new wall_type(get_step(owner, SOUTH), owner)


/obj/effect/forcefield/wizard
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster)
	. = ..()
	caster_weakref = WEAKREF(caster)

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(WEAKREF(mover) == caster_weakref)
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.anti_magic_check(chargecost = 0))
			return TRUE
