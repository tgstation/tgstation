#define STATUE_FILTER "statue_filter"
#define FILTER_COLOR "#34b347"
#define RECALL_DURATION 3 SECONDS
#define MINIMUM_COLOR_VALUE 20

/obj/item/frog_statue
	name = "frog statue"
	desc = "Are they really comfortable living in this thing?"
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "frog_statue"
	item_flags = NOBLUDGEON
	///our pet frog
	var/mob/living/contained_frog
	///the summon cooldown
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/frog_statue/attack_self(mob/user)
	. = ..()

	if(.)
		return TRUE

	if(!COOLDOWN_FINISHED(src, summon_cooldown))
		user.balloon_alert(user, "recharging!")
		return TRUE

	COOLDOWN_START(src, summon_cooldown, 30 SECONDS)
	if(isnull(contained_frog))
		user.balloon_alert(user, "no frog linked!")
		return TRUE
	if(contained_frog.loc == src)
		release_frog(user)
		return TRUE
	recall_frog(user)
	return TRUE

/obj/item/frog_statue/examine(mob/user)
	. = ..()
	if(!IS_WIZARD(user))
		return
	if(isnull(contained_frog))
		. += span_notice("There are currently no frogs linked to this statue!")
	else
		. += span_notice("Using it will [(contained_frog in src) ? "release" : "recall"] the beast!")

///resummon the frog into its home
/obj/item/frog_statue/proc/recall_frog(mob/user)
	playsound(src, 'sound/items/frog_statue_release.ogg', 20)
	user.Beam(contained_frog, icon_state = "lichbeam", time = RECALL_DURATION)
	animate(contained_frog, transform = matrix().Scale(0.3, 0.3), time = RECALL_DURATION)
	addtimer(CALLBACK(contained_frog, TYPE_PROC_REF(/atom/movable, forceMove), src), RECALL_DURATION)

///release the frog to wreak havoc
/obj/item/frog_statue/proc/release_frog(mob/user)
	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(2, user))
		if(possible_turf.is_blocked_turf() || isopenspaceturf(possible_turf))
			continue
		possible_turfs += possible_turf
	playsound(src, 'sound/items/frog_statue_release.ogg', 50, TRUE)
	var/turf/final_turf = length(possible_turfs) ? pick(possible_turfs) : get_turf(src)
	user.Beam(final_turf, icon_state = "lichbeam", time = RECALL_DURATION)
	contained_frog.forceMove(final_turf)
	animate(contained_frog, transform = matrix(), time = RECALL_DURATION)
	REMOVE_TRAIT(contained_frog, TRAIT_AI_PAUSED, MAGIC_TRAIT)

///set this frog as our inhabitor
/obj/item/frog_statue/proc/set_new_frog(mob/living/frog)
	frog.transform = frog.transform.Scale(0.3, 0.3)
	contained_frog = frog
	animate_filter()
	RegisterSignal(frog, COMSIG_QDELETING, PROC_REF(render_obsolete))

/// we have lost our frog, let out a scream!
/obj/item/frog_statue/proc/render_obsolete(datum/source)
	SIGNAL_HANDLER

	contained_frog = null
	playsound(src, 'sound/effects/magic/demon_dies.ogg', 50, TRUE)
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/item/frog_statue/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(arrived != contained_frog)
		return
	animate_filter()
	ADD_TRAIT(contained_frog, TRAIT_AI_PAUSED, MAGIC_TRAIT)
	if(contained_frog.health < contained_frog.maxHealth)
		START_PROCESSING(SSobj, src)

/obj/item/frog_statue/process(seconds_per_tick)
	if(isnull(contained_frog))
		return
	if(contained_frog.health == contained_frog.maxHealth)
		STOP_PROCESSING(SSobj, src)
		return
	if(contained_frog.stat == DEAD)
		contained_frog.revive()
	contained_frog.adjustBruteLoss(-5)

/obj/item/frog_statue/proc/animate_filter(mob/living/frog)
	add_filter(STATUE_FILTER, 2, list("type" = "outline", "color" = FILTER_COLOR, "size" = 1))
	var/filter = get_filter(STATUE_FILTER)
	animate(filter, alpha = 230, time = 2 SECONDS, loop = -1)
	animate(alpha = 30, time = 0.5 SECONDS)

/obj/item/frog_statue/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != contained_frog)
		return
	clear_filters()

/obj/item/frog_contract
	name = "frog contract"
	desc = "Create a pact with an elder frog! This great beast will be your mount, protector, but most importantly your friend."
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "scroll"

/obj/item/frog_contract/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	create_frog(user)
	return TRUE

///customize our own frog and trap it into the statue
/obj/item/frog_contract/proc/create_frog(mob/user)
	var/obj/item/frog_statue/statue = new(null)
	var/mob/living/basic/leaper/new_frog = new(statue)
	statue.set_new_frog(new_frog)
	new_frog.befriend(user)
	ADD_TRAIT(new_frog, TRAIT_AI_PAUSED, MAGIC_TRAIT)
	select_frog_name(user, new_frog)
	select_frog_color(user, new_frog)
	user.put_in_hands(statue)
	qdel(src)



/obj/item/frog_contract/proc/select_frog_name(mob/user, mob/new_frog)
	var/frog_name = sanitize_name(tgui_input_text(user, "Choose your frog's name!", "Name pet toad", "leaper", MAX_NAME_LEN), allow_numbers = TRUE)
	if(!frog_name)
		to_chat(user, span_warning("Please enter a valid name."))
		select_frog_name(user, new_frog)
		return
	new_frog.name = frog_name

/obj/item/frog_contract/proc/select_frog_color(mob/user, mob/living/basic/leaper/new_frog)
	var/frog_color  = input(user, "Select your frog's color!" , "Pet toad color", COLOR_GREEN) as color|null
	if(isnull(frog_color))
		to_chat(user, span_warning("Please choose a valid color."))
		select_frog_color(user, new_frog)
		return
	var/list/hsv_frog = rgb2hsv(frog_color)
	if(hsv_frog[3] < MINIMUM_COLOR_VALUE)
		to_chat(user, span_danger("This color is too dark!"))
		select_frog_color(user, new_frog)
		return
	new_frog.set_color_overlay(frog_color)


#undef STATUE_FILTER
#undef FILTER_COLOR
#undef RECALL_DURATION
#undef MINIMUM_COLOR_VALUE
