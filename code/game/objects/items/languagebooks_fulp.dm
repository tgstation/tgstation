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
	remarks = list("always bring a towel...", "no eating rats in polite company...", "no, spears are not dinnerware...", "don't panic...", "42...")
	icon_state = "book_common"
	language_name = "Galactic Common"

/obj/item/book/granter/language_book/aphasia
	name = "Maps of Meaning"
	desc = "A forgotten tome from ancient earth history. Even the cover gives you a headache."
	learnable_language = /datum/language/aphasia
	remarks = list("I should really tidy my room...", "beware the feminine chaos dragon...", "think like a lobster", "my head hurts...", "this is just gibberish...", "yes daddy...")
	icon_state = "book_aphasia"
	language_name = "Gibberish"

/obj/item/book/granter/language_book/beachbum
	name = "DUDE Magazine"
	desc = "This gnarly pile of papers will give you the raddest insights into modern youth culture! Tubular!"
	learnable_language = /datum/language/beachbum
	remarks = list("wipeout!", "woah that's bogus, dude...", "that's some heinous stuff...", "radical...", "look at this bodacious pinup babe!", "my brain feels softer...")
	icon_state = "book_beachbum"
	language_name = "Beach Bum"

/obj/item/book/granter/language_book/drone
	name = "Binary 101"
	desc = "...or How I Stopped Worrying and Learned to Love the Hats."
	learnable_language = /datum/language/drone
	remarks = list("hello world...", "zero before one one, but never after zero one zero...", "hats...", "processing...", "beep boop")
	icon_state = "book_drone"
	language_name = "Binary"

/obj/item/book/granter/language_book/narsian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Nar'Sian, without being a cultist! The pages are stained with blood, proving its authenticity!"
	learnable_language = /datum/language/narsie
	remarks = list("finally, I see!", "the veil peels back before my mortal eyes...", "ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn...", "is this welsh?", "i can feel her behind my eyes")
	icon_state = "book_narsie"
	language_name = "Nar'sian"
	

/obj/item/book/granter/language_book/ratvarian
	name = "Your Guide to the One True God"
	desc = "This guide details how to speak Ratvarian, without being a cultist! The entire tome is making an unsettling ticking noise."
	learnable_language = /datum/language/ratvar
	remarks = list("yes, of course...", "how logical...", "tick tock tick tock tick tock...", "it's all connected!", "like clockwork...")
	icon_state = "book_ratvar"
	language_name = "Ratvarian"

/obj/item/book/granter/language_book/piratespeak
	name = "To Hornswagle a Bilgerat"
	desc = "A longwinded and dull nautical romance novel featuring an alarming amount of sailing jargon. Piratical tripe."
	learnable_language = /datum/language/piratespeak
	remarks = list("fore is the front, aft is the back...", "port is the left, starboard is the right...", "what even is a piece of eight?", "drink up me hearties, yo ho!", "how to gesture with a hook hand...")
	icon_state = "book_pirate"
	language_name = "Pirate"

/obj/item/book/granter/language_book/monkey
	name = "A Book Made Out of a Monkey"
	desc = "Oh wow now that's just gross. It's still moving slightly."
	learnable_language = /datum/language/monkey
	remarks = list("never ick in ooc...", "a whole chapter on bananas...", "disarming techniques and you...", "monkeys with machine guns", "ook ook ee ee aaa!")
	icon_state = "book_monkey"
	language_name = "Monkey"

/obj/item/book/granter/language_book/mushroom
	name = "'A Fun Guide to Mushrooms' by Mike O'Phile"
	desc = "All the puns in this book dont leave mushroom to spore."
	learnable_language = /datum/language/mushroom
	remarks = list("these puns should be crimini...", "this book is written very porcini...", "what a shittake...", "please no morel!", "my first cellium...", "this is giving me trama...")
	icon_state = "book_mushroom"
	language_name = "Mushroom"

/obj/item/book/granter/language_book/draconic
	name = "Draconic for Dummies"
	desc = "Now you, too, can be a member of the lizgang! Lisp not included!"
	learnable_language = /datum/language/draconic
	remarks = list("101 ways to cook mouse...", "just eat it raw...", "how to polish a spear...", "hissing techniques; the basics...", "scales and you, care routine...")
	icon_state = "book_draconic"
	language_name = "Draconic"

/obj/item/book/granter/language_book/slime
	name = "Slimes: A Xenolinguistic Analysis"
	desc = "A longwinded scientific journal on Slime communication. The pages are slightly sticky."
	learnable_language = /datum/language/slime
	remarks = list("'help xenobio!' safe slime feeding techniques and you...", "preferred method for removing monkey meat from a slime processor...", "why you should never eat monkey cubes...", "its okay to be grey...")
	icon_state = "book_slime"
	language_name = "Slimeish"

/obj/item/book/granter/language_book/xeno
	name = "Untitled Screenplay"
	desc = "EXTREME CLOSEUPS OF FLICKERING INSTRUMENT PANELS.  Readouts and digital displays pulse eerily with the technology of the distant future..."
	learnable_language = /datum/language/xenocommon
	remarks = list("oh no ripley run!", "I'm on the edge of my seat!", "wait he was a robot!?", "I think this might be a visual metaphor...", "no, not the cat!", "oh ew that's gross...")
	icon_state = "book_xeno"
	language_name = "Xenomorph"

/obj/item/book/granter/language_book/blahsucker
	name = "Mysterious Diary"
	desc = "This book has a  M E N A C I N G  aura"
	learnable_language = /datum/language/vampiric
	remarks = list("notes on heaven? weird...", "jotaro was here, dio is a loser...", "who's this johnathan guy anyway?", "hey is this a reference to...", "I should really burn this...")
	icon_state = "book_vampire"
	language_name = "Blah-Sucker"

/obj/item/book/granter/language_book/russian
	name = "The Cyka's Guide To Space-Russian"
	desc = "A nu cheeki breeki iv damke!"
	learnable_language = /datum/language/russian
	remarks = list("what if the workers owned the means of production..?", "permanent revolution or socialism in one star system..?", "man I'd go for some cheap grain alcohol right now...", "squatting and you; hip drive...", "huh, lying down protects you from bears...")
	icon_state = "book_russian"
	language_name = "Space Russian"
