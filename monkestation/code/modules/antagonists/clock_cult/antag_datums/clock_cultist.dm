/datum/antagonist/clock_cultist
	name = "\improper Clock Cultist"
	antagpanel_category = "Clock Cultist"
	preview_outfit = /datum/outfit/clock/preview
	job_rank = ROLE_CLOCK_CULTIST
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = ",r For Ratvar!!!"
	ui_name = "AntagInfoClock"
	show_to_ghosts = TRUE //to make testing easier
	antag_hud_name = "clockwork"
	/// If this one has access to conversion scriptures
	var/can_convert = TRUE
	/// Ref to the cultist's communication ability
	var/datum/action/innate/clockcult/comm/communicate = new
	/// Ref to the cultist's slab recall ability
	var/datum/action/innate/clockcult/recall_slab/recall = new
	///our cult team
	var/datum/team/clock_cult/clock_team
	///should we directly give them a slab or not
	var/give_slab = TRUE
	///our overlay for after the assault begins
	var/mutable_appearance/forbearance

/datum/antagonist/clock_cultist/Destroy()
	QDEL_NULL(communicate)
	return ..()

/datum/antagonist/clock_cultist/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	current.playsound_local(get_turf(owner.current), 'sound/magic/clockwork/scripture_tier_up.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	objectives |= clock_team.objectives
	if(give_slab)
		give_clockwork_slab(current)
	current.log_message("has been converted to the cult of Rat'var!", LOG_ATTACK, color="#960000")

//given_clock_team is provided by conversion methods
/datum/antagonist/clock_cultist/create_team(datum/team/clock_cult/given_clock_team)
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_OUTPOST_OF_COGS)
	if(!given_clock_team)
		if(GLOB.main_clock_cult)
			clock_team = GLOB.main_clock_cult
			return
		clock_team = new /datum/team/clock_cult
		clock_team.setup_objectives()
		return

	if(!istype(given_clock_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	clock_team = given_clock_team

/datum/antagonist/clock_cultist/get_team()
	return clock_team

/datum/antagonist/clock_cultist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= FACTION_CLOCK
	current.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	current.throw_alert("clockinfo", /atom/movable/screen/alert/clocksense)
	if(!istype(current, /mob/living/eminence))
		add_team_hud(current)
		communicate.Grant(current)
		recall.Grant(current)
		RegisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED, PROC_REF(switch_recall_slab))
		current.AddComponent(/datum/component/turf_healing, healing_types = list(TOX = 4), healing_turfs = list(/turf/open/floor/bronze, /turf/open/indestructible/reebe_flooring))
		handle_clown_mutation(current, mob_override ? null : "The light of Rat'var allows you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
		ADD_TRAIT(current, TRAIT_KNOW_ENGI_WIRES, CULT_TRAIT)
	if(ishuman(current) && GLOB.clock_ark)
		var/obj/structure/destructible/clockwork/the_ark/ark = GLOB.clock_ark
		if(ark.current_state >= 2) //active state value
			forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
			current.add_overlay(forbearance)

/datum/antagonist/clock_cultist/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= FACTION_CLOCK
	current.remove_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_CULTIST)
	current.clear_alert("clockinfo")
	if(!istype(current, /mob/living/eminence))
		communicate.Remove(current)
		recall.Remove(current)
		UnregisterSignal(current, COMSIG_CLOCKWORK_SLAB_USED)
		current.TakeComponent(/datum/component/turf_healing)
		handle_clown_mutation(current, removing = FALSE)
		ADD_TRAIT(current, TRAIT_KNOW_ENGI_WIRES, CULT_TRAIT)
	if(forbearance)
		current.cut_overlay(list(forbearance))

/datum/antagonist/clock_cultist/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_owner.current, for_clock_cult = TRUE)

/datum/antagonist/clock_cultist/on_removal()
	if(!silent)
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!"), ignored_mobs = owner.current)
		to_chat(owner.current, span_userdanger("As the ticking fades from the back of your mind, you forget all memories you had as a servant of Rat'var."))
	owner.current.log_message("has renounced the cult of Rat'var!", LOG_ATTACK, color="#960000")
	return ..()

/datum/antagonist/clock_cultist/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)
//	icon.Crop(-15, -15, 48, 48)
	// Move the guy back to the bottom left, 32x32.
//	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/clock_cultist/on_mindshield(mob/implanter)
	if(!silent)
		to_chat(owner.current, span_warning("You feel something pushing away the light of Rat'var, but you resist it!"))
	return

/datum/antagonist/clock_cultist/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has made [key_name_admin(new_owner)] into a servant of Rat'var.")
	log_admin("[key_name(admin)] has made [key_name(new_owner)] into a servant of Rat'var.")

/datum/antagonist/clock_cultist/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/clock_cultist/get_admin_commands()
	. = ..()
	.["Give Slab"] = CALLBACK(src, PROC_REF(admin_give_slab))
	.["Remove Slab"] = CALLBACK(src, PROC_REF(admin_take_slab))

/datum/antagonist/clock_cultist/proc/admin_take_slab(mob/admin)
	var/mob/living/current = owner.current
	for(var/object in current.get_all_contents())
		if(istype(object, /obj/item/clockwork/clockwork_slab))
			qdel(object)

/datum/antagonist/clock_cultist/proc/admin_give_slab(mob/admin)
	if(!give_clockwork_slab(owner.current))
		to_chat(admin, span_danger("Spawning clockwork slab failed!"))

//give a mob a slab directly into their inventory
/datum/antagonist/clock_cultist/proc/give_clockwork_slab(mob/living/carbon/human/give_to)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET)

	var/obj/item/clockwork/clockwork_slab/created_slab = new
	if(!give_to.equip_in_one_of_slots(created_slab, slots))
		to_chat(give_to, span_userdanger("Unfortunately, you weren't able to be given a [created_slab]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(give_to, span_danger("You have been given a [created_slab]."))
		return TRUE

/// Change the slab in the recall ability, if it's different from the last one.
/datum/antagonist/clock_cultist/proc/switch_recall_slab(datum/source, obj/item/clockwork/clockwork_slab/slab)
	if(slab == recall.marked_slab)
		return

	recall.unmark_item()
	recall.mark_item(slab)
	to_chat(owner.current, span_brass("You re-attune yourself to a new Clockwork Slab."))

/datum/antagonist/clock_cultist/eminence
	name = "Eminence"
	give_slab = FALSE
	antag_moodlet = null
	show_to_ghosts = TRUE
	communicate = null
	recall = null
	//all our innate actions
	var/datum/action/innate/clockcult/space_fold/trigger_events = new
	var/datum/action/cooldown/eminence/purge_reagents/remove_water = new
	var/datum/action/cooldown/eminence/linked_abscond/recall_servant = new
	var/datum/action/innate/clockcult/teleport_to_servant/find_servant = new
	var/datum/action/innate/clockcult/teleport_to_station/to_station = new
	var/datum/action/innate/clockcult/eminence_abscond/return_home = new

/datum/antagonist/clock_cultist/eminence/Destroy()
	QDEL_NULL(trigger_events)
	return ..()

/datum/antagonist/clock_cultist/eminence/greet()
	to_chat(owner.current, span_bigbrass("You are the Eminence, a being bound to Rat'var. By his light you are able to influence nearby space and time."))
	to_chat(owner.current, span_brass("Your abilities: As the Eminence you have access to various abilities, they are as follows. \
									   You may click on various machines to interface with them or a servant to mark them."))
	to_chat(owner.current, span_brass("Purge Reagents: Remove all reagents from the bloodstream of a marked servant, this is useful for a servant who is being deconverted by holy water."))
	to_chat(owner.current, span_brass("Linked Abscond: Return a marked servant and anything they are pulling to reebe, this has a lengthy cooldown and they must remain still for 7 seconds."))
	to_chat(owner.current, span_brass("Space Fold: Fold local spacetime to ensure certain \"events\" are inflicted upon the station, while doing this will cost cogs, \
									   these cogs are not taken from the cult itself. The cooldown is based on the cog cost of the event."))
	to_chat(owner.current, span_brass("You can also open doors and windoors as well as interact with buttons."))

/datum/antagonist/clock_cultist/eminence/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	add_team_hud(current, /datum/antagonist/clock_cultist)
	trigger_events.Grant(current)
	remove_water.Grant(current)
	recall_servant.Grant(current)
	find_servant.Grant(current)
	to_station.Grant(current)
	return_home.Grant(current)

//should never happen but still dont want runtimes in case it does
/datum/antagonist/clock_cultist/eminence/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	trigger_events.Remove(current)
	remove_water.Remove(current)
	recall_servant.Remove(current)
	find_servant.Remove(current)
	to_station.Remove(current)
	return_home.Remove(current)

/datum/antagonist/clock_cultist/eminence/on_removal() //this should never happen without an admin being involved, something has gone wrong
	to_chat(owner.current, span_userdanger("You lost your eminence antagonist status! This should not happen and you should ahelp(f1) unless you are already talking to an admin."))
	return ..()

/datum/outfit/clock/preview
	name = "Clock Cultist (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/clockwork
	head = /obj/item/clothing/head/helmet/clockwork
	l_hand = /obj/item/clockwork/weapon/brass_sword


/datum/antagonist/clock_cultist/solo
	name = "Clock Cultist (Solo)"
	can_convert = FALSE
