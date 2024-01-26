/mob/living/basic/mothroach/void
	name = "void mothroach"
	desc = "A mothroach from the stars!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_mothroach"
	icon_living = "void_mothroach"
	icon_dead = "void_mothroach_dead"
	held_state = "void_mothroach"
	held_lh = 'monkestation/code/modules/donator/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/code/modules/donator/icons/mob/pets_held_rh.dmi'
	head_icon = 'monkestation/code/modules/donator/icons/mob/pets_held.dmi'
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/spycrab
	name = "spy crab"
	desc = "hon hon hon"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/spycrab/Initialize(mapload)
	. = ..()
	var/random_icon = pick("crab_red","crab_blue")
	icon_state = random_icon
	icon_living = random_icon
	icon_dead = "[random_icon]_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/blahaj
	name = "\improper Blåhaj"
	desc = "The blue shark can swim very far, dive really deep and hear noises from almost 250 meters away."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "blahaj"
	icon_living = "blahaj"
	icon_dead = "blahaj_dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/

/mob/living/basic/pet/cirno  //nobody needs to know she's a lizard
	name = "Cirno"
	desc = "She is the greatest."
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "cirno-happy"
	icon_living = "cirno-happy"
	icon_dead = "cirno-happy"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/
	basic_mob_flags = FLIP_ON_DEATH

/mob/living/basic/lizard/snake
	name = "Three Headed Snake"
	desc = "This little fella looks familiar..."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "triple_snake"
	icon_living = "triple_snake"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/dog/germanshepherd
	name = "German Shepherd"
	desc = "He's so cool, he's got sunglasses!!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "germanshepherd"
	icon_living = "germanshepherd"
	icon_dead = "germanshepherd_dead"
	icon_gib = null
	can_be_held = FALSE // as funny as this would be, a german shepherd is way too big to carry with one hand
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/slime/talkative
	name = "Extroverted Slime"
	desc = "He's got a lot to say!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "slime"
	icon_living = "slime"
	icon_dead = "slime_dead"
	gold_core_spawnable = NO_SPAWN
	initial_language_holder = /datum/language_holder/slime
	ai_controller = /datum/ai_controller/basic_controller/
	var/quips = list("Your fingers taste like Donk Pockets, get out more.",
					"I've seen salad that dresses better than you.",
					"I smell smoke, are you thinking too hard again?",
					"This one's gene pool needs more chlorine...",
					"I expected nothing and yet I'm still disappointed.",
					"Why is this walking participation trophy touching me?",
					"If I throw a stick, will you leave?",)
	var/positive_quips = list("Hey there, slime pal!",
								"Aw thanks buddy!",)

/mob/living/basic/pet/slime/talkative/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user == src || src.stat != CONSCIOUS || (user.istate & ISTATE_HARM) || LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	new /obj/effect/temp_visual/heart(src.loc)
	if(prob(33))
		if(isslimeperson(user) || isoozeling(user))
			src.say(pick(positive_quips))
		else
			src.say(pick(quips))


/mob/living/basic/pet/spider/dancing
	name = "Dancin' Spider"
	desc = "Look at him go!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "spider"
	icon_living = "spider"
	icon_dead = "spider_dead"
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/

/mob/living/basic/butterfly/void
	name = "Void Butterfly"
	desc = "They say if a void butterfly flaps its wings..."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_butterfly"
	icon_living = "void_butterfly"
	icon_dead = "void_butterfly_dead"
	gold_core_spawnable = NO_SPAWN
	health = 20
	maxHealth = 20

/mob/living/basic/butterfly/void/spacial
	fixed_color = TRUE
