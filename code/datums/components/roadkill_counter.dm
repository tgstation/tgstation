/datum/component/roadkill_counter
	var/list/names

/datum/component/roadkill_counter/Initialize()
	if(!istype(parent, /obj/docking_port/mobile))
		. = COMPONENT_INCOMPATIBLE
		CRASH("A roadkill counter component has been applied to an incorrect object. parent: [parent]")

	names = list()
	RegisterSignal(COMSIG_SHUTTLE_DOCKING_START, .proc/Start)
	RegisterSignal(COMSIG_SHUTTLE_ROADKILL, .proc/Roadkill)
	RegisterSignal(COMSIG_SHUTTLE_DOCKING_SUCCESS, .proc/Success)

/datum/component/roadkill_counter/proc/Start()
	names.Cut()

/datum/component/roadkill_counter/proc/Roadkill(mob/living/M)
	names += M.real_name

/datum/component/roadkill_counter/proc/Success()
	if(names.len)
		addtimer(CALLBACK(src, .proc/Mocking_Message, names), 200)

/datum/component/roadkill_counter/proc/Mocking_Message()
	if(names.len)
		priority_announce("Congratulations to [english_list(names)] for being crushed and killed instantly by [parent].")
