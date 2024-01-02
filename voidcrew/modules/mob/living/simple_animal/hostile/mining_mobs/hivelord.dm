/mob/living/simple_animal/hostile/asteroid/hivelord/legion/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/simple_animal/hostile/big_legion/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/simple_animal/hostile/asteroid/hivelord/legion/crystal/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/simple_animal/hostile/asteroid/hivelord/beach
	name = "crystal hivelord"
	icon = 'voidcrew/icons/mob/beach/beach_hivelord.dmi'
	icon_state = "hivelord"
	icon_living = "hivelord"
	icon_dead = "hivelord_dead"
	icon_gib = "syndicate_gib"
	brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/beach
	faction = list(FACTION_BEACH, FACTION_CRYSTAL)
	//loot = list(/obj/item/strange_crystal)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/beach
	icon = 'voidcrew/icons/mob/beach/beach_hivelord.dmi'
	icon_state = "hivelord_tentacle"
	icon_living = "hivelord_tentacle"
	icon_aggro = "hivelord_tentacle"
	icon_dead = "hivelord_tentacle"
	icon_gib = "syndicate_gib"
	pixel_x = 6
	color = COLOR_BRIGHT_BLUE
	faction = list(FACTION_BEACH, FACTION_CRYSTAL)
