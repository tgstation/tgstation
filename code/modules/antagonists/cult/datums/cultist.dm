/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = "FOR NAR'SIE!!"
	preview_outfit = /datum/outfit/cultist
	pref_flag = ROLE_CULTIST
	antag_hud_name = "cult"
	stinger_sound = 'sound/music/antag/bloodcult/bloodcult_gain.ogg'

	///Boolean on whether the starting equipment should be given to their inventory.
	var/give_equipment = FALSE
	///Reference to the Blood cult team they are part of.
	var/datum/team/cult/cult_team

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	if(!is_convertable_to_cult(new_owner.current, cult_team))
		return FALSE
	return ..()

/datum/antagonist/cult/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
	objectives |= cult_team.objectives
	. = ..()
	var/mob/living/current = owner.current
	if(give_equipment)
		equip_cultist(TRUE)

	var/datum/action/innate/cult/comm/communion = new(owner)
	communion.Grant(current)
	if(ishuman(current))
		var/datum/action/innate/cult/blood_magic/magic = new(owner)
		magic.Grant(current)

	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color=COLOR_CULT_RED)

/datum/antagonist/cult/on_removal()
	if (!owner.current)
		return ..()

	if(!silent)
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!"), ignored_mobs = owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color=COLOR_CULT_RED)

	for(var/datum/action/innate/cult/cult_buttons in owner.current.actions)
		qdel(cult_buttons)

	return ..()

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current || mob_override
	handle_clown_mutation(current, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= FACTION_CULT
	current.grant_language(/datum/language/narsie, source = LANGUAGE_CULTIST)

	current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

	if(cult_team.cult_risen)
		current.AddElement(/datum/element/cult_eyes, initial_delay = 0 SECONDS)
		ADD_TRAIT(current, TRAIT_DESENSITIZED, CULT_TRAIT)
	if(cult_team.cult_ascendent)
		current.AddElement(/datum/element/cult_halo, initial_delay = 0 SECONDS)

	ADD_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
	add_team_hud(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current || mob_override
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= FACTION_CULT
	current.remove_language(/datum/language/narsie, source = LANGUAGE_CULTIST)

	current.clear_alert("bloodsense")
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image

	if (HAS_TRAIT(current, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		current.RemoveElement(/datum/element/cult_eyes)
	if (HAS_TRAIT(current, TRAIT_CULT_HALO))
		current.RemoveElement(/datum/element/cult_halo)

	REMOVE_TRAIT(current, TRAIT_DESENSITIZED, CULT_TRAIT)
	REMOVE_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)

/datum/antagonist/cult/on_mindshield(mob/implanter)
	if(!silent)
		to_chat(owner.current, span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
	return

/datum/antagonist/cult/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has cult-ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has cult-ed [key_name(new_owner)].")

/datum/antagonist/cult/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src, PROC_REF(admin_give_dagger))
	.["Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_give_metal))
	.["Remove Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_take_all))

	if(is_cult_leader())
		.["Demote From Leader"] = CALLBACK(src, PROC_REF(demote_from_leader))
	else if(isnull(cult_team.cult_leader_datum))
		.["Make Cult Leader"] = CALLBACK(src, PROC_REF(make_cult_leader))

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

///Equips the cultist with a dagger and runed metal.
/datum/antagonist/cult/proc/equip_cultist(metal = TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(owner, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

///Attempts to make a new item and put it in a potential inventory slot in the provided mob.
/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/obj/item = new item_path(mob)
	ADD_TRAIT(item, TRAIT_CONTRABAND, INNATE_TRAIT)
	var/where = mob.equip_conspicuous_item(item)
	if(!where)
		to_chat(mob, span_userdanger("Unfortunately, you weren't able to get [item]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE

	to_chat(mob, span_danger("You have [item] in your [where]."))
	if(where == "backpack")
		mob.back.atom_storage?.show_contents(mob)
	return TRUE

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal = FALSE))
		to_chat(admin, span_danger("Spawning dagger failed!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal = TRUE))
		to_chat(admin, span_danger("Spawning runed metal failed!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	for(var/o in current.get_all_contents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

///Returns whether or not this datum is its team's leader.
/datum/antagonist/cult/proc/is_cult_leader()
	return (cult_team.cult_leader_datum == src)

///Turns this antag datum into its team's leader, assigning them their unique abilities, hud, and deathrattle.
/datum/antagonist/cult/proc/make_cult_leader()
	if(cult_team.cult_leader_datum)
		return FALSE

	cult_team.cult_leader_datum = src
	antag_hud_name = "cultmaster"
	add_team_hud(owner.current)
	RegisterSignal(owner.current, COMSIG_MOB_STATCHANGE, PROC_REF(deathrattle))

	if(!cult_team.reckoning_complete)
		var/datum/action/innate/cult/master/finalreck/reckoning = new
		reckoning.Grant(owner.current)
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new
	bloodmark.Grant(owner.current)
	throwing.Grant(owner.current)
	if(!cult_team.leader_passed_on)
		var/datum/action/innate/cult/master/pass_role/pass_role = new
		pass_role.Grant(owner.current)
	owner.current.update_mob_action_buttons()

	for(var/datum/mind/cult_mind as anything in cult_team.members)
		if (cult_mind != owner)
			to_chat(cult_mind.current, span_cult_large("[owner.current] is your cult's Master! \
				Follow [owner.current.p_their()] orders to the best of your ability!"))

	to_chat(owner.current, span_cult_large("<span class='warningplain'>You are the cult's Master</span>. \
		As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
		targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of \
		summoning the entire living cult to your location <b><i>once</i></b>. Use these abilities to direct the cult \
		to victory at any cost."))

	return TRUE

///Admin-only helper to demote someone from Cult leader, taking away their HUD, abilities, and deathrattle
/datum/antagonist/cult/proc/demote_from_leader()
	if(!cult_team.cult_leader_datum)
		return FALSE
	cult_team.cult_leader_datum = null

	antag_hud_name = initial(antag_hud_name)
	add_team_hud(owner.current)
	UnregisterSignal(owner.current, COMSIG_MOB_STATCHANGE)

	var/datum/action/innate/cult/master/finalreck/reckoning = locate() in owner.current.actions
	if(reckoning)
		reckoning.Remove(owner.current)
	var/datum/action/innate/cult/master/cultmark/bloodmark = locate() in owner.current.actions
	if(bloodmark)
		bloodmark.Remove(owner.current)
	var/datum/action/innate/cult/master/pulse/throwing = locate() in owner.current.actions
	if(throwing)
		throwing.Remove(owner.current)
	var/datum/action/innate/cult/master/pass_role/pass_role = locate() in owner.current.actions
	if(pass_role)
		pass_role.Remove(owner.current)
	owner.current.update_mob_action_buttons()
	to_chat(owner.current, span_cult_large("You have been demoted from being the cult's Master, you are now a mere acolyte!"))
	return TRUE

///If dead (and Narsie isn't summoned), will alert all Cultists of their death, sending their location out.
/datum/antagonist/cult/proc/deathrattle(datum/source)
	SIGNAL_HANDLER

	if(owner.current?.stat != DEAD)
		return
	if(!QDELETED(GLOB.cult_narsie))
		return
	if(!is_cult_leader())
		return

	var/area/current_area = get_area(owner.current)
	for(var/datum/mind/cult_mind as anything in cult_team.members)
		SEND_SOUND(cult_mind, sound('sound/effects/hallucinations/veryfar_noise.ogg'))
		to_chat(cult_mind, span_cult_large("The Cult's Master, [owner.current.name], has fallen in \the [current_area]!"))

/datum/antagonist/cult/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// The longsword is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/cultblade/longsword = new
	icon.Blend(icon(longsword.lefthand_file, longsword.inhand_icon_state), ICON_OVERLAY)
	qdel(longsword)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

///Used to check if the owner is counted as a secondary invoker for runes.
/datum/antagonist/cult/proc/check_invoke_validity()
	return TRUE
