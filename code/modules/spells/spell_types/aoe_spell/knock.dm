/datum/action/cooldown/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and closets."
	action_icon_state = "knock"

	sound = 'sound/magic/knock.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS

	invocation = "AULIE OXIN FIERA"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	range = 3

	var/static/list/knockable_things = typecacheof(list(
		/obj/machinery/door/airlock,
		/obj/structure/closet,
	))

/datum/action/cooldown/spell/aoe/knock/is_valid_target(atom/cast_on)
	return is_type_in_typecache(cast_on, knockable_things)

/datum/action/cooldown/spell/aoe/knock/cast_on_thing_in_aoe(atom/cast_on)
	if(istype(cast_on, /obj/machinery/door))
		INVOKE_ASYNC(src, .proc/open_door, cast_on)
	if(istype(cast_on, /obj/structure/closet))
		INVOKE_ASYNC(src, .proc/open_closet, cast_on)

/datum/action/cooldown/spell/aoe/knock/proc/open_door(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock_door = door
		airlock_door.locked = FALSE
	door.open()

/datum/action/cooldown/spell/aoe/knock/proc/open_closet(obj/structure/closet/closet)
	closet.locked = FALSE
	closet.open()
