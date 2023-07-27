//Less exciting dog breeds

/mob/living/basic/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "They're a pug."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "pug"
	held_state = "pug"

/mob/living/basic/pet/dog/pug/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PUG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/pet/dog/pug/mcgriff
	name = "McGriff"
	real_name = "McGriff"
	desc = "This dog can tell something smells around here, and that something is CRIME!"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "They're a bull terrier."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "bullterrier"
	held_state = "bullterrier"

/mob/living/basic/pet/dog/breaddog //Most of the code originates from Cak
	name = "Kobun"
	real_name = "Kobun"
	desc = "It is a dog made out of bread. 'The universe is definitely half full'."
	icon_state = "breaddog"
	icon_living = "breaddog"
	icon_dead = "breaddog_dead"
	head_icon = 'icons/mob/clothing/head/pets_head.dmi'
	health = 50
	maxHealth = 50
	gender = NEUTER
	damage_coeff = list(BRUTE = 3, BURN = 3, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	butcher_results = list(/obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1, /obj/item/food/breadslice/plain = 3,  \
	/obj/item/food/meat/slab = 2)
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	held_state = "breaddog"
	worn_slot_flags = ITEM_SLOT_HEAD

/mob/living/basic/pet/dog/breaddog/CheckParts(list/parts)
	. = ..()
	var/obj/item/organ/internal/brain/candidate = locate(/obj/item/organ/internal/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "[span_boldbig("You are a bread dog!")]<b> You're a harmless dog/bread hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free bread to the station!	'I’m not alone, and you aren’t either'</b>")
	var/default_name = "Kobun"
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "You are the [name]. Would you like to change your name to something else?", "Name change", default_name, MAX_NAME_LEN)), cap_after_symbols = FALSE)
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>[new_name]</b>!"))
		name = new_name
		real_name = new_name

/mob/living/basic/pet/dog/breaddog/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(stat)
		return

	if(health < maxHealth)
		adjustBruteLoss(-4 * seconds_per_tick) //Fast life regen

	for(var/mob/living/carbon/humanoid_entities in view(3, src)) //Mood aura which stay as long you do not wear Sanallite as hat or carry(I will try to make it work with hat someday(obviously weaker than normal one))
		humanoid_entities.add_mood_event("kobun", /datum/mood_event/kobun)

/mob/living/basic/pet/dog/breaddog/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
