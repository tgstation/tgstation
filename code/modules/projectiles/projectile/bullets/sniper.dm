// .50 (Sniper)

/obj/item/projectile/bullet/p50
	name =".50 bullet"
	speed = 0.4
	damage = 70
	paralyze = 100
	dismemberment = 50
	armour_penetration = 50
	var/breakthings = TRUE

/obj/item/projectile/bullet/p50/on_hit(atom/target, blocked = 0)
	if(isobj(target) && (blocked != 100) && breakthings)
		var/obj/O = target
		O.take_damage(80, BRUTE, "bullet", FALSE)
	return ..()

/obj/item/projectile/bullet/p50/soporific
	name =".50 soporific bullet"
	armour_penetration = 0
	damage = 0
	dismemberment = 0
	paralyze = 0
	breakthings = FALSE

/obj/item/projectile/bullet/p50/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/item/projectile/bullet/p50/penetrator
	name =".50 penetrator bullet"
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	movement_type = FLYING | UNSTOPPABLE
	dismemberment = 0 //It goes through you cleanly.
	paralyze = 0
	breakthings = FALSE
