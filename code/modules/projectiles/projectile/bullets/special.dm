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
		if(M.can_block_magic())
			return BULLET_ACT_BLOCK
		else
			M.slip(100, M.loc, GALOSHES_DONT_HELP|SLIDE, 0, FALSE)

// Mime

/obj/projectile/bullet/mime
	damage = 40

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/living_target = target
	living_target.set_silence_if_lower(20 SECONDS)
