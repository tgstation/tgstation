/mob/living/basic/frog
	speak_emote = list("квак","куак","квуак")

	damaged_sounds = list('modular_bandastation/mobs/sound/frog_damaged.ogg')
	death_sound = 'modular_bandastation/mobs/sound/frog_death.ogg'

	attack_sound = 'modular_bandastation/mobs/sound/frog_scream_1.ogg'
	stepped_sound = 'modular_bandastation/mobs/sound/frog_scream_2.ogg'

/mob/living/basic/frog/rare/toxic
	name = "яркая лягушка"
	desc = "Уникальная токсичная раскраска. Лучше не трогать голыми руками."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	icon_resting = "rare_frog"
	melee_damage_type = TOX
	melee_damage_lower = 1
	melee_damage_upper = 3

	poison_per_bite = 5

	gold_core_spawnable = HOSTILE_SPAWN
	stepped_sound = 'modular_bandastation/mobs/sound/frog_scream_3.ogg'

/mob/living/basic/frog/scream
	name = "орущая лягушка"
	real_name = "орущая лягушка"
	desc = "Не любит когда на неё наступают. Используется в качестве наказания за проступки"
	attack_sound = 'sound/mobs/non-humanoids/frog/reee.ogg'
	stepped_sound = 'sound/mobs/non-humanoids/frog/huuu.ogg'
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/rare/toxic/scream
	attack_sound = 'sound/mobs/non-humanoids/frog/reee.ogg'
	stepped_sound = 'sound/mobs/non-humanoids/frog/huuu.ogg'
	gold_core_spawnable = NO_SPAWN

// Toxic frog procs
/mob/living/basic/frog/rare/toxic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(ishuman(user))
		if(!istype(user.gloves, /obj/item/clothing/gloves))
			var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
			if(!IS_ROBOTIC_LIMB(active_arm))
				to_chat(user, span_warning("Дотронувшись до [src.name], ваша кожа начинает чесаться!"))
				toxin_affect(user)
	. = ..()

/mob/living/basic/frog/rare/toxic/on_entered(datum/source, entered as mob|obj)
	. = ..()
	if(stat || !ishuman(entered))
		return
	var/mob/living/carbon/human/H = entered
	if(istype(H.shoes, /obj/item/clothing/shoes))
		return
	var/obj/item/bodypart/leg/left = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/leg/right = H.get_bodypart(BODY_ZONE_R_LEG)
	if(!IS_ROBOTIC_LIMB(left))
		toxin_affect(H)
		to_chat(H, span_warning("Ваши ступни начинают чесаться!"))
		return
	if(!IS_ROBOTIC_LIMB(right))
		toxin_affect(H)
		to_chat(H, span_warning("Ваши ступни начинают чесаться!"))
		return

/mob/living/basic/frog/rare/toxic/proc/toxin_affect(mob/living/carbon/human/M as mob)
	if(M.reagents && !poison_per_bite == 0)
		M.reagents.add_reagent(poison_type, poison_per_bite)
