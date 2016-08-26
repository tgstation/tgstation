/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	luminosity = 1
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer
	impact_type = /obj/effect/overlay/temp/projectile/impact

/obj/item/projectile/beam/laser

/obj/item/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle/heavy
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer/heavy
	impact_type = /obj/effect/overlay/temp/projectile/impact/heavy

/obj/item/projectile/beam/laser/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.IgniteMob()

/obj/item/projectile/beam/weak
	damage = 15
	armour_penetration = 50

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = 1

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 30
	range = 15
	forcedodge = 1
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle/xray
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer/xray
	impact_type = /obj/effect/overlay/temp/projectile/impact/xray

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 36
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle/disable
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer/disable
	impact_type = /obj/effect/overlay/temp/projectile/impact/disable

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	luminosity = 2
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle/pulse
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer/pulse
	impact_type = /obj/effect/overlay/temp/projectile/impact/pulse

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = 0)
	. = ..()
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)

/obj/item/projectile/beam/pulse/shot
	damage = 40

/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/item/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = 0, hit_zone)
	life -= 10
	if(life > 0)
		. = -1
	..()

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	legacy = 1
	luminosity = 2
	animate_movement = SLIDE_STEPS

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/emitter/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL

/obj/item/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/item/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)

/obj/item/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	muzzle_type = /obj/effect/overlay/temp/projectile/muzzle/blue
	tracer_type	= /obj/effect/overlay/temp/projectile/tracer/blue
	impact_type = /obj/effect/overlay/temp/projectile/impact/blue

/obj/item/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN

/obj/item/projectile/beam/instakill/blue
	icon_state = "blue_laser"

/obj/item/projectile/beam/instakill/red
	icon_state = "red_laser"

/obj/item/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message("<span class='danger'>[M] explodes into a shower of gibs!</span>")
		M.gib()