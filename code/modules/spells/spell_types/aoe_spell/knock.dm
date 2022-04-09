/datum/action/cooldown/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and closets."
	button_icon_state = "knock"

	sound = 'sound/magic/knock.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS

	invocation = "AULIE OXIN FIERA"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	outer_radius = 3

	var/static/list/knockable_things = typecacheof(list(
		/obj/machinery/door/airlock,
		/obj/structure/closet,
	))

/datum/action/cooldown/spell/aoe/knock/is_affected_by_aoe(atom/center, atom/thing)
	return is_type_in_typecache(thing, knockable_things)

/datum/action/cooldown/spell/aoe/knock/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(istype(victim, /obj/machinery/door))
		INVOKE_ASYNC(src, .proc/open_door, victim)
	if(istype(victim, /obj/structure/closet))
		INVOKE_ASYNC(src, .proc/open_closet, victim)

/datum/action/cooldown/spell/aoe/knock/proc/open_door(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock_door = door
		airlock_door.locked = FALSE
	door.open()

/datum/action/cooldown/spell/aoe/knock/proc/open_closet(obj/structure/closet/closet)
	closet.locked = FALSE
	closet.open()
