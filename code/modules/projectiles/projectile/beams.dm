/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 32
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	flag = "laser"
	eyeblur = 2
	var/ignite_chance = 75

/obj/item/projectile/beam/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(ignite_chance)
			if(prob(ignite_chance))
				M.adjust_fire_stacks(4)
				M.IgniteMob()

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = 1

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5


/obj/item/projectile/beam/egun
	name = "laser"
	damage = 25
	ignite_chance = 25

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	ignite_chance = 100
	damage = 58

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 28
	irradiate = 40
	range = 15
	forcedodge = 1

/obj/item/projectile/beam/scatter_xray
	name = "scatter xray beam"
	icon_state = "xray"
	damage = 12
	irradiate = 20
	range = 15
	forcedodge = 1

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 36
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = 0)
	. = ..()
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)

/obj/item/projectile/beam/pulse/shot
	damage = 40

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

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