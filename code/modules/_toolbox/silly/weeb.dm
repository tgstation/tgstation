/mob/living/simple_animal/hostile/weeaboo
	name = "Weeaboo"
	icon = 'icons/mob/human.dmi'
	icon_state = "caucasian_m"
	icon_dead = ""
	icon_living = "caucasian_m"
	maxHealth = 100
	health = 100
	melee_damage_lower = 10
	melee_damage_type = "brute"
	melee_damage_upper = 10
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = "slashes"
	gold_core_spawnable = 1
	var/clothingcolor = null
	var/list/colors = list(
		"blue" = /obj/item/clothing/under/schoolgirl,
		"red" = /obj/item/clothing/under/schoolgirl/red,
		"orange" = /obj/item/clothing/under/schoolgirl/orange,
		"green" = /obj/item/clothing/under/schoolgirl/green)
	var/hair_style = "Long Over Eye"
	var/hair_color = "000"
	var/facial_hair_style = "Neckbeard"
	var/facial_hair_color = "000"
	var/theskin_tone = "caucasian1"

/mob/living/simple_animal/hostile/weeaboo/Initialize()
	. = ..()
	var/datum/sprite_accessory/hair/hair = GLOB.hair_styles_list[hair_style]
	var/datum/sprite_accessory/facial_hair/facial_hair = GLOB.facial_hair_styles_list[facial_hair_style]
	var/image/I
	var/list/overlayslist = list()
	I = new()
	I.icon = hair.icon
	I.icon_state = hair.icon_state
	I.color = "#[hair_color]"
	I.layer = 4.4
	overlayslist += I
	I = new()
	I.icon = facial_hair.icon
	I.icon_state = facial_hair.icon_state
	I.color = "#[facial_hair_color]"
	I.layer = 4.4
	overlayslist += I
	var/list/bodyparts = list(
	"human_r_arm" = 4.2,
	"human_l_arm" = 4.2,
	"human_r_hand" = 4.2,
	"human_l_hand" = 4.2,
	"human_r_leg" = 4.2,
	"human_l_leg" = 4.2,
	"human_head_m" = 4.1,
	"human_chest_m" = 4.0)
	for(var/text in bodyparts)
		I = new()
		I.icon = 'icons/mob/human_parts_greyscale.dmi'
		I.icon_state = text
		I.color = "#[theskin_tone && skintone2hex(theskin_tone)]"
		I.layer = bodyparts[text]
		overlayslist += I
	if(!(clothingcolor in colors))
		clothingcolor = pick(colors)
	var/uniformcolor = ""
	if(clothingcolor != "blue")
		uniformcolor = clothingcolor
	I = new()
	I.icon = 'icons/mob/uniform.dmi'
	I.icon_state = "schoolgirl[uniformcolor]"
	I.layer = 4.3
	overlayslist += I
	I = new()
	I.icon = 'icons/mob/feet.dmi'
	I.icon_state = "black"
	I.layer = 4.3
	overlayslist += I
	add_overlay(overlayslist)
	I = new()
	I.icon = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	I.icon_state = "katana"
	I.layer = 4.4
	overlayslist += I
	add_overlay(overlayslist)

/mob/living/simple_animal/hostile/weeaboo/death()
	. = ..()
	var/mob/living/carbon/human/H = new(loc)
	H.name = name
	H.real_name = name
	H.hair_style = hair_style
	H.hair_color = hair_color
	H.facial_hair_style = facial_hair_style
	H.facial_hair_color = facial_hair_color
	H.skin_tone = theskin_tone
	if(!(clothingcolor in colors))
		clothingcolor = pick(colors)
	var/uniformpath = colors[clothingcolor]
	H.equip_to_slot_or_del(new uniformpath(), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(), slot_shoes)
	H.regenerate_icons()
	new /obj/item/toy/katana(loc)
	H.death()
	qdel(src)

/mob/living/simple_animal/hostile/weeaboo/blue
	clothingcolor = "blue"
/mob/living/simple_animal/hostile/weeaboo/red
	clothingcolor = "red"
/mob/living/simple_animal/hostile/weeaboo/orange
	clothingcolor = "orange"
/mob/living/simple_animal/hostile/weeaboo/green
	clothingcolor = "green"