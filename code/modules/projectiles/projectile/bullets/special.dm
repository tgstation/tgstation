// Honker

/obj/projectile/bullet/honker
	name = "banana"
	damage = 0
	movement_type = FLYING
	projectile_piercing = ALL
	nodamage = TRUE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/honker/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/bullet/honker/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/M = target
	if(istype(M))
		if(M.anti_magic_check())
			return BULLET_ACT_BLOCK
		else
			M.slip(100, M.loc, GALOSHES_DONT_HELP|SLIDE, 0, FALSE)

// Crook clown

/obj/projectile/bullet/coin
	name = "coin"
	damage = 15
	hitsound = 'sound/machines/coindrop.ogg'
	icon_state = "coin"

/obj/projectile/bullet/coin/on_hit(atom/target, blocked = FALSE)
	new /obj/item/food/clowncoin(get_turf(loc))

/obj/projectile/bullet/coin/on_range()
	new /obj/item/food/clowncoin(get_turf(loc))

/obj/projectile/bullet/coin_b
	name = "coin_b"
	damage = 45
	hitsound = 'sound/machines/coindrop.ogg'
	icon_state = "coin_b"

/obj/projectile/bullet/coin_b/on_hit(atom/target, blocked = FALSE)
	new /obj/item/food/clowncoin/bananium(get_turf(loc))

/obj/projectile/bullet/coin_b/on_range()
	new /obj/item/food/clowncoin/bananium(get_turf(loc))

/obj/projectile/bullet/coin_b/Initialize()
	. = ..()
	AddElement(/datum/element/bullet_trail)

/datum/element/bullet_trail
	element_flags = ELEMENT_DETACH

/datum/element/bullet_trail/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/lubricate)

/datum/element/bullet_trail/proc/lubricate(atom/movable/coin_b)
	SIGNAL_HANDLER

	var/turf/open/OT = get_turf(coin_b)
	if(istype(OT))
		OT.MakeSlippery(TURF_WET_LUBE, 20)
		return TRUE

// Mime

/obj/projectile/bullet/mime
	damage = 40

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)
