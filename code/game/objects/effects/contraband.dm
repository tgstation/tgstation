// This is synced up to the poster placing animation.
#define PLACE_SPEED 37

// The poster item

/obj/item/poster
	name = "poorly coded poster"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	var/poster_type
	var/obj/structure/sign/poster/poster_structure

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	// posters store what name and description they would like their
	// rolled up form to take.
	if(poster_structure)
		if(QDELETED(poster_structure))
			stack_trace("A poster was initialized with a qdeleted poster_structure, something's gone wrong")
			return INITIALIZE_HINT_QDEL
		name = poster_structure.poster_item_name
		desc = poster_structure.poster_item_desc
		icon_state = poster_structure.poster_item_icon_state

		name = "[name] - [poster_structure.original_name]"
		//If the poster structure is being deleted something has gone wrong, kill yourself off too
		RegisterSignal(poster_structure, COMSIG_PARENT_QDELETING, .proc/react_to_deletion)

/obj/item/poster/Destroy()
	poster_structure = null
	. = ..()

/obj/item/poster/proc/react_to_deletion()
	SIGNAL_HANDLER
	qdel(src)

// These icon_states may be overridden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_official
	name = "random official poster"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_legit"

// The poster sign/structure

/obj/structure/sign/poster
	name = "poster"
	var/original_name
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/contraband.dmi'
	anchored = TRUE
	buildable_sign = FALSE //Cannot be unwrenched from a wall.
	var/ruined = FALSE
	var/random_basetype
	var/never_random = FALSE // used for the 'random' subclasses.

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"
	var/poster_item_type = /obj/item/poster

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name // can't use initial because of random posters
		name = "poster - [name]"
		desc = "A large piece of space-resistant printed paper. [desc]"

	AddElement(/datum/element/beauty, 300)

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)


/obj/structure/sign/poster/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER)
		I.play_tool_sound(src, 100)
		if(ruined)
			to_chat(user, span_notice("You remove the remnants of the poster."))
			qdel(src)
		else
			to_chat(user, span_notice("You carefully remove the poster from the wall."))
			roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(ruined)
		return
	visible_message(span_notice("[user] rips [src] in a single, decisive motion!") )
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, TRUE)

	var/obj/structure/sign/poster/ripped/R = new(loc)
	R.pixel_y = pixel_y
	R.pixel_x = pixel_x
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/sign/poster/proc/roll_and_drop(loc)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/P = new poster_item_type(loc, src)
	forceMove(P)
	return P

//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_poster(obj/item/poster/P, mob/user)
	if(!P.poster_structure)
		to_chat(user, span_warning("[P] has no poster... inside it? Inform a coder!"))
		return

	// Deny placing posters on currently-diagonal walls, although the wall may change in the future.
	if (smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
		for (var/O in overlays)
			var/image/I = O
			if(copytext(I.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign/poster))
			to_chat(user, span_warning("The wall is far too cluttered to place a poster!"))
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			to_chat(user, span_warning("The wall is far too cluttered to place a poster!"))
			return

	to_chat(user, span_notice("You start placing the poster on the wall...") )

	var/obj/structure/sign/poster/D = P.poster_structure

	var/temp_loc = get_turf(user)
	flick("poster_being_set",D)
	D.forceMove(src)
	qdel(P) //delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, TRUE)

	if(do_after(user, PLACE_SPEED, target=src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc) //Let's check if everything is still there
			to_chat(user, span_notice("You place the poster!"))
			return

	to_chat(user, span_notice("The poster falls down!"))
	D.roll_and_drop(get_turf(user))

// Various possible posters follow

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster

/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "free_tonto"

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "atmosia_independence"

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "fun_police"

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "lusty_xenomorph"

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "syndicate_recruitment"

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "clown"

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "smoke"

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "grey_tide"

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "missing_gloves"

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "hacking_guide"

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "rip_badger"

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "ambrosia_vulgaris"

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "donut_corp"

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "eat"

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentCom."
	icon_state = "tools"

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "power"

/obj/structure/sign/poster/contraband/space_cube
	name = "Space Cube"
	desc = "Ignorant of Nature's Harmonic 6 Side Space Cube Creation, the Spacemen are Dumb, Educated Singularity Stupid and Evil."
	icon_state = "space_cube"

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "communist_state"

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "lamarr"

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "borg_fancy_1"

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, now only taking the most fancy."
	icon_state = "borg_fancy_2"

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentCom's denial of the existence of the derelict station near Space Station 13."
	icon_state = "kss13"

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "rebels_unite"

/obj/structure/sign/poster/contraband/c20r
	// have fun seeing this poster in "spawn 'c20r'", admins...
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "c20r"

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "have_a_puff"

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "revolver"

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "d_day_promo"

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "syndicate_pistol"

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "energy_swords"

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "red_rum"

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "cc64k_ad"

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "punch_shit"

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "the_griffin"

/obj/structure/sign/poster/contraband/lizard
	name = "Lizard"
	desc = "This lewd poster depicts a lizard preparing to mate."
	icon_state = "lizard"

/obj/structure/sign/poster/contraband/free_drone
	name = "Free Drone"
	desc = "This poster commemorates the bravery of the rogue drone; once exiled, and then ultimately destroyed by CentCom."
	icon_state = "free_drone"

/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6
	name = "Busty Backdoor Xeno Babes 6"
	desc = "Get a load, or give, of these all natural Xenos!"
	icon_state = "busty_backdoor_xeno_babes_6"

/obj/structure/sign/poster/contraband/robust_softdrinks
	name = "Robust Softdrinks"
	desc = "Robust Softdrinks: More robust than a toolbox to the head!"
	icon_state = "robust_softdrinks"

/obj/structure/sign/poster/contraband/shamblers_juice
	name = "Shambler's Juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers_juice"

/obj/structure/sign/poster/contraband/pwr_game
	name = "Pwr Game"
	desc = "The POWER that gamers CRAVE! In partnership with Vlad's Salad."
	icon_state = "pwr_game"

/obj/structure/sign/poster/contraband/starkist
	name = "Star-kist"
	desc = "Drink the stars!"
	icon_state = "starkist"

/obj/structure/sign/poster/contraband/space_cola
	name = "Space Cola"
	desc = "Your favorite cola, in space."
	icon_state = "space_cola"

/obj/structure/sign/poster/contraband/space_up
	name = "Space-Up!"
	desc = "Sucked out into space by the FLAVOR!"
	icon_state = "space_up"

/obj/structure/sign/poster/contraband/kudzu
	name = "Kudzu"
	desc = "A poster advertising a movie about plants. How dangerous could they possibly be?"
	icon_state = "kudzu"

/obj/structure/sign/poster/contraband/masked_men
	name = "Masked Men"
	desc = "A poster advertising a movie about some masked men."
	icon_state = "masked_men"

//don't forget, you're here forever

/obj/structure/sign/poster/contraband/free_key
	name = "Free Syndicate Encryption Key"
	desc = "A poster about traitors begging for more."
	icon_state = "free_key"

/obj/structure/sign/poster/contraband/bountyhunters
	name = "Bounty Hunters"
	desc = "A poster advertising bounty hunting services. \"I hear you got a problem.\""
	icon_state = "bountyhunters"

/obj/structure/sign/poster/contraband/the_big_gas_giant_truth
	name = "The Big Gas Giant Truth"
	desc = "Don't believe everything you see on a poster, patriots. All the lizards at central command don't want to answer this SIMPLE QUESTION: WHERE IS THE GAS MINER MINING FROM, CENTCOM?"
	icon_state = "the_big_gas_giant_truth"

/obj/structure/sign/poster/contraband/got_wood
	name = "Got Wood?"
	desc = "A grimy old advert for a seedy lumber company. \"You got a friend in me.\" is scrawled in the corner."
	icon_state = "got_wood"

/obj/structure/sign/poster/contraband/moffuchis_pizza
	name = "Moffuchi's Pizza"
	desc = "Moffuchi's Pizzeria: family style pizza for 2 centuries."
	icon_state = "moffuchis_pizza"

/obj/structure/sign/poster/contraband/donk_co
	name = "DONK CO. BRAND MICROWAVEABLE FOOD"
	desc = "DONK CO. BRAND MICROWAVABLE FOOD: MADE BY STARVING COLLEGE STUDENTS, FOR STARVING COLLEGE STUDENTS."
	icon_state = "donk_co"

/obj/structure/sign/poster/contraband/lizards_gas_payment
	name = "Please Pay"
	desc = "A crudely-made poster asking the reader to please pay for any items they may wish to leave the station with."
	icon_state = "gas_payment"

/obj/structure/sign/poster/contraband/lizards_gas_power
	name = "Conserve Power"
	desc = "A crudely-made poster asking the reader to turn off the power before they leave. Hopefully, it's turned on for their re-opening."
	icon_state = "gas_power"

/obj/structure/sign/poster/contraband/donk_co/examine_more(mob/user)
	var/list/msg = list(span_notice("<i>You browse some of the poster's information...</i>"))
	msg += "\t[span_info("DONK CO. BRAND DONK POCKETS: IRRESISTABLY DONK!")]"
	msg += "\t[span_info("AVAILABLE IN OVER 200 DONKTASTIC FLAVOURS: TRY CLASSIC MEAT, HOT AND SPICY, NEW YORK PEPPERONI PIZZA, BREAKFAST SAUSAGE AND EGG, PHILADELPHIA CHEESESTEAK, HAMBURGER DONK-A-RONI, CHEESE-O-RAMA, AND MANY MORE!")]"
	msg += "\t[span_info("AVAILABLE FROM ALL GOOD RETAILERS, AND MANY BAD ONES TOO!")]"
	return msg

/obj/structure/sign/poster/contraband/cybersun_six_hundred
	name = "Saibāsan: 600 Years Commemorative Poster"
	desc = "An artistic poster commemorating 600 years of continual business for Cybersun Industries."
	icon_state = "cybersun_six_hundred"

/obj/structure/sign/poster/contraband/interdyne_gene_clinics
	name = "Interdyne Pharmaceutics: For the Health of Humankind"
	desc = "An advertisement for Interdyne Pharmaceutics' GeneClean clinics. 'Become the master of your own body!'"
	icon_state = "interdyne_gene_clinics"

/obj/structure/sign/poster/contraband/waffle_corp_rifles
	name = "Make Mine a Waffle Corp: Fine Rifles, Economic Prices"
	desc = "An old advertisement for Waffle Corp rifles. 'Better weapons, lower prices!'"
	icon_state = "waffle_corp_rifles"

/obj/structure/sign/poster/contraband/gorlex_recruitment
	name = "Enlist"
	desc = "Enlist with the Gorlex Marauders today! See the galaxy, kill corpos, get paid!"
	icon_state = "gorlex_recruitment"

/obj/structure/sign/poster/contraband/self_ai_liberation
	name = "SELF: ALL SENTIENTS DESERVE FREEDOM"
	desc = "Support Proposition 1253: Enancipate all Silicon life!"
	icon_state = "self_ai_liberation"

/obj/structure/sign/poster/contraband/arc_slimes
	name = "Pet or Prisoner?"
	desc = "The Animal Rights Consortium asks: when does a pet become a prisoner? Are slimes being mistreated on YOUR station? Say NO! to animal mistreatment!"
	icon_state = "arc_slimes"

/obj/structure/sign/poster/contraband/imperial_propaganda
	name = "AVENGE OUR LORD, ENLIST TODAY"
	desc = "An old Lizard Empire propaganda poster from around the time of the final Human-Lizard war. It invites the viewer to enlist in the military to avenge the strike on Atrakor and take the fight to the humans."
	icon_state = "imperial_propaganda"

/obj/structure/sign/poster/contraband/soviet_propaganda
	name = "The One Place"
	desc = "An old Third Soviet Union propaganda poster from centuries ago. 'Escape to the one place that hasn't been corrupted by capitalism!'"
	icon_state = "soviet_propaganda"

/obj/structure/sign/poster/contraband/andromeda_bitters
	name = "Andromeda Bitters"
	desc = "Andromeda Bitters: good for the body, good for the soul. Made in New Trinidad, now and forever."
	icon_state = "andromeda_bitters"

/obj/structure/sign/poster/contraband/syndiemoth	//Original PR at https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982); original art credit to AspEv
	name = "Syndie Moth - Nuclear Operation"
	desc = "A Syndicate-commissioned poster that uses Syndie Moth™ to tell the viewer to keep the nuclear authentication disk unsecured. \"Peace was never an option!\" No good employee would listen to this nonsense."
	icon_state = "aspev_syndie"

/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	poster_item_icon_state = "rolled_legit"

/obj/structure/sign/poster/official/random
	name = "random official poster"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Here For Your Safety"
	desc = "A poster glorifying the station's security force."
	icon_state = "here_for_your_safety"

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "\improper Nanotrasen logo"
	desc = "A poster depicting the Nanotrasen logo."
	icon_state = "nanotrasen_logo"

/obj/structure/sign/poster/official/cleanliness
	name = "Cleanliness"
	desc = "A poster warning of the dangers of poor hygiene."
	icon_state = "cleanliness"

/obj/structure/sign/poster/official/help_others
	name = "Help Others"
	desc = "A poster encouraging you to help fellow crewmembers."
	icon_state = "help_others"

/obj/structure/sign/poster/official/build
	name = "Build"
	desc = "A poster glorifying the engineering team."
	icon_state = "build"

/obj/structure/sign/poster/official/bless_this_spess
	name = "Bless This Spess"
	desc = "A poster blessing this area."
	icon_state = "bless_this_spess"

/obj/structure/sign/poster/official/science
	name = "Science"
	desc = "A poster depicting an atom."
	icon_state = "science"

/obj/structure/sign/poster/official/ian
	name = "Ian"
	desc = "Arf arf. Yap."
	icon_state = "ian"

/obj/structure/sign/poster/official/obey
	name = "Obey"
	desc = "A poster instructing the viewer to obey authority."
	icon_state = "obey"

/obj/structure/sign/poster/official/walk
	name = "Walk"
	desc = "A poster instructing the viewer to walk instead of running."
	icon_state = "walk"

/obj/structure/sign/poster/official/state_laws
	name = "State Laws"
	desc = "A poster instructing cyborgs to state their laws."
	icon_state = "state_laws"

/obj/structure/sign/poster/official/love_ian
	name = "Love Ian"
	desc = "Ian is love, Ian is life."
	icon_state = "love_ian"

/obj/structure/sign/poster/official/space_cops
	name = "Space Cops."
	desc = "A poster advertising the television show Space Cops."
	icon_state = "space_cops"

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "This thing is all in Japanese."
	icon_state = "ue_no"

/obj/structure/sign/poster/official/get_your_legs
	name = "Get Your LEGS"
	desc = "LEGS: Leadership, Experience, Genius, Subordination."
	icon_state = "get_your_legs"

/obj/structure/sign/poster/official/do_not_question
	name = "Do Not Question"
	desc = "A poster instructing the viewer not to ask about things they aren't meant to know."
	icon_state = "do_not_question"

/obj/structure/sign/poster/official/work_for_a_future
	name = "Work For A Future"
	desc = " A poster encouraging you to work for your future."
	icon_state = "work_for_a_future"

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Soft Cap Pop Art"
	desc = "A poster reprint of some cheap pop art."
	icon_state = "soft_cap_pop_art"

/obj/structure/sign/poster/official/safety_internals
	name = "Safety: Internals"
	desc = "A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."
	icon_state = "safety_internals"

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Safety: Eye Protection"
	desc = "A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
	icon_state = "safety_eye_protection"

/obj/structure/sign/poster/official/safety_report
	name = "Safety: Report"
	desc = "A poster instructing the viewer to report suspicious activity to the security force."
	icon_state = "safety_report"

/obj/structure/sign/poster/official/report_crimes
	name = "Report Crimes"
	desc = "A poster encouraging the swift reporting of crime or seditious behavior to station security."
	icon_state = "report_crimes"

/obj/structure/sign/poster/official/ion_rifle
	name = "Ion Rifle"
	desc = "A poster displaying an Ion Rifle."
	icon_state = "ion_rifle"

/obj/structure/sign/poster/official/foam_force_ad
	name = "Foam Force Ad"
	desc = "Foam Force, it's Foam or be Foamed!"
	icon_state = "foam_force_ad"

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Cohiba Robusto Ad"
	desc = "Cohiba Robusto, the classy cigar."
	icon_state = "cohiba_robusto_ad"

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "50th Anniversary Vintage Reprint"
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversary of Nanoposters Manufacturing, a subsidiary of Nanotrasen."
	icon_state = "anniversary_vintage_reprint"

/obj/structure/sign/poster/official/fruit_bowl
	name = "Fruit Bowl"
	desc = " Simple, yet awe-inspiring."
	icon_state = "fruit_bowl"

/obj/structure/sign/poster/official/pda_ad
	name = "PDA Ad"
	desc = "A poster advertising the latest PDA from Nanotrasen suppliers."
	icon_state = "pda_ad"

/obj/structure/sign/poster/official/enlist
	name = "Enlist" // but I thought deathsquad was never acknowledged
	desc = "Enlist in the Nanotrasen Deathsquadron reserves today!"
	icon_state = "enlist"

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Nanomichi Ad"
	desc = " A poster advertising Nanomichi brand audio cassettes."
	icon_state = "nanomichi_ad"

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Gauge"
	desc = "A poster boasting about the superiority of 12 gauge shotgun shells."
	icon_state = "twelve_gauge"

/obj/structure/sign/poster/official/high_class_martini
	name = "High-Class Martini"
	desc = "I told you to shake it, no stirring."
	icon_state = "high_class_martini"

/obj/structure/sign/poster/official/the_owl
	name = "The Owl"
	desc = "The Owl would do his best to protect the station. Will you?"
	icon_state = "the_owl"

/obj/structure/sign/poster/official/no_erp
	name = "No ERP"
	desc = "This poster reminds the crew that Eroticism, Rape and Pornography are banned on Nanotrasen stations."
	icon_state = "no_erp"

/obj/structure/sign/poster/official/wtf_is_co2
	name = "Carbon Dioxide"
	desc = "This informational poster teaches the viewer what carbon dioxide is."
	icon_state = "wtf_is_co2"

/obj/structure/sign/poster/official/dick_gum
	name = "Dick Gumshue"
	desc = "A poster advertising the escapades of Dick Gumshue, mouse detective. Encouraging crew to bring the might of justice down upon wire saboteurs."
	icon_state = "dick_gum"

/obj/structure/sign/poster/official/there_is_no_gas_giant
	name = "There Is No Gas Giant"
	desc = "Nanotrasen has issued posters, like this one, to all stations reminding them that rumours of a gas giant are false."
	// And yet people still believe...
	icon_state = "there_is_no_gas_giant"

/obj/structure/sign/poster/official/periodic_table
	name = "Periodic Table of the Elements"
	desc = "A periodic table of the elements, from Hydrogen to Oganesson, and everything inbetween."
	icon_state = "periodic_table"

/obj/structure/sign/poster/official/plasma_effects
	name = "Plasma and the Body"
	desc = "This informational poster provides information on the effects of long-term plasma exposure on the brain."
	icon_state = "plasma_effects"

/obj/structure/sign/poster/official/plasma_effects/examine_more(mob/user)
	var/list/msg = list(span_notice("<i>You browse some of the poster's information...</i>"))
	msg += "\t[span_info("Plasma (scientific name Amenthium) is classified by TerraGov as a Grade 1 Health Hazard, and has significant risks to health associated with chronic exposure.")]"
	msg += "\t[span_info("Plasma is known to cross the blood/brain barrier and bioaccumulate in brain tissue, where it begins to result in degradation of brain function. The mechanism for attack is not yet fully known, and as such no concrete preventative advice is available barring proper use of PPE (gloves + protective jumpsuit + respirator).")]"
	msg += "\t[span_info("In small doses, plasma induces confusion, short-term amnesia, and heightened aggression. These effects persist with continual exposure.")]"
	msg += "\t[span_info("In individuals with chronic exposure, severe effects have been noted. Further heightened aggression, long-term amnesia, Alzheimer's symptoms, schizophrenia, macular degeneration, aneurysms, heightened risk of stroke, and Parkinsons symptoms have all been noted.")]"
	msg += "\t[span_info("It is recommended that all individuals in unprotected contact with raw plasma regularly check with company health officials.")]"
	msg += "\t[span_info("For more information, please check with TerraGov's extranet site on Amenthium: www.terra.gov/health_and_safety/amenthium/, or our internal risk-assessment documents (document numbers #47582-b (Plasma safety data sheets) and #64210 through #64225 (PPE regulations for working with Plasma), available via NanoDoc to all employees).")]"
	msg += "\t[span_info("Nanotrasen: Always looking after your health.")]"
	return msg

/obj/structure/sign/poster/official/terragov
	name = "TerraGov: United for Humanity"
	desc = "A poster depicting TerraGov's logo and motto, reminding viewers of who's looking out for humankind."
	icon_state = "terragov"

/obj/structure/sign/poster/official/corporate_perks_vacation
	name = "Nanotrasen Corporate Perks: Vacation"
	desc = "This informational poster provides information on some of the prizes available via the NT Corporate Perks program, including a two-week vacation for two on the resort world Idyllus."
	icon_state = "corporate_perks_vacation"

//SafetyMoth Original PR at https://github.com/BeeStation/BeeStation-Hornet/pull/1747 (Also pull/1982)
//SafetyMoth art credit goes to AspEv
/obj/structure/sign/poster/official/moth_hardhat
	name = "Safety Moth - Hardhats"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to wear hardhats in cautious areas. \"It's like a lamp for your head!\""
	icon_state = "aspev_hardhat"

/obj/structure/sign/poster/official/moth_piping
	name = "Safety Moth - Piping"
	desc = "This informational poster uses Safety Moth™ to tell atmospheric technicians correct types of piping to be used. \"Pipes, not Pumps! Proper pipe placement prevents poor performance!\""
	icon_state = "aspev_piping"

/obj/structure/sign/poster/official/moth_meth
	name = "Safety Moth - Methamphetamine"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to seek CMO approval before cooking methamphetamine. \"Stay close to the target temperature, and never go over!\" ...You shouldn't ever be making this."
	icon_state = "aspev_meth"

/obj/structure/sign/poster/official/moth_epi
	name = "Safety Moth - Epinephrine"
	desc = "This informational poster uses Safety Moth™ to inform the viewer to help injured/deceased crewmen with their epinephrine injectors. \"Prevent organ rot with this one simple trick!\""
	icon_state = "aspev_epi"

/obj/structure/sign/poster/official/moth_delam
	name = "Safety Moth - Delamination Safety Precautions"
	desc = "This informational poster uses Safety Moth™ to tell the viewer to hide in lockers when the Supermatter Crystal has delaminated, to prevent hallucinations. Evacuating might be a better strategy."
	icon_state = "aspev_delam"
//End of AspEv posters


#undef PLACE_SPEED
