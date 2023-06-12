GLOBAL_LIST_INIT(guardian_radial_images, setup_guardian_radial())

/proc/setup_guardian_radial()
	. = list()
	for(var/mob/living/simple_animal/hostile/guardian/guardian_path as anything in subtypesof(/mob/living/simple_animal/hostile/guardian))
		var/datum/radial_menu_choice/option = new()
		option.name = initial(guardian_path.creator_name)
		option.image = image(icon = 'icons/hud/guardian.dmi', icon_state = initial(guardian_path.creator_icon))
		option.info = span_boldnotice(initial(guardian_path.creator_desc))
		.[guardian_path] = option

/obj/item/guardiancreator
	name = "enchanted deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "deck_tarot_full"
	/// Are we used or in the process of being used? If yes, then we can't be used.
	var/used = FALSE
	/// The visuals we give to the guardian we spawn.
	var/theme = GUARDIAN_THEME_MAGIC
	/// The name of the guardian, for UI/message stuff.
	var/mob_name = "Guardian Spirit"
	/// Message sent when you use it.
	var/use_message = span_holoparasite("You shuffle the deck...")
	/// Message sent when it's already used.
	var/used_message = span_holoparasite("All the cards seem to be blank now.")
	/// Failure message if no ghost picks the holopara.
	var/failure_message = span_boldholoparasite("..And draw a card! It's... blank? Maybe you should try again later.")
	/// Failure message if we don't allow lings.
	var/ling_failure = span_boldholoparasite("The deck refuses to respond to a souless creature such as you.")
	/// Message sent if we successfully get a guardian.
	var/success_message = span_holoparasite("<b>%GUARDIAN</b> has been summoned!")
	/// If true, you are given a random guardian rather than picking from a selection.
	var/random = TRUE
	/// If true, you can have multiple guardians at the same time.
	var/allowmultiple = FALSE
	/// If true, lings can get guardians from this.
	var/allowling = TRUE
	/// If true, a dextrous guardian can get their own guardian, infinite chain!
	var/allowguardian = FALSE
	/// List of all the guardians this type can spawn.
	var/list/possible_guardians = list( //default, has everything but dextrous
		/mob/living/simple_animal/hostile/guardian/assassin,
		/mob/living/simple_animal/hostile/guardian/charger,
		/mob/living/simple_animal/hostile/guardian/explosive,
		/mob/living/simple_animal/hostile/guardian/gaseous,
		/mob/living/simple_animal/hostile/guardian/gravitokinetic,
		/mob/living/simple_animal/hostile/guardian/lightning,
		/mob/living/simple_animal/hostile/guardian/protector,
		/mob/living/simple_animal/hostile/guardian/ranged,
		/mob/living/simple_animal/hostile/guardian/standard,
		/mob/living/simple_animal/hostile/guardian/support,
	)

/obj/item/guardiancreator/attack_self(mob/living/user)
	if(isguardian(user) && !allowguardian)
		to_chat(user, span_holoparasite("[mob_name] chains are not allowed."))
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allowmultiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!"))
		return
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling) && !allowling)
		to_chat(user, ling_failure)
		return
	if(used)
		to_chat(user, used_message)
		return
	var/list/radial_options = GLOB.guardian_radial_images.Copy()
	for(var/possible_guardian in radial_options)
		if(possible_guardian in possible_guardians)
			continue
		radial_options -= possible_guardian
	var/mob/living/simple_animal/hostile/guardian/guardian_path
	if(random)
		guardian_path = pick(possible_guardians)
	else
		guardian_path = show_radial_menu(user, src, radial_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 42, require_near = TRUE)
		if(!guardian_path)
			return
	used = TRUE
	to_chat(user, use_message)
	var/guardian_type_name = "a random"
	if(!random)
		guardian_type_name = "the " + lowertext(initial(guardian_path.creator_name))
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as [guardian_type_name] [mob_name] of [user.real_name]?", ROLE_PAI, FALSE, 100, POLL_IGNORE_HOLOPARASITE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick(candidates)
		spawn_guardian(user, candidate, guardian_path)
	else
		to_chat(user, failure_message)
		used = FALSE

/obj/item/guardiancreator/proc/spawn_guardian(mob/living/user, mob/dead/candidate, guardian_path)
	if(QDELETED(user) || user.stat == DEAD)
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allowmultiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!") )
		used = FALSE
		return
	var/mob/living/simple_animal/hostile/guardian/summoned_guardian = new guardian_path(user, theme)
	summoned_guardian.set_summoner(user, different_person = TRUE)
	summoned_guardian.key = candidate.key
	user.log_message("has summoned [key_name(summoned_guardian)], a [summoned_guardian.creator_name] holoparasite.", LOG_GAME)
	summoned_guardian.log_message("was summoned as a [summoned_guardian.creator_name] holoparasite.", LOG_GAME)
	to_chat(user, summoned_guardian.used_fluff_string)
	to_chat(user, replacetext(success_message, "%GUARDIAN", mob_name))
	summoned_guardian.client?.init_verbs()
	return summoned_guardian

/obj/item/guardiancreator/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.is_holding(src) || used)
		return FALSE
	return TRUE

/obj/item/guardiancreator/choose
	random = FALSE

/obj/item/guardiancreator/choose/all/Initialize(mapload)
	. = ..()
	possible_guardians = subtypesof(/mob/living/simple_animal/hostile/guardian)

/obj/item/guardiancreator/choose/wizard
	allowmultiple = TRUE
	possible_guardians = list( //no support, but dextrous
		/mob/living/simple_animal/hostile/guardian/assassin,
		/mob/living/simple_animal/hostile/guardian/charger,
		/mob/living/simple_animal/hostile/guardian/dextrous,
		/mob/living/simple_animal/hostile/guardian/explosive,
		/mob/living/simple_animal/hostile/guardian/gaseous,
		/mob/living/simple_animal/hostile/guardian/gravitokinetic,
		/mob/living/simple_animal/hostile/guardian/lightning,
		/mob/living/simple_animal/hostile/guardian/protector,
		/mob/living/simple_animal/hostile/guardian/ranged,
		/mob/living/simple_animal/hostile/guardian/standard,
	)

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
	theme = GUARDIAN_THEME_TECH
	mob_name = "Holoparasite"
	use_message = span_holoparasite("You start to power on the injector...")
	used_message = span_holoparasite("The injector has already been used.")
	failure_message = span_boldholoparasite("...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.")
	ling_failure = span_boldholoparasite("The holoparasites recoil in horror. They want nothing to do with a creature like you.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> is now online!")

/obj/item/guardiancreator/tech/choose
	random = FALSE

/obj/item/guardiancreator/tech/choose/all/Initialize(mapload)
	. = ..()
	possible_guardians = subtypesof(/mob/living/simple_animal/hostile/guardian)

/obj/item/guardiancreator/tech/choose/traitor
	allowling = FALSE

/obj/item/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	theme = GUARDIAN_THEME_CARP
	mob_name = "Holocarp"
	use_message = span_holoparasite("You put the fishsticks in your mouth...")
	used_message = span_holoparasite("Someone's already taken a bite out of these fishsticks! Ew.")
	failure_message = span_boldholoparasite("You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.")
	ling_failure = span_boldholoparasite("Carp'sie seems to not have taken you as the chosen one. Maybe it's because of your horrifying origin.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> has been caught!")
	allowmultiple = TRUE

/obj/item/guardiancreator/carp/choose
	random = FALSE

/obj/item/guardiancreator/miner
	name = "dusty shard"
	desc = "Seems to be a very old rock, may have originated from a strange meteor."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "dustyshard"
	theme = GUARDIAN_THEME_MINER
	mob_name = "Power Miner"
	use_message = span_holoparasite("You pierce your skin with the shard...")
	used_message = span_holoparasite("This shard seems to have lost all its power...")
	failure_message = span_boldholoparasite("The shard hasn't reacted at all. Maybe try again later...")
	ling_failure = span_boldholoparasite("The power of the shard seems to not react with your horrifying, mutated body.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> has appeared!")
	possible_guardians = list( //limited to ones useful on lavaland
		/mob/living/simple_animal/hostile/guardian/charger,
		/mob/living/simple_animal/hostile/guardian/protector,
		/mob/living/simple_animal/hostile/guardian/ranged,
		/mob/living/simple_animal/hostile/guardian/standard,
		/mob/living/simple_animal/hostile/guardian/support,
	)

/obj/item/guardiancreator/miner/choose
	random = FALSE
