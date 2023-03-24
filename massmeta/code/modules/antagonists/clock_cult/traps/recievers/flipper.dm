/obj/item/clockwork/trap_placer/flipper
	name = "трамплин"
	desc = "Панель вращающегося пола, приводимая в действие паром. Когда ввод будет получен, он бросит на него любого."
	icon_state = "pressure_sensor"
	result_path = /obj/structure/destructible/clockwork/trap/flipper

/obj/structure/destructible/clockwork/trap/flipper
	name = "трамплин"
	desc = "Панель вращающегося пола, приводимая в действие паром. Когда ввод будет получен, он бросит на него любого."
	icon_state = "pressure_sensor"
	component_datum = /datum/component/clockwork_trap/flipper
	unwrench_path = /obj/item/clockwork/trap_placer/flipper
	var/cooldown = 0

/obj/structure/destructible/clockwork/trap/flipper/proc/flip()
	if(cooldown > world.time)
		return
	cooldown = world.time + 200
	flick("flipper", src)
	for(var/atom/movable/AM in get_turf(src))
		if(AM.anchored)
			continue
		AM.throw_at(get_edge_target_turf(src, dir), 6, 4)

/datum/component/clockwork_trap/flipper
	takes_input = TRUE

/datum/component/clockwork_trap/flipper/trigger()
	if(!..())
		return
	var/obj/structure/destructible/clockwork/trap/flipper/F = parent
	if(!istype(F))
		return
	F.flip()
