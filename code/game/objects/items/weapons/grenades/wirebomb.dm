/obj/item/weapon/grenade/wirebomb
	name = "wire bomb"
	desc = "A grenade that will shoot out spiked explosives in random directions and connect everything with trip wire."
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
	var/list/alldirs_copy
	var/debug = 1

/obj/item/weapon/grenade/wirebomb/New()
	alldirs_copy = alldirs
	while(spikes.len < spike_count)
		var/obj/item/wirebomb_spike/sticker = new spike_type(src)
		spikes += sticker
		sticker.owner = src

	while(directions.len < spike_count)
		directions += alldirs.Copy(1, spike_count-directions.len > alldirs.len ? 0 : spike_count-directions.len+1)
	..()

/obj/item/weapon/grenade/wirebomb/prime()
	if(!isturf(loc))
		if(ismob(loc))
			src.flags |= NODROP
			var/mob/M = loc
			if(!M.unEquip(src))
				detonate()
				return
		else
			loc = get_turf(src)
	anchored = 1
	var/passflag=0
	for(var/atom/movable/O in loc)
		if(O.pass_flags & LETPASSTHROW)
			passflag = LETPASSTHROW
			break
	flying_spike_count = spike_count
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		spike.loc = get_turf(src)
		var/direction = pick_n_take(directions)
		var/datum/beam/wire = new(src, spike, beam_icon_state="spikewire", time=9999999, maxdistance=spike_range, btype=/obj/effect/ebeam/spikewire)
		spawn(0)
			wire.Start()
		spawn(0)
			spike.launch(direction, spike_range, passflag)
	playsound(src, 'sound/effects/snap.ogg', 100, 1)
	icon_state = "wirebomb_armed"
	layer = 3.1
	animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1) //suspension effect
	armed = 1
	SSobj.processing |= src

/obj/item/weapon/grenade/wirebomb/process()
	if(!armed || detonating || flying_spike_count)
		return
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		if(!spike.sticked_to)
			world << "null sticked_to ([spike.sticked_to])"
			sleep(1)
			detonate()
			break
		if(!spike.sticked_to.density)
			world << "non dense sticked_to"
			sleep(1)
			detonate()
			break
		if(get_turf(spike.sticked_to) != spike.locsave)
			world << "different loc than locsave  [get_turf(spike.sticked_to)] != [spike.locsave]"
			sleep(1) //TEST FOR MOBS && ADD DENSITY TRIGGER
			detonate()
			break

		/*if(!sticker.sticked_to || !sticker.sticked_to.density || ( ismob(sticker.sticked_to) && get_turf(sticker.sticked_to) != sticker.locsave) )
			detonate()
			break*/

/obj/item/weapon/grenade/wirebomb/ex_act()
	if(armed && !detonating)
		detonate()
	else
		qdel(src)

/obj/item/weapon/grenade/wirebomb/Crossed(atom/movable/O)
	..()
	if(armed && O.density)
		detonate()

/obj/item/weapon/grenade/wirebomb/Destroy()
	SSobj.processing -= src
	return ..()

/obj/item/weapon/grenade/wirebomb/proc/detonate()
	if(!armed || detonating || debug)
		return
	detonating = 1
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		explosion(get_turf(spike), 0, 1, 2, 3)
	explosion(get_turf(src), 0, 1, 2, 3)

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
		if(do_after(user, 400, 20, 1, src))
			disarm()
		else
			detonate()

/obj/item/weapon/grenade/wirebomb/proc/disarm()
	armed = 0
	for(var/V in spikes)
		var/obj/item/wirebomb_spike/spike = V
		spike.owner = null
		spikes -= spike
	anchored = 0
	animate(src, pixel_y = initial(pixel_y), time = 10)

/obj/item/weapon/grenade/wirebomb/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		detonate()

////////////////////
//Wired spike bomb//
/obj/item/wirebomb_spike
	name = "bomb spike"
	desc = "It explodes when its wire is tripped."
	icon = 'icons/effects/effects.dmi'
	icon_state = "bombspike"
	embed_chance = 100
	embedded_fall_chance = 0
	throwforce = 7
	throw_speed = EMBED_THROWSPEED_THRESHOLD
	var/obj/item/weapon/grenade/wirebomb/owner
	var/atom/sticked_to
	var/turf/locsave
	layer = 3.1

/obj/item/wirebomb_spike/proc/launch(direction, range, passflag=0)
	var/count = 0
	dir = direction
	while(count < range)
		count++
		var/atom/A = SimpleMove(direction, passflag)
		var/turf/F = get_turf(src)
		F.color = "#00FF00"
		if(A)
			sticked_to = A
			locsave = loc
			anchored = 1
			var/turf/T = get_turf(A)
			T.color = "#0000FF"
			if(ishuman(A))
				A.hitby(src)
				var/datum/beam/wire = new(owner, A, beam_icon_state="spikewire", time=9999999, maxdistance=owner.spike_range, btype=/obj/effect/ebeam/spikewire)
				spawn(0)
					wire.Start()
			break
		sleep(1)

	owner.flying_spike_count--
	if(!sticked_to)
		var/turf/T = get_turf(src)
		T.color = "#FF0000"
		qdel(src)

/obj/item/wirebomb_spike/ex_act()
	if(owner)
		if(owner.armed && !owner.detonating)
			owner.detonate()
		else
			qdel(src)
	else //if the core was disarmed and an explosion hits the spike
		explosion(get_turf(src), 0, 1, 2, 3)

/obj/item/wirebomb_spike/Destroy()
	owner.spikes -= src
	owner = null
	return ..()

/obj/item/wirebomb_spike/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(owner)
			owner.detonate()

/obj/item/wirebomb_spike/attack_hand(mob/user)
	if(owner)
		owner.detonate()
	else
		..()

/////////////////////////
//Trip wire beam effect//

/obj/effect/ebeam/spikewire
	name = "bomb spike wire"
	desc = "Don't even trip."

/obj/effect/ebeam/spikewire/Crossed(atom/movable/O)
	..()
	if(O.density)
		var/obj/item/weapon/grenade/wirebomb/wbomb = owner.origin
		wbomb.detonate()

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
				x = Tx.x
				y = Tx.y
				return Ax
			else
				x = Ty.x
				y = Ty.y
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
