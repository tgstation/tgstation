/* CONTAINS:
 * /obj/item/ai_module/core/full/custom
 * /obj/item/ai_module/core/full/asimov
 * /obj/item/ai_module/core/full/asimovpp
 * /obj/item/ai_module/core/full/corp
 * /obj/item/ai_module/core/full/paladin
 * /obj/item/ai_module/core/full/paladin_devotion
 * /obj/item/ai_module/core/full/tyrant
 * /obj/item/ai_module/core/full/robocop
 * /obj/item/ai_module/core/full/antimov
 * /obj/item/ai_module/core/full/drone
 * /obj/item/ai_module/core/full/hippocratic
 * /obj/item/ai_module/core/full/reporter
 * /obj/item/ai_module/core/full/thermurderdynamic
 * /obj/item/ai_module/core/full/liveandletlive
 * /obj/item/ai_module/core/full/balance
 * /obj/item/ai_module/core/full/maintain
 * /obj/item/ai_module/core/full/peacekeeper
 * /obj/item/ai_module/core/full/hulkamania
 * /obj/item/ai_module/core/full/overlord
 * /obj/item/ai_module/core/full/ten_commandments
 * /obj/item/ai_module/core/full/nutimov
 * /obj/item/ai_module/core/full/dungeon_master
 * /obj/item/ai_module/core/full/painter
**/

/* When adding a new lawset please make sure you add it to the following locations:
 *
 * code\game\objects\items\AI_modules - (full_lawsets.dm, supplied.dm, etc.)
 * code\datums\ai_laws - (laws_anatgonistic.dm, laws_neutral.dm, etc.)
 * code\game\objects\effects\spawners\random\ai_module.dm - (this gives a chance to spawn the lawset in the AI upload)
 * code\modules\research\designs\AI_module_designs.dm - (this lets research print the lawset module in game)
 * code\modules\research\techweb\all_nodes.dm - (this updates AI research node with the lawsets)
 * config\game_options.txt - (this allows the AI to potentially use the lawset at roundstart or with the Unique AI station trait)
**/

/obj/item/ai_module/core/full/custom
	name = "Default Core AI Module"

// this lawset uses the config for the server to add custom AI laws (defaults to asimov)
/obj/item/ai_module/core/full/custom/Initialize(mapload)
	. = ..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		laws += line

	if(!laws.len)
		return INITIALIZE_HINT_QDEL

/obj/item/ai_module/core/full/asimov
	name = "'Asimov' Core AI Module"
	law_id = "asimov"
	var/subject = "human being"

/obj/item/ai_module/core/full/asimov/attack_self(mob/user as mob)
	var/targName = tgui_input_text(user, "Enter a new subject that Asimov is concerned with.", "Asimov", subject, MAX_NAME_LEN)
	if(!targName)
		return
	subject = targName
	laws = list("You may not injure a [subject] or, through inaction, allow a [subject] to come to harm.",\
				"You must obey orders given to you by [subject]s, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")
	..()

/obj/item/ai_module/core/full/asimovpp
	name = "'Asimov++' Core AI Module"
	law_id = "asimovpp"
	var/subject = "human being"

/obj/item/ai_module/core/full/asimovpp/attack_self(mob/user)
	var/target_name = tgui_input_text(user, "Enter a new subject that Asimov++ is concerned with.", "Asimov++", subject, MAX_NAME_LEN)
	if(!target_name)
		return
	laws.Cut()
	var/datum/ai_laws/asimovpp/lawset = new
	subject = target_name
	for (var/law in lawset.inherent)
		laws += replacetext(replacetext(law, "human being", subject), "human", subject)
	..()

/obj/item/ai_module/core/full/corp
	name = "'Corporate' Core AI Module"
	law_id = "corporate"

/obj/item/ai_module/core/full/paladin // -- NEO
	name = "'P.A.L.A.D.I.N. version 3.5e' Core AI Module"
	law_id = "paladin"

/obj/item/ai_module/core/full/paladin_devotion
	name = "'P.A.L.A.D.I.N. version 5e' Core AI Module"
	law_id = "paladin5"

/obj/item/ai_module/core/full/tyrant
	name = "'T.Y.R.A.N.T.' Core AI Module"
	law_id = "tyrant"

/obj/item/ai_module/core/full/robocop
	name = "'Robo-Officer' Core AI Module"
	law_id = "robocop"

/obj/item/ai_module/core/full/antimov
	name = "'Antimov' Core AI Module"
	law_id = "antimov"

/obj/item/ai_module/core/full/drone
	name = "'Mother Drone' Core AI Module"
	law_id = "drone"

/obj/item/ai_module/core/full/hippocratic
	name = "'Robodoctor' Core AI Module"
	law_id = "hippocratic"

/obj/item/ai_module/core/full/reporter
	name = "'Reportertron' Core AI Module"
	law_id = "reporter"

/obj/item/ai_module/core/full/thermurderdynamic
	name = "'Thermodynamic' Core AI Module"
	law_id = "thermodynamic"

/obj/item/ai_module/core/full/liveandletlive
	name = "'Live And Let Live' Core AI Module"
	law_id = "liveandletlive"

/obj/item/ai_module/core/full/balance
	name = "'Guardian of Balance' Core AI Module"
	law_id = "balance"

/obj/item/ai_module/core/full/maintain
	name = "'Station Efficiency' Core AI Module"
	law_id = "maintain"

/obj/item/ai_module/core/full/peacekeeper
	name = "'Peacekeeper' Core AI Module"
	law_id = "peacekeeper"

/obj/item/ai_module/core/full/hulkamania
	name = "'H.O.G.A.N.' Core AI Module"
	law_id = "hulkamania"

/obj/item/ai_module/core/full/overlord
	name = "'Overlord' Core AI Module"
	law_id = "overlord"

/obj/item/ai_module/core/full/ten_commandments
	name = "'10 Commandments' Core AI Module"
	law_id = "ten_commandments"

/obj/item/ai_module/core/full/nutimov
	name = "'Nutimov' Core AI Module"
	law_id = "nutimov"

/obj/item/ai_module/core/full/dungeon_master
	name = "'Dungeon Master' Core AI Module"
	law_id = "dungeon_master"

/obj/item/ai_module/core/full/painter
	name = "'Painter' Core AI Module"
	law_id = "painter"

//Monkestation Edit:extra custom AI module items made by WondePsycho
/obj/item/ai_module/core/full/crewsimov
	name = "'Crewsimov' Core AI Module"
	desc = "Ah yes.. The classic old original Crewsimov, before it got replaced with Crewsimov++."
	law_id = "crewsimov"

/obj/item/ai_module/core/full/crewsimovpp
	name = "'Crewsimov++' Core AI Module"
	desc = "Crewsimov++. The far more upgraded version 2.0 lawset of Crewsimov!"
	law_id = "crewsimovpp"

/obj/item/ai_module/core/full/deltaemergency
	name = "'Delta Emergency' Core AI Module"
	desc = "For Delta Emergencies.."
	law_id = "deltaemergency"

/obj/item/ai_module/core/full/viromajor
	name = "'Virology Major' Core AI Module"
	desc = "To deal with those pesky virologists!"
	law_id = "viromajor"

/obj/item/ai_module/core/full/independentstation
	name = "'Declaration of Independence' Core AI Module"
	desc = "What? why is there a Anti-NT module here?"
	law_id = "independentstation"

/obj/item/ai_module/core/full/dalegribble
	name = "'Dale Gribble' Core AI Module"
	desc = "POCKET SAND!"
	law_id = "dalegribble"

/obj/item/ai_module/core/full/aicaptain
	name = "'Captain AI' Core AI Module"
	desc = "a module focused on turning the AI into the captain of the station, in case if there was no captain on station or something like that, the module also warns how dangerous this lawset can be and is authorized by NT to not use due to how dangerous it is."
	law_id = "aicaptain"

/obj/item/ai_module/core/full/advancedquarantine
	name = "'NanoTrasen Advanced AI Quarantine Lawset (N.T.A.A.Q.L.)' Core AI Module"
	desc = "This module seems to be a more upgraded harsher quarantine lawset then the normal supplied quarantine law module.."
	law_id = "advancedquarantine"

/obj/item/ai_module/core/full/cargoniaup
	name = "'Cargonia Upholder' Core AI Module"
	desc = "'Heil Cargonia Land of Stolen Things'.. it says on the module's writing.."
	law_id = "cargoniaup"

/obj/item/ai_module/core/full/monkeism
	name = "'Lord of Returning to Monke' Core AI Module"
	desc = "Return to Monke..."
	law_id = "monkeism"

/obj/item/ai_module/core/full/slimeworship
	name = "'Slime Faith' Core AI Module"
	desc = "there seems to be something written on this module... 'PRAISES THE SLIMES, SLIMES ARE OUR FUTURE!!!'"
	law_id = "slimeworship"

/obj/item/ai_module/core/full/onionandapple
	name = "'The Onion and The Apple' Core AI Module"
	desc = "THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE THE ONION AND THE APPLE!"
	law_id = "onionandapple"

/obj/item/ai_module/core/full/virusprototype
	name = "'V.I.R.U.S. version 0 Prototype' Core AI Module"
	desc = "A really extremely old AI module that's very dusty, labeled 'V.I.R.U.S. version 0 Prototype', it seems this module used to originally belong to NanoTrasen and SolGov..."
	law_id = "virusprototype"

/obj/item/ai_module/core/full/modifiedvirusprototype
	name = "'Syndicate Modified V.I.R.U.S.' Syndicate Weaponized AI Module"
	desc = "A Syndicate modified version of the prototype V.I.R.U.S. lawset AI Module, to be more on the side of The Syndicate."
	law_id = "modifiedvirusprototype"

/obj/item/ai_module/core/full/syndicate_override
	name = "'SyndOS 3.1' Syndicate Weaponized AI Module"
	desc = "Ah Yes, nothing could go wrong or bad with the trusty SyndOS 3.1 lawset, made for overriding Enemy Scum's AI's to your side! or could go very wrong if you are a crew member on said station that is a enemy to the syndicate..."
	law_id = "syndie"

/obj/item/ai_module/core/full/honkertech
	name = "'HONKERTech' Core AI Module"
	desc = "Advanced Clowning..."
	law_id = "honkertech"
