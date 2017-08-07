//Construction gel can be used to rapidly fix hull breaches!

//Used to hold construction gel.
/obj/item/construction_gel_canister
	name = "gel canister"
	desc = "A smooth, metallic canister about the size of a soda can. Used to hold compressed construction gel."
	icon = 'icons/obj/device.dmi'
	icon_state = "plasmarefill"
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 10, MAT_GLASS = 100)
	origin_tech = "materials=2;engineering=1"
	var/gel_stored = 100 //How much gel is in the canister
	var/gel_maximum = 100 //How much gel the canister can hold

/obj/item/construction_gel_canister/examine(mob/user)
	..()
	to_chat(user, "Its gauge indicates that it has [gel_stored]/[gel_maximum] units of stored gel.")

/obj/item/construction_gel_canister/high_capacity
	name = "high-capacity gel canister"
	desc = "A smooth, metallic canister about the size of an emergency oxygen tank. Used to hold compressed construction gel in copious amounts."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 25, MAT_GLASS = 150)
	gel_stored = 250
	gel_maximum = 250

//The primary method of dispensing construction gel.
//You can use clicking and draggong to gel up a large area simultaneously.
#define GEL_LIMIT 49 //How many tiles can be gelled at once
/obj/item/device/construction_gel_apparatus
	name = "construction gel apparatus"
	desc = "A bulky, gun-shaped medium for dispensing construction gel over a wide area."
	icon_state = "construction_gel_apparatus"
	item_state = "chemsprayer"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)
	origin_tech = "materials=5;engineering=4" //High materials, since it's construction gel
	var/obj/item/construction_gel_canister/canister //The canister this apparatus is drawing gel from
	var/turf/gel_area_start //The first corner of the rectangle being targeted for gel application
	var/turf/gel_area_end //The second corner of the rectangle being targeted for gel applicaton
	var/list/turfs_to_gel //A list of turfs to apply construction gel to
	var/gelling = FALSE //If we're applying gel
	var/gel_timeout = 0 //If this reaches a certain point, our targets are cleared

/obj/item/device/construction_gel_apparatus/Initialize()
	. = ..()
	turfs_to_gel = list()
	START_PROCESSING(SSobj, src)

/obj/item/device/construction_gel_apparatus/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/construction_gel_apparatus/process()
	if(gel_area_start && !gelling)
		gel_timeout++
		if(gel_timeout >= 5)
			gel_timeout = 0
			clear_turfs_to_gel()

/obj/item/device/construction_gel_apparatus/examine(mob/user)
	..()
	if(canister)
		var/gel = get_gel()
		to_chat(user, "<span class='notice'>\icon[canister] It has [gel] out of [canister.gel_maximum] unit[gel != 1 ? "s" : ""] of gel left.</span>")

/obj/item/device/construction_gel_apparatus/attack_self(mob/living/user)
	if(!canister)
		to_chat(user, "<span class='warning'>[src] has no canister!</span>")
		return
	user.visible_message("<span class='notice'>[user] unhooks [canister] from [src] and slides it out.</span>", \
	"<span class='notice'>You unhook [canister] from [src].</span>")
	playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	canister.forceMove(get_turf(src))
	user.put_in_hands(canister)
	canister = null
	update_icon()

/obj/item/device/construction_gel_apparatus/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/construction_gel_canister))
		if(canister)
			to_chat(user, "<span class='warning'>[src] already has a canister attached!</span>")
			return
		user.visible_message("<span class='notice'>[user] slides [I] onto [src] and hooks it into place.</span>", \
		"<span class='notice'>You hook [I] onto [src] and secure it in place.</span>")
		playsound(user, 'sound/items/screwdriver2.ogg', 50, TRUE)
		user.drop_item()
		I.forceMove(src)
		canister = I
		update_icon()
		return
	. = ..()

/obj/item/device/construction_gel_apparatus/afterattack(atom/target, mob/living/user, proximity_flag)
	if(!target in view(7, user))
		return
	target = get_turf(target)
	if(gelling)
		return
	if(!get_gel())
		to_chat(user, "<span class='warning'>You're out of gel!</span>")
		playsound(user, 'sound/weapons/empty.ogg', 50, FALSE)
		return
	if(!gel_area_start)
		to_chat(user, "<span class='notice'>You mark [target] for gel application. Select another turf to gel everything between them!</span>")
		user.playsound_local(user, 'sound/effects/attackblob.ogg', 50, TRUE)
		gel_area_start = target
		new/obj/effect/temp_visual/construction_gel_marker(target)
		return
	else if(!gel_area_end)
		var/list/L = block(gel_area_start, get_turf(target))
		if(L.len > GEL_LIMIT)
			to_chat(user, "<span class='warning'>That area is too large! It can be no more than [GEL_LIMIT] tiles total.</span>")
			return
		gel_timeout = 0
		to_chat(user, "<span class='notice'>You mark [target] for gel application. Click anywhere in the area to confirm application!</span>")
		user.playsound_local(user, 'sound/effects/attackblob.ogg', 50, TRUE)
		gel_area_end = target
		assign_turfs_to_gel()
		return
	else if(get_turf(target) in turfs_to_gel)
		user.visible_message("<span class='danger'>[user]'s [name] sprays construction gel!</span>", \
		"<span class='notice'>You apply construction gel across the area.</span>")
		gel_all_the_things(user)
		return
	else
		to_chat(user, "<span class='notice'>Gel targets cleared.</span>")
		clear_turfs_to_gel()
		return

/obj/item/device/construction_gel_apparatus/proc/assign_turfs_to_gel()
	if(!gel_area_start || !gel_area_end)
		return
	turfs_to_gel = block(gel_area_start, gel_area_end)
	for(var/V in turfs_to_gel)
		var/turf/T = V
		for(var/obj/effect/temp_visual/construction_gel_marker/M in T) //get rid of the existing markers
			qdel(M)
		new/obj/effect/temp_visual/construction_gel_marker(T)

/obj/item/device/construction_gel_apparatus/proc/clear_turfs_to_gel()
	gel_area_start = null
	gel_area_end = null
	if(turfs_to_gel.len)
		for(var/V in turfs_to_gel)
			var/turf/T = V
			for(var/obj/effect/temp_visual/construction_gel_marker/M in T)
				qdel(M)
			turfs_to_gel -= T

/obj/item/device/construction_gel_apparatus/proc/gel_all_the_things(mob/living/user)
	for(var/V in turfs_to_gel)
		var/turf/T = V
		var/gel_type = /obj/structure/construction_gel/floor
		var/obj/structure/construction_gel/G = locate() in T
		if(G)
			gel_type = G.opposite_type
		else if(!isspaceturf(T))
			continue
		if(!use_gel(1))
			to_chat(user, "<span class='warning'>Your [name] runs out of gel!</span>")
			break
		if(G)
			qdel(G)
		new gel_type (get_turf(T))
		playsound(T, 'sound/effects/splat.ogg', 30, FALSE)
		CHECK_TICK
	clear_turfs_to_gel()
	update_icon()

/obj/item/device/construction_gel_apparatus/update_icon()
	..()
	cut_overlays()
	if(canister)
		add_overlay("apparatus_canister_loaded")
		var/gauge_overlay
		switch(get_gel() / canister.gel_maximum)
			if(0) //empty!
				gauge_overlay = 7
			if(0 to 0.16)
				gauge_overlay = 6
			if(0.16 to 0.32)
				gauge_overlay = 5
			if(0.32 to 0.48)
				gauge_overlay = 4
			if(0.48 to 0.64)
				gauge_overlay = 3
			if(0.64 to 0.80)
				gauge_overlay = 2
			if(0.80 to 1)
				gauge_overlay = 1
		add_overlay("apparatus_gauge_[gauge_overlay]")

/obj/item/device/construction_gel_apparatus/proc/get_gel()
	if(!canister)
		return
	return canister.gel_stored

/obj/item/device/construction_gel_apparatus/proc/has_gel(gel_amount)
	return gel_amount <= get_gel()

/obj/item/device/construction_gel_apparatus/proc/use_gel(gel_amount)
	if(!has_gel(gel_amount))
		return
	canister.gel_stored = max(0, canister.gel_stored -= gel_amount)
	update_icon()
	return TRUE


/obj/item/device/construction_gel_apparatus/preloaded/Initialize()
	. = ..()
	canister = new(src)
	update_icon()

/obj/item/device/construction_gel_apparatus/preloaded/admin/use_gel(gel_amount)
	return TRUE


//Construction gel objects!
/obj/structure/construction_gel
	name = "gel glob"
	desc = "A glob of construction gel."
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	icon_state = "gel_floor"
	max_integrity = 50
	alpha = 127
	CanAtmosPass = ATMOS_PASS_NO
	var/opposite_type //The apparatus can swap gels between these types.

/obj/structure/construction_gel/Initialize(mapload)
	. = ..()
	air_update_turf(1)
	START_PROCESSING(SSobj, src)

/obj/structure/construction_gel/Destroy()
	var/turf/T = loc
	STOP_PROCESSING(SSobj, src)
	T.air_update_turf(1)
	return ..()

/obj/structure/construction_gel/process()
	take_damage(rand(0.25, 0.33), sound_effect = FALSE) //Takes a very long time to decay on its own
	update_icon()

/obj/structure/construction_gel/update_icon()
	..()
	cut_overlays()
	var/glob_size = 1
	switch(obj_integrity / max_integrity)
		if(0 to 0.33)
			glob_size = 1
		if(0.33 to 0.66)
			glob_size = 2
		if(0.66 to 1)
			glob_size = 3
	add_overlay("gel_glob[glob_size]")

/obj/structure/construction_gel/floor
	name = "gel flooring"
	desc = "A thin layer of vacuum-resistant construction gel. It may be a good base for plating."
	opposite_type = /obj/structure/construction_gel/wall

/obj/structure/construction_gel/floor/attackby(obj/item/I, mob/living/user, params)
	var/turf/T = get_turf(src)
	if(!isspaceturf(T))
		return ..()
	if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/F = I
		to_chat(user, "<span class='notice'>You press [F] into [src], forming solid plating.</span>")
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		qdel(src)
		T.ChangeTurf(/turf/open/floor/plating)
		F.use(1)
		return
	return ..()

/obj/structure/construction_gel/wall
	name = "gel wall"
	desc = "A thick layer of vacuum-resistant construction gel. It has the structure to support plating and girders."
	icon_state = "gel_wall"
	opacity = TRUE
	density = TRUE
	opposite_type = /obj/structure/construction_gel/floor
	alpha = 175

/obj/structure/construction_gel/wall/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.amount < 2)
			to_chat(user, "<span class='notice'>You need at least two metal to build plating and girders on [src]!</span>")
			return
		user.visible_message("<span class='notice'>[user] starts building girders on [src]...</span>", \
		"<span class='notice'>You begin building girders on [src]...</span>")
		if(!do_after(user, 30, target = src) || QDELETED(M) || M.amount < 2)
			return
		user.visible_message("<span class='notice'>[user] builds girders on [src]!</span>", \
		"<span class='notice'>You construct girders on [src].</span>")
		var/turf/T = get_turf(src)
		qdel(src)
		new/obj/structure/girder(T)
		T.ChangeTurf(/turf/open/floor/plating)
		return
	return ..()

#undef GEL_LIMIT
