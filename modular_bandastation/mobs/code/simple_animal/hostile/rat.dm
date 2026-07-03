/mob/living/basic/mouse/rat
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	squeak_sound = 'modular_bandastation/mobs/sound/rat_squeak.ogg'
	icon_state = "rat_gray"
	icon_living = "rat_gray"
	icon_dead = "rat_gray_dead"
	icon_resting = "rat_gray_sleep"
	maxHealth = 15
	health = 15
	mob_size = MOB_SIZE_SMALL
	body_icon_state = "rat"
	body_color = null
	possible_body_colors = list("white", "gray", "irish")

	// holder
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_EARS
	held_lh = 'modular_bandastation/mobs/icons/inhands/mobs_lefthand.dmi'
	held_rh = 'modular_bandastation/mobs/icons/inhands/mobs_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'

/mob/living/basic/mouse/rat/Initialize(mapload)
	. = ..()
	switch(body_color)
		if("white")
			desc = /mob/living/basic/mouse/rat/white::desc
		if("irish")
			desc = /mob/living/basic/mouse/rat/irish::desc
		else
			desc = /mob/living/basic/mouse/rat::desc

/mob/living/basic/mouse/rat/gray
	name = "серая крыса"
	real_name = "серая крыса"
	desc = "Не яркий представитель своего вида."
	body_color = "gray"

/mob/living/basic/mouse/rat/white
	name = "белая крыса"
	real_name = "белая крыса"
	desc = "Типичный представитель лабораторных крыс."
	icon_state = "rat_white"
	icon_living = "rat_white"
	icon_dead = "rat_white_dead"
	icon_resting = "rat_white_sleep"
	body_color = "white"

/mob/living/basic/mouse/rat/irish
	name = "ирландский крыс"
	real_name = "ирландский крыс"
	desc = "Ирландская крыса, борец за независимость. На космической станции?! На этот раз им точно некуда бежать!"
	icon_state = "rat_irish"
	icon_living = "rat_irish"
	icon_dead = "rat_irish_dead"
	icon_resting = "rat_irish_sleep"
	body_color = "irish"
