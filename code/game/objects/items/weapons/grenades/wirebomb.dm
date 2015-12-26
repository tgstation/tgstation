/obj/item/weapon/grenade/wirebomb
	name = "wire bomb"
	desc = "A grenade that will shoot out spiked explosives in random directions and connect everything with trip wire."
	icon_state = "wirebomb"
	item_state = "flashbang"
	var/armed = 0
	var/detonating = 0
	var/spike_count = 10
	var/flying_spike_count = 0 //runtime fix
	var/armed_spike_count = 0
	var/list/stickers = list()
	var/spike_type = /obj/item/wirebomb_spike //other types should be a child of this
	var/spike_range = 8
	var/list/directions = list()

/obj/item/weapon/grenade/wirebomb/New()
	while(stickers.len < spike_count)
		var/obj/item/wirebomb_spike/sticker = new spike_type(src)
		stickers += sticker
		sticker.owner = src

	while(directions.len < spike_count)
		if(directions.len < 1)
			directions += pick(NORTH, NORTHWEST, NORTHEAST, WEST)
		if(directions.len < 2)
			directions += pick(SOUTH, SOUTHWEST, SOUTHEAST, EAST)
		directions += pick(alldirs)
	..()

/obj/item/weapon/grenade/wirebomb/prime()
	if(!isturf(loc))
		if(ismob(loc))
			var/mob/M = loc
			M.unEquip(src,1)
		else
			loc = get_turf(src)
	anchored = 1
	for(var/V in stickers)
		var/obj/item/wirebomb_spike/sticker = V
		sticker.loc = get_turf(src)
		var/direction = pick_n_take(directions)
		var/datum/beam/wire = new(src, sticker, beam_icon_state="stickerwire", time=9999999, maxdistance=spike_range, btype=/obj/effect/ebeam/spikewire)
		spawn(0)
			wire.Start()
		flying_spike_count = spike_count
		spawn(0)
			sticker.launch(direction, spike_range)
	playsound(src, 'sound/effects/snap.ogg', 100, 1)
	icon_state = "wirebomb_armed"
	layer = 3.1
	animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1) //suspension effect
	armed = 1
	SSobj.processing |= src

/obj/item/weapon/grenade/wirebomb/process()
	if(!armed || detonating || flying_spike_count || !armed_spike_count)
		return
	for(var/V in stickers)
		var/obj/item/wirebomb_spike/sticker = V
		if(!sticker.spiked_to || !sticker.spiked_to.density || ( ismob(sticker.spiked_to) && get_turf(sticker.spiked_to) != sticker.locsave) )
			detonate()
			break

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
	if(!armed || detonating)
		return
	detonating = 1
	for(var/V in stickers)
		var/obj/item/wirebomb_spike/sticker = V
		explosion(get_turf(sticker), 0, 1, 2, 3)
	explosion(get_turf(src), 0, 1, 2, 3)

/obj/item/weapon/grenade/wirebomb/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		detonate()

//Wired spike bomb

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
	var/atom/spiked_to
	var/turf/locsave //for when sticker is embedded

/obj/item/wirebomb_spike/proc/launch(direction, range)
	. = spiked_to
	var/count = 0
	while(count < range)
		count++
		if( !Move(get_step(loc, direction), direction) )
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

			var/turf/T = locate(x+x_off,y+y_off,z)
			if(x_off && y_off)
				var/turf/Tx = locate(x,y+y_off,z)
				var/turf/Ty = locate(x+x_off,y,z)
				if(Tx.density && Ty.density) //sticker can't pass diagonally through dense tiles
					T = rand(50) ? Tx : Ty

			if(T.density)
				spiked_to = T
			else
				for(var/V in T)
					var/atom/A = V
					if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/H
						H.hitby(src)
						spiked_to = A
						locsave = T
						var/datum/beam/wire = new(owner, H, beam_icon_state="stickerwire", time=9999999, maxdistance=owner.spike_range, btype=/obj/effect/ebeam/spikewire)
						spawn(0)
							wire.Start()
					else if(A.density && !ismob(A))
						spiked_to = A
			if(spiked_to)
				anchored = 1
				owner.armed_spike_count++
			break
		else
			var/mob/living/carbon/human/H = locate() in loc
			if(H)
				locsave = loc
				H.hitby(src)
				spiked_to = H
				var/datum/beam/wire = new(owner, H, beam_icon_state="spikewire", time=9999999, maxdistance=owner.spike_range, btype=/obj/effect/ebeam/spikewire)
				spawn(0)
					wire.Start()
				break
		sleep(1)
	dir = direction
	owner.flying_spike_count--
	if(!spiked_to)
		qdel(src)

/obj/item/wirebomb_spike/ex_act()
	if(owner.armed && !owner.detonating)
		owner.detonate()
	else
		qdel(src)

/obj/item/wirebomb_spike/Destroy()
	owner.stickers -= src
	owner = null
	return ..()

/obj/item/wirebomb_spike/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		owner.detonate()


//Trip wire beam effect
/obj/effect/ebeam/spikewire
	name = "bomb spike wire"
	desc = "Don't even trip."

/obj/effect/ebeam/spikewire/Crossed(atom/movable/O)
	..()
	if(O.density)
		var/obj/item/weapon/grenade/wirebomb/sticky = owner.origin
		sticky.detonate()
