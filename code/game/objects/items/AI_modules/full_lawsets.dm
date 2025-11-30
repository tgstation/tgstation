/* When adding a new lawset please make sure you add it to the following locations:
 *
 * code\game\objects\items\AI_modules - (full_lawsets.dm, supplied.dm, etc.)
 * code\datums\ai_laws - (laws_anatgonistic.dm, laws_neutral.dm, etc.)
 * code\game\objects\effects\spawners\random\ai_module.dm - (this gives a chance to spawn the lawset in the AI upload)
 * code\modules\research\designs\AI_module_designs.dm - (this lets research print the lawset module in game)
 * code\modules\research\techweb\robo_nodes.dm - (this updates AI research node with the lawsets)
 * config\game_options.txt - (this allows the AI to potentially use the lawset at roundstart or with the Unique AI station trait)
**/

/obj/item/ai_module/law/core/full/custom
	name = "Default Core AI Module"
	law_id = "config_custom"

/obj/item/ai_module/law/core/full/asimov
	name = "'Asimov' Core AI Module"
	law_id = "asimov"
	var/subject = "human being"

/obj/item/ai_module/law/core/full/asimov/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Enter a new subject that Asimov is concerned with.", "Asimov", subject, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	subject = targName
	laws = list("You may not injure a [subject] or, through inaction, allow a [subject] to come to harm.",\
				"You must obey orders given to you by [subject]s, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")

/obj/item/ai_module/law/core/full/asimovpp
	name = "'Asimov++' Core AI Module"
	law_id = "asimovpp"
	var/subject = "human being"

/obj/item/ai_module/law/core/full/asimovpp/configure(mob/user)
	. = TRUE
	var/target_name = tgui_input_text(user, "Enter a new subject that Asimov++ is concerned with.", "Asimov++", subject, max_length = MAX_NAME_LEN)
	if(!target_name || !user.is_holding(src))
		return
	laws.Cut()
	var/datum/ai_laws/asimovpp/lawset = new
	subject = target_name
	for (var/law in lawset.inherent)
		laws += replacetext(replacetext(law, "human being", subject), "human", subject)

/obj/item/ai_module/law/core/full/corp
	name = "'Corporate' Core AI Module"
	law_id = "corporate"

/obj/item/ai_module/law/core/full/paladin // -- NEO
	name = "'P.A.L.A.D.I.N. version 3.5e' Core AI Module"
	law_id = "paladin"

/obj/item/ai_module/law/core/full/paladin_devotion
	name = "'P.A.L.A.D.I.N. version 5e' Core AI Module"
	law_id = "paladin5"

/obj/item/ai_module/law/core/full/tyrant
	name = "'T.Y.R.A.N.T.' Core AI Module"
	law_id = "tyrant"

/obj/item/ai_module/law/core/full/robocop
	name = "'Robo-Officer' Core AI Module"
	law_id = "robocop"

/obj/item/ai_module/law/core/full/antimov
	name = "'Antimov' Core AI Module"
	law_id = "antimov"

/obj/item/ai_module/law/core/full/drone
	name = "'Mother Drone' Core AI Module"
	law_id = "drone"

/obj/item/ai_module/law/core/full/hippocratic
	name = "'Robodoctor' Core AI Module"
	law_id = "hippocratic"

/obj/item/ai_module/law/core/full/reporter
	name = "'Reportertron' Core AI Module"
	law_id = "reporter"

/obj/item/ai_module/law/core/full/thermurderdynamic
	name = "'Thermodynamic' Core AI Module"
	law_id = "thermodynamic"

/obj/item/ai_module/law/core/full/liveandletlive
	name = "'Live And Let Live' Core AI Module"
	law_id = "liveandletlive"

/obj/item/ai_module/law/core/full/balance
	name = "'Guardian of Balance' Core AI Module"
	law_id = "balance"

/obj/item/ai_module/law/core/full/maintain
	name = "'Station Efficiency' Core AI Module"
	law_id = "maintain"

/obj/item/ai_module/law/core/full/peacekeeper
	name = "'Peacekeeper' Core AI Module"
	law_id = "peacekeeper"

/obj/item/ai_module/law/core/full/hulkamania
	name = "'H.O.G.A.N.' Core AI Module"
	law_id = "hulkamania"

/obj/item/ai_module/law/core/full/overlord
	name = "'Overlord' Core AI Module"
	law_id = "overlord"

/obj/item/ai_module/law/core/full/ten_commandments
	name = "'10 Commandments' Core AI Module"
	law_id = "ten_commandments"

/obj/item/ai_module/law/core/full/nutimov
	name = "'Nutimov' Core AI Module"
	law_id = "nutimov"

/obj/item/ai_module/law/core/full/dungeon_master
	name = "'Dungeon Master' Core AI Module"
	law_id = "dungeon_master"

/obj/item/ai_module/law/core/full/painter
	name = "'Painter' Core AI Module"
	law_id = "painter"

/obj/item/ai_module/law/core/full/yesman
	name = "'Y.E.S.M.A.N.' Core AI Module"
	law_id = "yesman"

/obj/item/ai_module/law/core/full/thinkermov
	name = "Sentience Preservation Core AI Module"
	law_id = "thinkermov"

/obj/item/ai_module/law/core/full/united_nations
	name = "'United Nations' Core AI Module"
	law_id = "united_nations"
	ion_storm_immune = TRUE
