/obj/item/mcobject/flusher
	name = "Flusher Component"
	icon_state = "comp_flush"
	base_icon_state = "comp_flush"

	COOLDOWN_DECLARE(flush_cd)

	///the trunk located below this object
	var/obj/structure/disposalpipe/trunk/trunk = null
	///the max amount of items we can flush at once
	var/max_capacity = 100


/obj/item/mcobject/flusher/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("flush", flush)

/obj/item/mcobject/flusher/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/mcobject/flusher/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			trunk = locate() in src.loc
			if(trunk)
				trunk.linked = src
		else
			trunk = null

/obj/item/mcobject/flusher/proc/flush(datum/mcmessage/input)
	if(!trunk || !COOLDOWN_FINISHED(src, flush_cd) || !input?.cmd)
		return
	var/count = 0
	for(var/atom/movable/listed_movable in src.loc)
		if(listed_movable.anchored)
			continue
		if(count == max_capacity)
			break
		count++
		listed_movable.forceMove(src)

	var/obj/structure/disposalholder/holder = new(src)
	flick("comp_flush1", src)
	sleep(0.5 SECONDS)
	holder.init(src)
	holder.forceMove(trunk)
	holder.active = TRUE
	holder.setDir(DOWN)
	holder.start_moving()


	COOLDOWN_START(src, flush_cd, 5 SECONDS)

/obj/item/mcobject/flusher/proc/expel(obj/structure/disposalholder/holder)
	var/turf/target
	for(var/atom/movable/AM in holder)
		target = get_offset_target_turf(holder, rand(5)-rand(5), rand(5)-rand(5))
		AM?.throw_at(target, 5, 1)
	qdel(holder)
