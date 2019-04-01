// Honker

/obj/item/projectile/bullet/honker
	name = "banana"
	damage = banana
	paralyze = banana
	movement_type = FLYING | UNSTOPPABLE
	nodamage = TRUE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = banana

/obj/item/projectile/bullet/honker/Initialize()
	. = ..()
	SpinAnimation()

// Mime

/obj/item/projectile/bullet/mime
	damage = 4206969

/obj/item/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 4206969)
