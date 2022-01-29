
/obj/item/melee/sickly_blade
	name = "\improper sickly blade"
	desc = "A sickly green crescent blade, decorated with an ornamental eye. You feel like you're being watched..."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 17
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/after_use_message = ""

/obj/item/melee/sickly_blade/attack(mob/living/M, mob/living/user)
	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_danger("You feel a pulse of alien intellect lash out at your mind!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return TRUE

	return ..()

/obj/item/melee/sickly_blade/attack_self(mob/user)
	var/turf/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)
	if(IS_HERETIC_OR_MONSTER(user))
		if(do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user, span_warning("As you shatter [src], you feel a gust of energy flow through your body. [after_use_message]"))
		else
			to_chat(user, span_warning("You shatter [src], but your plea goes unanswered."))
	else
		to_chat(user,span_warning("You shatter [src]."))
	playsound(src, "shatter", 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target))
		return

	if(proximity_flag)
		SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target)
	else
		SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, target)

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	. += span_notice("You can shatter the blade to teleport to a random, (mostly) safe location by <b>activating it in-hand</b>.")

/obj/item/melee/sickly_blade/rust
	name = "\improper rusted blade"
	desc = "This crescent blade is decrepit, wasting to rust. \
		Yet still it bites, ripping flesh and bone with jagged, rotten teeth."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"
	after_use_message = "The Rusted Hills hear your call..."

/obj/item/melee/sickly_blade/ash
	name = "\improper ashen blade"
	desc = "Molten and unwrought, a hunk of metal warped to cinders and slag. \
		Unmade, it aspires to be more than it is, and shears soot-filled wounds with a blunt edge."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"
	after_use_message = "The Nightwater hears your call..."

/obj/item/melee/sickly_blade/flesh
	name = "\improper bloody blade"
	desc = "A crescent blade born from a fleshwarped creature. \
		Keenly aware, it seeks to spread to others the suffering it has endured from its dreadful origins."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"
	after_use_message = "The Marshal hears your call..."

/obj/item/melee/sickly_blade/void
	name = "\improper void blade"
	desc = "Devoid of any substance, this blade reflects nothingness. \
		It is a real depiction of purity, and chaos that ensues after its implementation."
	icon_state = "void_blade"
	inhand_icon_state = "void_blade"
	after_use_message = "The Aristocrat hears your call..."

/obj/item/melee/rune_carver
	name = "carving knife"
	desc = "Cold Steel, pure and perfect, this knife can carve the floor in many ways - but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "rune_carver"
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_SMALL
	wound_bonus = 20
	force = 10
	throwforce = 20
	embedding = list(embed_chance=75, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=5, rip_time=15)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	///turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed, /turf/open/space, /turf/open/openspace, /turf/open/lava))
	///A check to see if you are in process of drawing a rune
	var/drawing = FALSE
	///A list of current runes
	var/list/current_runes = list()
	///Max amount of runes
	var/max_rune_amt = 3
	///Linked action
	var/datum/action/innate/rune_shatter/linked_action

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	. += "This item can carve 'Alert carving' - nearly invisible rune that when stepped on gives you a prompt about where someone stood on it and who it was, doesn't get destroyed by being stepped on."
	. += "This item can carve 'Grasping carving' - when stepped on it causes heavy damage to the legs and stuns for 5 seconds."
	. += "This item can carve 'Mad carving' - when stepped on it causes dizzyness, jiterryness, temporary blindness, confusion , stuttering and slurring."

/obj/item/melee/rune_carver/Initialize(mapload)
	. = ..()
	linked_action = new(src)

/obj/item/melee/rune_carver/Destroy()
	. = ..()
	QDEL_NULL(linked_action)

/obj/item/melee/rune_carver/pickup(mob/user)
	. = ..()
	linked_action.Grant(user, src)

/obj/item/melee/rune_carver/dropped(mob/user, silent)
	. = ..()
	linked_action.Remove(user, src)

/obj/item/melee/rune_carver/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isturf(target) && !is_type_in_typecache(target,blacklisted_turfs) && !drawing && proximity_flag)
		carve_rune(target,user,proximity_flag,click_parameters)

///Action of carving runes, gives you the ability to click on floor and choose a rune of your need.
/obj/item/melee/rune_carver/proc/carve_rune(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/structure/trap/eldritch/elder = locate() in range(1,target)
	if(elder)
		to_chat(user,span_notice("You can't draw runes that close to each other!"))
		return

	for(var/_rune_ref in current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		if(!rune_ref.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		to_chat(user,span_notice("The blade cannot support more runes!"))
		return

	var/list/pick_list = list()
	for(var/E in subtypesof(/obj/structure/trap/eldritch))
		var/obj/structure/trap/eldritch/eldritch = E
		pick_list[initial(eldritch.name)] = eldritch

	drawing = TRUE

	var/type = pick_list[tgui_input_list(user, "Choose the rune", "Rune", pick_list) ]
	if(isnull(type))
		drawing = FALSE
		return


	to_chat(user,span_notice("You start drawing the rune..."))
	if(!do_after(user, 5 SECONDS, target = target))
		drawing = FALSE
		return

	drawing = FALSE
	var/obj/structure/trap/eldritch/new_rune = new type(target, user)
	current_runes += WEAKREF(new_rune)

/datum/action/innate/rune_shatter
	name = "Rune break"
	desc = "Destroys all runes that were drawn by this blade."
	background_icon_state = "bg_ecult"
	button_icon_state = "rune_break"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	///Reference to the rune knife it is inside of
	var/obj/item/melee/rune_carver/sword

/datum/action/innate/rune_shatter/Grant(mob/user, obj/object)
	sword = object
	return ..()

/datum/action/innate/rune_shatter/Activate()
	for(var/_rune_ref in sword.current_runes)
		var/datum/weakref/rune_ref = _rune_ref
		qdel(rune_ref.resolve())
	sword.current_runes.Cut()
