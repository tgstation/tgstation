/mob/living/basic/pet/dog
	attack_verb_continuous = "вгрызается"
	attack_verb_simple = "кусает"
	death_sound = 'modular_bandastation/mobs/sound/dog_yelp.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/dog_yelp.ogg')
	var/list/growl_sounds = list('modular_bandastation/mobs/sound/dog_grawl1.ogg','modular_bandastation/mobs/sound/dog_grawl2.ogg') //Used in emote.

	butcher_results = list(/obj/item/food/meat/slab/corgi/dog = 4)

/mob/living/basic/pet/dog/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		wuv(-1, user)
	else
		wuv(1, user)

/mob/living/basic/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the corgi) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				manual_emote("счастливо скулит!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("growl")
				playsound(src, pick(src.growl_sounds), 75, TRUE)

/mob/living/basic/pet/dog/corgi/narsie
	maxHealth = 300
	health = 300
	melee_damage_type = STAMINA	//Пади ниц!
	melee_damage_lower = 50
	melee_damage_upper = 100

/mob/living/basic/pet/dog/corgi/puppy
	butcher_results = list(/obj/item/food/meat/slab/corgi = 1)

/mob/living/basic/pet/dog/corgi/puppy/void
	maxHealth = 80
	health = 80

/mob/living/basic/pet/dog/corgi/puppy/slime
	name = "слизнёк"
	real_name = "слизи"
	desc = "Крайне склизкий. Но прикольный!"
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	habitable_atmos = null
	minimum_survivable_temperature = 250 //Weak to cold
	maximum_survivable_temperature = INFINITY

	held_state = "slime_puppy"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/pet/dog/tamaskan
	name = "тамаскан"
	real_name = "тамаскан"
	desc = "Хорошая семейная собака. Уживается с другими собаками и ассистентами."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "tamaskan"
	icon_living = "tamaskan"
	icon_dead = "tamaskan_dead"
	held_state = "bullterrier"

/mob/living/basic/pet/dog/german
	name = "овчарка"
	real_name = "овчарка"
	desc = "Немецкая овчарка с помесью двортерьера. Судя по крупу - явно не породистый."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "german"
	icon_living = "german"
	icon_dead = "german_dead"
	held_state = "bullterrier"

/mob/living/basic/pet/dog/brittany
	name = "брит"
	real_name = "брит"
	desc = "Старая порода, которую любят аристократы."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "brittany"
	icon_living = "brittany"
	icon_dead = "brittany_dead"
	held_state = "bullterrier"
