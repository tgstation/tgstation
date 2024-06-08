
/obj/item/melee/sickly_blade
	name = "\improper sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	throwforce = 10
	wound_bonus = 5
	bare_wound_bonus = 15
	toolspeed = 0.375
	demolition_mod = 0.8
	hitsound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 35
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/after_use_message = ""

/obj/item/melee/sickly_blade/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(.)
		return .
	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_danger("You feel a pulse of alien intellect lash out at your mind!"))
		user.AdjustParalyzed(5 SECONDS)
		return TRUE
	return .

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, click_parameters)
	if(isliving(target))
		SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)

/obj/item/melee/sickly_blade/attack_self(mob/user)
	var/turf/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)
	if(IS_HERETIC_OR_MONSTER(user))
		if(do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user, span_warning("As you shatter [src], you feel a gust of energy flow through your body. [after_use_message]"))
		else
			to_chat(user, span_warning("You shatter [src], but your plea goes unanswered."))
	else
		to_chat(user,span_warning("You shatter [src]."))
	playsound(src, SFX_SHATTER, 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)

/obj/item/melee/sickly_blade/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isliving(interacting_with))
		SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, interacting_with, src)
		return ITEM_INTERACT_BLOCKING

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	. += span_notice("You can shatter the blade to teleport to a random, (mostly) safe location by <b>activating it in-hand</b>.")

// Path of Rust's blade
/obj/item/melee/sickly_blade/rust
	name = "\improper rusted blade"
	desc = "This crescent blade is decrepit, wasting to rust. \
		Yet still it bites, ripping flesh and bone with jagged, rotten teeth."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"
	after_use_message = "The Rusted Hills hear your call..."

// Path of Ash's blade
/obj/item/melee/sickly_blade/ash
	name = "\improper ashen blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. \
		Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"
	after_use_message = "The Nightwatcher hears your call..."
	resistance_flags = FIRE_PROOF

// Path of Flesh's blade
/obj/item/melee/sickly_blade/flesh
	name = "\improper bloody blade"
	desc = "A crescent blade born from a fleshwarped creature. \
		Keenly aware, it seeks to spread to others the suffering it has endured from its dreadful origins."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"
	after_use_message = "The Marshal hears your call..."

/obj/item/melee/sickly_blade/flesh/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)

	AddComponent(
		/datum/component/bloody_spreader,\
		blood_left = INFINITY,\
		blood_dna = list("Unknown DNA" = "X*"),\
		diseases = null,\
	)

// Path of Void's blade
/obj/item/melee/sickly_blade/void
	name = "\improper void blade"
	desc = "Devoid of any substance, this blade reflects nothingness. \
		It is a real depiction of purity, and chaos that ensues after its implementation."
	icon_state = "void_blade"
	inhand_icon_state = "void_blade"
	after_use_message = "The Aristocrat hears your call..."

// Path of the Blade's... blade.
// Opting for /dark instead of /blade to avoid "sickly_blade/blade".
/obj/item/melee/sickly_blade/dark
	name = "\improper sundered blade"
	desc = "A galliant blade, sundered and torn. \
		Furiously, the blade cuts. Silver scars bind it forever to its dark purpose."
	icon_state = "dark_blade"
	inhand_icon_state = "dark_blade"
	after_use_message = "The Torn Champion hears your call..."

// Path of Cosmos's blade
/obj/item/melee/sickly_blade/cosmic
	name = "\improper cosmic blade"
	desc = "A mote of celestial resonance, shaped into a star-woven blade. \
		An iridescent exile, carving radiant trails, desperately seeking unification."
	icon_state = "cosmic_blade"
	inhand_icon_state = "cosmic_blade"
	after_use_message = "The Stargazer hears your call..."

// Path of Knock's blade
/obj/item/melee/sickly_blade/lock
	name = "\improper key blade"
	desc = "A blade and a key, a key to what? \
		What grand gates does it open?"
	icon_state = "key_blade"
	inhand_icon_state = "key_blade"
	after_use_message = "The Stewards hear your call..."
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1.3

// Path of Moon's blade
/obj/item/melee/sickly_blade/moon
	name = "\improper moon blade"
	desc = "A blade of iron, reflecting the truth of the earth: All join the troupe one day. \
		A troupe bringing joy, carving smiles on their faces if they want one or not."
	icon_state = "moon_blade"
	inhand_icon_state = "moon_blade"
	after_use_message = "The Moon hears your call..."
