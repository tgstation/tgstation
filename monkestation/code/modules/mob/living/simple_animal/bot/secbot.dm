/mob/living/simple_animal/bot/secbot/pizzky
	name = "\improper Shitcuritron"
	desc = "he smells like garbage"
	icon = 'monkestation/icons/mob/aibots.dmi'
	icon_state = "secbot"
	chasesounds = list('monkestation/sound/voice/pizzky/criminal.ogg','monkestation/sound/voice/pizzky/freeze.ogg','monkestation/sound/voice/pizzky/justice.ogg')
	arrestsounds = "pizzky"
	auto_patrol = TRUE
	verb_whisper = "grumbles"
	var/last_grumble_speak = 0

/mob/living/simple_animal/bot/secbot/pizzky/bot_patrol()
	..()
	if((last_grumble_speak + 100 SECONDS) < world.time) //these messages should be fairly rare
		var/list/messagevoice = list("I can't take it anymore I'm gonna beat the fucking piss out of the clown.\
									  I'm gonna beat him within an inch of his fucking life.  I fucking hate that \
									  honking bitch." = 'monkestation/sound/voice/pizzky/mumble1.ogg',
									"If I had a mouth I think I'd really like apple juice boxes.  I really wish the \
									vending machines had apple juice boxes." = 'monkestation/sound/voice/pizzky/mumble2.ogg',
									"Holy crap do not get hired for nanotrasen security, worst mistake I have ever \
									 made." = 'monkestation/sound/voice/pizzky/mumble3.ogg',
									 "I swear to got these vending machines give people botulism.  I don't know how these \
									 people keep walking around." = 'monkestation/sound/voice/pizzky/mumble4.ogg')
		var/message = pick(messagevoice)
		whisper(message)
		playsound(src, messagevoice[message], 40, 0) //and pretty quiet
		last_grumble_speak = world.time

/mob/living/simple_animal/bot/secbot/pizzky/Initialize(mapload)
	. = ..()
	last_grumble_speak = world.time //so he doesn't grumble on spawn
	var/list/messagevoice = list("I AM NOW ALIVE AND I'M ABOUT TO MAKE IT EVERYONE ELSE'S PROBLEM!" = 'monkestation/sound/voice/pizzky/spawn1.ogg',
								 "WHY THE FUCK WOULD YOU BUILD THIS? WHAT THE FUCK IS WRONG WITH YOU?!" = 'monkestation/sound/voice/pizzky/spawn2.ogg')
	var/message = pick(messagevoice)
	say(message)
	playsound(src,messagevoice[message], 100, 0)

/mob/living/simple_animal/bot/secbot/pizzky/explode()
	var/atom/Tsec = drop_location()
	new /obj/item/food/pizzaslice/meat(Tsec)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/S = new(Tsec)
	S.reagents.add_reagent(/datum/reagent/consumable/ethanol/moonshine, 15)
	S.on_reagent_change(ADD_REAGENT)
	..()
