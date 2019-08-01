/obj/item/book/granter/language_book
var/language_name = "error"
var/learnable_language = "error"

/obj/item/book/granter/language/already_known(mob/user)
	if(!user.has_language(learnable_language))
		return TRUE
	else
		to_chat(user, "You can already speak fluent [language_name]!")
		return FALSE

/obj/item/book/granter/language_book/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>You start leafing through the language book...</span>")

/obj/item/book/granter/language_book/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>You feel you've learned enough to understand [language_name]!</span>")
	user.grant_language(learnable_language)
	user.log_message("learned the language [language_name] ([learnable_language])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/language_book/recoil(mob/user)
	to_chat(user, "<span class='notice'>The words on the pages fade and vanish!/span>")

/obj/item/book/granter/language_book/onlearned(mob/user)
	..()
	if(oneuse)
		to_chat(user, "<span class='notice'>All the pages are blank, how useless!/span>")

/obj/item/book/granter/language_book/common
	name = "Ashwalker's Guide To The Galaxy"
	desc = "This missionary tome intended to teach Ashwalkers to speak Galactic Common has fallen into widespread use across the galaxy."
	learnable_language = /datum/language/common
	remarks = list("Dead-stick stability...", "Symmetry seems to play a rather large factor...", "Accounting for crosswinds... really?", "Drag coefficients of various paper types...", "Thrust to weight ratios?", "Positive dihedral angle?", "Center of gravity forward of the center of lift...")


/obj/item/book/granter/language_book/aphasia
	name = "Maps of Meaning"
	desc = "A forgotten tome from ancient earth history. Even the cover gives you a headache."
	learnable_language = /datum/language/aphasia

/obj/item/book/granter/language_book/beachbum
	name = "DUDE Magazine"
	desc = "This gnarly pile of papers will give you the raddest insights into modern youth culture! Tubular!"
	learnable_language = /datum/language/beachbum

/obj/item/book/granter/language_book/drone
	name = "Binary 101"
	desc = "...or How I Stopped Worrying and Learned to Love the Hats."
	learnable_language = /datum/language/drone

/obj/item/book/granter/language_book/narsian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Nar'Sian, without being a cultist! The pages are stained with blood, proving its authenticity!"
	learnable_language = /datum/language/narsie

/obj/item/book/granter/language_book/ratvarian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Ratvarian, without being a cultist! The entire tome is making an unsettling ticking noise."
	learnable_language = /datum/language/ratvar

/obj/item/book/granter/language_book/piratespeak
	name = "To Hornswagle a Bilgerat"
	desc = "A longwinded and dull nautical romance novel featuring an alarming amount of sailing jargon. Piratical tripe."
	learnable_language = /datum/language/piratespeak

/obj/item/book/granter/language_book/monkey
	name = "A Book Made Out of a Monkey"
	desc = "Oh wow now that's just gross. It's still moving slightly."
	learnable_language = /datum/language/monkey

/obj/item/book/granter/language_booke/mushroom
	name = "'A Fun Guide to Mushrooms' by Mike O'Phile"
	desc = "All the puns in this book dont leave mushroom to spore."
	learnable_language = /datum/language/mushroom

/obj/item/book/granter/language_book/draconic
	name = "Draconic for Dummies"
	desc = "Now you, too, can be a member of the lizgang! Lisp not included!"
	learnable_language = /datum/language/draconic

/obj/item/book/granter/language_book/slime
	name = "Slimes: A Xenolinguistic Analysis"
	desc = "A longwinded scientific journal on Slime communication. The pages are slightly sticky."
	learnable_language = /datum/language/slime

/obj/item/book/granter/language_book/xeno
	name = "Untitled Screenplay"
	desc = "EXTREME CLOSEUPS OF FLICKERING INSTRUMENT PANELS.  Readouts and digital displays pulse eerily with the technology of the distant future..."
	learnable_language = /datum/language/xenocommon

/obj/item/book/granter/language_book/blahsucker
	name = "Mysterious Diary"
	desc = "This book has a T H R E A T E N I N G aura"
	learnable_language = /datum/language/vampiric
