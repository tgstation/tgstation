/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = FALSE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/projectile/bullet/pellet/Range()
	..()
	damage += -0.75
	if(damage < 0)
		qdel(src)

/obj/item/projectile/bullet/incendiary
	damage = 20
	var/fire_stacks = 4

/obj/item/projectile/bullet/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()

/obj/item/projectile/bullet/incendiary/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

// .357 (Syndie Revolver)

/obj/item/projectile/bullet/a357
	name = ".357 bullet"
	damage = 60

// 7.62 (Nagant Rifle)
 
/obj/item/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 60

/obj/item/projectile/bullet/a762_enchanted
	name = "enchanted 7.62 bullet"
	damage = 5
	stamina = 80

// 7.62x38mmR (Nagant Revolver)

/obj/item/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 60

// .50AE (Desert Eagle)

/obj/item/projectile/bullet/a50AE
	name = ".50AE bullet"
	damage = 60

// .38 (Detective's Gun)

/obj/item/projectile/bullet/c38
	name = ".38 bullet"
	damage = 15
	knockdown = 30
	stamina = 50

// 10mm (Stechkin)

/obj/item/projectile/bullet/c10mm
	name = "10mm bullet"
	damage = 30

/obj/item/projectile/bullet/c10mm_ap
	name = "10mm armor-piercing bullet"
	damage = 27
	armour_penetration = 40

/obj/item/projectile/bullet/c10mm_hp
	name = "10mm hollow-point bullet"
	damage = 40
	armour_penetration = -50

/obj/item/projectile/bullet/incendiary/c10mm
	name = "10mm incendiary bullet"
	damage = 15
	fire_stacks = 2

// 9mm (Stechkin APS)

/obj/item/projectile/bullet/c9mm
	name = "9mm bullet"
	damage = 20

/obj/item/projectile/bullet/c9mm_ap
	name = "9mm armor-piercing bullet"
	damage = 15
	armour_penetration = 40

/obj/item/projectile/bullet/incendiary/c9mm
	name = "9mm incendiary bullet"
	damage = 10
	fire_stacks = 1

// 4.6x30mm (Autorifles)

/obj/item/projectile/bullet/c46x30mm
	desc = "4.6x30mm bullet"
	damage = 20

/obj/item/projectile/bullet/c46x30mm_ap
	name = "4.6x30mm armor-piercing bullet"
	damage = 15
	armour_penetration = 40

/obj/item/projectile/bullet/incendiary/c46x30mm
	name = "4.6x30mm incendiary bullet"
	damage = 10
	fire_stacks = 1

// .45 (M1911)

/obj/item/projectile/bullet/c45
	name = ".45 bullet"
	damage = 20
	stamina = 65

/obj/item/projectile/bullet/c45_nostamina
	name = ".45 bullet"
	damage = 20

// 5.56mm (M-90gl Carbine)

/obj/item/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35

// 40mm (Grenade Launcher

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3)
	return TRUE

// .50 (Sniper)

/obj/item/projectile/bullet/p50
	name =".50 bullet"
	speed = 0		//360 alwaysscope.
	damage = 70
	knockdown = 100
	dismemberment = 50
	armour_penetration = 50
	var/breakthings = TRUE

/obj/item/projectile/bullet/p50/on_hit(atom/target, blocked = 0)
	if((blocked != 100) && (!ismob(target) && breakthings))
		target.ex_act(rand(1,2))
	return ..()

/obj/item/projectile/bullet/p50/soporific
	name =".50 soporific bullet"
	armour_penetration = 0
	nodamage = TRUE
	dismemberment = 0
	knockdown = 0
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
	forcedodge = TRUE
	dismemberment = 0 //It goes through you cleanly.
	knockdown = 0
	breakthings = FALSE

// 1.95x129mm (SAW)

/obj/item/projectile/bullet/mm195x129
	name = "1.95x129mm bullet"
	damage = 45
	armour_penetration = 5

/obj/item/projectile/bullet/mm195x129_ap
	name = "1.95x129mm armor-piercing bullet"
	damage = 40
	armour_penetration = 75

/obj/item/projectile/bullet/mm195x129_hp
	name = "1.95x129mm hollow-point bullet"
	damage = 60
	armour_penetration = -60

/obj/item/projectile/bullet/incendiary/mm195x129
	name = "1.95x129mm incendiary bullet"
	damage = 15
	fire_stacks = 3

// Shotgun

/obj/item/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	damage = 60

/obj/item/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	damage = 5
	stamina = 80

/obj/item/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	damage = 20

/obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 5

/obj/item/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	knockdown = 100
	stutter = 5
	jitter = 20
	range = 7
	icon_state = "spark"
	color = "#FFFF00"

/obj/item/projectile/bullet/shotgun_meteorslug
	name = "meteorslug"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 20
	knockdown = 80
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/shotgun_meteorslug/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovableatom(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/shotgun_meteorslug/Initialize()
	. = ..()
	SpinAnimation()

/obj/item/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	damage = 25
	knockdown = 50

/obj/item/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 1)
	return TRUE

/obj/item/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 12.5

/obj/item/projectile/bullet/pellet/shotgun_rubbershot
	damage = 3
	stamina = 25

/obj/item/projectile/bullet/pellet/shotgun_improvised
	damage = 6

/obj/item/projectile/bullet/pellet/shotgun_improvised/Initialize()
	. = ..()
	range = rand(1, 8)

/obj/item/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Scattershot

/obj/item/projectile/bullet/scattershot
	damage = 20
	stamina = 65

// LMD (exosuits)

/obj/item/projectile/bullet/lmg
	damage = 20

// Turrets

/obj/item/projectile/bullet/manned_turret
	damage = 20

/obj/item/projectile/bullet/syndicate_turret
	damage = 20

// FNX-99 (Mechs)

/obj/item/projectile/bullet/incendiary/fnx99
	damage = 20

// C3D (Borgs)

/obj/item/projectile/bullet/c3d
	damage = 20

// Honker

/obj/item/projectile/bullet/honker
	damage = 0
	knockdown = 60
	forcedodge = TRUE
	nodamage = TRUE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200

/obj/item/projectile/bullet/honker/New()
	..()
	SpinAnimation()

// Mime

/obj/item/projectile/bullet/mime
	damage = 20

/obj/item/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)

// Darts

/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/piercing = FALSE

/obj/item/projectile/bullet/dart/New()
	..()
	create_reagents(50)
	reagents.set_reacting(FALSE)

/obj/item/projectile/bullet/dart/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(null, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INJECT)
				reagents.trans_to(M, reagents.total_volume)
				return TRUE
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against \the [src]!</span>")

	..(target, blocked)
	reagents.set_reacting(TRUE)
	reagents.handle_reactions()
	return TRUE

/obj/item/projectile/bullet/dart/metalfoam/New()
	..()
	reagents.add_reagent("aluminium", 15)
	reagents.add_reagent("foaming_agent", 5)
	reagents.add_reagent("facid", 5)

//This one is for future syringe guns update
/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"

// DNA injector

/obj/item/projectile/bullet/dnainjector
	name = "\improper DNA injector"
	icon_state = "syringeproj"
	var/obj/item/dnainjector/injector
	damage = 5
	hitsound_wall = "shatter"

/obj/item/projectile/bullet/dnainjector/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100)
			if(M.can_inject(null, FALSE, def_zone, FALSE))
				if(injector.inject(M, firer))
					QDEL_NULL(injector)
					return TRUE
			else
				blocked = 100
				target.visible_message("<span class='danger'>\The [src] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against \the [src]!</span>")
	return ..()

/obj/item/projectile/bullet/dnainjector/Destroy()
	QDEL_NULL(injector)
	return ..()

