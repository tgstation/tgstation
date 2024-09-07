/// Multipilier to the fishing weights of anything that's not a fish nor a dud
/// for the magnet hook.
#define MAGNET_HOOK_BONUS_MULTIPLIER 5
/// Multiplier for the fishing weights of fish for the rescue hook.
#define RESCUE_HOOK_FISH_MULTIPLIER 0

// Reels

/obj/item/fishing_line
	name = "fishing line reel"
	desc = "A fishing line. In spite of its simplicity, the added length will make fishing a speck easier."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "reel_blue"
	w_class = WEIGHT_CLASS_SMALL
	///A list of traits that this fishing line has, checked by fish traits and the minigame.
	var/list/fishing_line_traits
	/// Color of the fishing line
	var/line_color = COLOR_GRAY

/obj/item/fishing_line/reinforced
	name = "reinforced fishing line reel"
	desc = "Essential for fishing in extreme environments."
	icon_state = "reel_green"
	fishing_line_traits = FISHING_LINE_REINFORCED
	line_color = "#2b9c2b"

/obj/item/fishing_line/cloaked
	name = "cloaked fishing line reel"
	desc = "Even harder to notice than the common variety."
	icon_state = "reel_white"
	fishing_line_traits = FISHING_LINE_CLOAKED
	line_color = "#82cfdd"

/obj/item/fishing_line/bouncy
	name = "flexible fishing line reel"
	desc = "This specialized line is much harder to snap."
	icon_state = "reel_red"
	fishing_line_traits = FISHING_LINE_BOUNCY
	line_color = "#99313f"

/obj/item/fishing_line/sinew
	name = "fishing sinew"
	desc = "An all-natural fishing line made of stretched out sinew. A bit stiff, but usable to fish in extreme enviroments."
	icon_state = "reel_sinew"
	fishing_line_traits = FISHING_LINE_REINFORCED|FISHING_LINE_STIFF
	line_color = "#d1cca3"

/**
 * A special line reel that let you skip the biting phase of the minigame, netting you a completion bonus,
 * and thrown hooked items at you, so you can rapidly catch them from afar.
 * It may also work on mobs if the right hook is attached.
 */
/obj/item/fishing_line/auto_reel
	name = "fishing line auto-reel"
	desc = "A fishing line that automatically spins lures and begins reeling in fish the moment it bites. Also good for hurling things towards you."
	icon_state = "reel_auto"
	fishing_line_traits = FISHING_LINE_AUTOREEL
	line_color = "#F88414"

/obj/item/fishing_line/auto_reel/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FISHING_EQUIPMENT_SLOTTED, PROC_REF(line_equipped))

/obj/item/fishing_line/auto_reel/proc/line_equipped(datum/source, obj/item/fishing_rod/rod)
	SIGNAL_HANDLER
	RegisterSignal(rod, COMSIG_FISHING_ROD_HOOKED_ITEM, PROC_REF(on_hooked_item))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_removed))

/obj/item/fishing_line/auto_reel/proc/on_removed(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(old_loc, COMSIG_FISHING_ROD_HOOKED_ITEM)

/obj/item/fishing_line/auto_reel/proc/on_hooked_item(obj/item/fishing_rod/source, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(!ismovable(target))
		return
	var/atom/movable/movable_target = target
	var/please_be_gentle = FALSE
	var/atom/destination
	var/datum/callback/throw_callback
	if(isliving(movable_target) || !isitem(movable_target))
		destination = get_step_towards(user, target)
		please_be_gentle = TRUE
	else
		destination = user
		throw_callback = CALLBACK(src, PROC_REF(clear_hitby_signal), movable_target)
		RegisterSignal(movable_target, COMSIG_ATOM_PREHITBY, PROC_REF(catch_it_chucklenut))

	if(!movable_target.safe_throw_at(destination, source.cast_range, 2, callback = throw_callback, gentle = please_be_gentle))
		UnregisterSignal(movable_target, COMSIG_ATOM_PREHITBY)
	else
		playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)

/obj/item/fishing_line/auto_reel/proc/catch_it_chucklenut(obj/item/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/mob/living/user = throwingdatum.initial_target.resolve()
	if(QDELETED(user) || hit_atom != user)
		return
	if(user.try_catch_item(source, skip_throw_mode_check = TRUE, try_offhand = TRUE))
		return COMSIG_HIT_PREVENTED

/obj/item/fishing_line/auto_reel/proc/clear_hitby_signal(obj/item/item)
	UnregisterSignal(item, COMSIG_ATOM_PREHITBY)

// Hooks

/obj/item/fishing_hook
	name = "simple fishing hook"
	desc = "A simple fishing hook. Don't expect to hook onto anything without one."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "hook"
	w_class = WEIGHT_CLASS_TINY

	/// A list of traits that this fishing hook has, checked by fish traits and the minigame
	var/list/fishing_hook_traits
	/// icon state added to main rod icon when this hook is equipped
	var/rod_overlay_icon_state = "hook_overlay"
	/// What subtype of `/obj/item/chasm_detritus` do we fish out of chasms? Defaults to `/obj/item/chasm_detritus`.
	var/chasm_detritus_type = /datum/chasm_detritus


/**
 * Simple getter proc for hooks to implement special hook bonuses for
 * certain `fish_type` (or FISHING_DUD), additive. Is applied after
 * `get_hook_bonus_multiplicative()`.
 */
/obj/item/fishing_hook/proc/get_hook_bonus_additive(fish_type)
	return FISHING_DEFAULT_HOOK_BONUS_ADDITIVE


/**
 * Simple getter proc for hooks to implement special hook bonuses for
 * certain `fish_type` (or FISHING_DUD), multiplicative. Is applied before
 * `get_hook_bonus_additive()`.
 */
/obj/item/fishing_hook/proc/get_hook_bonus_multiplicative(fish_type)
	return FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE

///Check if tha target can be caught by the hook
/obj/item/fishing_hook/proc/can_be_hooked(atom/target)
	return isitem(target)

///Any special effect when hooking a target that's not managed by the fishing rod.
/obj/item/fishing_hook/proc/hook_attached(atom/target, obj/item/fishing_rod/rod)
	return

/**
 * Is there a reason why this hook couldn't fish in target_fish_source?
 * If so, return the denial reason as a string, otherwise return `null`.
 *
 * Arguments:
 * * target_fish_source - The /datum/fish_source we're trying to fish in.
 */
/obj/item/fishing_hook/proc/reason_we_cant_fish(datum/fish_source/target_fish_source)
	return null


/obj/item/fishing_hook/magnet
	name = "magnetic hook"
	desc = "Won't make catching fish any easier, but it might help with looking for other things."
	icon_state = "treasure"
	rod_overlay_icon_state = "hook_treasure_overlay"
	chasm_detritus_type = /datum/chasm_detritus/restricted/objects

/obj/item/fishing_hook/magnet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FISHING_EQUIPMENT_SLOTTED, PROC_REF(hook_equipped))

///We make sure that the fishng rod doesn't need a bait to reliably catch non-fish loot.
/obj/item/fishing_hook/magnet/proc/hook_equipped(datum/source, obj/item/fishing_rod/rod)
	SIGNAL_HANDLER
	ADD_TRAIT(rod, TRAIT_ROD_REMOVE_FISHING_DUD, type)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_removed))

/obj/item/fishing_hook/magnet/proc/on_removed(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	REMOVE_TRAIT(old_loc, TRAIT_ROD_REMOVE_FISHING_DUD, type)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/obj/item/fishing_hook/magnet/get_hook_bonus_multiplicative(fish_type, datum/fish_source/source)
	if(fish_type == FISHING_DUD || ispath(fish_type, /obj/item/fish))
		return ..()

	// We multiply the odds by five for everything that's not a fish nor a dud
	return MAGNET_HOOK_BONUS_MULTIPLIER

/obj/item/fishing_hook/shiny
	name = "shiny lure hook"
	icon_state = "gold_shiny"
	fishing_hook_traits = FISHING_HOOK_SHINY
	rod_overlay_icon_state = "hook_shiny_overlay"

/obj/item/fishing_hook/weighted
	name = "weighted hook"
	icon_state = "weighted"
	fishing_hook_traits = FISHING_HOOK_WEIGHTED
	rod_overlay_icon_state = "hook_weighted_overlay"


/obj/item/fishing_hook/rescue
	name = "rescue hook"
	desc = "An unwieldy hook meant to help with the rescue of those that have fallen down in chasms. You can tell there's no way you'll catch any fish with this, and that it won't be of any use outside of chasms."
	icon_state = "rescue"
	rod_overlay_icon_state = "hook_rescue_overlay"
	chasm_detritus_type = /datum/chasm_detritus/restricted/bodies

/obj/item/fishing_hook/rescue/can_be_hooked(atom/target)
	return ..() || isliving(target)

/obj/item/fishing_hook/rescue/hook_attached(atom/target, obj/item/fishing_rod/rod)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/grouped/hooked, rod.fishing_line)

// This hook can only fish in chasms.
/obj/item/fishing_hook/rescue/reason_we_cant_fish(datum/fish_source/target_fish_source)
	if(istype(target_fish_source, /datum/fish_source/chasm))
		return ..()

	return "The hook on your fishing rod wasn't meant for traditional fishing, rendering it useless at doing so!"


/obj/item/fishing_hook/rescue/get_hook_bonus_multiplicative(fish_type, datum/fish_source/source)
	// Sorry, you won't catch fish with this.
	if(ispath(fish_type, /obj/item/fish))
		return RESCUE_HOOK_FISH_MULTIPLIER

	return ..()


/obj/item/fishing_hook/bone
	name = "bone hook"
	desc = "A simple hook carved from sharpened bone"
	icon_state = "hook_bone"

/obj/item/fishing_hook/stabilized
	name = "gyro-stabilized hook"
	desc = "A quirky hook that grants the user a better control of the tool, allowing them to move the bait both and up and down when reeling in, otherwise keeping it in place."
	icon_state = "gyro"
	fishing_hook_traits = FISHING_HOOK_BIDIRECTIONAL
	rod_overlay_icon_state = "hook_gyro_overlay"

/obj/item/fishing_hook/stabilized/examine(mob/user)
	. = ..()
	. += span_notice("While fishing, you can hold the <b>Right</b> Mouse Button to move the bait down, rather than up.")

/obj/item/fishing_hook/jaws
	name = "jawed hook"
	desc = "Despite hints of rust, this gritty beartrap-like hook hybrid manages to look even more threating than the real thing. May neptune have mercy of whatever gets caught in its jaws."
	icon_state = "jaws"
	w_class = WEIGHT_CLASS_NORMAL
	fishing_hook_traits = FISHING_HOOK_NO_ESCAPE|FISHING_HOOK_NO_ESCAPE|FISHING_HOOK_KILL
	rod_overlay_icon_state = "hook_jaws_overlay"

/obj/item/fishing_hook/jaws/can_be_hooked(atom/target)
	return ..() || isliving(target)

/obj/item/fishing_hook/jaws/hook_attached(atom/target, obj/item/fishing_rod/rod)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/grouped/hooked/jaws, rod.fishing_line)

/obj/item/storage/toolbox/fishing
	name = "fishing toolbox"
	desc = "Contains everything you need for your fishing trip."
	icon_state = "fishing"
	inhand_icon_state = "artistic_toolbox"
	material_flags = NONE

/obj/item/storage/toolbox/fishing/Initialize(mapload)
	. = ..()
	// Can hold fishing rod despite the size
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/fishing_rod,
	))
	atom_storage.exception_hold = exception_cache

/obj/item/storage/toolbox/fishing/PopulateContents()
	new /obj/item/bait_can/worm(src)
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)
	new /obj/item/paper/paperslip/fishing_tip(src)

/obj/item/storage/toolbox/fishing/small
	name = "compact fishing toolbox"
	desc = "Contains everything you need for your fishing trip. Except for the bait."
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5

/obj/item/storage/toolbox/fishing/small/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL //It can still hold a fishing rod

/obj/item/storage/toolbox/fishing/small/PopulateContents()
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)
	new /obj/item/paper/paperslip/fishing_tip(src)

/obj/item/storage/toolbox/fishing/master
	name = "super fishing toolbox"
	desc = "Contains EVERYTHING (almost) you need for your fishing trip."
	icon_state = "gold"
	inhand_icon_state = "toolbox_gold"

/obj/item/storage/toolbox/fishing/master/PopulateContents()
	new /obj/item/fishing_rod/telescopic/master(src)
	new /obj/item/storage/box/fishing_hooks/master(src)
	new /obj/item/storage/box/fishing_lines/master(src)
	new /obj/item/bait_can/super_baits(src)
	new /obj/item/fish_feed(src)
	new /obj/item/aquarium_kit(src)
	new /obj/item/fish_analyzer(src)
	new /obj/item/experi_scanner(src)

/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"
	illustration = "fish"

/obj/item/storage/box/fishing_hooks/PopulateContents()
	new /obj/item/fishing_hook/magnet(src)
	new /obj/item/fishing_hook/shiny(src)
	new /obj/item/fishing_hook/weighted(src)

/obj/item/storage/box/fishing_hooks/master

/obj/item/storage/box/fishing_hooks/master/PopulateContents()
	. = ..()
	new /obj/item/fishing_hook/stabilized(src)
	new /obj/item/fishing_hook/jaws(src)

/obj/item/storage/box/fishing_lines
	name = "fishing line set"
	illustration = "fish"

/obj/item/storage/box/fishing_lines/PopulateContents()
	new /obj/item/fishing_line/bouncy(src)
	new /obj/item/fishing_line/reinforced(src)
	new /obj/item/fishing_line/cloaked(src)

/obj/item/storage/box/fishing_lines/master

/obj/item/storage/box/fishing_lines/master/PopulateContents()
	. = ..()
	new /obj/item/fishing_line/auto_reel(src)

/obj/item/storage/box/fish_debug
	name = "box full of fish"
	illustration = "fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/obj/item/fish))
		new fish_type(src)

///Used to give the average player info about fishing stuff that's unknown to many.
/obj/item/paper/paperslip/fishing_tip
	name = "fishing tip"
	desc = "A slip of paper containing a pearl of wisdom about fishing within it, though you wish it were an actual pearl."

/obj/item/paper/paperslip/fortune/Initialize(mapload)
	default_raw_text = pick(GLOB.fishing_tips)
	return ..()

///From the fishing mystery box. It's basically a lazarus and a few bottles of strange reagents.
/obj/item/storage/box/fish_revival_kit
	name = "fish revival kit"
	desc = "Become a fish doctor today."
	illustration = "fish"

/obj/item/storage/box/fish_revival_kit/PopulateContents()
	new /obj/item/lazarus_injector(src)
	new /obj/item/reagent_containers/cup/bottle/strange_reagent(src)
	new /obj/item/reagent_containers/cup(src) //to splash the reagents on the fish.
	new /obj/item/storage/fish_case(src)
	new /obj/item/storage/fish_case(src)

/obj/item/storage/box/fishing_lures
	name = "fishing lures set"
	desc = "A small tackle box containing all the fishing lures you will ever need to curb randomness."
	icon_state = "plasticbox"
	foldable_result = null
	illustration = "fish"

/obj/item/storage/box/fishing_lures/PopulateContents()
	new /obj/item/paper/lures_instructions(src)
	var/list/typesof = typesof(/obj/item/fishing_lure)
	for(var/type in typesof)
		new type (src)
	atom_storage.set_holdable(/obj/item/fishing_lure) //can only hold lures
	//adds an extra slot, so we can put back the lures even if we didn't take out the instructions.
	atom_storage.max_slots = length(typesof) + 1
	atom_storage.max_total_storage = WEIGHT_CLASS_SMALL * (atom_storage.max_slots + 1)

/obj/item/paper/lures_instructions
	name = "instructions paper"
	icon_state = "slipfull"
	show_written_words = FALSE
	desc = "A piece of grey paper with an how-to for dummies about fishing lures printed on it. Smells cheap."
	default_raw_text =  "<b>Thank you for buying this set.</b><br>\
		This a simple non-exhaustive set of instructions on how to use fishing lures, some information may \
		be slightly incorrect or oversimplified.<br><br>\

		First and foremost, fishing lures are <b>inedible, artificia baits</b>, fairly sturdy so that \
		they won't be destroyed by the hungry fish. However, they need to be <b>spun at intervals</b> to replicate \
		the motion of a prey or organic bait to tempt the fish, since a piece of plastic and metal ins't \
		by itself all that tasty. <b>Different lures</b> can be used to catch <b>different fish</b>.<br><br>\

		To help you, each lure comes with <b>a small light</b> that's attached to the <b>float</b> of your fishing rod. \
		For those who don't know it, the float is basically the thing bobbing up'n'down above the fishing spot. \
		The light will flash <b>green<b> and a sound cue will be played when the bait is <b>ready<b> to be spun. \
		Do <b>not</b> spin while the light is still <b>red</b>.<br><br>\
		That's all, best of luck to your angling journey.<br><br>"

#undef MAGNET_HOOK_BONUS_MULTIPLIER
#undef RESCUE_HOOK_FISH_MULTIPLIER
