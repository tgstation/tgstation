/obj/item/weapon/grenade/wirebomb
	name = "tripwire bomb"
	desc = "A grenade that will shoot out spiked explosives in random directions and connect everything with tripwire."
	icon_state = "wirebomb"
	item_state = "flashbang"
	var/armed = 0
	var/detonating = 0
	var/spike_count = 8
	var/flying_spike_count = 0 //runtime fix
	var/list/spikes = list()
	var/spike_type = /obj/item/wirebomb_spike //other types should be a child of this
	var/spike_range = 8
	var/list/directions = list()

/obj/item/weapon/grenade/wirebomb/New()
	while(spikes.len < spike_count)
		var/obj/item/wirebomb_spike/sticker = new spike_type(src)
		spikes += sticker
		sticker.owner = src

	while(directions.len < spike_count)
		directions += alldirs.Copy(1, spike_count-directions.len > alldirs.len ? 0 : spike_count-directions.len+1)
	..()

/obj/item/weapon/grenade/wirebomb/prime()
	set waitfor = 0
	if(!isturf(loc))
		if(ismob(loc))
			var/mob/M = loc
			if(!M.unEquip(src))
				detonate()
				return
		else
			loc = get_turf(src)

	anchored = 1
	var/passflag=0
	for(var/R in loc)
		var/atom/movable/AM = R
		if(AM.pass_flags & LETPASSTHROW)
			passflag = LETPASSTHROW
			break

	flying_spike_count = spike_count
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		spike.loc = get_turf(src)
		var/direction = pick_n_take(directions)
		spike.wire = new(src, spike, beam_icon_state="spikewire", time=9999999, maxdistance=spike_range+1, btype=/obj/effect/ebeam/spikewire)
		spawn(0)
			spike.wire.Start()
		spike.launch(direction, spike_range, passflag)

	playsound(src, 'sound/effects/snap.ogg', 100, 1)
	icon_state = "wirebomb_armed"
	layer = OBJ_LAYER + 0.5
	armed = 1
	SSobj.processing |= src

/obj/item/weapon/grenade/wirebomb/process()
	if(detonating || !armed)
		return
	if(!spikes.len)
		disarm()
		return
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		if(spike.sticked_to && !spike.sticked_to.density)
			detonate()

/obj/item/weapon/grenade/wirebomb/ex_act()
	if(armed && !detonating)
		detonate()
	else
		qdel(src)

/obj/item/weapon/grenade/wirebomb/Crossed(atom/movable/O)
	if(armed && O.density)
		detonate()

/obj/item/weapon/grenade/wirebomb/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/item/weapon/grenade/wirebomb/proc/detonate()
	if(!armed || detonating)
		return
	detonating = 1
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		explosion(get_turf(spike), 0, 2, 3)
	explosion(get_turf(src), 0, 2, 3)

/obj/item/weapon/grenade/wirebomb/attack_hand(mob/user)
	if(armed)
		detonate()
	else if(!anchored)
		..()

/obj/item/weapon/grenade/wirebomb/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/wirecutters))
		if(!armed)
			return
		user << "<span class='warning'>You start disarming [src]. If you stop now it will go off!</span>"
		if(do_after(user, 400, target=src))
			disarm()
		else
			detonate()
	else if(armed)
		detonate()
	else
		. = ..()

/obj/item/weapon/grenade/wirebomb/proc/disarm()
	armed = 0
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		spike.owner = null
		spike.icon_state = "bombspike_disarmed"
		if(spike.wire)
			spike.wire.End()
			spike.wire = null
		spikes -= spike
	anchored = 0
	icon_state = "wirebomb_disarmed"

/obj/item/weapon/grenade/wirebomb/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		detonate()


////////////////////
//Wired spike bomb//
////////////////////
/obj/item/wirebomb_spike
	name = "bomb spike"
	desc = "It explodes when triggered by its tripwire"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bombspike"
	throwforce = 20
	var/obj/item/weapon/grenade/wirebomb/owner
	var/atom/sticked_to
	var/datum/beam/wire

/obj/item/wirebomb_spike/proc/launch(direction, range, passflag=0)
	set waitfor = 0

	var/count = 0
	dir = direction
	while(count < range)
		count++
		var/atom/A = SimpleMove(direction, passflag)
		if(A)
			sticked_to = A
			if(istype(A, /atom/movable))
				var/atom/movable/AM = A
				glue_object(AM)
				if(AM.anchored)
					anchored=1
				if(ismob(AM))
					var/mob/M = AM
					M.hitby(src,1,0)
			else
				anchored = 1
			layer = A.layer+0.1
			break
		sleep(1)

	owner.flying_spike_count--
	if(!sticked_to)
		qdel(src)

/obj/item/wirebomb_spike/ex_act()
	if(owner)
		if(owner.armed && !owner.detonating)
			owner.detonate()
			return
	else
		explosion(get_turf(src), 0, 1, 2, 3)
	qdel(src)

/obj/item/wirebomb_spike/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(owner)
			owner.detonate()

/obj/item/wirebomb_spike/attack_hand(mob/user)
	if(!sticked_to)
		anchored = 0
	if(!anchored && !glued_objects.len)
		..()
	else
		user << "<span class='warning'>It's wedged into [sticked_to]. You can't pick it up.</span>"

/obj/item/wirebomb_spike/glued_move(atom/movable/AM)
	..()
	if(owner)
		owner.detonate()

/obj/item/wirebomb_spike/unglue_object(atom/movable/AM)
	..()
	if(owner)
		owner.detonate()

/obj/item/wirebomb_spike/Move()
	if(..())
		if(owner)
			owner.detonate()

/obj/item/wirebomb_spike/proc/SimpleMove(direction, passflag=0)
	var/x_off = 0
	var/y_off = 0
	if(direction & NORTH)
		y_off = 1
	else if(direction & SOUTH)
		y_off = -1
	if(direction & EAST)
		x_off = 1
	else if(direction & WEST)
		x_off = -1

	var/new_x = max(1, min(world.maxx, x+x_off))
	var/new_y = max(1, min(world.maxy, y+y_off))

	if(x_off && y_off) //if diagonal movement, check for density on both sides before moving
		var/turf/Tx = locate(new_x, y, z)
		var/turf/Ty = locate(x, new_y, z)
		var/atom/Ax
		var/atom/Ay

		if(Tx.density)
			Ax = Tx
		else
			for(var/V in Tx)
				var/atom/movable/A = V
				if(A.density && !(A.pass_flags & passflag))
					Ax = A
					break

		if(Ty.density)
			Ay = Ty
		else
			for(var/V in Ty)
				var/atom/movable/A = V
				if(A.density && !(A.pass_flags & passflag))
					Ay = A
					break

		if(Ax && Ay)  //if movement forward is impossible, randomly choose a side to end movement in
			if(rand(50))
				loc = Tx
				return Ax
			else
				loc = Ty
				return Ay

	x = new_x
	y = new_y
	var/turf/T = loc
	if(T.density)
		return T
	else
		for(var/V in T)
			var/atom/movable/A = V
			if(A.density && !(A.pass_flags & passflag))
				return A

/obj/item/wirebomb_spike/Destroy()
	if(owner)
		owner.spikes -= src
		owner = null
	wire = null
	return ..()

/////////////////////////
//Trip wire beam effect//
/////////////////////////
/obj/effect/ebeam/spikewire
	name = "bomb spike tripwire"
	desc = "Don't even trip."

/obj/effect/ebeam/spikewire/Crossed(atom/movable/O)
	if(O.density)
		if(owner && owner.origin)
			var/obj/item/weapon/grenade/wirebomb/wbomb = owner.origin
			wbomb.detonate()
