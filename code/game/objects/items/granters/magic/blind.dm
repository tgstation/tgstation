/obj/item/book/granter/action/spell/blind
	granted_action = /datum/action/cooldown/spell/pointed/blind
	action_name = "blind"
	icon_state = "bookblind"
	desc = "This book looks blurry, no matter how you look at it."
	remarks = list(
		"Well I can't learn anything if I can't read the damn thing!",
		"Why would you use a dark font on a dark background...",
		"Ah, I can't see an Oh, I'm fine...",
		"I can't see my hand...!",
		"I'm manually blinking, damn you book...",
		"I can't read this page, but somehow I feel like I learned something from it...",
		"Hey, who turned off the lights?",
	)

/obj/item/book/granter/action/spell/blind/recoil(mob/living/user)
	. = ..()
	to_chat(user, span_warning("You go blind!"))
	user.blind_eyes(10)

/obj/item/book/granter/action/spell/blind/wgw
	name = "Woody's Got Wood"
	pages_to_mastery = 69 // Andy's favorite number
	uses = 0 // it's spent
	desc = "This book looks dangerious. Only suffering awaits those who read."
	remarks = list( // Death awaits
		"One day while Andy was masturbating, Woody got wood.",
		"He could no longer help himself!",
		"He watched as Andy stroked his juicy kawaii cock.",
		"He approached Andy which startled him and make him pee everywhere on the floor and on Woody too.",
		"Being drenched in his urine made him harder than ever!",
		"Woody: 'Andy Senpai! I'm alive and I want to be INSIDE OF YOU.',
		"Andy: 'Oh Woody Chan! I always knew you were alive! I want to stuff you up my kawaii ass!'",
		"Woody grabbed a bunch of flavored lube and rubbed it all over his head.",
		"Woody: 'Oh my! It's cherry flavored lube! Cherry is my favorite!'",
		"Woody then stuffed his head up into Andy's tight ass!",
		"The other toys around the room watched intently as Woody shoved his head back and forth into Andy's nice ass, continuously making a squishy wet noise.",
		"Andy: `Oh my goodness, Woody Chan! You are churning my insides up so well! Your nose is stimulating my prostate!`",
		"OH YES! All the other toys became so aroused by this, that they could not help themselves anymore!",
		"Andy: `No wait guys! My ass cannot hold this much! I'm getting so full!`",
		"All the toys went inside of poor squirming Andy and pretty much, he was beyond full, and died from having his insides completely damaged.",
		"The mother came inside and found Andy, dead with a huge ass hemorrhage on his anus, with a HUGE belly full of toys.",
	)
