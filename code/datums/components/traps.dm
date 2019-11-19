//make any object into a landmine or tripwire

#define COMSIG_TRAP_ACTIVATE "activate_trap" //sent to traps to activate them
#define COMSIG_TRAP_LINK "link_trap" //a trap sent this will store ref of parent of component sending it in linked_datums
#define COMSIG_TRAP_UNLINK "unlink_trap" //a trap sent this will remove ref of parent of component sending it in linked_datums

/datum/component/trap
	var/list/linked_datums = list() //holds references to other traps, triggers use it to activate linked traps
	var/datum/callback/obj_activation_callback //callback invoked on activation, for easy handling of special effects that need properties/methods of parent

	//todo - various commonly needed trap features
	var/list/allowed_parent_types = list()
	var/activation_sound
	var/starts_invisible
	var/del_on_activation

/datum/component/trap/Initialize(_datums_to_link, _obj_activation_callback)
	for(var/datum/target in _datums_to_link)
		linked_datums += target
		SEND_SIGNAL(target, COMSIG_TRAP_LINK)
	obj_activation_callback = _obj_activation_callback
	RegisterSignal(parent, COMSIG_TRAP_LINK, .proc/trap_link)
	RegisterSignal(parent, COMSIG_TRAP_UNLINK, .proc/trap_unlink)
	RegisterSignal(parent, COMSIG_TRAP_ACTIVATE, .proc/activate) 

/datum/component/trap/proc/activate()
	//override with custom behavior

	obj_activation_callback?.Invoke()
	if(isatom(parent))
		var/atom/A = parent
		A.visible_message("The [A] activates!") //debug message
	//todo: playsound, etc

/datum/component/trap/proc/trap_link(datum/component/source)
	linked_datums += source.parent
	
/datum/component/trap/proc/trap_unlink(datum/component/source)
	linked_datums -= source.parent

/datum/component/trap/proc/activate_linked_datums()
	for(var/datum/target in linked_datums)
		SEND_SIGNAL(target, COMSIG_TRAP_ACTIVATE)

/datum/component/trap/Destroy()
	for(var/datum/target_datum in linked_datums)
		SEND_SIGNAL(target_datum, COMSIG_TRAP_UNLINK)
	. = ..()

//triggers
/datum/component/trap/trigger/activate()
	//override with custom behavior
	
	activate_linked_datums()
	. = ..()

//example feature implementation for assessing sanity of component's organization, remove for final version

/datum/component/trap/landmine/activate()
	explosion(get_turf(parent),-1,-1,2, flame_range = 4)
	. = ..()

/datum/component/trap/trigger/tripwire/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/activate)

/datum/component/trap/trigger/tripwire/activate(datum/source, atom/movable/AM)
	if(!ismob(AM))
		return
	. = ..()

/obj/landmine/Initialize(mapload, list/triggers_to_link)
	. = ..()
	AddComponent(/datum/component/trap/landmine, triggers_to_link)
	new /obj/tripwire(loc, list(src))

/obj/tripwire/Initialize(mapload, list/traps_to_link)
	. = ..()
	AddComponent(/datum/component/trap/trigger/tripwire, traps_to_link)
