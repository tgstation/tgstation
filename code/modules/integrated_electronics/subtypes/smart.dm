/obj/item/integrated_circuit/smart
	category_text = "Smart"

/obj/item/integrated_circuit/smart/basic_pathfinder
	name = "basic pathfinder"
	desc = "This complex circuit is able to determine what direction a given target is."
	extended_desc = "This circuit uses a miniturized integrated camera to determine where the target is. If the machine \
	cannot see the target, it will not be able to calculate the correct direction."
	icon_state = "numberpad"
	complexity = 5
	inputs = list("target" = IC_PINTYPE_REF,"ignore obstacles" = IC_PINTYPE_BOOLEAN)
	outputs = list("dir" = IC_PINTYPE_DIR)
	activators = list("calculate dir" = IC_PINTYPE_PULSE_IN, "on calculated" = IC_PINTYPE_PULSE_OUT,"not calculated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/smart/basic_pathfinder/do_work()
	var/datum/integrated_io/I = inputs[1]
	set_pin_data(IC_OUTPUT, 1, null)
	if(!isweakref(I.data))
		return
		activate_pin(3)
	var/atom/A = I.data.resolve()
	if(!A)
		activate_pin(3)
		return
	if(!(A in view(get_turf(src))))
		push_data()
		activate_pin(3)
		return // Can't see the target.

	if(get_pin_data(IC_INPUT, 2))
		set_pin_data(IC_OUTPUT, 1, get_dir(get_turf(src), get_turf(A)))
	else
		set_pin_data(IC_OUTPUT, 1, get_dir(get_turf(src), get_step_towards2(get_turf(src),A)))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/smart/coord_basic_pathfinder
	name = "coordinate pathfinder"
	desc = "This complex circuit is able to determine what direction a given target is."
	extended_desc = "This circuit uses absolute coordinates to determine where the target is. If the machine \
	cannot see the target, it will not be able to calculate the correct direction. \
	This circuit will only work while inside an assembly."
	icon_state = "numberpad"
	complexity = 5
	inputs = list("X" = IC_PINTYPE_NUMBER,"Y" = IC_PINTYPE_NUMBER,"ignore obstacles" = IC_PINTYPE_BOOLEAN)
	outputs = list(	"dir" 					= IC_PINTYPE_DIR,
					"distance"				= IC_PINTYPE_NUMBER
	)
	activators = list("calculate dir" = IC_PINTYPE_PULSE_IN, "on calculated" = IC_PINTYPE_PULSE_OUT,"not calculated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40

/obj/item/integrated_circuit/smart/coord_basic_pathfinder/do_work()
	if(!assembly)
		activate_pin(3)
		return
	var/turf/T = get_turf(assembly)
	var/target_x = CLAMP(get_pin_data(IC_INPUT, 1), 0, world.maxx)
	var/target_y = CLAMP(get_pin_data(IC_INPUT, 2), 0, world.maxy)
	var/turf/A = locate(target_x, target_y, T.z)
	set_pin_data(IC_OUTPUT, 1, null)
	if(!A||A==T)
		activate_pin(3)
		return
	if(get_pin_data(IC_INPUT, 2))
		set_pin_data(IC_OUTPUT, 1, get_dir(get_turf(src), get_turf(A)))
	else
		set_pin_data(IC_OUTPUT, 1, get_dir(get_turf(src), get_step_towards2(get_turf(src),A)))
	set_pin_data(IC_OUTPUT, 2, sqrt((A.x-T.x)*(A.x-T.x)+ (A.y-T.y)*(A.y-T.y)))
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/smart/advanced_pathfinder
	name = "advanced pathfinder"
	desc = "This circuit uses a complex processor for long-range pathfinding."
	extended_desc = "This circuit uses absolute coordinates to find its target. A path will be generated to the target, taking obstacles into account, \
	and pathing around any instances of said input. The passkey provided from a card reader is used to calculate a valid path through airlocks."
	icon_state = "numberpad"
	complexity = 40
	cooldown_per_use = 50
	inputs = list("X target" = IC_PINTYPE_NUMBER,"Y target" = IC_PINTYPE_NUMBER,"obstacle" = IC_PINTYPE_REF,"access" = IC_PINTYPE_STRING)
	outputs = list("X" = IC_PINTYPE_LIST,"Y" = IC_PINTYPE_LIST)
	activators = list("calculate path" = IC_PINTYPE_PULSE_IN, "on calculated" = IC_PINTYPE_PULSE_OUT,"not calculated" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 80
	var/obj/item/card/id/idc

/obj/item/integrated_circuit/smart/advanced_pathfinder/Initialize()
	.=..()
	idc = new(src)

/obj/item/integrated_circuit/smart/advanced_pathfinder/do_work()
	if(!assembly)
		activate_pin(3)
		return
	idc.access = assembly.access_card.access
	var/turf/a_loc = get_turf(assembly)
	var/list/P = cir_get_path_to(assembly, locate(get_pin_data(IC_INPUT, 1),get_pin_data(IC_INPUT, 2),a_loc.z), /turf/proc/Distance_cardinal, 0, 200, id=idc, exclude=get_turf(get_pin_data_as_type(IC_INPUT,3, /atom)), simulated_only = 0)

	if(!P)
		activate_pin(3)
		return
	else
		var/list/Xn =  new/list(P.len)
		var/list/Yn =  new/list(P.len)
		var/turf/T
		for(var/i =1 to P.len)
			T=P[i]
			Xn[i] = T.x
			Yn[i] = T.y
		set_pin_data(IC_OUTPUT, 1, Xn)
		set_pin_data(IC_OUTPUT, 2, Yn)
		push_data()
		activate_pin(2)
