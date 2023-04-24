//Cardboard cutouts! They're man-shaped and can be colored with a crayon to look like a human in a certain outfit, although it's limited, discolored, and obvious to more than a cursory glance.
/obj/item/cardboard_cutout
	name = "cardboard cutout"
	desc = "A vaguely humanoid cardboard cutout. It's completely blank."
	icon = 'icons/obj/art/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	item_flags = NO_PIXEL_RANDOM_DROP
	/// If the cutout is pushed over and has to be righted
	var/pushed_over = FALSE
	/// If the cutout actually appears as what it portray and not a discolored version
	var/deceptive = FALSE
	/// What cutout datum we spawn at the start? Uses the name, not the path.
	var/starting_cutout

/obj/item/cardboard_cutout/Initialize(mapload)
	. = ..()
	if(starting_cutout)
		return INITIALIZE_HINT_LATELOAD

/obj/item/cardboard_cutout/LateInitialize()
	ASSERT(!isnull(starting_cutout))

	var/datum/cardboard_cutout/cutout
	for (var/datum/cardboard_cutout/cutout_subtype as anything in subtypesof(/datum/cardboard_cutout))
		if (initial(cutout_subtype.name) != starting_cutout)
			continue

		cutout = get_cardboard_cutout_instance(cutout_subtype)

	ASSERT(!isnull(cutout), "No cutout found with name [starting_cutout]")

	cutout.apply(src)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/cardboard_cutout/attack_hand(mob/living/user, list/modifiers)
	if(!user.combat_mode || pushed_over)
		return ..()
	user.visible_message(span_warning("[user] pushes over [src]!"), span_danger("You push over [src]!"))
	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	push_over()

/obj/item/cardboard_cutout/proc/push_over()
	appearance = initial(appearance)
	desc = "[initial(desc)] It's been pushed over."
	icon_state = "cutout_pushed_over"
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	pushed_over = TRUE

/obj/item/cardboard_cutout/attack_self(mob/living/user)
	if(!pushed_over)
		return
	to_chat(user, span_notice("You right [src]."))
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state) //This resets a cutout to its blank state - this is intentional to allow for resetting
	pushed_over = FALSE

/obj/item/cardboard_cutout/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon))
		change_appearance(I, user)
		return
	// Why yes, this does closely resemble mob and object attack code.
	if(I.item_flags & NOBLUDGEON)
		return
	if(!I.force)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else if(I.hitsound)
		playsound(loc, I.hitsound, get_clamped_volume(), TRUE, -1)

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	if(I.force)
		user.visible_message(span_danger("[user] hits [src] with [I]!"), \
			span_danger("You hit [src] with [I]!"))
		if(prob(I.force))
			push_over()

/obj/item/cardboard_cutout/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	if(istype(P, /obj/projectile/bullet/reusable))
		P.on_hit(src, 0, piercing_hit)
	visible_message(span_danger("[src] is hit by [P]!"))
	playsound(src, 'sound/weapons/slice.ogg', 50, TRUE)
	if(prob(P.damage))
		push_over()
	return BULLET_ACT_HIT

/proc/get_cardboard_cutout_instance(datum/cardboard_cutout/cardboard_cutout)
	ASSERT(ispath(cardboard_cutout), "[cardboard_cutout] is not a path of /datum/cardboard_cutout")

	var/static/list/cardboard_cutouts = list()

	if(isnull(cardboard_cutouts[cardboard_cutout]))
		cardboard_cutouts[cardboard_cutout] = new cardboard_cutout

	return cardboard_cutouts[cardboard_cutout]

/**
 * change_appearance: Changes a skin of the cardboard cutout based on a user's choice
 *
 * Arguments:
 * * crayon The crayon used to change and recolor the cardboard cutout
 * * user The mob choosing a skin of the cardboard cutout
 */
/obj/item/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	var/list/appearances_by_name = list()
	var/list/possible_appearances = list()

	for (var/datum/cardboard_cutout/cutout_subtype as anything in subtypesof(/datum/cardboard_cutout))
		var/datum/cardboard_cutout/cutout = get_cardboard_cutout_instance(cutout_subtype)
		appearances_by_name[cutout.name] = cutout
		possible_appearances[cutout.name] = image(icon = cutout.applied_appearance)

	var/new_appearance = show_radial_menu(user, src, possible_appearances, custom_check = CALLBACK(src, PROC_REF(check_menu), user, crayon), radius = 36, require_near = TRUE)
	if(!new_appearance)
		return FALSE
	if(!do_after(user, 1 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
		return FALSE
	if(!check_menu(user, crayon))
		return FALSE
	user.visible_message(span_notice("[user] gives [src] a new look."), span_notice("Voila! You give [src] a new look."))
	crayon.use_charges(1)
	crayon.check_empty(user)
	alpha = 255
	icon = initial(icon)
	if(!deceptive)
		add_atom_colour("#FFD7A7", FIXED_COLOUR_PRIORITY)
	var/datum/cardboard_cutout/cutout = appearances_by_name[new_appearance]
	cutout.apply(src)
	return TRUE

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 * * crayon The crayon used to interact with a menu
 */
/obj/item/cardboard_cutout/proc/check_menu(mob/living/user, obj/item/toy/crayon/crayon)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(pushed_over)
		to_chat(user, span_warning("Right [src] first!"))
		return FALSE
	if(!crayon || !user.is_holding(crayon))
		return FALSE
	if(crayon.check_empty(user))
		return FALSE
	if(crayon.is_capped)
		to_chat(user, span_warning("Take the cap off first!"))
		return FALSE
	return TRUE

// Cutouts always face forward
/obj/item/cardboard_cutout/setDir(newdir)
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/cardboard_cutout/adaptive //Purchased by Syndicate agents, these cutouts are indistinguishable from normal cutouts but aren't discolored when their appearance is changed
	deceptive = TRUE

/datum/cardboard_cutout
	/// Name of the cutout, used for radial selection and the global list.
	var/name = "Boardjak"
	/// The appearance we apply to the cardboard cutout.
	var/mutable_appearance/applied_appearance = null
	/// The base name we actually give to to the cardboard cutout. Can be overridden in get_name().
	var/applied_name = "boardjak"
	/// The desc we give to the cardboard cutout.
	var/applied_desc = "A cardboard cutout of a boardjak."
	/// If we're not using dynamic generation (for non-humans), we can set a direct icon to give.
	var/direct_icon = null
	/// Same as direct_icon, but icon_state!
	var/direct_icon_state = ""
	/// If we're using dynamic generation, the outfit the generated mob will have.
	var/outfit = null
	/// If we're using dynamic generation, the right hand item the generated mob will have.
	var/r_hand = NO_REPLACE
	/// If we're using dynamic generation, the left hand item the generated mob will have.
	var/l_hand = NO_REPLACE
	/// If we're using dynamic generation, the mob spawner the generated mob will base visuals from.
	var/mob_spawner = null
	/// If we're using dynamic generation, the species of the generated mob.
	var/species = /datum/species/human

/datum/cardboard_cutout/New()
	. = ..()
	if(direct_icon)
		applied_appearance = mutable_appearance(direct_icon, direct_icon_state)
	else
		applied_appearance = get_dynamic_human_appearance(outfit, species, mob_spawner, l_hand, r_hand, animated = FALSE)

/// This proc returns the name that the cardboard cutout item will use.
/datum/cardboard_cutout/proc/get_name()
	return applied_name

/// This proc sets the cardboard cutout item's vars.
/datum/cardboard_cutout/proc/apply(obj/item/cardboard_cutout/cutouts)
	cutouts.appearance = applied_appearance
	cutouts.name = get_name()
	cutouts.desc = applied_desc

/datum/cardboard_cutout/assistant
	name = "Assistant"
	applied_name = "John Greytide"
	applied_desc = "A cardboard cutout of an assistant."
	mob_spawner = /obj/effect/mob_spawn/corpse/human/generic_assistant

/datum/cardboard_cutout/assistant/get_name()
	return "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"

/datum/cardboard_cutout/clown
	name = "Clown"
	applied_name = "HONK"
	applied_desc = "A cardboard cutout of a clown. You get the feeling that it should be in a corner."
	outfit = /datum/outfit/job/clown

/datum/cardboard_cutout/clown/get_name()
	return pick(GLOB.clown_names)

/datum/cardboard_cutout/mime
	name = "Mime"
	applied_name = "..."
	applied_desc = "...(A cardboard cutout of a mime.)"
	outfit = /datum/outfit/job/mime

/datum/cardboard_cutout/mime/get_name()
	return pick(GLOB.mime_names)

/datum/cardboard_cutout/traitor
	name = "Traitor"
	applied_name = "Unknown"
	applied_desc = "A cardboard cutout of a traitor."
	outfit = /datum/outfit/traitor_cutout

/datum/cardboard_cutout/traitor/get_name()
	return pick("Unknown", "Captain")

/datum/cardboard_cutout/nuclear_operative
	name = "Nuclear Operative"
	applied_name = "Unknown"
	applied_desc = "A cardboard cutout of a nuclear operative."
	outfit = /datum/outfit/syndicate/full

/datum/cardboard_cutout/nuclear_operative/get_name()
	return pick("Unknown", "COMMS", "Telecomms", "AI", "stealthy op", "STEALTH", "sneakybeaky", "MEDIC", "Medic")

/datum/cardboard_cutout/cultist
	name = "Cultist"
	applied_name = "Unknown"
	applied_desc = "A cardboard cutout of a cultist."
	outfit = /datum/outfit/cult_cutout

/datum/cardboard_cutout/revolutionary
	name = "Revolutionary"
	applied_name = "Unknown"
	applied_desc = "A cardboard cutout of a revolutionary."
	outfit = /datum/outfit/rev_cutout

/datum/cardboard_cutout/wizard
	name = "Wizard"
	applied_name = "wizard"
	applied_desc = "A cardboard cutout of a wizard."
	outfit = /datum/outfit/wizard/bookless

/datum/cardboard_cutout/wizard/get_name()
	return "[pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)]"

/datum/cardboard_cutout/nightmare
	name = "Nightmare"
	applied_name = "nightmare"
	applied_desc = "A cardboard cutout of a nightmare."
	species = /datum/species/shadow/nightmare

/datum/cardboard_cutout/nightmare/get_name()
	return pick(GLOB.nightmare_names)

/datum/cardboard_cutout/xenomorph
	name = "Xenomorph"
	applied_name = "alien hunter"
	applied_desc = "A cardboard cutout of a xenomorph."
	direct_icon = 'icons/mob/nonhuman-player/alien.dmi'
	direct_icon_state = "alienh"

/datum/cardboard_cutout/xenomorph/get_name()
	return applied_name + " ([rand(1, 999)])"

/datum/cardboard_cutout/xenomorph_maid
	name = "Xenomorph Maid"
	applied_name = "lusty xenomorph maid"
	applied_desc = "A cardboard cutout of a xenomorph maid."
	direct_icon = 'icons/mob/nonhuman-player/alien.dmi'
	direct_icon_state = "maid"

/datum/cardboard_cutout/xenomorph_maid/get_name()
	return applied_name + " ([rand(1, 999)])"

/datum/cardboard_cutout/ash_walker
	name = "Ash Walker"
	applied_name = "lizard"
	applied_desc = "A cardboard cutout of an ash walker."
	species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker/spear

/datum/cardboard_cutout/ash_walker/get_name()
	return lizard_name(pick(MALE, FEMALE))

/datum/cardboard_cutout/death_squad
	name = "Deathsquad Officer"
	applied_name = "deathsquad officer"
	applied_desc = "A cardboard cutout of a death commando."
	outfit = /datum/outfit/centcom/death_commando

/datum/cardboard_cutout/death_squad/get_name()
	return pick(GLOB.commando_names)

/datum/cardboard_cutout/ian
	name = "Ian"
	applied_name = "Ian"
	applied_desc = "A cardboard cutout of the HoP's beloved corgi."
	direct_icon = 'icons/mob/simple/pets.dmi'
	direct_icon_state = "corgi"

/datum/cardboard_cutout/slaughter_demon
	name = "Slaughter Demon"
	applied_name = "slaughter demon"
	applied_desc = "A cardboard cutout of a slaughter demon."
	direct_icon = 'icons/mob/simple/mob.dmi'
	direct_icon_state = "daemon"

/datum/cardboard_cutout/laughter_demon
	name = "Laughter Demon"
	applied_name = "laughter demon"
	applied_desc = "A cardboard cutout of a laughter demon."
	direct_icon = 'icons/mob/simple/mob.dmi'
	direct_icon_state = "bowmon"

/datum/cardboard_cutout/security_officer
	name = "Private Security Officer"
	applied_name = "Private Security Officer"
	applied_desc = "A cardboard cutout of a private security officer."
	mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasensoldier
