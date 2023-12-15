/datum/antagonist/tiger_fanatic
	name = "Fanatic"
	antagpanel_category = "Other"
	job_rank = ROLE_TIGER_FANATIC
	show_name_in_check_antagonists = TRUE
	preview_outfit = /datum/outfit/tiger_fanatic
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "FOR THE HIVE!!"
	hardcore_random_bonus = TRUE
	ui_name = "AntagInfoTigerFanatic"
	var/blessings = 0

/datum/antagonist/tiger_fanatic/greet()
	. = ..()
	to_chat(owner.current, span_changeling("You worship the changeling hive!."))
	to_chat(owner.current, span_changeling("You have detected the pressence of the changeling hive mind, and have smuggled yourself aboard the station."))
	to_chat(owner.current, span_changeling("This is your one opertunity to make contact with a changeling, you must be assimilated into the hive in order to accend."))
	to_chat(owner.current, span_changeling("You have a weak connection to the changeling hivemind, your body has been conditioned to make you a perfect offering to the changelings."))
	owner.announce_objectives()

/datum/antagonist/tiger_fanatic/ui_data(mob/user)
	var/list/data = list()
	data["key"] = MODE_KEY_CHANGELING
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/tiger_fanatic/on_gain()
	owner.special_role = ROLE_TIGER_FANATIC
	SEND_SOUND(owner.current, sound('sound/effects/tiger_greeting.ogg'))
	forge_objectives()
	. = ..()

/datum/antagonist/tiger_fanatic/forge_objectives()
	var/datum/objective/be_absorbed/absorbed_escape/absorbed = new
	var/datum/objective/changeling_blessed/blessed = new
	absorbed.owner = owner
	blessed.owner = owner
	objectives += absorbed
	objectives += blessed
	. = ..()

/datum/objective/be_absorbed
	name = "be absorbed"
	explanation_text = "Be absorbed by a changeling so you may ascend to a higher level of being!"
	martyr_compatible = TRUE
	admin_grantable = TRUE
	var/player_absorbed = FALSE

/datum/objective/be_absorbed/check_completion()
	if(player_absorbed)
		return TRUE
	return FALSE


/datum/objective/be_absorbed/absorbed_escape
	name = "be absorbed"
	explanation_text = "Ascend by being absorbed by a changeling, or escape on the shuttle or an escape pod alive and without being in custody."
	martyr_compatible = TRUE
	admin_grantable = TRUE


/datum/objective/be_absorbed/absorbed_escape/check_completion()
	if(player_absorbed || considered_escaped(owner))
		return TRUE
	return FALSE

/datum/antagonist/tiger_fanatic/proc/receive_blessing()
	blessings += 1
	if(iscarbon(owner.current))
		var/mob/living/carbon/blessed_one = owner.current
		blessed_one.add_mood_event("tiger fanatic", /datum/mood_event/changeling_enjoyer)

/datum/objective/changeling_blessed
	name = "be blessed by a changeling"
	explanation_text = "Have a changeling use their powers on you 3 times."
	martyr_compatible = TRUE
	admin_grantable = TRUE
	completed = FALSE
	var/blessings_required = 3

/datum/objective/changeling_blessed/check_completion()
	var/datum/antagonist/tiger_fanatic/tiger_fanatic = owner.has_antag_datum(/datum/antagonist/tiger_fanatic)
	if(isnull(tiger_fanatic))
		return FALSE
	if(tiger_fanatic.blessings >= blessings_required)
		return TRUE
	return FALSE

/proc/create_tiger_fanatic(spawn_loc)
	var/mob/living/carbon/human/tiger = new(spawn_loc)
	tiger.randomize_human_appearance(~(RANDOMIZE_NAME|RANDOMIZE_SPECIES))
	tiger.equipOutfit(/datum/outfit/tiger_fanatic)
	var/obj/item/storage/backpack/satchel/flat/empty/stash = new(spawn_loc)
	new /obj/item/knife/combat(stash)
	new /obj/item/gun/ballistic/automatic/pistol/deagle(stash)
	new /obj/item/ammo_box/magazine/m50(stash)
	new /obj/item/grenade/chem_grenade/bioterrorfoam(stash)
	new /obj/item/card/emag/doorjack(stash)
	new /obj/item/reagent_containers/cup/glass/flask/ritual_wine(stash)
	tiger.put_in_hands(stash)
	return tiger
