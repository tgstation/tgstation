// the different states of the mystery box
/// Closed, can't interact
#define MYSTERY_BOX_COOLING_DOWN 0
/// Closed, ready to be interacted with
#define MYSTERY_BOX_STANDBY 1
/// The box is choosing the prize
#define MYSTERY_BOX_CHOOSING 2
/// The box is presenting the prize, for someone to claim it
#define MYSTERY_BOX_PRESENTING 3

/// How long the box takes to decide what the prize is
#define MBOX_DURATION_CHOOSING 5 SECONDS
/// How long the box takes to start expiring the offer, though it's still valid until MBOX_DURATION_EXPIRING finishes. Timed to the sound clips
#define MBOX_DURATION_PRESENTING 7.4 SECONDS
/// How long the box takes to start lowering the prize back into itself. When this finishes, the prize is gone
#define MBOX_DURATION_EXPIRING 2 SECONDS
/// How long after the box closes until it can go again
#define MBOX_DURATION_STANDBY 2 SECONDS

/obj/structure/mystery_box
	name = "mystery box"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "wooden"

	pixel_y = -4

	var/crate_open_sound = 'sound/machines/crate_open.ogg'
	var/crate_close_sound = 'sound/machines/crate_close.ogg'
	var/open_sound = 'sound/effects/mysterybox/mbox_full.ogg'
	var/grant_sound = 'sound/effects/mysterybox/mbox_end.ogg'
	/// The box's current state, and whether it can be interacted with in different ways
	var/box_state = MYSTERY_BOX_STANDBY
	/// The object that represents the
	var/obj/mystery_box_item/presented_item
	/// A timer for how long it takes for the box to start its expire animation
	var/box_expire_timer
	/// A timer for how long it takes for the box to close itself
	var/box_close_timer
	/// Every type that's a child of this that has an icon, icon_state, and isn't ABSTRACT is fair game. More granularity to come
	var/selectable_base_type = /obj/item/gun
	/// Holds every type that the box can roll, rolled on Initialize()
	var/list/valid_types = list()


/obj/structure/mystery_box/Initialize(mapload)
	. = ..()
	for(var/iter_path in typesof(selectable_base_type))
		if(ispath(iter_path) && ispath(iter_path, /obj/item))
			var/obj/item/iter_item = iter_path
			if((initial(iter_item.item_flags) & ABSTRACT) || !initial(iter_item.icon_state))
				continue
			valid_types += iter_path

/obj/structure/mystery_box/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	switch(box_state)
		if(MYSTERY_BOX_COOLING_DOWN)

		if(MYSTERY_BOX_STANDBY)
			activate(user)

		if(MYSTERY_BOX_CHOOSING)

		if(MYSTERY_BOX_PRESENTING)
			if(presented_item.claimable)
				grant_weapon(user)

/obj/structure/mystery_box/update_icon_state()
	icon_state = "[initial(icon_state)][box_state > MYSTERY_BOX_STANDBY ? "open" : ""]"
	return ..()

/// The box has been activated, play the sound and spawn the prop item
/obj/structure/mystery_box/proc/activate(mob/living/user)
	box_state = MYSTERY_BOX_CHOOSING
	update_icon_state()
	presented_item = new(loc)
	presented_item.start_animation(src)
	playsound(src, open_sound, 50, FALSE, channel = CHANNEL_MBOX)
	playsound(src, crate_open_sound, 80)
	//addtimer(CALLBACK(src, .proc/present_weapon), MBOX_DURATION_CHOOSING)

/// The box has finished choosing, mark it as available for grabbing
/obj/structure/mystery_box/proc/present_weapon()
	testing("Box is now presenting [presented_item.selected_path]")
	box_state = MYSTERY_BOX_PRESENTING
	box_expire_timer = addtimer(CALLBACK(src, .proc/expire_offer), MBOX_DURATION_PRESENTING - MBOX_DURATION_EXPIRING, TIMER_STOPPABLE)

/// The prize is still claimable, but the animation will show it start to recede back into the box
/obj/structure/mystery_box/proc/expire_offer()
	presented_item.expire_animation()
	box_expire_timer = addtimer(CALLBACK(src, .proc/close_box), MBOX_DURATION_EXPIRING, TIMER_STOPPABLE)

/// The box is closed, whether because the prize fully expired, or it was claimed. Start resetting all of the state stuff
/obj/structure/mystery_box/proc/close_box()
	box_state = MYSTERY_BOX_COOLING_DOWN
	update_icon_state()
	QDEL_NULL(presented_item)
	deltimer(box_close_timer)
	playsound(src, crate_close_sound, 100)
	box_close_timer = null
	addtimer(CALLBACK(src, .proc/ready_again), MBOX_DURATION_STANDBY)

/// The cooldown between activations has finished, shake to show that
/obj/structure/mystery_box/proc/ready_again()
	box_state = MYSTERY_BOX_STANDBY
	Shake(10, 0, 0.5 SECONDS)

/// Someone attacked the box with an empty hand, spawn the shown prize and give it to them, then close the box
/obj/structure/mystery_box/proc/grant_weapon(mob/living/user)
	var/obj/item/instantiated_weapon = new presented_item.selected_path(src)
	user.put_in_hands(instantiated_weapon)
	playsound(src, grant_sound, 50, FALSE, channel = CHANNEL_MBOX)
	close_box()


/// This represents the item that comes out of the box and is constantly changing before the box finishes deciding. Can probably be just an /atom or /movable.
/obj/mystery_box_item
	name = "???"
	desc = "Who knows what it'll be??"
	icon = 'icons/obj/guns/ballistic.dmi'
	icon_state = "detective"
	pixel_y = -8

	/// The currently selected item. Constantly changes while choosing, determines what is spawned if the prize is claimed, and its current icon
	var/selected_path = /obj/item/gun/ballistic/revolver/detective
	/// The box that spawned this
	var/obj/structure/mystery_box/parent_box
	/// Whether this prize is currently claimable
	var/claimable = FALSE


/obj/mystery_box_item/Initialize(mapload)
	. = ..()
	var/matrix/starting = matrix()
	starting.Scale(0.5,0.5)
	transform = starting
	add_filter("weapon_rays", 2, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))

/obj/mystery_box_item/Destroy(force)
	. = ..()
	parent_box = null

// this way, clicking on the prize will work the same as clicking on the box
/obj/mystery_box_item/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(claimable)
		parent_box.grant_weapon(user)

/// Start pushing the prize up
/obj/mystery_box_item/proc/start_animation(atom/parent)
	parent_box = parent

	var/matrix/starting = matrix()
	animate(src, pixel_y = 6, transform = starting, time = MBOX_DURATION_CHOOSING, easing = QUAD_EASING | EASE_OUT)
	loop_icon_changes()

/// Keep changing the icon and selected path
/obj/mystery_box_item/proc/loop_icon_changes()
	set waitfor = FALSE

	var/change_delay = 1
	var/change_delay_delta = 0.2
	var/start_time = world.time

	/// The uninstantiated item that's currently selected based off selected_path, for use with initial()
	var/obj/item/selected_item

	while(world.time < start_time + MBOX_DURATION_CHOOSING)
		change_delay += change_delay_delta
		selected_path = pick(parent_box.valid_types)
		selected_item = selected_path
		icon = initial(selected_item.icon)
		icon_state = initial(selected_item.icon_state)
		sleep(change_delay)

	add_filter("ready_outline", 2, list("type" = "outline", "color" = "#FBFF23", "size" = 0.2))
	parent_box.present_weapon()
	claimable = TRUE

/// Sink back into the box
/obj/mystery_box_item/proc/expire_animation()
	var/matrix/shrink_back = matrix()
	shrink_back.Scale(0.5,0.5)
	animate(src, pixel_y = -8, transform = shrink_back, time = MBOX_DURATION_CHOOSING)

#undef MYSTERY_BOX_COOLING_DOWN
#undef MYSTERY_BOX_STANDBY
#undef MYSTERY_BOX_CHOOSING
#undef MYSTERY_BOX_PRESENTING
#undef MBOX_DURATION_CHOOSING
#undef MBOX_DURATION_PRESENTING
#undef MBOX_DURATION_EXPIRING
#undef MBOX_DURATION_STANDBY
