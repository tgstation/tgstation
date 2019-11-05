/obj/item/book/granter/language_book
	var/language_name = null
	var/learnable_language = null
	icon = 'icons/obj/library_fulp.dmi'

/obj/item/book/granter/language_book/already_known(mob/user)
	if(!user.has_language(learnable_language))
		return FALSE
	else
		to_chat(user, "You can already speak fluent [language_name]!")
		return TRUE

/obj/item/book/granter/language_book/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>You start leafing through the language book...</span>")

/obj/item/book/granter/language_book/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>You feel you've learned enough to understand [language_name]!</span>")
	user.grant_language(learnable_language)
	var/obj/item/organ/tongue/T = user.getorgan(/obj/item/organ/tongue)
	if(!(learnable_language in T.languages_possible))
		T.languages_possible[learnable_language] = 1
	user.log_message("learned the language [language_name] ([learnable_language])", LOG_ATTACK, color="orange")
	onlearned(user)
	desc += " The pages are blank. Seems like copy protection."

/obj/item/book/granter/language_book/recoil(mob/user)
	to_chat(user, "<span class='notice'>All the pages are blank, how useless!</span>")

/obj/item/book/granter/language_book/onlearned(mob/user)
	..()
	if(oneuse)
		to_chat(user, "<span class='notice'>The words on the pages fade and vanish!</span>")

/obj/item/book/granter/language_book/common
	name = "Ashwalker's Guide To The Galaxy"
	desc = "This missionary tome intended to teach Ashwalkers to speak Galactic Common has fallen into widespread use across the galaxy."
	learnable_language = /datum/language/common
	remarks = list("Always bring a towel...", "No eating rats in polite company...", "No, spears are not dinnerware...", "Don't panic...", "42...")
	icon_state = "book_common"
	language_name = "Galactic Common"

/obj/item/book/granter/language_book/aphasia
	name = "Maps of Meaning"
	desc = "A forgotten tome from ancient earth history. Even the cover gives you a headache."
	learnable_language = /datum/language/aphasia
	remarks = list("I should really tidy my room...", "Beware the feminine chaos dragon...", "Consider the lobster...", "My head hurts...", "This is just gibberish...", "Yes daddy...")
	icon_state = "book_aphasia"
	language_name = "Gibberish"

/obj/item/book/granter/language_book/beachbum
	name = "DUDE Magazine"
	desc = "This gnarly pile of papers will give you the raddest insights into modern youth culture! Tubular!"
	learnable_language = /datum/language/beachbum
	remarks = list("Wipeout!", "Woah that's bogus, dude...", "That's some heinous stuff...", "Radical...", "Check out this bodacious pinup babe!", "My brain feels softer...")
	icon_state = "book_beachbum"
	language_name = "Beach Bum"

/obj/item/book/granter/language_book/drone
	name = "Binary 101"
	desc = "...or How I Stopped Worrying and Learned to Love the Hats."
	learnable_language = /datum/language/drone
	remarks = list("Hello world...", "Zero before one one, but never after zero one zero...", "Hats...", "Processing...", "Beep boop!")
	icon_state = "book_drone"
	language_name = "Binary"

/obj/item/book/granter/language_book/narsian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Nar'Sian, without being a cultist! The pages are stained with blood, proving its authenticity!"
	learnable_language = /datum/language/narsie
	remarks = list("Finally, I see!", "The veil peels back before my mortal eyes...", "Ph'nglui mglw'nafh Nar'sie R'lyeh wgah'nagl fhtagn...", "Is this welsh?", "I can feel her behind my eyes...")
	icon_state = "book_narsie"
	language_name = "Nar'sian"


/*obj/item/book/granter/language_book/ratvarian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Ratvarian, without being a cultist! The entire tome is making an unsettling ticking noise."
	learnable_language = /datum/language/ratvar
	remarks = list("Yes, of course...", "How logical...", "Tick tock tick tock tick tock...", "It's all connected!", "Like clockwork...")
	icon_state = "book_ratvar"
	language_name = "Ratvarian"*/

///obj/item/book/granter/language_book/piratespeak  //not actually assigned to pirates, so currently unused
//	name = "To Hornswagle a Bilgerat"
//	desc = "A longwinded and dull nautical romance novel featuring an alarming amount of sailing jargon. Piratical tripe."
//	learnable_language = /datum/language/piratespeak
//	remarks = list("Fore is the front of the ship, aft is the back...", "Port is the ship's left, starboard is the right...", "What even is a piece of eight?", "I wonder if they serve grog at the bar..?", "How to effectively gesture with a hook hand...")
//	icon_state = "book_pirate"
//	language_name = "Pirate"

/obj/item/book/granter/language_book/monkey
	name = "A Book Made Out of a Monkey"
	desc = "Oh now that's just gross. It's still moving slightly."
	learnable_language = /datum/language/monkey
	remarks = list("Never ick in ooc...", "A whole chapter on bananas...", "Disarming techniques and you...", "How many typewriters!?", "Ook ook ee ee aaa!")
	icon_state = "book_monkey"
	language_name = "Monkey"

///obj/item/book/granter/language_book/mushroom //attached to a commented-out race
//	name = "'A Fun Guide to Mushrooms' by Mike O'Phile"
//	desc = "All the puns in this book dont leave mushroom to spore."
//	learnable_language = /datum/language/mushroom
//	remarks = list("These puns are positively crimini...", "The writing in this book is very porcini...", "Absolute shittake...", "Please God no morel!", "My first cellium...", "This is giving me trama...")
//	icon_state = "book_mushroom"
//	language_name = "Mushroom"

/obj/item/book/granter/language_book/draconic
	name = "Draconic for Dummies"
	desc = "Now you, too, can be a member of the lizgang! Lisp not included!"
	learnable_language = /datum/language/draconic
	remarks = list("101 ways to cook mouse...", "Just eat it raw...", "How to polish a spear...", "Hissing techniques; the basics...", "Scales and you, care routine...")
	icon_state = "book_draconic"
	language_name = "Draconic"

/obj/item/book/granter/language_book/slime
	name = "Slimes: A Xenolinguistic Analysis"
	desc = "A longwinded scientific journal on Slime communication. The pages are slightly sticky."
	learnable_language = /datum/language/slime
	remarks = list("'Help xenobio!', Safe slime feeding techniques and you...", "Preferred method for removing monkey hair from a slime processor...", "Never ever eat monkey cubes, here's why...", "Extinguisher-kata?")
	icon_state = "book_slime"
	language_name = "Slimeish"

/obj/item/book/granter/language_book/xeno
	name = "Untitled Screenplay"
	desc = "Someone must have spilled guacamole onto this..."
	learnable_language = /datum/language/xenocommon
	remarks = list("Oh no ripley run!", "I'm on the edge of my seat!", "Woah, that guy was a robot!?", "I think this might be a visual metaphor...", "Mo, not the kitty cat!", "Oh ew that's gross...")
	icon_state = "book_xeno"
	language_name = "Xenomorph"

/obj/item/book/granter/language_book/blahsucker
	name = "Mysterious Diary"
	desc = "This book has a  M E N A C I N G  aura"
	learnable_language = /datum/language/vampiric
	remarks = list("Oh? On heaven?", "Jotaro was here, Dio is a loser...", "Who's this Johnathan guy anyway?", "Hey is this a reference to...", "I should really burn this...")
	icon_state = "book_vampire"
	language_name = "Blah-Sucker"

///obj/item/book/granter/language_book/russian // s o o n
//	name = "The Cyka's Guide To Space-Russian"
//	desc = "A nu cheeki breeki iv damke!"
//	learnable_language = /datum/language/russian
//	remarks = list("What if the space workers owned the means of space production..?", "Permanent revolution or socialism in one star system..?", "Boy I'd sure go for some cheap grain alcohol right now...", "Squatting and you; hip drive...", "Huh, lying down protects you from bears...")
//	icon_state = "book_russian"
//	language_name = "Space Russian"

/obj/item/book/granter/language_book/random
	icon_state = "random_book"

/obj/item/book/granter/language_book/random/Initialize()
	. = ..()
	var/real_type = pick(subtypesof(/obj/item/book/granter/language_book))
	new real_type(loc)
	return INITIALIZE_HINT_QDEL
