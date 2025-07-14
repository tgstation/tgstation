// Divine vocal cords

/obj/item/organ/vocal_cords/colossus
	name = "divine vocal cords"
	desc = "They carry the voice of an ancient god."
	icon_state = "voice_of_god"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_mod = 1
	var/base_multiplier = 1
	spans = list("colossus","yell")

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/obj/item/organ/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target

/datum/action/item_action/organ_action/colossus/IsAvailable(feedback = FALSE)
	if(!owner)
		return FALSE
	if(world.time < cords.next_command)
		if (feedback)
			owner.balloon_alert(owner, "wait [DisplayTimeText(cords.next_command - world.time)]!")
		return FALSE
	if(isliving(owner))
		var/mob/living/living = owner
		if(!living.can_speak())
			if (feedback)
				owner.balloon_alert(owner, "can't speak!")
			return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			if (feedback)
				owner.balloon_alert(owner, "unconscious!")
			return FALSE
	return TRUE

/datum/action/item_action/organ_action/colossus/do_effect(trigger_flags)
	var/command = tgui_input_text(owner, "Speak with the Voice of God", "Command", max_length = MAX_MESSAGE_LEN)
	if(!command)
		return FALSE
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	owner.say(".x[command]")
	return TRUE

/obj/item/organ/vocal_cords/colossus/can_speak_with()
	if(!owner)
		return FALSE

	if(world.time < next_command)
		to_chat(owner, span_notice("You must wait [DisplayTimeText(next_command - world.time)] before Speaking again."))
		return FALSE

	return owner.can_speak()

/obj/item/organ/vocal_cords/colossus/handle_speech(message)
	playsound(get_turf(owner), 'sound/effects/magic/clockwork/invoke_general.ogg', 300, TRUE, 5)
	return //voice of god speaks for us

/obj/item/organ/vocal_cords/colossus/speak_with(message)
	var/cooldown = voice_of_god(uppertext(message), owner, spans, base_multiplier)
	next_command = world.time + (cooldown * cooldown_mod)

// Anomalous crystal

#define ACTIVATE_TOUCH "touch"
#define ACTIVATE_SPEECH "speech"
#define ACTIVATE_HEAT "heat"
#define ACTIVATE_BULLET "bullet"
#define ACTIVATE_ENERGY "energy"
#define ACTIVATE_BOMB "bomb"
#define ACTIVATE_MOB_BUMP "bumping"
#define ACTIVATE_WEAPON "weapon"
#define ACTIVATE_MAGIC "magic"

/obj/machinery/anomalous_crystal
	name = "anomalous crystal"
	desc = "A strange chunk of crystal, being in the presence of it fills you with equal parts excitement and dread."
	var/observer_desc = "Anomalous crystals have descriptions that only observers can see. But this one hasn't been changed from the default."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "anomaly_crystal"
	light_range = 8
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	anchored = FALSE
	density = TRUE
	var/activation_method
	var/list/possible_methods = list(ACTIVATE_TOUCH, ACTIVATE_SPEECH, ACTIVATE_HEAT, ACTIVATE_BULLET, ACTIVATE_ENERGY, ACTIVATE_BOMB, ACTIVATE_MOB_BUMP, ACTIVATE_WEAPON, ACTIVATE_MAGIC)
	var/activation_damage_type = null
	/// Cooldown on this crystal
	var/cooldown_add = 3 SECONDS
	/// Time needed to use this crystal
	var/use_time = 0
	/// If we are being used
	var/active = FALSE
	var/activation_sound = 'sound/effects/break_stone.ogg'
	COOLDOWN_DECLARE(cooldown_timer)

/obj/machinery/anomalous_crystal/Initialize(mapload)
	. = ..()
	if(!activation_method)
		activation_method = pick(possible_methods)
	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)

/obj/machinery/anomalous_crystal/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += observer_desc
		. += "It is activated by [activation_method]."

/obj/machinery/anomalous_crystal/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, radio_freq_name, radio_freq_color, spans, list/message_mods = list(), message_range)
	. = ..()
	if(isliving(speaker))
		ActivationReaction(speaker, ACTIVATE_SPEECH)

/obj/machinery/anomalous_crystal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	ActivationReaction(user, ACTIVATE_TOUCH)

/obj/machinery/anomalous_crystal/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(I.get_temperature())
		ActivationReaction(user, ACTIVATE_HEAT)
	else
		ActivationReaction(user, ACTIVATE_WEAPON)
	..()

/obj/machinery/anomalous_crystal/bullet_act(obj/projectile/proj, def_zone)
	. = ..()
	if(istype(proj, /obj/projectile/magic))
		ActivationReaction(proj.firer, ACTIVATE_MAGIC, proj.damage_type)
		return
	ActivationReaction(proj.firer, proj.armor_flag, proj.damage_type)

/obj/machinery/anomalous_crystal/proc/ActivationReaction(mob/user, method, damtype)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(activation_damage_type && activation_damage_type != damtype)
		return FALSE
	if(method != activation_method)
		return FALSE
	if(active)
		return FALSE
	if(use_time)
		charge_animation()
	COOLDOWN_START(src, cooldown_timer, cooldown_add)
	playsound(user, activation_sound, 100, TRUE)
	log_game("[src] activated by [key_name(user)] in [AREACOORD(src)]. The last fingerprints on the [src] was [fingerprintslast].")
	return TRUE

/obj/machinery/anomalous_crystal/proc/charge_animation()
	icon_state = "anomaly_crystal_charging"
	active = TRUE
	set_anchored(TRUE)
	balloon_alert_to_viewers("charging...")
	playsound(src, 'sound/effects/magic/disable_tech.ogg', 50, TRUE)
	sleep(use_time)
	icon_state = initial(icon_state)
	active = FALSE
	set_anchored(FALSE)
	return TRUE

/obj/machinery/anomalous_crystal/Bumped(atom/movable/AM)
	..()
	if(ismob(AM))
		ActivationReaction(AM, ACTIVATE_MOB_BUMP)

/obj/machinery/anomalous_crystal/ex_act()
	ActivationReaction(null, ACTIVATE_BOMB)
	return TRUE

/obj/machinery/anomalous_crystal/honk //Revives the dead, but strips and equips them as a clown
	observer_desc = "This crystal revives targets around it as clowns. Oh, that's horrible...."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/items/bikehorn.ogg'
	use_time = 3 SECONDS
	/// List of REFs to mobs that have been turned into a clown
	var/list/clowned_mob_refs = list()

/obj/machinery/anomalous_crystal/honk/ActivationReaction(mob/user)
	. = ..()
	if(!.)
		return FALSE

	for(var/atom/thing as anything in range(1, src))
		if(isturf(thing))
			new /obj/effect/decal/cleanable/confetti(thing)
			continue

		if(!ishuman(thing))
			continue

		var/mob/living/carbon/human/new_clown = thing

		if(new_clown.stat != DEAD)
			continue

		new_clown.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)

		var/clown_ref = REF(new_clown)
		if(clown_ref in clowned_mob_refs) //one clowning per person
			continue

		for(var/obj/item/to_strip in new_clown.get_equipped_items())
			new_clown.dropItemToGround(to_strip)
		new_clown.dress_up_as_job(SSjob.get_job_type(/datum/job/clown))
		clowned_mob_refs += clown_ref

	return TRUE

/// Transforms the area to look like a new one
/obj/machinery/anomalous_crystal/theme_warp
	observer_desc = "This crystal warps the area around it to a theme."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 20 SECONDS
	use_time = 5 SECONDS
	/// Theme which we turn areas into on activation
	var/datum/dimension_theme/terrain_theme
	/// List of all areas we've affected
	var/list/converted_areas = list()

/obj/machinery/anomalous_crystal/theme_warp/Initialize(mapload)
	. = ..()
	terrain_theme = SSmaterials.dimensional_themes[pick(subtypesof(/datum/dimension_theme))]
	observer_desc = "This crystal changes the area around it to match the theme of \"[terrain_theme.name]\"."

/obj/machinery/anomalous_crystal/theme_warp/ActivationReaction(mob/user, method)
	. = ..()
	if (!.)
		return FALSE
	var/area/current_area = get_area(src)
	if (current_area in converted_areas)
		return FALSE
	terrain_theme.apply_theme_to_list_of_turfs(current_area.get_turfs_from_all_zlevels())
	converted_areas += current_area
	return TRUE

/obj/machinery/anomalous_crystal/theme_warp/Destroy()
	terrain_theme = null
	converted_areas.Cut()
	return ..()

/obj/machinery/anomalous_crystal/emitter //Generates a projectile when interacted with
	observer_desc = "This crystal generates a projectile when activated."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 5 SECONDS
	var/obj/projectile/generated_projectile = /obj/projectile/colossus

/obj/machinery/anomalous_crystal/emitter/Initialize(mapload)
	. = ..()
	observer_desc = "This crystal generates \a [initial(generated_projectile.name)] when activated."

/obj/machinery/anomalous_crystal/emitter/ActivationReaction(mob/user, method)
	if(..())
		var/obj/projectile/proj = new generated_projectile(get_turf(src))
		proj.firer = src
		proj.fire(dir2angle(dir))

/obj/machinery/anomalous_crystal/dark_reprise //Revives anyone nearby, but turns them into shadowpeople and renders them uncloneable, so the crystal is your only hope of getting up again if you go down.
	observer_desc = "When activated, this crystal revives anyone nearby, but turns them into Shadowpeople and makes them unclonable, making the crystal their only hope of getting up again."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/effects/hallucinations/growl1.ogg'
	use_time = 3 SECONDS

/obj/machinery/anomalous_crystal/dark_reprise/ActivationReaction(mob/user, method)
	. = ..()
	if(!.)
		return FALSE

	for(var/atom/thing as anything in range(1, src))
		if(isturf(thing))
			new /obj/effect/temp_visual/cult/sparks(thing)
			continue

		if(!ishuman(thing))
			continue

		var/mob/living/carbon/human/to_revive = thing

		if(to_revive.stat != DEAD)
			continue

		to_revive.set_species(/datum/species/shadow, TRUE)
		to_revive.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)
		//Free revives, but significantly limits your options for reviving except via the crystal
		//except JK who cares about BADDNA anymore. this even heals suicides.
		ADD_TRAIT(to_revive, TRAIT_BADDNA, MAGIC_TRAIT)

	return TRUE

/obj/machinery/anomalous_crystal/helpers //Lets ghost spawn as helpful creatures that can only heal people slightly. Incredibly fragile and they can't converse with humans
	observer_desc = "This crystal allows ghosts to turn into a fragile creature that can heal people."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/effects/ghost2.ogg'
	use_time = 5 SECONDS
	var/ready_to_deploy = FALSE

/obj/machinery/anomalous_crystal/helpers/ActivationReaction(mob/user, method)
	if(..() && !ready_to_deploy)
		SSpoints_of_interest.make_point_of_interest(src)
		ready_to_deploy = TRUE
		notify_ghosts(
			"An anomalous crystal has been activated in [get_area(src)]! This crystal can always be used by ghosts hereafter.",
			source = src,
			header = "Anomalous crystal activated",
			click_interact = TRUE,
			ghost_sound = 'sound/effects/ghost2.ogg',
		)

/obj/machinery/anomalous_crystal/helpers/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(ready_to_deploy)
		var/be_helper = tgui_alert(usr, "Become a Lightgeist? (Warning, You can no longer be revived!)", "Lightgeist Deployment", list("Yes", "No"))
		if((be_helper == "Yes") && !QDELETED(src) && isobserver(user))
			var/mob/living/basic/lightgeist/deployable = new(get_turf(loc))
			deployable.PossessByPlayer(user.key)

/obj/machinery/anomalous_crystal/possessor //Allows you to bodyjack small animals, then exit them at your leisure, but you can only do this once per activation. Because they blow up. Also, if the bodyjacked animal dies, SO DO YOU.
	observer_desc = "When activated, this crystal allows you to take over small animals, and then exit them at the possessors leisure. Exiting the animal kills it, and if you die while possessing the animal, you die as well."
	activation_method = ACTIVATE_TOUCH
	use_time = 1 SECONDS

/obj/machinery/anomalous_crystal/possessor/ActivationReaction(mob/user, method)
	. = ..()
	if (!. || !ishuman(user))
		return FALSE

	var/list/valid_mobs = list()
	var/list/nearby_things = range(1, src)
	for(var/mob/living/basic/possible_mob in nearby_things)
		if (!is_valid_animal(possible_mob))
			continue
		valid_mobs += possible_mob
	for(var/mob/living/simple_animal/possible_mob in nearby_things)
		if (!is_valid_animal(possible_mob))
			continue
		valid_mobs += possible_mob

	if (!length(valid_mobs)) //Just in case there aren't any animals on the station, this will leave you with a terrible option to possess if you feel like it //i found it funny that in the file for a giant angel beast theres a cockroach
		new /mob/living/basic/cockroach/bloodroach(get_step(src,dir))
		return

	var/mob/living/picked_mob = pick(valid_mobs)
	var/obj/structure/closet/stasis/possessor_container = new /obj/structure/closet/stasis(picked_mob)
	user.forceMove(possessor_container)

/// Returns true if this is a mob you're allowed to possess
/obj/machinery/anomalous_crystal/possessor/proc/is_valid_animal(mob/living/check_mob)
	return check_mob.stat != DEAD && !check_mob.ckey && check_mob.mob_size < MOB_SIZE_LARGE && check_mob.melee_damage_upper <= 5


/obj/structure/closet/stasis
	name = "quantum entanglement stasis warp field"
	desc = "You can hardly comprehend this thing... which is why you can't see it."
	icon_state = null //This shouldn't even be visible, so if it DOES show up, at least nobody will notice
	enable_door_overlay = FALSE //For obvious reasons
	density = TRUE
	anchored = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	paint_jobs = null
	///The animal the closet (and the user's body) is inside of
	var/mob/living/holder_animal

/obj/structure/closet/stasis/Initialize(mapload)
	. = ..()
	if(isanimal_or_basicmob(loc))
		holder_animal = loc
		RegisterSignal(holder_animal, COMSIG_LIVING_DEATH, PROC_REF(on_holder_animal_death))
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/structure/closet/stasis/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && holder_animal)
		var/mob/living/possessor = arrived
		possessor.add_traits(list(TRAIT_UNDENSE, TRAIT_NO_TRANSFORM, TRAIT_GODMODE), STASIS_MUTE)
		possessor.mind.transfer_to(holder_animal)
		var/datum/action/exit_possession/escape = new(holder_animal)
		escape.Grant(holder_animal)
		remove_verb(holder_animal, /mob/living/verb/pulled)

/obj/structure/closet/stasis/dump_contents(kill = TRUE)
	for(var/mob/living/possessor in src)
		possessor.remove_traits(list(TRAIT_UNDENSE, TRAIT_NO_TRANSFORM, TRAIT_GODMODE), STASIS_MUTE)
		if(kill || !isanimal_or_basicmob(loc))
			possessor.investigate_log("has died from [src].", INVESTIGATE_DEATHS)
			possessor.death(FALSE)
		if(holder_animal)
			holder_animal.mind.transfer_to(possessor)
			possessor.mind.grab_ghost(force = TRUE)
			possessor.forceMove(get_turf(holder_animal))
			holder_animal.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			holder_animal.gib(DROP_ALL_REMAINS)
			return ..()
	return ..()

/obj/structure/closet/stasis/ex_act()
	return FALSE

///When our host animal dies in any way, we empty the stasis closet out.
/obj/structure/closet/stasis/proc/on_holder_animal_death()
	SIGNAL_HANDLER
	dump_contents()

/datum/action/exit_possession
	name = "Exit Possession"
	desc = "Exits the body you are possessing. They will explode violently when this occurs."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "exit_possession"

/datum/action/exit_possession/IsAvailable(feedback = FALSE)
	return ..() && isfloorturf(owner.loc)

/datum/action/exit_possession/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/structure/closet/stasis/stasis = locate() in owner
	if(!stasis)
		CRASH("[type] did not find a stasis closet thing in the owner.")

	stasis.dump_contents(FALSE)
	qdel(stasis)
	qdel(src)

#undef ACTIVATE_BOMB
#undef ACTIVATE_BULLET
#undef ACTIVATE_ENERGY
#undef ACTIVATE_HEAT
#undef ACTIVATE_MAGIC
#undef ACTIVATE_MOB_BUMP
#undef ACTIVATE_SPEECH
#undef ACTIVATE_TOUCH
#undef ACTIVATE_WEAPON
