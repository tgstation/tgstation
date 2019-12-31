// .50 (Sniper)

/obj/projectile/bullet/p50
	name =".50 bullet"
	speed = 0.4
	damage = 70
	paralyze = 100
	dismemberment = 50
	armour_penetration = 50
	var/breakthings = TRUE

/obj/projectile/bullet/p50/on_hit(atom/target, blocked = ZERO)
	if(isobj(target) && (blocked != 100) && breakthings)
		var/obj/O = target
		O.take_damage(80, BRUTE, "bullet", FALSE)
	return ..()

/obj/projectile/bullet/p50/soporific
	name =".50 soporific bullet"
	armour_penetration = ZERO
	damage = ZERO
	dismemberment = ZERO
	paralyze = ZERO
	breakthings = FALSE

/obj/projectile/bullet/p50/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/projectile/bullet/p50/penetrator
	name = "penetrator round"
	icon_state = "gauss"
	damage = 60
	movement_type = FLYING | UNSTOPPABLE
	dismemberment = ZERO //It goes through you cleanly.
	paralyze = ZERO
	breakthings = FALSE

/obj/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	icon_state = "gaussstrong"
	damage = 25
	speed = 0.3
	range = 16
