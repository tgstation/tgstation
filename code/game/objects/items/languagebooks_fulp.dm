/obj/item/book/granter/language
var/language_name = "error"
var/language = /datum/language

/obj/item/book/granter/language/already_known(mob/user)
	if(!user.has_language(language))
		return TRUE
	else
		to_chat(user, "You can already speak fluent [language_name]!")
		return FALSE

/obj/item/book/granter/language/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>You start leafing through the language book...</span>")

/obj/item/book/granter/l/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>You feel you've learned enough to understand [language_name]!</span>")
	user.grant_language(language)
	user.log_message("learned the language [language_name] ([language])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/spell/recoil(mob/user)
	to_chat(user, "<span class='notice'>The words on the pages fade and vanish!/span>")

/obj/item/book/granter/spell/onlearned(mob/user)
	..()
	if(oneuse)
		to_chat(user, "<span class='notice'>All the pages are blank, how useless!/span>")

/obj/item/book/granter/language/common
	name = "Ashwalker's Guide To The Galaxy"
	desc = "This missionary tome intended to teach Ashwalkers to speak Galactic Common has fallen into widespread use across the galaxy."
	language = /datum/language/common

/obj/item/book/granter/language/aphasia
	name = "12 Rules for Life"
	desc = "A forgotten tome from ancient earth history. Even the cover gives you a headache."
	language = /datum/language/aphasia

/obj/item/book/granter/language/beachbum
	name = "DUDE Magazine"
	desc = "This gnarly pile of papers will give you the raddest insights into modern youth culture! Tubular!"
	language = /datum/language/beachbum

/obj/item/book/granter/language/drone
	name = "Binary 101"
	desc = "...or How I Stopped Worrying and Learned to Love the Hats."
	language = /datum/language/drone

/obj/item/book/granter/language/narsian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Nar'Sian, without being a cultist! The pages are stained with blood, proving its authenticity!"
	language = /datum/language/narsie

/obj/item/book/granter/language/ratvarian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Ratvarian, without being a cultist! The entire tome is making an unsettling ticking noise."
	language = /datum/language/ratvar

/obj/item/book/granter/language/piratespeak
	name = "To Hornswagle a Bilgerat"
	desc = "A longwinded and dull nautical romance novel featuring an alarming amount of sailing jargon. Piratical tripe."
	language = /datum/language/piratespeak

/obj/item/book/granter/language/monkey
	name = "A Book Made Out of a Monkey"
	desc = "Oh wow now that's just gross. It's still moving slightly."
	language = /datum/language/piratespeak

/obj/item/book/granter/language/mushroom
	name = "'A Fun Guide to Mushrooms' by Mike O'Phile"
	desc = "All the puns in this book dont leave mushroom to spore."
	language = /datum/language/piratespeak
