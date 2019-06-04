/obj/item/projectile/hygiene
	name = "a splat of chemicals"
	icon_state = "cleaningbubble"
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/effects/slosh.ogg'
	hitsound_wall = 'sound/effects/slosh.ogg'

/obj/item/projectile/hygiene/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjust_hygiene(100)