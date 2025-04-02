#define ENGINE_COOLDOWN (5 SECONDS)
#define DASH_COOLDOWN (2.5 SECONDS)
#define HOUSE_EDGE_ICONS_MAX 3
#define HOUSE_EDGE_ICONS_MIN 0

/obj/item/v8_engine
	name = "ancient engine"
	desc = "An extremely well-preserved, massive V8 engine from the early 2000s. It seems to be missing the rest of the vehicle. There's a tiny label on the side."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "v8_engine"
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	throwforce = 15
	throw_range = 1
	throw_speed = 1
	COOLDOWN_DECLARE(engine_sound_cooldown)

/obj/item/v8_engine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=5, force_wielded=5)

/obj/item/v8_engine/attack_self(mob/user, modifiers)
	. = ..()
	if (!COOLDOWN_FINISHED(src, engine_sound_cooldown))
		return
	playsound(src, 'sound/items/car_engine_start.ogg', vol = 75, vary = FALSE, extrarange = 3)
	Shake(duration = ENGINE_COOLDOWN)
	to_chat(user, span_notice("Darn thing... it's too old to keep on without retrofitting it! Without modifications, it works like it's junk."))
	COOLDOWN_START(src, engine_sound_cooldown, ENGINE_COOLDOWN)

/obj/item/v8_engine/examine_more(mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(start_learning_recipe), user)

/obj/item/v8_engine/proc/start_learning_recipe(mob/user)
	if(!user.mind)
		return
	if(user.mind.has_crafting_recipe(user = user, potential_recipe = /datum/crafting_recipe/house_edge))
		return
	to_chat(user, span_notice("You peer at the label on the side, reading about some unique modifications that could be made to the engine..."))
	if(do_after(user, 15 SECONDS, src))
		user.mind.teach_crafting_recipe(/datum/crafting_recipe/house_edge)
		to_chat(user, span_notice("You learned how to make the House Edge."))

/obj/item/house_edge
	name = "House Edge"
	desc = "Dangerous. Loud. Sleek. It has a built in roulette wheel. This thing could easily rip your arm off if you're not careful."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "house_edge0"
	inhand_icon_state = "house_edge0"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	force = 12
	throwforce = 10
	throw_range = 5
	throw_speed = 1
	hitsound = 'sound/items/car_engine_start.ogg'
	/// The number of charges the house edge has accrued through 2-handed hits, to charge a more powerful charge attack.
	var/fire_charges = 0
	///Sound played when wielded.
	var/active_hitsound = 'sound/items/house_edge_hit.ogg'
	///Datum that tracks weapon dashing for the fire_charge system
	var/datum/action/innate/dash/charge
	COOLDOWN_DECLARE(fire_charge_cooldown)

/obj/item/house_edge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 12, force_wielded = 22, attacksound = active_hitsound)
	RegisterSignals(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_PRE_THROW, COMSIG_ITEM_ATTACK_SELF), PROC_REF(reset_charges))

/obj/item/house_edge/afterattack(atom/target, mob/user, list/modifiers)
	if(!ismob(target))
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		//Add a fire charge to a max of 3, updates icon_state.
		fire_charges = clamp((fire_charges + 1), HOUSE_EDGE_ICONS_MIN, HOUSE_EDGE_ICONS_MAX)
		COOLDOWN_RESET(src, fire_charge_cooldown)
	else
		//Lose a fire charge to a min of 0, updates icon_state.
		fire_charges = clamp((fire_charges - 1), HOUSE_EDGE_ICONS_MIN, HOUSE_EDGE_ICONS_MAX)
		do_sparks(number = 0, cardinal_only = TRUE, source = src)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/house_edge/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, fire_charge_cooldown))
		return ITEM_INTERACT_BLOCKING
	if(fire_charges <= 0)
		balloon_alert(user, "no fire charges!")
		return ITEM_INTERACT_BLOCKING
	user.throw_at(target = get_turf(interacting_with), range = 2 * fire_charges, speed = 5, thrower = user, spin = FALSE, gentle = FALSE, quickstart = TRUE)
	COOLDOWN_START(src, fire_charge_cooldown, DASH_COOLDOWN)
	reset_charges(on_dash = TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/house_edge/update_icon_state()
	inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "house_edge1" : "house_edge0"
	icon_state = "house_edge[fire_charges]"
	return ..()

/obj/item/house_edge/proc/reset_charges(on_dash = FALSE)
	if(!COOLDOWN_FINISHED(src, fire_charge_cooldown) && !on_dash)
		return
	if(fire_charges)
		balloon_alert_to_viewers("charges lost!")
	fire_charges = 0
	icon_state = "house_edge[fire_charges]"
	update_icon()

#undef ENGINE_COOLDOWN
#undef DASH_COOLDOWN
#undef HOUSE_EDGE_ICONS_MAX
#undef HOUSE_EDGE_ICONS_MIN
