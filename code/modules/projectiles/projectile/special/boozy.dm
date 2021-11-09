/obj/projectile/boozy
	name = "moonshine shot"
	icon_state = "boozy"
	damage = 0
	speed = 1.6
	nodamage = TRUE
	hitsound = 'sound/effects/footstep/water1.ogg'

/obj/projectile/boozy/Initialize(mapload)
	. = ..()
	create_reagents(15)
	reagents.add_reagent(/datum/reagent/consumable/ethanol/moonshine, 10)

/obj/projectile/boozy/on_hit(atom/target, blocked = FALSE)
	if(prob(60)) //boom headshot
		def_zone = BODY_ZONE_HEAD

	if(!iscarbon(target))
		..()
		return BULLET_ACT_HIT

	var/mob/living/carbon/drunkard = target
	if(blocked != 100) // not completely blocked
		if(def_zone == BODY_ZONE_HEAD && drunkard.is_face_visible())
			reagents.trans_to(drunkard, reagents.total_volume, methods = INGEST)
			playsound(drunkard, 'sound/items/drink.ogg', 30)

	reagents.expose(drunkard, TOUCH) //they are splashed by some liquor either way
	..()
	return BULLET_ACT_HIT
