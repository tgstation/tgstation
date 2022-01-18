/datum/component/dusting
	/// Consume all objects that bump into the atom. Only applies to dense atoms.
	var/consume_on_bumped = TRUE
	/// Consume when attacked by a mob
	var/consume_on_attack = TRUE
	/// Consume when attacked by a mob using an item
	var/consume_on_attackby = TRUE
	/// Consume when trying to get picked up by a mob
	var/consume_on_pickup = FALSE
	/// Consume when we are throw onto something
	var/consume_on_throw = TRUE
	/// If we consume the contents of atoms we consume as well. This ignores turfs regardless if consume_turfs is TRUE
	var/consume_all_contents = FALSE
	/// If we consume turfs
	var/consume_turfs = FALSE
	/// The sound to play when consuming something
	var/consumption_sound = 'sound/effects/supermatter.ogg'
	/// Radiation arguments for when we consume a specific atom
	var/list/radiation_atom = list(
		"default" = list("range"=6,"threshold"=0.6,"chance"=60),
		/obj = list("range"=3,"threshold"=0.1,"chance"=30),
	)
	/// Range to send consumption texts
	var/consume_text_range = 10
	/// Text to show to deaf people when something had been consumed. %parent% for parent this component is attached to, %target% to what got consumed
	var/consume_text_visual = span_danger("As %parent% slowly stops resonating, you find your skin covered in new radiation burns.")
	/// Audible text to show to people when something had been consumed. %parent% for parent this component is attached to, %target% to what got consumed
	var/consume_text_audible = span_danger("The unearthly ringing subsides and you find your skin covered in new radiation burns.")
	/// Audible text to show to people when they can't see what's being consumed, but are still in range to recieve consumtion messages. %parent% for parent this component is attached to, %target% to what got consumed
	var/consume_text_unseen = span_hear("An unearthly ringing fills your ears, and you find your skin covered in new radiation burns.")
	/// If a target has this flag, don't consume it
	var/ignore_flags = SUPERMATTER_IGNORES_1
	/// If a mob has this flag, don't consume it, along with ignore_flags
	var/ignore_status_flags = GODMODE
	/// Ignore subtypes of this type to consume. Becomes typecache list
	var/list/ignore_subtypesof = list(/obj/effect, /obj/item/scalpel/supermatter)

	/// Currently not sending any messages to admins to prevent chat spam. Not a bool
	var/ignoring_admin_messages = 0
	/// Skipping retype vars
	var/atom/atom_parent

/datum/component/dusting/Initialize(
	consume_on_bumped = TRUE,
	consume_on_attack = TRUE,
	consume_on_attackby = TRUE,
	consume_on_pickup = FALSE,
	consume_on_throw = TRUE,
	consume_all_contents = FALSE,
	consume_turfs = FALSE,
	consumption_sound = 'sound/effects/supermatter.ogg',
	list/radiation_atom = list(
		"default" = list("range"=6,"threshold"=0.6,"chance"=60),
		/obj = list("range"=3,"threshold"=0.1,"chance"=30),
	),
	consume_text_range = 10,
	consume_text_visual = span_danger("As %parent% slowly stops resonating, you find your skin covered in new radiation burns."),
	consume_text_audible = span_danger("The unearthly ringing subsides and you find your skin covered in new radiation burns."),
	consume_text_unseen = span_hear("An unearthly ringing fills your ears, and you find your skin covered in new radiation burns."),
	ignore_flags = SUPERMATTER_IGNORES_1,
	ignore_status_flags = GODMODE,
	ignore_subtypesof = list(/obj/effect, /obj/item/scalpel/supermatter),
	register_signals = TRUE,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	atom_parent = parent
	src.consume_on_bumped = consume_on_bumped
	src.consume_on_attack = consume_on_attack
	src.consume_on_attackby = consume_on_attackby
	src.consume_on_pickup = consume_on_pickup
	src.consume_on_throw = consume_on_throw
	src.consume_all_contents = consume_all_contents
	src.consume_turfs = consume_turfs
	src.consumption_sound = consumption_sound
	src.radiation_atom = radiation_atom
	src.consume_text_range = consume_text_range
	src.consume_text_visual = consume_text_visual
	src.consume_text_audible = consume_text_audible
	src.consume_text_unseen = consume_text_unseen
	src.ignore_flags = ignore_flags
	src.ignore_status_flags = ignore_status_flags
	src.ignore_subtypesof = typecacheof(ignore_subtypesof)

	if(register_signals) //For specifically the case of the supermatter, it has too much interaction
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ATOM_BULLET_ACT), .proc/attack_atom)
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/on_throw_impact)
		RegisterSignal(parent, COMSIG_ATOM_BUMPED, .proc/on_bumped)
		RegisterSignal(parent, list(\
			COMSIG_ATOM_ATTACK_HAND,
			COMSIG_ATOM_HULK_ATTACK,
			COMSIG_ATOM_ATTACK_ANIMAL,
			COMSIG_ATOM_ATTACK_BASIC_MOB,
			COMSIG_ATOM_ATTACK_PAW
			), .proc/on_attack_hand)

/datum/component/dusting/Destroy()
	UnregisterSignal(parent, list(\
		COMSIG_ITEM_ATTACK,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ITEM_PICKUP,
		COMSIG_MOVABLE_IMPACT,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_BASIC_MOB,
		COMSIG_ATOM_ATTACK_PAW,
		))
	return ..()


/datum/component/dusting/proc/attack_atom(datum/source, atom/attacked_atom, mob/living/user, params)
	SIGNAL_HANDLER
	if(consume_on_attack)
		if(consume_atom(attacked_atom))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/dusting/proc/on_attack_hand(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(consume_on_attack && isturf(atom_parent.loc)) //Prevent eating if it's in your inventory
		consume_atom(user)

/datum/component/dusting/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER
	if(consume_on_attackby && isturf(atom_parent.loc)) //Prevent eating if it's in your inventory
		consume_atom(attacking_item)

/datum/component/dusting/proc/on_pickup(datum/source, mob/user)
	SIGNAL_HANDLER
	if(consume_on_pickup)
		consume_atom(user)

/datum/component/dusting/proc/on_bumped(datum/source, atom/bumped_atom)
	SIGNAL_HANDLER
	if(consume_on_bumped)
		consume_atom(bumped_atom)

/datum/component/dusting/proc/on_throw_impact(datum/source, hit_atom, throwingdatum)
	SIGNAL_HANDLER
	if(consume_on_throw)
		consume_atom(hit_atom)

/datum/component/dusting/proc/consume_atom(atom/consumed_atom, currently_consuming_contents)
	if(consumed_atom.flags_1 & ignore_flags)
		return
	if(is_type_in_typecache(consumed_atom, ignore_subtypesof))
		return
	if(!consume_turfs && isturf(consumed_atom))
		return
	if(ismob(consumed_atom) && !isliving(consumed_atom)) //Don't kill ghosts/eyes somehow
		return
	if(ignoring_admin_messages == 1)
		ignoring_admin_messages = 2
		message_admins("[atom_parent] ([src.type]) has consumed multiple objects [ADMIN_JMP(atom_parent)].")

	//First, consume the contents
	if(consume_all_contents && !currently_consuming_contents)
		ignoring_admin_messages = 1
		for(var/atom/thing as anything in consumed_atom.get_all_contents())
			consume_atom(thing, TRUE)
		ignoring_admin_messages = 0
	
	//Next, consume the actual atom
	playsound(get_turf(parent), consumption_sound, 80, vary = TRUE)
	if(ismob(consumed_atom))
		var/mob/living/consumed_living = consumed_atom
		message_admins("[atom_parent] ([src.type]) has consumed [key_name_admin(consumed_living)] [ADMIN_JMP(atom_parent)].")
		atom_parent.investigate_log("has consumed [key_name(consumed_living)].", INVESTIGATE_SUPERMATTER)
		consumed_living.visible_message(span_danger("[consumed_living] slams into [atom_parent] inducing a resonance... [consumed_living.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into [atom_parent] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
		consumed_living.dust(force = TRUE)
	if(isobj(consumed_atom))
		var/obj/consumed_object = consumed_atom
		var/suspicion = ""
		if(consumed_object.fingerprintslast)
			suspicion = "last touched by [consumed_object.fingerprintslast]"
		if(!ignoring_admin_messages)
			message_admins("[atom_parent] has consumed [consumed_object], [suspicion] [ADMIN_JMP(atom_parent)].")
		atom_parent.investigate_log("has consumed [consumed_object] - [suspicion].", INVESTIGATE_SUPERMATTER)
		consumed_object.visible_message(span_danger("[consumed_object] smacks into [atom_parent] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
		qdel(consumed_object)
	if(isturf(consumed_atom))
		if(isspaceturf(consumed_atom)) //don't scrape away reality at its seams
			return
		var/turf/old_turf = consumed_atom
		var/turf/new_turf = old_turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		if(new_turf.type == old_turf.type)
			return
		new_turf.visible_message(span_danger("[atom_parent] consumes [old_turf] and reveals [new_turf] underneath."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))

	//Next, do radiation and give fluff text to nearby mobs
	. = TRUE

	var/radiation_array = "default"
	if(radiation_atom[atom_parent.type])
		radiation_array = atom_parent.type
	else
		var/actual_subtype //used to check the best subtype in the list without breaking early. if we broke early, obj/item would return an obj value when obj/item is also defined
		for(var/typepath in radiation_atom)
			if(istype(atom_parent, typepath) && (ispath(typepath, actual_subtype) || !actual_subtype))
				radiation_array = typepath
				actual_subtype = typepath

	var/range = radiation_atom[radiation_array]["range"]
	var/threshold = radiation_atom[radiation_array]["threshold"]
	var/chance = radiation_atom[radiation_array]["chance"]
	if(radiation_atom[radiation_array]?.len != 3) //helper to say "hey you forgot this"
		stack_trace("radiation_atom list length cannot be anything but 3 (returned as [radiation_atom[radiation_array]?.len])")

	if(!(range || threshold || chance)) //Don't continue w/ radiation nor its messages if any of these are set to 0
		warning("[type] tried to pulse radiation without the correct arguments. range=[range], threshold=[threshold], chance=[chance]") //Send a warning just in case this was never intended
		return
	radiation_pulse(parent, max_range = range, threshold = threshold, chance = chance)
	var/visual_message = rename_text(consume_text_visual, consumed_atom)
	var/audible_message = rename_text(consume_text_audible, consumed_atom)
	var/unseen_message = rename_text(consume_text_unseen, consumed_atom)
	for(var/mob/living/near_mob in range(consume_text_range, parent))
		if(HAS_TRAIT(near_mob, TRAIT_RADIMMUNE) || issilicon(near_mob))
			continue
		if(ishuman(near_mob) && SSradiation.wearing_rad_protected_clothing(near_mob))
			continue
		if(near_mob in view(consume_text_range, atom_parent))
			near_mob.show_message(visual_message, MSG_VISUAL, audible_message, MSG_AUDIBLE)
		else
			near_mob.show_message(unseen_message, MSG_AUDIBLE)
		atom_parent.investigate_log("has irradiated [key_name(near_mob)] after consuming [consumed_atom].", INVESTIGATE_SUPERMATTER)

//Helper proc
/datum/component/dusting/proc/rename_text(text, target)
	. = replacetext(text, "%parent%", "[atom_parent]")
	if(target)
		return replacetext(., "%target%", "\The [target]")
