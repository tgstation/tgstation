/mob/living/basic/pet/cat
	death_sound = 'modular_bandastation/mobs/sound/cat_meow.ogg'
	damaged_sounds = list('modular_bandastation/mobs/sound/cat_meow.ogg')
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/pet/cat/fat
	name = "толстокот"
	desc = "Упитан. Счастлив. В своей тарелке."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "iriska"
	icon_living = "iriska"
	icon_dead = "iriska_dead"
	gender = FEMALE
	mob_size = MOB_SIZE_LARGE // THICK!!!
	//canmove = FALSE
	butcher_results = list(/obj/item/food/meat = 8)
	maxHealth = 40 // Sooooo faaaat...
	health = 40
	speed = 20 // TOO FAT
	resting = TRUE

/obj/item/mmi/posibrain/sphere/relaymove(mob/living/user, direction)
	return	// LAZY

/mob/living/basic/pet/cat/white
	name = "белый кот"
	desc = "Белоснежная шерстка. Плохо различается на белой плитке, зато отлично виден в темноте!"
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "penny"
	icon_living = "penny"
	icon_dead = "penny_dead"
	gender = MALE

	held_state = "crusher"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/pet/cat/birman
	name = "кот бирма"
	real_name = "кот бирма"
	desc = "Священная порода Бирма."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "crusher"
	icon_living = "crusher"
	icon_dead = "crusher_dead"
	gender = MALE

	held_state = "crusher"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'


/mob/living/basic/pet/cat/black
	name = "черный кот"
	real_name = "черный кот"
	desc = "Он ужас летящий на крыльях ночи! Он - тыгыдык и спотыкание во тьме ночной! Бойся не заметить черного кота в тени!"
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "salem"
	icon_living = "salem"
	icon_dead = "salem_dead"
	gender = MALE

	held_state = "black_cat"
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/pet/cat/space/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
