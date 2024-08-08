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

/obj/item/mcobject/flusher/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			trunk_check()
		else
			trunk = null

/obj/item/mcobject/flusher/proc/flush(datum/mcmessage/input)
	trunk_check()
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

/obj/item/mcobject/flusher/proc/expel(obj/structure/disposalholder/H)
	playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)
	flick("comp_flush1", src)
	pipe_eject(H)

	H.vent_gas(loc)
	qdel(H)

/obj/item/mcobject/flusher/proc/trunk_check()
	trunk = locate() in src.loc
	if(trunk)
		trunk.linked = src
	else
		trunk = null
