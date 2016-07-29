/mob/living/simple_animal/hostile/humanoid/vox
	name = "vox"
	desc = "A bird-like creature. This one is feral."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "vox"

	min_oxy = 0
	max_oxy = 1
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 5 //breathe N2
	max_n2 = 0

	corpse = /obj/effect/landmark/corpse/vox

/////////VOX SHARPSHOOTERS
//Armed with crossbows

/mob/living/simple_animal/hostile/humanoid/vox/crossbow
	name = "vox sharpshooter"
	desc = "A raider with ranged combat training and a crossbow."
	icon_state = "sharpshooter"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

	ranged_cooldown_cap = 9

	corpse = /obj/effect/landmark/corpse/vox/crossbow
	items_to_drop = list(/obj/item/weapon/crossbow, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill)

/mob/living/simple_animal/hostile/humanoid/vox/crossbow/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return
	if(!istype(target, /turf))
		return

	var/obj/item/weapon/arrow/A = new /obj/item/weapon/arrow/quill(get_turf(src))

	A.throw_at(target,10,25)

	return

/mob/living/simple_animal/hostile/humanoid/vox/crossbow/spacesuit
	desc = "A raider with ranged combat training, crossbow and a spacesuit to survive in an environment without N2."
	icon_state = "sharpshooter_space"

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0

	corpse = /obj/effect/landmark/corpse/vox/crossbow/space

///////VOX CYBER OPERATORS
//Armed with ion guns

/mob/living/simple_animal/hostile/humanoid/vox/ion
	name = "vox cyber operator"
	desc = "A raider equipped with an ion gun, to take down cyborgs and mechs."
	icon_state = "ion"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/ion
	projectilesound = 'sound/weapons/ion.ogg'
	ranged_cooldown_cap = 4

	items_to_drop = list(/obj/item/weapon/gun/energy/ionrifle)

	corpse = /obj/effect/landmark/corpse/vox/ion

/mob/living/simple_animal/hostile/humanoid/vox/ion/spacesuit
	desc = "A raider equipped with an ion gun and a spacesuit to survive in an environment without N2."
	icon_state = "ion_space"

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0

	corpse = /obj/effect/landmark/corpse/vox/ion/space

/obj/effect/landmark/corpse/vox
	name = "vox"
	mutantrace = "Vox"

/obj/effect/landmark/corpse/vox/crossbow
	name = "vox sharpshooter"
	corpseuniform = /obj/item/clothing/under/vox/vox_casual
	corpseshoes = /obj/item/clothing/shoes/magboots/vox

/obj/effect/landmark/corpse/vox/crossbow/space
	corpsesuit = /obj/item/clothing/suit/space/vox/pressure
	corpsemask = /obj/item/clothing/mask/breath/vox
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/pressure

/obj/effect/landmark/corpse/vox/ion
	name = "vox cyber operator"
	corpseuniform = /obj/item/clothing/under/rank/roboticist
	corpseshoes = /obj/item/clothing/shoes/magboots/vox
	corpseglasses = /obj/item/clothing/glasses/scanner/meson

/obj/effect/landmark/corpse/vox/ion/space
	corpsesuit = /obj/item/clothing/suit/space/vox/pressure
	corpsemask = /obj/item/clothing/mask/breath/vox
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/pressure