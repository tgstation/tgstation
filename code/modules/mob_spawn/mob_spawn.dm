/obj/effect/mob_spawn
	name = "Mob Spawner"
	density = TRUE
	anchored = TRUE
	//So it shows up in the map editor
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "mobspawner"
	/// Can this spawner be used up?
	var/infinite_use = FALSE
	///A forced name of the mob, though can be overridden if a special name is passed as an argument
	var/mob_name
	///the type of the mob, you best inherit this
	var/mob_type = /mob/living/basic/cockroach

	////Human specific stuff. Don't set these if you aren't using a human, the unit tests will put a stop to your sinful hand.

	///sets the human as a species, use a typepath (example: /datum/species/skeleton)
	var/datum/species/mob_species
	///equips the human with an outfit.
	var/datum/outfit/outfit
	///for mappers to override parts of the outfit. really only in here for secret away missions, please try to refrain from using this out of laziness
	var/list/outfit_override
	///sets a human's hairstyle
	var/hairstyle
	///sets a human's facial hair
	var/facial_hairstyle
	///sets a human's hair color (use special for gradients, sorry)
	var/haircolor
	///sets a human's facial hair color
	var/facial_haircolor
	///sets a human's skin tone
	var/skin_tone
	/// Weakref to the mob this spawner created - just if you needed to do something with it.
	var/datum/weakref/spawned_mob_ref

/obj/effect/mob_spawn/Initialize(mapload)
	. = ..()
	if(faction)
		faction = string_list(faction)

/obj/effect/mob_spawn/Destroy()
	spawned_mob_ref = null
	if(istype(outfit))
		QDEL_NULL(outfit)
	return ..()

/**
 * Creates whatever mob the spawner makes.
 *
 * * mob_possessor - The ghost/mob that is possessing this mob, if applicable
 * * newname - A forced name for the mob, if applicable
 * * apply_prefs - Whether we should apply the possessor's preferences to the mob, if applicable
 *
 * Returns
 * - the created mob
 * - CANCEL_SPAWN if the spawn process should be stopped
 * - null if the spawn failed (and something went wrong)
 */
/obj/effect/mob_spawn/proc/create(mob/mob_possessor, newname, apply_prefs)
	SHOULD_NOT_SLEEP(TRUE)

	var/mob/living/spawned_mob = new mob_type(get_turf(src)) //living mobs only
	special(spawned_mob, mob_possessor, apply_prefs)
	name_mob(spawned_mob, newname)
	equip(spawned_mob)
	spawned_mob_ref = WEAKREF(spawned_mob)
	return spawned_mob

/**
 * Any special behavior that needs to be done to the mob after it's created but before it's equipped.
 *
 * * spawned_mob - The mob that was created
 * * mob_possessor - The ghost/mob that is possessing this mob, if applicable
 * * apply_prefs - Whether we should apply the possessor's preferences to the mob, if applicable
 */
/obj/effect/mob_spawn/proc/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	SHOULD_CALL_PARENT(TRUE)
	if(faction)
		spawned_mob.faction = faction
	if(ishuman(spawned_mob))
		var/mob/living/carbon/human/spawned_human = spawned_mob
		if(mob_species)
			spawned_human.set_species(mob_species)
		spawned_human.dna.species.give_important_for_life(spawned_human) // for preventing plasmamen from combusting immediately upon spawning
		spawned_human.underwear = "Nude"
		spawned_human.undershirt = "Nude"
		spawned_human.socks = "Nude"
		randomize_human_normie(spawned_human)
		if(hairstyle)
			spawned_human.set_hairstyle(hairstyle, update = FALSE)
		if(facial_hairstyle)
			spawned_human.set_facial_hairstyle(facial_hairstyle, update = FALSE)
		if(haircolor)
			spawned_human.set_haircolor(haircolor, update = FALSE)
		if(facial_haircolor)
			spawned_human.set_facial_haircolor(facial_haircolor, update = FALSE)
		spawned_human.update_body(is_creating = TRUE)

/obj/effect/mob_spawn/proc/name_mob(mob/living/spawned_mob, forced_name)
	var/chosen_name
	//passed arguments on mob spawns are number one priority
	if(forced_name)
		chosen_name = forced_name
	//then the mob name var
	else if(mob_name)
		chosen_name = mob_name
	//then if no name was chosen the one the mob has by default works great
	if(!chosen_name)
		return
	//not using an old name doesn't update records- but ghost roles don't have records so who cares
	spawned_mob.fully_replace_character_name(null, chosen_name)

/obj/effect/mob_spawn/proc/equip(mob/living/spawned_mob)
	if(outfit)
		var/mob/living/carbon/human/spawned_human = spawned_mob
		if(outfit_override)
			outfit = new outfit //create it now to apply vars
			for(var/outfit_var in outfit_override)
				if(!ispath(outfit_override[outfit_var]) && !isnull(outfit_override[outfit_var]))
					CRASH("outfit_override var on [mob_name] spawner has incorrect values! it must be an assoc list with outfit \"var\" = path | null")
				outfit.vars[outfit_var] = outfit_override[outfit_var]
		spawned_human.equipOutfit(outfit)

///these mob spawn subtypes do not trigger until attacked by a ghost.
/obj/effect/mob_spawn/ghost_role
	///a short, lowercase name for the mob used in possession prompt that pops up on ghost attacks. must be set.
	var/prompt_name = ""
	///if false, you won't prompt for this role. best used for replacing the prompt system with something else like a radial, or something.
	var/prompt_ghost = TRUE
	///how many times this spawner can be used (it won't delete unless it's out of uses and the var to delete itself is set)
	var/uses = 1
	/// Does the spawner delete itself when it runs out of uses?
	var/deletes_on_zero_uses_left = TRUE
	///bitflag that determines if players can spawn in as their statics
	var/allow_custom_character = NONE

	////descriptions

	///This should be the declaration of what the ghost role is, and maybe a short blurb after if you want. Shown in the spawner menu and after spawning first.
	var/you_are_text = ""
	///This should be the actual instructions/description/context to the ghost role. This should be the really long explainy bit, basically.
	var/flavour_text = ""
	///This is critical non-policy information about the ghost role. Shown in the spawner menu and after spawning last.
	var/important_text = ""

	///Show these on spawn? Usually used for hardcoded special flavor
	var/show_flavor = TRUE

	////bans and policy

	///which role to check for a job ban (ROLE_LAVALAND is the default ghost role ban)
	var/role_ban = ROLE_LAVALAND
	/// Typepath indicating the kind of job datum this ghost role will have. PLEASE inherit this with a new job datum, it's not hard. jobs come with policy configs.
	var/spawner_job_path = /datum/job/ghost_role

	/// Whether this offers a temporary body or not. Essentially, you'll be able to reenter your body after using this spawner.
	var/temp_body = FALSE


/obj/effect/mob_spawn/ghost_role/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)
	LAZYADD(GLOB.mob_spawners[format_text(name)], src)

/obj/effect/mob_spawn/ghost_role/Destroy()
	var/list/spawners = GLOB.mob_spawners[format_text(name)]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= format_text(name)
	return ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/ghost_role/attack_ghost(mob/dead/observer/user)
	if(!SSticker.HasRoundStarted() || isnull(loc) || QDELETED(src))
		return

	// Lazylist of the ckeys that currently are trying to access any spawner, so that they can't try to spawn more than once (in case there's sleeps).
	var/static/list/ckeys_trying_to_spawn
	if(LAZYFIND(ckeys_trying_to_spawn, user.ckey))
		return
	if(uses <= 0 && !infinite_use)
		to_chat(user, span_warning("This spawner is out of charges!"))
		return FALSE
	if(!can_ghost_take(user))
		return FALSE

	uses -= 1 // Remove a use EARLY to account for sleep / inputs
	var/user_ckey = user.ckey // Just in case shenanigans happen, we always want to remove it from the list.
	LAZYADD(ckeys_trying_to_spawn, user_ckey)

	var/prompt_fail = FALSE
	var/apply_prefs = FALSE
	if(prompt_ghost)
		var/prompt = "Become [prompt_name]?"
		if(!temp_body && user.can_reenter_corpse && user.mind)
			prompt += " (Warning, You can no longer be revived!)"
		prompt_fail = tgui_alert(user, prompt, buttons = list("Yes", "No"), timeout = 10 SECONDS) != "Yes"

	var/species_pref = user.client.prefs.read_preference(/datum/preference/choiced/species) || /datum/species/human
	if(!prompt_fail && user.started_as_observer && allow_custom_character && (GLOB.species_prototypes[species_pref].inherent_respiration_type & RESPIRATION_OXYGEN))
		var/static_prompt = "Because you haven't taken a role so far, you may spawn in as \
			[((allow_custom_character & GHOSTROLE_TAKE_PREFS_SPECIES) || species_pref == /datum/species/human) ? "" : "a human version of"] \
			your customized character with a random name. Would you like to?"
		apply_prefs = tgui_alert(user, static_prompt, "Custom Character", list("Yes", "No"), 10 SECONDS) == "Yes"

	if(!prompt_fail && !pre_ghost_take(user))
		prompt_fail = TRUE

	if(prompt_fail || !can_ghost_take(user) || !create_from_ghost(user, apply_prefs, subtract_uses = FALSE))
		uses += 1
	LAZYREMOVE(ckeys_trying_to_spawn, user_ckey)

/// Allows for modifications before the ghost is turned into a mob.
/// You can put sleeps or inputs in here, sanity checking is done for you after this proc returns.
/// Returning FALSE will cancel the spawn process.
/obj/effect/mob_spawn/ghost_role/proc/pre_ghost_take(mob/dead/observer/user)
	return TRUE

/// Checks if a ghost can take this ghost role.
/obj/effect/mob_spawn/ghost_role/proc/can_ghost_take(mob/dead/observer/user)
	if(is_banned_from(user.ckey, role_ban))
		to_chat(user, span_warning("You are banned from this role!"))
		return FALL_STOP_INTERCEPTING
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, span_warning("An admin has temporarily disabled non-admin ghost roles!"))
		return FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!allow_spawn(user, silent = FALSE))
		return FALSE
	return TRUE

/**
 * Uses a use and creates a mob from a passed ghost
 *
 * Does NOT validate that the spawn is possible or valid - assumes this has been done already!
 *
 * If you are manually forcing a player into this mob spawn,
 * you should be using this and not directly calling [proc/create].
 *
 * * * user - The ghost/mob that is possessing this mob
 * * * apply_prefs - Whether we should apply the possessor's preferences to the mob
 * * * subtract_uses - Whether to subtract a use from the spawner.
 * Set to FALSE if you want to handle uses manually elsewhere.
 */
/obj/effect/mob_spawn/ghost_role/proc/create_from_ghost(mob/dead/observer/user, apply_prefs, subtract_uses = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	ASSERT(istype(user))

	user.log_message("became a [prompt_name].", LOG_GAME)
	if(!temp_body)
		user.mind = null // dissassociate mind, don't let it follow us to the next life

	var/mob/created = create(user, apply_prefs = apply_prefs)
	if(ismob(created))
		SEND_SIGNAL(src, COMSIG_GHOSTROLE_SPAWNED, created)
		if(subtract_uses)
			uses -= 1
		check_uses()
	else if(isnull(created)) // null instead of explicit CANCEL_SPAWN means something went wrong
		CRASH("An instance of [type] didn't return anything when creating a mob, this might be broken!")

	return created

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname, apply_prefs)
	if(!mob_possessor.key) // This is in the scenario that the server is somehow lagging, or someone fucked up their code, and we try to spawn the same person in twice. We'll simply not spawn anything and CRASH(), so that we report what happened.
		CRASH("Attempted to create an instance of [type] with a mob that had no ckey attached to it, which isn't supported by ghost role spawners!")

	return ..()

/obj/effect/mob_spawn/ghost_role/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	if(mob_possessor)
		if(mob_possessor.client && apply_prefs && allow_custom_character && ishuman(spawned_mob))
			var/mob/living/carbon/human/spawned_human = spawned_mob
			if(allow_custom_character & GHOSTROLE_TAKE_PREFS_APPEARANCE)
				mob_possessor.client.prefs.apply_prefs_to(spawned_human, icon_updates = TRUE, do_not_apply = typesof(/datum/preference/name, /datum/preference/choiced/species))
			if(allow_custom_character & GHOSTROLE_TAKE_PREFS_SPECIES)
				spawned_human.set_species(mob_possessor.client.prefs.read_preference(/datum/preference/choiced/species))
				spawned_human.fully_replace_character_name(spawned_human.real_name, spawned_human.generate_random_mob_name())
		if(mob_possessor.mind)
			mob_possessor.mind.transfer_to(spawned_mob, force_key_move = TRUE)
		else
			spawned_mob.PossessByPlayer(mob_possessor.key)

	var/datum/mind/spawned_mind = spawned_mob.mind
	if(spawned_mind)
		spawned_mob.mind.set_assigned_role_with_greeting(SSjob.get_job_type(spawner_job_path))
		spawned_mind.name = spawned_mob.real_name
	if(show_flavor)
		var/output_message = span_infoplain("<span class='big bold'>[you_are_text]</span>")
		if(flavour_text != "")
			output_message += "\n<span class='infoplain'><b>[flavour_text]</b></span>"
		if(important_text != "")
			output_message += "\n[span_userdanger("[important_text]")]"
		to_chat(spawned_mob, output_message)

/// Checks if the spawner has zero uses left, if so, delete yourself... NOW!
/obj/effect/mob_spawn/ghost_role/proc/check_uses()
	if(!uses && deletes_on_zero_uses_left)
		qdel(src)

///override this to add special spawn conditions to a ghost role
/obj/effect/mob_spawn/ghost_role/proc/allow_spawn(mob/user, silent = FALSE)
	return TRUE

///these mob spawn subtypes trigger immediately (New or Initialize) and are not player controlled... since they're dead, you know?
/obj/effect/mob_spawn/corpse
	density = FALSE //these are pretty much abstract objects that leave a corpse in their place.
	///when this mob spawn should auto trigger.
	var/spawn_when = CORPSE_INSTANT

	////damage values (very often, mappers want corpses to be mangled)

	///brute damage this corpse will spawn with
	var/brute_damage = 0
	///oxy damage this corpse will spawn with
	var/oxy_damage = 0
	///burn damage this corpse will spawn with
	var/burn_damage = 0

	///what environmental storytelling script should this corpse have
	var/corpse_description = ""
	///optionally different text to display if the target is a clown
	var/naive_corpse_description = ""

/obj/effect/mob_spawn/corpse/Initialize(mapload, no_spawn)
	. = ..()
	if(no_spawn)
		return
	switch(spawn_when)
		if(CORPSE_INSTANT)
			INVOKE_ASYNC(src, PROC_REF(create))
		if(CORPSE_ROUNDSTART)
			if(mapload || (SSticker && SSticker.current_state > GAME_STATE_SETTING_UP))
				INVOKE_ASYNC(src, PROC_REF(create))

/obj/effect/mob_spawn/corpse/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.death(TRUE)
	spawned_mob.adjust_oxy_loss(oxy_damage)
	spawned_mob.adjust_brute_loss(brute_damage)
	spawned_mob.adjust_fire_loss(burn_damage)
	if (corpse_description)
		spawned_mob.AddComponent(/datum/component/temporary_description, corpse_description, naive_corpse_description)

/obj/effect/mob_spawn/corpse/create(mob/mob_possessor, newname, apply_prefs)
	. = ..()
	qdel(src)

//almost all mob spawns in this game, dead or living, are human. so voila

/obj/effect/mob_spawn/ghost_role/human
	//gives it a base sprite instead of a mapping helper. makes sense, right?
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_type = /mob/living/carbon/human

/obj/effect/mob_spawn/corpse/human
	icon_state = "corpsehuman"
	mob_type = /mob/living/carbon/human
	///disables PDA and sensors. only makes sense on corpses because ghost roles could simply turn those on again.
	var/conceal_presence = TRUE
	///husks the corpse if true.
	var/husk = FALSE

/obj/effect/mob_spawn/corpse/human/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	. = ..()
	if(husk)
		spawned_human.Drain()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		spawned_human.cure_husk()
	spawned_human.job = name

/obj/effect/mob_spawn/corpse/human/equip(mob/living/carbon/human/spawned_human)
	. = ..()
	if(conceal_presence)
		// We don't want corpse PDAs to show up in the messenger list.
		var/obj/item/modular_computer/pda/messenger = locate() in spawned_human
		if(messenger)
			var/datum/computer_file/program/messenger/message_app = locate() in messenger.stored_files
			if(message_app)
				message_app.invisible = TRUE
		// Or on crew monitors
		var/obj/item/clothing/under/sensor_clothes = spawned_human.w_uniform
		if(istype(sensor_clothes))
			sensor_clothes.set_sensor_mode(SENSOR_OFF)

//don't use this in subtypes, just add 1000 brute yourself. that being said, this is a type that has 1000 brute. it doesn't really have a home anywhere else, it just needs to exist
/obj/effect/mob_spawn/corpse/human/damaged
	brute_damage = 1000

/obj/effect/mob_spawn/cockroach
	name = "Cockroach Spawner"
	desc = "A spawner for cockroaches, the most common vermin in the station. Small chance to spawn a bloodroach."
	mob_type = /mob/living/basic/cockroach
	var/bloodroach_chance = 1 // 1% chance to spawn a bloodroach

/obj/effect/mob_spawn/cockroach/Initialize(mapload)
	if(prob(bloodroach_chance))
		mob_type = /mob/living/basic/cockroach/bloodroach
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(create))
	qdel(src)
