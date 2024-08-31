/obj/effect/mob_spawn
	/// Do we use a random appearance for this role?
	var/random_appearance = TRUE

/obj/effect/mob_spawn/ghost_role
	/// set this to make the spawner use the outfit.name instead of its name var for things like cryo announcements and ghost records
	/// modifying the actual name during the game will cause issues with the GLOB.mob_spawners associative list
	var/use_outfit_name
	/// Can we use our loadout for this role?
	var/loadout_enabled = FALSE
	/// Can we use our quirks for this role?
	var/quirks_enabled = FALSE
	/// Are we limited to a certain species type? LISTED TYPE
	var/restricted_species

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname)
	var/load_prefs = FALSE
	//if we can load our own appearance and it's not restricted, try
	if(!random_appearance && mob_possessor?.client)
		//if we have gotten to this point, they have already waived their species pref.-- they were told they need to use the specific species already
		if((restricted_species && (mob_possessor?.client?.prefs?.read_preference(/datum/preference/choiced/species) in restricted_species)) || !restricted_species)
			var/appearance_choice = tgui_alert(mob_possessor, "Use currently loaded character preferences?", "Appearance Type", list("Yes", "No"))
			if(appearance_choice == "Yes")
				load_prefs = TRUE

	var/mob/living/spawned_mob = ..(mob_possessor, newname, load_prefs)

	var/mob/living/carbon/human/spawned_human
	if (istype(spawned_mob, /mob/living/carbon/human))
		spawned_human = spawned_mob

		if(!load_prefs)
			var/datum/language_holder/holder = spawned_human.get_language_holder()
			holder.get_selected_language() //we need this here so a language starts off selected

			return spawned_human

		spawned_human?.client?.prefs?.safe_transfer_prefs_to(spawned_human)
		spawned_human.dna.update_dna_identity()
		if(spawned_human.mind)
			spawned_human.mind.name = spawned_human.real_name // the mind gets initialized with the random name given as a result of the parent create() so we need to readjust it
		spawned_human.dna.species.give_important_for_life(spawned_human) // make sure they get plasmaman/vox internals etc before anything else

		if(quirks_enabled)
			SSquirks.AssignQuirks(spawned_human, spawned_human.client)

		post_transfer_prefs(spawned_human)

	if(load_prefs && loadout_enabled)
		spawned_human?.equip_outfit_and_loadout(outfit, spawned_mob.client.prefs)
	else if (!isnull(spawned_human))
		equip(spawned_human)

	return spawned_mob

/// This edit would cause somewhat ugly diffs, so I'm just replacing it.
/// Original proc in code/modules/mob_spawn/mob_spawn.dm ~line 39.
/obj/effect/mob_spawn/create(mob/mob_possessor, newname, is_pref_loaded)
	var/mob/living/spawned_mob = new mob_type(get_turf(src)) //living mobs only
	name_mob(spawned_mob, newname)
	special(spawned_mob, mob_possessor)
	if(!is_pref_loaded)
		equip(spawned_mob)
	return spawned_mob

// Anything that can potentially be overwritten by transferring prefs must go in this proc
// This is needed because safe_transfer_prefs_to() can override some things that get set in special() for certain roles, like name replacement
// In those cases, please override this proc as well as special()
// TODO: refactor create() and special() so that this is no longer necessary
/obj/effect/mob_spawn/ghost_role/proc/post_transfer_prefs(mob/living/new_spawn)
	return


/obj/effect/mob_spawn/ghost_role/human/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	var/mob/living/carbon/human/spawned_human = spawned_mob
	var/datum/job/spawned_job = SSjob.GetJobType(spawner_job_path)

	spawned_human.job = spawned_job.title

