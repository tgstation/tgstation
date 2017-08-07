//Construction gel can be used to rapidly fix hull breaches!

//Used to hold construction gel.
/obj/item/construction_gel_canister
	name = "gel canister"
	desc = "A smooth, metallic canister about the width of a soda can and twice as tall. Used to hold compressed construction gel."
	icon = 'icons/obj/device.dmi'
	icon_state = "plasmarefill"
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 25, MAT_GLASS = 150)
	origin_tech = "materials=4;engineering=1"
	var/gel_stored = 100 //How much gel is in the canister
	var/gel_maximum = 100 //How much gel the canister can hold

//The primary method of dispensing construction gel.
//You can use clicking and draggong to gel up a large area simultaneously.
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

//Construction gel objects!

/obj/structure/construction_gel
	name = "gel glob"
	desc = "A glob of construction gel."
	density = FALSE
	opacity = FALSE
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
		T.ChangeTurf(/turf/open/floor/plating)
		F.use(1)
		qdel(src)
		return
	return ..()

/obj/structure/construction_gel/wall
	name = "gel wall"
	desc = "A thick layer of vacuum-resistant construction gel. It should have the structure to support girders."
	icon_state = "gel_wall"
	opacity = TRUE
	density = TRUE
	opposite_type = /obj/structure/construction_gel/floor

/obj/structure/construction_gel/wall/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.amount < 2)
			to_chat(user, "<span class='notice'>You need at least two metal to build girders on [src]!</span>")
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
		new opposite_type (T)
		return
	return ..()
