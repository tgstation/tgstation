//Thing that you stick on the floor
/obj/item/clockwork/trap_placer
	name = "ловушка"
	desc = "джокера"
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	w_class = WEIGHT_CLASS_HUGE
	var/result_path = /obj/structure/destructible/clockwork/trap

/obj/item/clockwork/trap_placer/attack_self(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	for(var/obj/structure/destructible/clockwork/trap/T in get_turf(src))
		if(istype(T, type))
			to_chat(user, span_warning("That space is occupied!"))
			return
	to_chat(user, span_brass("You place [src], use a <b>clockwork slab</b> to link it to other traps."))
	var/obj/new_obj = new result_path(get_turf(src))
	new_obj.setDir(user.dir)
	qdel(src)

//Thing you stick on the wall
/obj/item/wallframe/clocktrap
	name = "эээ"
	desc = "че?"
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	pixel_shift = -24
	w_class = WEIGHT_CLASS_HUGE
	result_path = /obj/structure/destructible/clockwork/trap

/obj/item/wallframe/clocktrap/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += span_brass("<hr>Это можно разместить на стене.")

//Wall item (either spawned by a wallframe or directly)
/obj/structure/destructible/clockwork/trap
	name = "ыыы"
	desc = "пук"
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	density = FALSE
	layer = LOW_OBJ_LAYER
	break_message = span_warning("Замысловатое устройство разваливается.")
	var/unwrench_path = /obj/item/wallframe/clocktrap
	var/component_datum = /datum/component/clockwork_trap

/obj/structure/destructible/clockwork/trap/Initialize(mapload)
	. = ..()
	AddComponent(component_datum)

/obj/structure/destructible/clockwork/trap/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, span_warning("Начинаю откручивать [src]..."))
	if(do_after(user, 50, target=src))
		to_chat(user, span_warning("Отсоединяю [src], убирая все подключения к нему."))
		new unwrench_path(get_turf(src))
		qdel(src)
		return TRUE

//Component
/datum/component/clockwork_trap
	var/list/outputs
	var/sends_input = FALSE
	var/takes_input = FALSE

/datum/component/clockwork_trap/Initialize(mapload)
	. = ..()
	outputs = list()

	RegisterSignal(parent, COMSIG_CLOCKWORK_SIGNAL_RECEIVED, PROC_REF(trigger))
	RegisterSignal(parent, COMSIG_ATOM_EMINENCE_ACT, PROC_REF(trigger))	//The eminence can trigger traps too
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(clicked))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(OnAttackBy))

/datum/component/clockwork_trap/proc/add_input(datum/component/clockwork_trap/input)
	outputs |= input.parent

/datum/component/clockwork_trap/proc/add_output(datum/component/clockwork_trap/output)
	output.outputs |= parent

/datum/component/clockwork_trap/proc/trigger()
	return TRUE

/datum/component/clockwork_trap/proc/clicked(mob/user)
	return

/datum/component/clockwork_trap/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	if(is_servant_of_ratvar(user))
		if(istype(I, /obj/item/clockwork/clockwork_slab))
			var/obj/item/clockwork/clockwork_slab/slab = I
			if(slab.buffer)
				if(takes_input)
					to_chat(user, span_brass("Подключаю [slab.buffer.parent] к [parent]."))
					add_output(slab.buffer)
					slab.buffer = null
				else
					to_chat(user, span_brass("У этого механизма нет входа."))
			else
				if(sends_input)
					to_chat(user, span_brass("Буду подключать [parent] к другим механизмам."))
					slab.buffer = src
				else
					to_chat(user, span_brass("Этот механизм не имеет выходов."))

/datum/component/clockwork_trap/proc/trigger_connected()
	for(var/obj/O in outputs)
		SEND_SIGNAL(O, COMSIG_CLOCKWORK_SIGNAL_RECEIVED)
