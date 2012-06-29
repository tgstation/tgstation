/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

	glowstr = 3
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.7

/obj/item/projectile/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

	glowstr = 3
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.7

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40

	glowstr = 4
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.8

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30

	glowstr = 3
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.7
	sd_ColorRed = 0.1

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50

	glowstr = 4
	sd_ColorBlue = 0.9
	sd_ColorGreen = 0.2
	sd_ColorRed = 0.1

/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

	glowstr = 4
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.8

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"

	glowstr = 4
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.7
	sd_ColorRed = 0.2

/obj/item/projectile/bluetag
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	glowstr = 3
	sd_ColorBlue = 0.7
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.1

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/redtag
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	glowstr = 3
	sd_ColorBlue = 0.1
	sd_ColorGreen = 0.1
	sd_ColorRed = 0.7

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1

/obj/item/projectile/omnitag//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	glowstr = 3
	sd_ColorBlue = 0.9
	sd_ColorGreen = 0.3
	sd_ColorRed = 0.1

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
				M.Weaken(5)
		return 1