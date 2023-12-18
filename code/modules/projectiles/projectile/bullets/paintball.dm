/obj/projectile/paintball
	name = "empty paintball"
	icon_state = "paintball"
	damage = 0
	hitsound = 'sound/weapons/throwtap.ogg'

/obj/projectile/paintball/Initialize(mapload)
	. = ..()
	create_reagents(10, NO_REACT)

/obj/projectile/paintball/on_hit(atom/target, blocked = 0, pierce_hit)
	if(blocked != 100) // not completely blocked
		..()
		reagents.trans_to(target, reagents.total_volume, methods = VAPOR)
		return BULLET_ACT_HIT

	..()
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/paintball/red
	name = "red paintball"
	color = "#eb180c"

/obj/projectile/paintball/red/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/colorful_reagent/powder/red, 10)

/obj/projectile/paintball/blue
	name = "blue paintball"
	color = "#0c4beb"

/obj/projectile/paintball/blue/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/colorful_reagent/powder/blue, 10)

/obj/projectile/paintball/pepper
	name = "pepperball"
	color = "#B31008"

/obj/projectile/paintball/pepper/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
