#define INSPECT_TIMER 10 SECONDS
#define PET_COOLDOWN 10 SECONDS
#define GROOM_COOLDOWN 30 SECONDS

/*
 * A component that allows mobs to have happiness levels
 */
/datum/component/happiness
	dupe_mode = COMPONENT_DUPE_UNIQUE //Prioritize the old comp over, which may have callbacks and stuff specific to the mob.
	///our current happiness level
	var/happiness_level
	///our maximum happiness level
	var/maximum_happiness
	///happiness AI blackboard key
	var/blackboard_key
	///happiness when we get groomed
	var/on_groom_change
	///happiness when we get petted
	var/on_petted_change
	///happiness when we eat
	var/on_eat_change
	///percentages we should be calling back on
	var/list/callback_percentages
	///callback when our happiness changes
	var/datum/callback/happiness_callback

	///how long till we can inspect happiness again?
	COOLDOWN_DECLARE(happiness_inspect)
	///how long till we can pet it again?
	COOLDOWN_DECLARE(pet_cooldown)
	///how long till we can groom it again
	COOLDOWN_DECLARE(groom_cooldown)

/datum/component/happiness/Initialize(maximum_happiness = 400, blackboard_key = BB_BASIC_HAPPINESS, on_groom_change = 200, on_eat_change = 300, on_petted_change = 30, callback_percentages = list(0, 25, 50, 75, 100), happiness_callback)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.maximum_happiness = maximum_happiness
	src.blackboard_key = blackboard_key
	src.on_groom_change = on_groom_change
	src.on_petted_change = on_petted_change
	src.on_eat_change = on_eat_change
	src.happiness_callback = happiness_callback
	src.callback_percentages = callback_percentages

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/happiness/RegisterWithParent()

	if(on_petted_change)
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_petted))
	if(on_groom_change)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	if(on_eat_change)
		RegisterSignal(parent, COMSIG_MOB_ATE, PROC_REF(on_eat))
	RegisterSignal(parent, COMSIG_SHIFT_CLICKED_ON, PROC_REF(view_happiness))

/datum/component/happiness/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_MOB_ATE))
	happiness_callback = null

/datum/component/happiness/proc/on_eat(datum/source)
	SIGNAL_HANDLER

	increase_happiness_level(on_eat_change)

/datum/component/happiness/proc/on_clean(mob/living/source)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, groom_cooldown))
		return

	var/mob/living/living_parent = parent
	if (living_parent.stat != CONSCIOUS)
		return

	COOLDOWN_START(src, groom_cooldown, GROOM_COOLDOWN)
	increase_happiness_level(on_groom_change)

/datum/component/happiness/proc/on_petted(datum/source, mob/living/petter, list/modifiers)
	SIGNAL_HANDLER
	if(!LAZYACCESS(modifiers, LEFT_CLICK) || petter.combat_mode)
		return

	var/mob/living/living_parent = parent
	if (living_parent.stat != CONSCIOUS)
		return

	pet_animal()

/datum/component/happiness/proc/pet_animal()
	if(!COOLDOWN_FINISHED(src, pet_cooldown))
		return
	increase_happiness_level(on_petted_change)
	COOLDOWN_START(src, pet_cooldown, PET_COOLDOWN)


/datum/component/happiness/proc/increase_happiness_level(amount)
	happiness_level = min(happiness_level + amount, maximum_happiness)
	if(!HAS_TRAIT(parent, TRAIT_MOB_HIDE_HAPPINESS))
		var/mob/living/living_parent = parent
		new /obj/effect/temp_visual/heart(living_parent.loc)
		living_parent.spin(spintime = 2 SECONDS, speed = 1)
	START_PROCESSING(SSprocessing, src)

/datum/component/happiness/proc/view_happiness(mob/living/source, mob/living/clicker)
	if(HAS_TRAIT(source, TRAIT_MOB_HIDE_HAPPINESS) || !istype(clicker) || !COOLDOWN_FINISHED(src, happiness_inspect) || !clicker.CanReach(source))
		return
	var/y_position = source.get_cached_height() + 1
	var/obj/effect/overlay/happiness_overlay/hearts = new
	hearts.pixel_y = y_position
	hearts.set_hearts(happiness_level/maximum_happiness)
	source.vis_contents += hearts
	COOLDOWN_START(src, happiness_inspect, INSPECT_TIMER)


/datum/component/happiness/process()
	var/mob/living/living_parent = parent
	var/happiness_percentage = happiness_level/maximum_happiness
	living_parent.ai_controller?.set_blackboard_key(blackboard_key, happiness_percentage)
	var/check_percentage_in_list = round(happiness_percentage * 100, 1)
	if(check_percentage_in_list in callback_percentages)
		SEND_SIGNAL(parent, COMSIG_MOB_HAPPINESS_CHANGE, happiness_percentage)
		happiness_callback?.Invoke(happiness_percentage)

	if(happiness_level <= 0)
		return PROCESS_KILL
	var/modifier = living_parent.ai_controller?.blackboard[BB_BASIC_DEPRESSED] ? 2 : 1
	happiness_level = max(0, happiness_level - modifier)

/obj/effect/overlay/happiness_overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	layer = ABOVE_HUD_PLANE
	///how many hearts should we display
	VAR_PRIVATE/hearts_percentage
	///icon of our heart
	var/heart_icon = 'icons/effects/effects.dmi'

/obj/effect/overlay/happiness_overlay/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS)

/obj/effect/overlay/happiness_overlay/proc/set_hearts(happiness_percentage)
	hearts_percentage = happiness_percentage
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/overlay/happiness_overlay/update_overlays()
	. = ..()
	var/static/list/heart_positions = list(-13, -5, 3, 11)
	var/display_amount = round(length(heart_positions) * hearts_percentage, 1)
	for(var/index in 1 to length(heart_positions))
		var/heart_icon_state = display_amount >= index ? "full_heart" : "empty_heart"
		var/mutable_appearance/display_icon = mutable_appearance(icon = heart_icon, icon_state = heart_icon_state, layer = ABOVE_HUD_PLANE)
		display_icon.pixel_x = heart_positions[index]
		. += display_icon

#undef INSPECT_TIMER
#undef PET_COOLDOWN
#undef GROOM_COOLDOWN
