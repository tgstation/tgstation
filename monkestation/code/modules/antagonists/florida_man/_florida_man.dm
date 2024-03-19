/datum/antagonist/florida_man
	name = "Space Florida Man"
	roundend_category = "Florida Men"
	antagpanel_category = "Florida Man"
	job_rank = ROLE_FLORIDA_MAN
	objectives = list()
	show_to_ghosts = TRUE
	preview_outfit = /datum/outfit/florida_man_one

/datum/antagonist/florida_man/on_gain()
	forge_objectives()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/floridan = owner.current

		//Abilities & Traits added here
		ADD_TRAIT(floridan, TRAIT_CLUMSY, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_DUMB, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_STABLELIVER, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_STABLEHEART, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_TOXIMMUNE, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_JAILBIRD, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_IGNORESLOWDOWN, SPECIES_TRAIT)
		ADD_TRAIT(floridan, TRAIT_VENTCRAWLER_NUDE, SPECIES_TRAIT)

		floridan.physiology.stun_mod = 0.25
		var/datum/action/cooldown/spell/florida_doorbuster/DB = new
		var/datum/action/cooldown/spell/florida_cuff_break/CB = new
		var/datum/action/cooldown/spell/florida_regeneration/RG = new
		DB.Grant(floridan)
		CB.Grant(floridan)
		RG.Grant(floridan)
	. = ..()


/datum/antagonist/florida_man/forge_objectives()
	var/datum/objective/meth = new /datum/objective
	var/list/selected_objective = pick(GLOB.florida_man_base_objectives)

	meth.owner = owner
	if(prob(25))
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]], [pick(GLOB.florida_man_objective_suffix)]"
	else
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]]."
	objectives += meth

/datum/antagonist/florida_man/greet()
	var/mob/living/carbon/floridan = owner.current

	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/ambience/antag/floridaman.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, "<span class='boldannounce'>You are THE Florida Man!\nYou're not quite sure how you got out here in space, but you don't generally bother thinking about things.\n\nYou love methamphetamine!\nYou love wrestling lizards!\nYou love getting drunk!\nYou love sticking it to THE MAN!\nYou don't act with any coherent plan or objective.\nYou don't outright want to destroy the station or murder people, as you have no home to return to.\n\nGo forth, son of Space Florida, and sow chaos!</span>")
	owner.announce_objectives()
	if(!prob(1)) // 1% chance to be Tony Brony...because meme references to streams are good!
		floridan.fully_replace_character_name(newname = "Florida Man")
	else
		floridan.fully_replace_character_name(newname = "Tony Brony")

/datum/antagonist/florida_man/antag_token(datum/mind/hosts_mind, mob/spender)
	. = ..()
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/florida_man_three)
		new_mob.mind.add_antag_datum(/datum/antagonist/florida_man)
	else
		hosts_mind.add_antag_datum(/datum/antagonist/florida_man)
