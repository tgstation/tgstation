/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/piercing = FALSE

/obj/item/projectile/bullet/dart/Initialize()
	. = ..()
	create_reagents(50, NO_REACT)

/obj/item/projectile/bullet/dart/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against \the [src]!</span>")

	..(target, blocked)
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/dart/metalfoam/Initialize()
	. = ..()
	reagents.add_reagent("aluminium", 15)
	reagents.add_reagent("foaming_agent", 5)
	reagents.add_reagent("facid", 5)

/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"
