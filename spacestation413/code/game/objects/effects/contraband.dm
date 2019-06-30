/obj/structure/sign/poster/contraband/spacestation413 // random structure requires this sorry
	icon = 'spacestation413/icons/obj/contraband.dmi'

/obj/structure/sign/poster/official/spacestation413
	icon = 'spacestation413/icons/obj/contraband.dmi'

/obj/structure/sign/poster/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon = initial(selected.icon)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)

/obj/structure/sign/poster/contraband/spacestation413/tildeath
	name = "~ATH"
	desc = "A poster advertising the ultimate programming language. Or the ultimate programmer. You're not sure which."
	icon_state = "poster1"

/obj/structure/sign/poster/contraband/spacestation413/sburbdever
	name = "SBURB by Tyler Dever"
	desc = "Did you know this piano album is actually based on Christian concepts? If you didn't, you should be ashamed of yourself."
	icon_state = "poster2"

/obj/structure/sign/poster/contraband/spacestation413/sweetbro
	name = "Sweet Brother"
	desc = "today i put.............JELLY on this hot god"
	icon_state = "poster3"

/obj/structure/sign/poster/contraband/spacestation413/sepulchritude
	name = "Sepulchritude"
	desc = "You are intrigued by Problem Sleuth's diplomacy skills. Also by his huge sword and wings."
	icon_state = "poster4"

/obj/structure/sign/poster/contraband/spacestation413/strife
	name = "STRIFE!"
	desc = "Bro is a really bad guy. A really BAD-ASS guy."
	icon_state = "poster5"

/obj/structure/sign/poster/contraband/spacestation413/felt
	name = "The Felt"
	desc = "Cigarette ashes burn red, but they fall like snow, and I hear this world calling my name, and this world's got to end someday soon."
	icon_state = "poster7"

/obj/structure/sign/poster/contraband/spacestation413/cangh2
	name = "Cool and New Greatest Hits 2"
	desc = "Featuring over 30 non-memetic tracks!"
	icon_state = "poster8"

/obj/structure/sign/poster/contraband/spacestation413/canwc
	name = "Cool and New Web Comic"
	desc = "4 kids habv play a game to make a unaverse and some other thigns hapen too."
	icon_state = "poster11"

/obj/structure/sign/poster/contraband/spacestation413/fathusky
	name = "Fat Husky"
	desc = "Huskies are energetic and athletic. This one isn't."
	icon_state = "poster12"

/obj/structure/sign/poster/contraband/spacestation413/niccage
	name = "Nicolas Cage"
	desc = "WHY COULDN'T YOU PUT THE BUNNY BACK IN THE BOX?"
	icon_state = "poster13"

/obj/structure/sign/poster/contraband/spacestation413/yeah
	name = "Yeah!!!!!!!!"
	desc = "This poster took a few too many liberties depicting Vriska. She should look deader."
	icon_state = "poster14"

/obj/structure/sign/poster/contraband/spacestation413/cherubim
	name = "Cherubim"
	desc = "Damn, Calliope looks like THAT?"
	icon_state = "poster15"

/obj/structure/sign/poster/contraband/spacestation413/canmt
	name = "Cool and New Music Team"
	desc = "Envy, greed, despair, memes."
	icon_state = "poster16"

/obj/structure/sign/poster/contraband/spacestation413/doctorremix
	name = "Homestuck Vol. 5"
	desc = "Featuring over 5 volumes of Doctor remixes!"
	icon_state = "poster17"

/obj/structure/sign/poster/contraband/spacestation413/symphonyimpossible
	name = "Symphony Impossible to Hear"
	desc = "You place your ear on the poster to test its claim, but you can only hear the crew laughing at you."
	icon_state = "poster19"

/obj/structure/sign/poster/contraband/spacestation413/bowmania
	name = "BOWMANIA"
	desc = "a tribute to a bowman, who, even he himself, was once a bowboy."
	icon_state = "poster20"

/obj/structure/sign/poster/contraband/spacestation413/femorafreack
	name = "Femorafreack"
	desc = "STOP, in the name of the law! Space justice must be a serve."
	icon_state = "poster21"

/obj/structure/sign/poster/contraband/spacestation413/whocares
	name = "Who Cares"
	desc = "A poster that claims nobody cares by the man who stopped caring."
	icon_state = "poster22"

/obj/structure/sign/poster/contraband/spacestation413/kickstarter
	name = "2.5 MILLION DOLLARS JADE"
	desc = "At least it's not a lumberjack again..."
	icon_state = "poster23"

/obj/structure/sign/poster/contraband/spacestation413/justiceisblind
	name = "JUSTICE IS BLIND"
	desc = "blind girl has nice ass?????"
	icon_state = "poster24"

/obj/structure/sign/poster/contraband/spacestation413/dudeweedlmao
	name = "Dude Weed Lmao"
	desc = "420 or something. I accidentally wrote over this poster's original description."
	icon_state = "poster25"

/obj/structure/sign/poster/contraband/spacestation413/ithaca
	name = "Ithaca"
	desc = "Long before there was you and I, Bowman made tunes to soothe our lives."
	icon_state = "poster26"

/obj/structure/sign/poster/contraband/spacestation413/megan
	name = "Megan"
	desc = "She hates her fucking job."
	icon_state = "poster27"

/obj/structure/sign/poster/contraband/spacestation413/pumpkins
	name = "Wait what?"
	desc = "Wonders where the fuck that pumpkin went???"
	icon_state = "poster28"

/obj/structure/sign/poster/contraband/spacestation413/letmetellyou
	name = "Disapproving Black Man"
	desc = "You STILL like Homestuck in 2017? Pathetic."
	icon_state = "poster29"

/obj/structure/sign/poster/contraband/spacestation413/howhigh
	name = "How High"
	desc = "AHAHAHAHAHA JUST HOW HIGH DO YOU EVEN HAVE TO BE JUST TO DO SOMETHING LIKE THAT........"
	icon_state = "poster30"

/obj/structure/sign/poster/contraband/spacestation413/oyo
	name = "One Year Older"
	desc = "Jit's Face will look disapproving if people don't hang this poster every October 18th."
	icon_state = "poster31"

/obj/structure/sign/poster/contraband/spacestation413/sburb
	name = "SBURB"
	desc = "This poster usually gets ignored in favor of teen drama. Sorry, space teen drama."
	icon_state = "poster32"

/obj/structure/sign/poster/contraband/spacestation413/cutejade
	name = "Kawaii Jade"
	desc = "The moment you lay eyes on this abomination, an urge to murder weebs awakens."
	icon_state = "poster33"

/obj/structure/sign/poster/contraband/spacestation413/cangh1
	name = "Cool and New Greatest Hits"
	desc = "You wish Rose was the Lord of Space Station 413 too..."
	icon_state = "poster34"

/obj/structure/sign/poster/contraband/spacestation413/gay
	name = "No offense but...isnt that kind of GAY"
	desc = "TL note: gay means homo"
	icon_state = "poster35"

/obj/structure/sign/poster/contraband/spacestation413/act7
	name = "Act 7"
	desc = "This is as much of a disappointment as your performance last round."
	icon_state = "poster36"

/obj/structure/sign/poster/contraband/spacestation413/heirtransparent
	name = "Heir Transparent"
	desc = "Haha what are you saying this is a perfectly normal hideously long arm, foreshortening and such."
	icon_state = "poster37"

/obj/structure/sign/poster/contraband/spacestation413/seerofmind
	name = "Seer of Mind"
	desc = "Maybe the back of the poster contains the meaning to Terezi: Remember... nope."
	icon_state = "poster38"

/obj/structure/sign/poster/contraband/spacestation413/cascade
	name = "Cascade"
	desc = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	icon_state = "poster39"

/obj/structure/sign/poster/contraband/spacestation413/midnightcrew
	name = "Midnight Crew"
	desc = "You are but a DVS sax compared to this band's shadow music skills."
	icon_state = "poster40"

/obj/structure/sign/poster/contraband/spacestation413/cam
	name = "Colours and Mayhem"
	desc = "Over 10% of the characters featured in this poster got some development!"
	icon_state = "poster41"

/obj/structure/sign/poster/contraband/spacestation413/bowman
	name = "Bowman"
	desc = "How relevant, how new, buy his albums!"
	icon_state = "poster42"

/obj/structure/sign/poster/contraband/spacestation413/lordenglish
	name = "Lord English"
	desc = "After hanging this poster, you will realize it was already there all along."
	icon_state = "poster43"

/obj/structure/sign/poster/contraband/spacestation413/caliborn
	name = "Caliborn"
	desc = "A poster depicting a finalist of the Jade and Calliope Rumble, to date his biggest achievement."
	icon_state = "poster44"

/obj/structure/sign/poster/official/spacestation413/sgrub
	name = "SGRUB"
	desc = "All in all: 7/10 game. ALL my friends died. 7/10."
	icon_state = "poster1_legit"

/obj/structure/sign/poster/official/spacestation413/yourewelcome
	name = "YOU'RE WELCOME"
	desc = "So long, and thanks for all the ships."
	icon_state = "poster12_legit"

/obj/structure/sign/poster/official/spacestation413/whatpumpkin
	name = "What Pumpkin"
	desc = "You almost applied there, but dying in a Space Station seems like a better way to waste your life."
	icon_state = "poster13_legit"

/obj/structure/sign/poster/official/spacestation413/vol10
	name = "Homestuck Vol. 10"
	desc = "PENUMBRA PHANTASM WHEN"
	icon_state = "poster14_legit"

/obj/structure/sign/poster/official/spacestation413/hiveswap
	name = "Hiveswap"
	desc = "Pfft, if you wanted funny item descriptions you'd read these posters."
	icon_state = "poster18_legit"

/obj/structure/sign/poster/official/spacestation413/yikes
	name = "Yikes"
	desc = "I don't want to participate in this discussion but I want to feel superior anyway."
	icon_state = "poster22_legit"

/obj/structure/sign/poster/official/spacestation413/nepeta
	name = "Nepeta"
	desc = "A truly terrible choice for a waifu."
	icon_state = "poster23_legit"

/obj/structure/sign/poster/official/spacestation413/poseasateam
	name = "Pose as a team"
	desc = "Cause shit just got real."
	icon_state = "poster24_legit"

/obj/structure/sign/poster/official/spacestation413/dirk
	name = "Dirk Strider"
	desc = "He's back, now without child abuse!"
	icon_state = "poster25_legit"

/obj/structure/sign/poster/official/spacestation413/rorb
	name = "Rorb Lalorb"
	desc = "ur so pretty"
	icon_state = "poster26_legit"

/obj/structure/sign/poster/official/spacestation413/tenseiface
	name = "Pink Butterfly Man"
	desc = "All who diss metal will have to answer to this eldritch creature."
	icon_state = "poster27_legit"

/obj/structure/sign/poster/official/spacestation413/mobiustrip
	name = "Mobius Trip and Hadron Kaleido"
	desc = "IT WAS THE DAWN OF BOW-MAN"
	icon_state = "poster28_legit"

/obj/structure/sign/poster/official/spacestation413/roxygen
	name = "Roxygen"
	desc = "This poster will keep being manufactured until the end of time, to make the other posters look better."
	icon_state = "poster29_legit"

/obj/structure/sign/poster/official/spacestation413/readworm
	name = "Worm"
	desc = "Read it! http://parahumans.wordpress.com/"
	icon_state = "poster31_legit"

/obj/structure/sign/poster/official/spacestation413/woc
	name = "Wizard of Chaos"
	desc = "You suddenly feel the urge to superglue your hand and stick it inside the supermatter."
	icon_state = "poster32_legit"

#undef PLACE_SPEED
