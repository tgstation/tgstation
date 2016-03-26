/mob/living/simple_animal/hostile/humanoid/grey
	name = "grey"
	desc = "A thin alien humanoid. This one seems to be feral."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey"

	corpse = /obj/effect/landmark/corpse/grey

/mob/living/simple_animal/hostile/humanoid/grey/space
	desc = "A thin alien humanoid in a space suit."

	icon_state = "grey_space"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	corpse = /obj/effect/landmark/corpse/grey/space

/obj/effect/landmark/corpse/grey
	name = "grey"
	mutantrace = "Grey"

/obj/effect/landmark/corpse/grey/space
	corpsemask = /obj/item/clothing/mask/breath
	corpsegloves = /obj/item/clothing/gloves/grey
	corpsesuit = /obj/item/clothing/suit/space/grey
	corpseuniform = /obj/item/clothing/under/color/grey
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/tank/oxygen
	corpsehelmet = /obj/item/clothing/head/helmet/space/grey
