/mob/living/basic
	response_help_continuous = "тычет"
	response_help_simple = "тычет"
	response_disarm_continuous = "толкает"
	response_disarm_simple = "толкает"
	response_harm_continuous = "пихает"
	response_harm_simple   = "пихает"

	attack_verb_continuous = "атакует"
	attack_verb_simple = "атакует"
	friendly_verb_continuous = "тычет"
	friendly_verb_simple = "тычет"

	attack_sound = null
	var/list/damaged_sounds = null // The sound played when player hits animal

/mob/living/basic/attacked_by(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

/mob/living/basic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

/mob/living/basic/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

/mob/living/basic/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

/mob/living/basic/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

/mob/living/basic/attack_robot(mob/living/user)
	. = ..()
	if(. && length(src.damaged_sounds) && src.stat != DEAD)
		playsound(src, pick(src.damaged_sounds), 40, 1)

// Animals additions

/* Megafauna */
/mob/living/simple_animal/hostile/megafauna/legion/death()
	. = ..()
	if(last_legion)
		death_sound = 'modular_bandastation/mobs/sound/legion_death.ogg'
		for(var/area/lavaland/L in typesof(/area/lavaland))
			SEND_SOUND(L, sound('modular_bandastation/mobs/sound/legion_death_far.ogg'))

/* Nar Sie */
/obj/narsie/Initialize(mapload)
	. = ..()
	SEND_SOUND(world, sound('modular_bandastation/mobs/sound/narsie_rises.ogg'))

/* ===== На случай если появится блюспейс сканер =====
/* Loot Drops */
/obj/effect/spawner/random/bluespace_tap/organic/Initialize(mapload)
	. = ..()
	LAZYADD(loot, list(
		//mob/living/basic/pet/dog/corgi = 5,

		/mob/living/basic/pet/dog/brittany = 2,
		/mob/living/basic/pet/dog/german = 2,
		/mob/living/basic/pet/dog/tamaskan = 2,
		/mob/living/basic/pet/dog/bullterrier = 2,

		//mob/living/basic/pet/cat = 5,

		/mob/living/basic/pet/cat/cak = 2,
		/mob/living/basic/pet/cat/fat = 2,
		/mob/living/basic/pet/cat/white = 2,
		/mob/living/basic/pet/cat/birman = 2,
		/mob/living/basic/pet/cat/spacecat = 2,

		//mob/living/basic/pet/fox = 5,

		/mob/living/basic/pet/fox/forest = 2,
		/mob/living/basic/pet/fox/fennec = 2,
		/mob/living/basic/possum = 2,

		/mob/living/basic/pet/penguin = 5,
		//mob/living/basic/pig = 5,
		))

*/
