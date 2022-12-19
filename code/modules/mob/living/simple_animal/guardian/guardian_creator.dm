/obj/item/guardiancreator
	name = "enchanted deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "deck_tarot_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = span_holoparasite("You shuffle the deck...")
	var/used_message = span_holoparasite("All the cards seem to be blank now.")
	var/failure_message = span_boldholoparasite("..And draw a card! It's...blank? Maybe you should try again later.")
	var/ling_failure = span_boldholoparasite("The deck refuses to respond to a souless creature such as you.")
	var/list/possible_guardians = list("Assassin", "Charger", "Explosive", "Gaseous", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")
	var/random = TRUE
	var/allowmultiple = FALSE
	var/allowling = TRUE
	var/allowguardian = FALSE
	var/datum/antagonist/antag_datum_to_give

/obj/item/guardiancreator/attack_self(mob/living/user)
	if(isguardian(user) && !allowguardian)
		to_chat(user, span_holoparasite("[mob_name] chains are not allowed."))
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allowmultiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!"))
		return
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling) && !allowling)
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE
	to_chat(user, "[use_message]")
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, FALSE, 100, POLL_IGNORE_HOLOPARASITE)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick(candidates)
		spawn_guardian(user, candidate)
	else
		to_chat(user, "[failure_message]")
		used = FALSE


/obj/item/guardiancreator/proc/spawn_guardian(mob/living/user, mob/dead/candidate)
	var/guardiantype = "Standard"
	if(random)
		guardiantype = pick(possible_guardians)
	else
		guardiantype = tgui_input_list(user, "Pick the type of [mob_name]", "Guardian Creation", sort_list(possible_guardians))
		if(isnull(guardiantype) || !candidate.client)
			to_chat(user, "[failure_message]" )
			used = FALSE
			return
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/standard
	switch(guardiantype)

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/standard

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/support

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/explosive

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/guardian/lightning

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

		if("Assassin")
			pickedtype = /mob/living/simple_animal/hostile/guardian/assassin

		if("Dextrous")
			pickedtype = /mob/living/simple_animal/hostile/guardian/dextrous

		if("Gravitokinetic")
			pickedtype = /mob/living/simple_animal/hostile/guardian/gravitokinetic

		if("Gaseous")
			pickedtype = /mob/living/simple_animal/hostile/guardian/gaseous

	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allowmultiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!") )
		used = FALSE
		return
	var/mob/living/simple_animal/hostile/guardian/summoned_guardian = new pickedtype(user, theme)
	summoned_guardian.key = candidate.key
	summoned_guardian.set_summoner(user, different_person = TRUE)
	user.log_message("has summoned [key_name(summoned_guardian)], a [guardiantype] holoparasite.", LOG_GAME)
	summoned_guardian.log_message("was summoned as a [guardiantype] holoparsite.", LOG_GAME)
	switch(theme)
		if("tech")
			to_chat(user, "[summoned_guardian.tech_fluff_string]")
			to_chat(user, span_holoparasite("<b>[summoned_guardian.real_name]</b> is now online!"))
		if("magic")
			to_chat(user, "[summoned_guardian.magic_fluff_string]")
			to_chat(user, span_holoparasite("<b>[summoned_guardian.real_name]</b> has been summoned!"))
		if("carp")
			to_chat(user, "[summoned_guardian.carp_fluff_string]")
			to_chat(user, span_holoparasite("<b>[summoned_guardian.real_name]</b> has been caught!"))
		if("miner")
			to_chat(user, "[summoned_guardian.miner_fluff_string]")
			to_chat(user, span_holoparasite("<b>[summoned_guardian.real_name]</b> has appeared!"))
	summoned_guardian?.client.init_verbs()
	return summoned_guardian

/obj/item/guardiancreator/choose
	random = FALSE

/obj/item/guardiancreator/choose/dextrous
	possible_guardians = list("Assassin", "Charger", "Dextrous", "Explosive", "Gaseous", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")

/obj/item/guardiancreator/choose/wizard
	possible_guardians = list("Assassin", "Charger", "Dextrous", "Explosive", "Gaseous", "Lightning", "Protector", "Ranged", "Standard", "Gravitokinetic")
	allowmultiple = TRUE

/obj/item/guardiancreator/choose/wizard/spawn_guardian(mob/living/user, mob/dead/candidate)
	. = ..()
	var/mob/guardian = .
	if(!guardian)
		return

	var/datum/antagonist/wizard/antag_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(antag_datum)
		if(!antag_datum.wiz_team)
			antag_datum.create_wiz_team()
		guardian.mind.add_antag_datum(/datum/antagonist/wizard_minion, antag_datum.wiz_team)

/obj/item/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = span_holoparasite("You start to power on the injector...")
	used_message = span_holoparasite("The injector has already been used.")
	failure_message = span_boldholoparasite("...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.")
	ling_failure = span_boldholoparasite("The holoparasites recoil in horror. They want nothing to do with a creature like you.")

/obj/item/guardiancreator/tech/choose/traitor
	possible_guardians = list("Assassin", "Charger", "Explosive", "Gaseous", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")
	allowling = FALSE

/obj/item/guardiancreator/tech/choose
	random = FALSE

/obj/item/guardiancreator/tech/choose/dextrous
	possible_guardians = list("Assassin", "Charger", "Dextrous", "Explosive", "Gaseous", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")

/obj/item/paper/guides/antag/guardian
	name = "Holoparasite Guide"
	default_raw_text = {"<b>A list of Holoparasite Types</b><br>

<br>
<b>Assassin</b>: Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br>
<br>
<b>Charger</b>: Moves extremely fast, does medium damage on attack, and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding.<br>
<br>
<b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
<br>
<b>Gaseous</b>: Creates sparks on touch and continuously expels a gas of its choice. Automatically extinguishes the user if they catch on fire.<br>
<br>
<b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them, doing constant damage.<br>
<br>
<b>Protector</b>: Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower.<br>
<br>
<b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
<br>
<b>Standard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
<br>
<b>Gravitokinetic</b>: Attacks will apply crushing gravity to the target. Can target the ground as well to slow targets advancing on you, but this will affect the user.<br>
<br>
"}

/obj/item/paper/guides/antag/guardian/wizard
	name = "Guardian Guide"
	default_raw_text = {"<b>A list of Guardian Types</b><br>

<br>
<b>Assassin</b>: Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br>
<br>
<b>Charger</b>: Moves extremely fast, does medium damage on attack, and can charge at targets, damaging the first target hit and forcing them to drop any items they are holding.<br>
<br>
<b>Dexterous</b>: Does low damage on attack, but is capable of holding items and storing a single item within it. It will drop items held in its hands when it recalls, but it will retain the stored item.<br>
<br>
<b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
<br>
<b>Gaseous</b>: Creates sparks on touch and continuously expels a gas of its choice. Automatically extinguishes the user if they catch on fire.<br>
<br>
<b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them, doing constant damage.<br>
<br>
<b>Protector</b>: Causes you to teleport to it when out of range, unlike other parasites. Has two modes; Combat, where it does and takes medium damage, and Protection, where it does and takes almost no damage but moves slightly slower.<br>
<br>
<b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
<br>
<b>Standard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
<br>
<b>Gravitokinetic</b>: Attacks will apply crushing gravity to the target. Can target the ground as well to slow targets advancing on you, but this will affect the user.<br>
<br>
"}


/obj/item/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/storage/box/syndie_kit/guardian/PopulateContents()
	new /obj/item/guardiancreator/tech/choose/traitor(src)
	new /obj/item/paper/guides/antag/guardian(src)

/obj/item/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	theme = "carp"
	mob_name = "Holocarp"
	use_message = span_holoparasite("You put the fishsticks in your mouth...")
	used_message = span_holoparasite("Someone's already taken a bite out of these fishsticks! Ew.")
	failure_message = span_boldholoparasite("You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.")
	ling_failure = span_boldholoparasite("Carp'sie seems to not have taken you as the chosen one. Maybe it's because of your horrifying origin.")
	allowmultiple = TRUE

/obj/item/guardiancreator/carp/choose
	random = FALSE

/obj/item/guardiancreator/miner
	name = "dusty shard"
	desc = "Seems to be a very old rock, may have originated from a strange meteor."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "dustyshard"
	theme = "miner"
	mob_name = "Power Miner"
	use_message = span_holoparasite("You pierce your skin with the shard...")
	used_message = span_holoparasite("This shard seems to have lost all its power...")
	failure_message = span_boldholoparasite("The shard hasn't reacted at all. Maybe try again later...")
	ling_failure = span_boldholoparasite("The power of the shard seems to not react with your horrifying, mutated body.")
	possible_guardians = list("Charger", "Protector", "Ranged", "Standard", "Support")

/obj/item/guardiancreator/miner/choose
	random = FALSE
