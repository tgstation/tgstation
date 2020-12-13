#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5
#define FOCUS_PER_SECOND_LIMIT 1.5

/datum/progressbar
	///The progress bar visual element.
	var/image/bar
	///The target where this progress bar is applied and where it is shown.
	var/atom/bar_loc
	///The mob whose client sees the progress bar.
	var/mob/user
	///The client seeing the progress bar.
	var/client/user_client
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///An optional, clickable object that can be used to speed up progress bars
	var/obj/effect/hallucination/simple/progress_focus/booster
	///How much bonus progress we've accured from a linked progress booster
	var/bonus_progress = 0

/datum/progressbar/New(mob/User, goal_number, atom/target, bonus_time, focus_sound)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if(QDELETED(User) || !istype(User))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] user")
		qdel(src)
		return
	if(!isnum(goal_number))
		stack_trace("/datum/progressbar created with [isnull(User) ? "null" : "invalid"] goal_number")
		qdel(src)
		return
	goal = goal_number
	bar_loc = target
	bar = image('icons/effects/progessbar.dmi', bar_loc, "prog_bar_0", HUD_LAYER)
	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = User

	LAZYADDASSOC(user.progressbars, bar_loc, src)
	var/list/bars = user.progressbars[bar_loc]
	listindex = bars.len

	if(user.client)
		user_client = user.client
		add_prog_bar_image_to_client()
	if(bonus_time)
		booster = new(get_turf(target), user, src, bonus_time, focus_sound)
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/on_user_delete)
	RegisterSignal(user, COMSIG_MOB_LOGOUT, .proc/clean_user_client)
	RegisterSignal(user, COMSIG_MOB_LOGIN, .proc/on_user_login)

/datum/progressbar/Destroy()
	if(user)
		for(var/pb in user.progressbars[bar_loc])
			var/datum/progressbar/progress_bar = pb
			if(progress_bar == src || progress_bar.listindex <= listindex)
				continue
			progress_bar.listindex--

			progress_bar.bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1))
			var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (progress_bar.listindex - 1)) - PROGRESSBAR_HEIGHT
			animate(progress_bar.bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

		LAZYREMOVEASSOC(user.progressbars, bar_loc, src)
		user = null

	if(user_client)
		clean_user_client()

	bar_loc = null

	if(bar)
		QDEL_NULL(bar)

	return ..()

///Called right before the user's Destroy()
/datum/progressbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER

	user.progressbars = null //We can simply nuke the list and stop worrying about updating other prog bars if the user itself is gone.
	user = null
	qdel(src)

///Removes the progress bar image from the user_client and nulls the variable, if it exists.
/datum/progressbar/proc/clean_user_client(datum/source)
	SIGNAL_HANDLER

	if(!user_client) //Disconnected, already gone.
		return
	user_client.images -= bar
	user_client = null

///Called by user's Login(), it transfers the progress bar image to the new client.
/datum/progressbar/proc/on_user_login(datum/source)
	SIGNAL_HANDLER

	if(user_client)
		if(user_client == user.client) //If this was not client handling I'd condemn this sanity check. But clients are fickle things.
			return
		clean_user_client()
	if(!user.client) //Clients can vanish at any time, the bastards.
		return
	user_client = user.client
	add_prog_bar_image_to_client()

///Adds a smoothly-appearing progress bar image to the player's screen.
/datum/progressbar/proc/add_prog_bar_image_to_client()
	bar.pixel_y = 0
	bar.alpha = 0
	user_client.images += bar
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

///Updates the progress bar image visually.
/datum/progressbar/proc/update(progress)
	progress = clamp(progress + bonus_progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"

///Boost the current progress by a specific amount
/datum/progressbar/proc/boost_progress(amount)
	bonus_progress += amount

///Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()
	if(last_progress < goal)
		bar.icon_state = "[bar.icon_state]_fail"
	if(booster)
		QDEL_NULL(booster)
	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)

///Special object used to reward mouse accuracy with a slight speed bonus to progressbars. Only used on certain objects.
/obj/effect/hallucination/simple/progress_focus
	name = "focus"
	desc = "If I focus, I might be able to speed up my progress a little bit."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "progress_focus"
	image_layer = HUD_LAYER
	///The progress bar that this booster is linked to
	var/datum/progressbar/linked_bar
	///How much this focus helps overall progress
	var/time_per_click
	///Sound played when clicked
	var/focus_sound = 'sound/machines/click.ogg'
	///Reference to a progress trap, used to discourage spam-clicking
	var/obj/effect/hallucination/simple/progress_trap/trap
	///How many times this focus can be used
	var/max_uses
	///How many times this focus has been used
	var/uses = 0

/obj/effect/hallucination/simple/progress_focus/Initialize(mapload, mob/target_mob, datum/progressbar/target_bar, bonus_time, f_sound)
	. = ..()
	var/fastest_possible_time = target_bar.goal - bonus_time
	max_uses = round(fastest_possible_time/10/FOCUS_PER_SECOND_LIMIT, 1)
	target = target_mob
	linked_bar = target_bar
	time_per_click = bonus_time/max_uses
	if (f_sound)
		focus_sound = f_sound
	trap = new(get_turf(src), target_mob, target_bar, time_per_click)
	message_admins("bar made with normal time [target_bar.goal] and fastest time [fastest_possible_time]. Max uses will be [max_uses] and strength will be [time_per_click].")

/obj/effect/hallucination/simple/progress_focus/attackby(obj/item/I, mob/user, params)
	. = ..()
	linked_bar.boost_progress(time_per_click)
	user.playsound_local(user, focus_sound, 50, TRUE)
	var/new_x = rand(-12,12)
	var/new_y = rand(-12,12)
	update_icon(image_state, image_icon, new_px = new_x, new_py = new_y)
	trap.update_icon(trap.image_state, trap.image_icon, new_px = new_x, new_py = new_y)
	uses += 1
	if (uses >= max_uses)
		linked_bar.booster = null
		qdel(src)

/obj/effect/hallucination/simple/progress_focus/Destroy()
	. = ..()
	QDEL_NULL(trap)
/obj/effect/hallucination/simple/progress_trap
	name = ""
	desc = ""
	image_icon = 'icons/effects/effects.dmi'
	image_state = "progress_trap"
	image_layer = ABOVE_HUD_LAYER
	///The progress bar that this booster is linked to
	var/datum/progressbar/linked_bar
	///How much this focus hurts overall progress
	var/loss_per_click

/obj/effect/hallucination/simple/progress_trap/Initialize(mapload, mob/target_mob, datum/progressbar/target_bar, time_delta)
	. = ..()
	target = target_mob
	linked_bar = target_bar
	loss_per_click = -1 * time_delta

/obj/effect/hallucination/simple/progress_trap/attackby(obj/item/I, mob/user, params)
	. = ..()
	linked_bar.boost_progress(loss_per_click)
	user.playsound_local(user, 'sound/machines/buzz-sigh.ogg', 50, TRUE)

#undef FOCUS_PER_SECOND_LIMIT
#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT
