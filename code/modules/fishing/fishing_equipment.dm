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
	///A bitfield of traits that this fishing line has, checked by fish traits and the minigame.
	var/fishing_line_traits
	/// Color of the fishing line
	var/line_color = COLOR_GRAY
	///The description given to the autowiki
	var/wiki_desc = "A generic fishing line. <b>Without one, the casting range of the rod will be significantly hampered.</b>"

/obj/item/fishing_line/reinforced
	name = "reinforced fishing line reel"
	desc = "Essential for fishing in extreme environments."
	icon_state = "reel_green"
	line_color = "#2aae34"
	wiki_desc = "Allows you to fish in lava and plasma rivers and lakes."

/obj/item/fishing_line/reinforced/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))

/obj/item/fishing_line/reinforced/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	ADD_TRAIT(rod, TRAIT_ROD_LAVA_USABLE, REF(src))

/obj/item/fishing_line/reinforced/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	REMOVE_TRAIT(rod, TRAIT_ROD_LAVA_USABLE, REF(src))

/obj/item/fishing_line/cloaked
	name = "cloaked fishing line reel"
	desc = "Even harder to notice than the common variety."
	icon_state = "reel_white"
	fishing_line_traits = FISHING_LINE_CLOAKED
	line_color = "#82cfdd20" //low alpha channel value, harder to see.
	wiki_desc = "Fishing anxious and wary fish will be easier with this equipped."

/obj/item/fishing_line/bouncy
	name = "flexible fishing line reel"
	desc = "This specialized line is much harder to snap."
	icon_state = "reel_red"
	fishing_line_traits = FISHING_LINE_BOUNCY
	line_color = "#af221f"
	wiki_desc = "It reduces the progression loss during the fishing minigame."

/obj/item/fishing_line/sinew
	name = "fishing sinew"
	desc = "An all-natural fishing line made of stretched out sinew. A bit stiff, but usable to fish in extreme enviroments."
	icon_state = "reel_sinew"
	fishing_line_traits = FISHING_LINE_STIFF
	line_color = "#d1cca3"
	wiki_desc = "Crafted from sinew. It allows you to fish in lava and plasma like the reinforced line, but it'll make the minigame harder."

/obj/item/fishing_line/sinew/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))

/obj/item/fishing_line/sinew/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	ADD_TRAIT(rod, TRAIT_ROD_LAVA_USABLE, REF(src))

/obj/item/fishing_line/sinew/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	REMOVE_TRAIT(rod, TRAIT_ROD_LAVA_USABLE, REF(src))

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
	wiki_desc = "Automatically starts the minigame and helps guide the bait a little. It also spin fishing lures for you without need of an input. \
		It can also be used to snag in objects from a distance and throw them in your direction.<br>\
		<b>It requires the Advanced Fishing Technology Node to be researched to be printed.</b>"

/obj/item/fishing_line/auto_reel/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))

/obj/item/fishing_line/auto_reel/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	RegisterSignal(rod, COMSIG_FISHING_ROD_HOOKED_ITEM, PROC_REF(on_hooked_item))

/obj/item/fishing_line/auto_reel/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	UnregisterSignal(rod, COMSIG_FISHING_ROD_HOOKED_ITEM)

/obj/item/fishing_line/auto_reel/proc/on_hooked_item(obj/item/fishing_rod/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(target) || target.anchored || target.move_resist >= MOVE_FORCE_STRONG)
		return
	var/please_be_gentle = FALSE
	var/atom/destination
	var/datum/callback/throw_callback
	if(isliving(target) || !isitem(target))
		destination = get_step_towards(user, target)
		please_be_gentle = TRUE
	else
		destination = user
		throw_callback = CALLBACK(src, PROC_REF(clear_hitby_signal), target)
		RegisterSignal(target, COMSIG_MOVABLE_PRE_IMPACT, PROC_REF(catch_it_chucklenut))

	if(!target.safe_throw_at(destination, source.cast_range, 2, callback = throw_callback, gentle = please_be_gentle))
		UnregisterSignal(target, COMSIG_MOVABLE_PRE_IMPACT)
	else
		playsound(src, 'sound/items/weapons/batonextend.ogg', 50, TRUE)

/obj/item/fishing_line/auto_reel/proc/catch_it_chucklenut(obj/item/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	var/mob/living/user = throwingdatum.initial_target.resolve()
	if(QDELETED(user) || hit_atom != user)
		return NONE
	if(!user.try_catch_item(source, skip_throw_mode_check = TRUE, try_offhand = TRUE))
		return NONE
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/obj/item/fishing_line/auto_reel/proc/clear_hitby_signal(obj/item/item)
	UnregisterSignal(item, COMSIG_MOVABLE_PRE_IMPACT)

// Hooks

/obj/item/fishing_hook
	name = "simple fishing hook"
	desc = "A simple fishing hook. Don't expect to hook onto anything without one."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "hook"
	w_class = WEIGHT_CLASS_TINY

	/// A bitfield of traits that this fishing hook has, checked by fish traits and the minigame
	var/fishing_hook_traits
	/// icon state added to main rod icon when this hook is equipped
	var/rod_overlay_icon_state = "hook_overlay"
	/// What subtype of `/datum/chasm_detritus` do we fish out of chasms? Defaults to `/datum/chasm_detritus`.
	var/chasm_detritus_type = /datum/chasm_detritus
	///The description given to the autowiki
	var/wiki_desc = "A generic fishing hook. <b>You won't be able to fish without one.</b>"

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
	if(isliving(target))
		var/mob/living/mob = target
		return (mob.mob_biotypes & MOB_AQUATIC)
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
	wiki_desc = "It vastly improves the chances of catching things other than fish."

/obj/item/fishing_hook/magnet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))

/obj/item/fishing_hook/magnet/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	ADD_TRAIT(rod, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src))

/obj/item/fishing_hook/magnet/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	REMOVE_TRAIT(rod, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src))

/obj/item/fishing_hook/magnet/get_hook_bonus_multiplicative(fish_type)
	if(fish_type == FISHING_DUD || ispath(fish_type, /obj/item/fish) || isfish(fish_type))
		return ..()

	// We multiply the odds by five for everything that's not a fish nor a dud
	return MAGNET_HOOK_BONUS_MULTIPLIER

/obj/item/fishing_hook/shiny
	name = "shiny lure hook"
	icon_state = "gold_shiny"
	rod_overlay_icon_state = "hook_shiny_overlay"
	wiki_desc = "It's used to attract shiny-loving fish and make them easier to catch."

/obj/item/fishing_hook/shiny/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(src, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))

/obj/item/fishing_hook/shiny/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	rod.material_fish_chance += 15 //Increases the chance of catching a shiny po... erh, material fish
	ADD_TRAIT(rod, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(src))

/obj/item/fishing_hook/shiny/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	rod.material_fish_chance -= 15
	REMOVE_TRAIT(rod, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(src))

/obj/item/fishing_hook/weighted
	name = "weighted hook"
	icon_state = "weighted"
	fishing_hook_traits = FISHING_HOOK_WEIGHTED
	rod_overlay_icon_state = "hook_weighted_overlay"
	wiki_desc = "It reduces the bounce that happens when you hit the boundaries of the minigame bar."

/obj/item/fishing_hook/rescue
	name = "rescue hook"
	desc = "An unwieldy hook meant to help with the rescue of those that have fallen down in chasms. You can tell there's no way you'll catch any fish with this, and that it won't be of any use outside of chasms."
	icon_state = "rescue"
	rod_overlay_icon_state = "hook_rescue_overlay"
	chasm_detritus_type = /datum/chasm_detritus/restricted/bodies
	wiki_desc = "A hook used to rescue bodies whom have fallen into chasms. \
		You won't catch fish with it, nor it can't be used for fishing outside of chasms, though it can still be used to reel in people and items from unreachable locations.."

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


/obj/item/fishing_hook/rescue/get_hook_bonus_multiplicative(fish_type)
	// Sorry, you won't catch fish with this.
	if(ispath(fish_type, /obj/item/fish) || isfish(fish_type))
		return RESCUE_HOOK_FISH_MULTIPLIER

	return ..()


/obj/item/fishing_hook/bone
	name = "bone hook"
	desc = "A simple hook carved from sharpened bone"
	icon_state = "hook_bone"
	wiki_desc = "A generic fishing hook carved out of sharpened bone. Bone fishing rods come pre-equipped with it."

/obj/item/fishing_hook/stabilized
	name = "gyro-stabilized hook"
	desc = "A quirky hook that grants the user a better control of the tool, allowing them to move the bait both and up and down when reeling in, otherwise keeping it in place."
	icon_state = "gyro"
	fishing_hook_traits = FISHING_HOOK_BIDIRECTIONAL
	rod_overlay_icon_state = "hook_gyro_overlay"
	wiki_desc = "It allows you to move both up (left-click) and down (right-click) during the minigame while negating gravity.<br>\
		<b>It requires the Advanced Fishing Technology Node to be researched to be printed.</b>"

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
	wiki_desc = "A beartrap-looking hook that makes losing the fishing minigame impossible (Unless you drop the rod or get stunned). However it'll hurt the fish and eventually kill it. \
		Funnily enough, you can snag in people with it too. It won't hurt them like a actual beartrap, but it'll still slow them down.<br>\
		<b>It has to be bought from the black market uplink.</b>"

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
	custom_price = PAYCHECK_CREW * 3
	///How much holding this affects fishing difficulty
	var/fishing_modifier = -4

/obj/item/storage/toolbox/fishing/Initialize(mapload)
	. = ..()
	// Can hold fishing rod despite the size
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/fishing_rod,
	))
	atom_storage.exception_hold = exception_cache
	AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier, ITEM_SLOT_HANDS)

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
	desc = "Contains (almost) EVERYTHING you need for your fishing trip."
	icon_state = "gold"
	inhand_icon_state = "toolbox_gold"
	fishing_modifier = -10

/obj/item/storage/toolbox/fishing/master/PopulateContents()
	new /obj/item/fishing_rod/telescopic/master(src)
	new /obj/item/storage/box/fishing_hooks/master(src)
	new /obj/item/storage/box/fishing_lines/master(src)
	new /obj/item/bait_can/super_baits(src)
	new /obj/item/reagent_containers/cup/fish_feed(src)
	new /obj/item/aquarium_kit(src)
	new /obj/item/fish_analyzer(src)

/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 2

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
	custom_price = PAYCHECK_CREW * 2

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

/obj/item/paper/paperslip/fishing_tip/Initialize(mapload)
	default_raw_text = pick(GLOB.fishing_tips)
	return ..()

///From the fishing mystery box. It's basically a lazarus and a few bottles of strange reagents.
/obj/item/storage/box/fish_revival_kit
	name = "fish revival kit"
	desc = "Become a fish doctor today. A label on the side indicates that fish require two to ten reagent units to be splashed onto them for revival, depending on size."
	illustration = "fish"

/obj/item/storage/box/fish_revival_kit/PopulateContents()
	new /obj/item/lazarus_injector(src)
	new /obj/item/reagent_containers/cup/bottle/fishy_reagent(src)
	new /obj/item/reagent_containers/cup(src) //to splash the reagents on the fish.
	new /obj/item/storage/fish_case(src)
	new /obj/item/storage/fish_case(src)

/obj/item/storage/box/fishing_lures
	name = "fishing lures set"
	desc = "A small tackle box containing all the fishing lures you will ever need to curb randomness."
	icon_state = "plasticbox"
	foldable_result = null
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 9

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
	desc = "A piece of grey paper with a how-to for dummies about fishing lures printed on it. Smells cheap."
	default_raw_text =  "<b>Thank you for buying this set.</b><br>\
		This a simple non-exhaustive set of instructions on how to use fishing lures, some information may \
		be slightly incorrect or oversimplified.<br><br>\

		First and foremost, fishing lures are <b>inedible, artificial baits</b> sturdy enough to not end up being \
		consumed by the hungry fish. However, they need to be <b>spun at intervals</b> to replicate \
		the motion of a prey or organic bait and tempt the fish, since a piece of plastic and metal ins't \
		all that appetitizing by itself. <b>Different lures</b> can be used to catch <b>different fish</b>.<br><br>\

		To help you, each lure comes with a <b>small light</b> diode that's attached to the <b>float</b> of your fishing rod. \
		A float is basically the thing bobbing up'n'down above the fishing spot. \
		The light will flash <b>green</b> and a <b>sound</b> cue will be played when the lure is <b>ready</b> to be spun. \
		Do <b>not</b> spin while the light is still <b>red</b>.<br><br>\
		That's all, best of luck to your angling journey."

///A modified mining capsule from the black market and sometimes random loot.
/obj/item/survivalcapsule/fishing
	name = "fishing spot capsule"
	desc = "An illegally modified mining capsule containing a small fishing spot connected to some faraway place."
	icon_state = "capsule_fishing"
	initial_language_holder = /datum/language_holder/speaking_machine
	verb_say = "beeps"
	verb_yell = "blares"
	voice_filter = "alimiter=0.9,acompressor=threshold=0.3:ratio=40:attack=15:release=350:makeup=1.5,highpass=f=1000,rubberband=pitch=1.5"
	template_id = "fishing_default"
	yeet_back = FALSE

/obj/item/survivalcapsule/fishing/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)
	register_context()

	if(SStts.tts_enabled) //This capsule informs you on why it cannot be deployed in a sliiiiightly different way.
		voice = pick(SStts.available_speakers)

/obj/item/survivalcapsule/fishing/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!held_item || held_item == src)
		context[SCREENTIP_CONTEXT_RMB] = "Change fishing spot"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/survivalcapsule/fishing/examine(mob/user)
	. = ..()
	. += span_info("[EXAMINE_HINT("Right-Click")] to change the selected fishing spot when held.")

/obj/item/survivalcapsule/fishing/examine_more(mob/user)
	. = ..()
	. += span_tinynotice("A tiny print on the side reads: \"Use a cryptographic sequencer to disable safeties\".")

/obj/item/survivalcapsule/fishing/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "safeties disabled")
	playsound(src, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/item/survivalcapsule/fishing/attack_self_secondary(mob/living/user)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(used)
		return
	var/list/choices = list()
	var/list/spot_ids_by_name = list()
	for(var/datum/map_template/shelter/fishing/spot as anything in typesof(/datum/map_template/shelter/fishing))
		if(!spot::safe && !(obj_flags & EMAGGED))
			continue
		choices[spot::name] = image('icons/hud/radial_fishing.dmi', spot::radial_icon)
		spot_ids_by_name[spot::name] = spot::shelter_id
	var/choice = show_radial_menu(user, src, choices, radius = 38, custom_check = CALLBACK(src, TYPE_PROC_REF(/atom, can_interact), user), tooltips = TRUE)
	if(!choice || used || !can_interact(user))
		return
	template_id = spot_ids_by_name[choice]
	template = SSmapping.shelter_templates[template_id]
	to_chat(user, span_notice("You change [src]'s selected fishing spot to [choice]."))
	playsound(src, 'sound/items/pen_click.ogg', 20, TRUE, -3)
	return

/obj/item/survivalcapsule/fishing/get_ignore_flags()
	. = ..()
	if(obj_flags & EMAGGED)
		. += CAPSULE_IGNORE_ANCHORED_OBJECTS|CAPSULE_IGNORE_BANNED_OBJECTS

/obj/item/survivalcapsule/fishing/fail_feedback(status)
	switch(status)
		if(SHELTER_DEPLOY_BAD_AREA)
			say("I refuse to deploy in this area.")
		if(SHELTER_DEPLOY_BAD_TURFS)
			say("The walls are too close! I need [template.width]x[template.height] area to deploy.")
		if(SHELTER_DEPLOY_ANCHORED_OBJECTS)
			say("Get these anchored objects out of the way! I need [template.width]x[template.height] area to deploy.")
		if(SHELTER_DEPLOY_BANNED_OBJECTS)
			say("Remove all cables and pipes around me in a [template.width]x[template.height] area or I won't deploy.")
		if(SHELTER_DEPLOY_OUTSIDE_MAP)
			say("For fucks sake, deploy me somewhere less far fatched!")

/obj/item/survivalcapsule/fishing/trigger_admin_alert(mob/triggerer, turf/trigger_loc)
	var/datum/map_template/shelter/fishing/spot = template
	if(spot.safe) //Don't log if the fishing spot is safe
		return

	var/area/area = get_area(src)

	if(!area.outdoors)
		message_admins("[ADMIN_LOOKUPFLW(triggerer)] activated an unsafe fishing capsule at [ADMIN_VERBOSEJMP(trigger_loc)]")
	log_admin("[key_name(triggerer)] activated an unsafe fishing capsule at [AREACOORD(trigger_loc)]")

/obj/item/survivalcapsule/fishing/hacked
	obj_flags = parent_type::obj_flags | EMAGGED

#undef MAGNET_HOOK_BONUS_MULTIPLIER
#undef RESCUE_HOOK_FISH_MULTIPLIER

/obj/item/storage/bag/fishing
	name = "fishing bag"
	desc = "A vibrant bag for storing caught fish."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_bag"
	worn_icon_state = "fishing_bag"
	resistance_flags = FLAMMABLE
	custom_price = PAYCHECK_CREW * 3
	///How much holding this affects fishing difficulty
	var/fishing_modifier = -2

/obj/item/storage/bag/fishing/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 24 // Up to 8 normal fish
	atom_storage.max_slots = 21
	atom_storage.set_holdable(/obj/item/fish)
	AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier, ITEM_SLOT_HANDS)

/obj/item/storage/bag/fishing/carpskin
	name = "carpskin fishing bag"
	desc = "A dapper fishing bag made from carpskin. You can store quite a lot of fishing gear in the small pockets formed by larger scales."
	icon_state = "fishing_bag_carpskin"
	worn_icon_state = "fishing_bag_carpskin"
	resistance_flags = ACID_PROOF
	storage_type = /datum/storage/carpskin_bag
	fishing_modifier = -4

/obj/item/storage/bag/fishing/carpskin/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 42 // Up to 14 normal fish, but we're assuming that you'll be storing a bunch of gear as well
	atom_storage.set_holdable(list(
		/obj/item/fish,
		/obj/item/fishing_line,
		/obj/item/fishing_hook,
		/obj/item/fishing_lure,
		/obj/item/fish_analyzer,
		/obj/item/bait_can,
	))
