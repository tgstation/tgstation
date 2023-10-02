/*
	Click code cleanup
	~Sayu
*/

// 1 decisecond click delay (above and beyond mob/next_move)
//This is mainly modified by click code, to modify click delays elsewhere, use next_move and changeNext_move()
/mob/var/next_click = 0

// THESE DO NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
/mob/var/next_move_adjust = 0 //Amount to adjust action/click delays by, + or -
/mob/var/next_move_modifier = 1 //Value to multiply action/click delays by


//Delays the mob's next click/action by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num+next_move_adjust)*next_move_modifier)

/mob/living/changeNext_move(num)
	var/mod = next_move_modifier
	var/adj = next_move_adjust
	for(var/datum/status_effect/effect as anything in status_effects)
		mod *= effect.nextmove_modifier()
		adj += effect.nextmove_adjust()
	next_move = world.time + ((num + adj)*mod)
	// updates overlays to show attack is on cd
	for(var/hand in hud_used?.hand_slots)
		var/atom/movable/screen/inventory/hand/handy = hud_used.hand_slots[hand]
		handy.update_appearance()

/// Returns the click cooldown which should be applied following a swing
/mob/living/proc/get_swing_nextmove(default_swing_cooldown, cooldown_multiplier)
	return default_swing_cooldown * cooldown_multiplier

/**
 * Before anything else, defer these calls to a per-mobtype handler.  This allows us to
 * remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.
 *
 * Alternately, you could hardcode every mob's variation in a flat [/mob/proc/ClickOn] proc; however,
 * that's a lot of code duplication and is hard to maintain.
 *
 * Note that this proc can be overridden, and is in the case of screen objects.
 */
/atom/Click(location, control, params)
	if(flags_1 & INITIALIZED_1)
		SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)

		usr.ClickOn(src, params)

/atom/DblClick(location,control,params)
	if(flags_1 & INITIALIZED_1)
		usr.DblClickOn(src,params)

/atom/MouseWheel(delta_x,delta_y,location,control,params)
	if(flags_1 & INITIALIZED_1)
		usr.MouseWheelOn(src, delta_x, delta_y, params)

/**
 * Standard mob ClickOn()
 * Handles exceptions: Buildmode, middle click, modified clicks, mech actions
 *
 * After that, mostly just check your state, check whether you're holding an item,
 * check whether you're adjacent to the target, then pass off the click to whoever
 * is receiving it.
 * The most common are:
 * * [mob/proc/click_on_without_item] (atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
 * * [atom/proc/attackby] (item,user) - used only when adjacent
 * * [obj/item/proc/afterattack] (atom,user,adjacent,params) - used both ranged and adjacent
 * * [mob/proc/click_on_without_item_at_range] (atom,modifiers) - used only ranged, only used for tk and laser eyes but could be changed
 */
/mob/proc/ClickOn(atom/clicked_on, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	// -- At the very start, divert into click intercepts first --
	// Notably, you can use click intercepts while you are notransform'd
	if(check_click_intercept(params, clicked_on) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return

	var/list/modifiers = params2list(params)
	// note these aren't true/false, they're string or null - where the string is "1".
	var/right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/middle_clicking = LAZYACCESS(modifiers, MIDDLE_CLICK)
	var/ctrl_clicking = LAZYACCESS(modifiers, CTRL_CLICK)
	var/shift_clicking = LAZYACCESS(modifiers, SHIFT_CLICK)

	// -- Early signal handling --
	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, clicked_on, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
		return

	// -- Shift click handling --
	if(shift_clicking)
		if(middle_clicking)
			ShiftMiddleClickOn(clicked_on)
			return
		if(ctrl_clicking)
			CtrlShiftClickOn(clicked_on)
			return
		ShiftClickOn(clicked_on)
		return

	// -- Middle click handling --
	if(middle_clicking)
		if(ctrl_clicking)
			CtrlMiddleClickOn(clicked_on)
		else
			MiddleClickOn(clicked_on, params)
		return

	// -- Alt and alt-right-click handling
	if(LAZYACCESS(modifiers, ALT_CLICK))
		if(right_clicking)
			alt_click_on_secondary(clicked_on)
		else
			AltClickOn(clicked_on)
		return

	// -- Basic control click handling --
	if(ctrl_clicking)
		CtrlClickOn(clicked_on)
		return

	// -- From here on, you can't click anything else if your're otherwise indesposed --
	if(incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
		return

	face_atom(clicked_on)

	if(next_move > world.time) // in the year 2000...
		return

	if(!LAZYACCESS(modifiers, "catcher") && clicked_on.IsObscured())
		return

	// -- Hands blocked (handcuffed) can't do much. --
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		changeNext_move(CLICK_CD_HANDCUFFED) //Doing shit in cuffs shall be vey slow
		click_on_without_item(clicked_on, FALSE, modifiers)
		return

	if(throw_mode)
		if(throw_item(clicked_on))
			changeNext_move(CLICK_CD_THROW)
		return

	var/obj/item/clicked_with_what = get_active_held_item()

	// -- Attack-self via click handling --
	if(clicked_with_what == clicked_on)
		if(right_clicking)
			clicked_with_what.attack_self_secondary(src, modifiers)
		else
			clicked_with_what.attack_self(src, modifiers)
		update_held_items()
		return

	// -- Handle stuff that's always clickable --
	// (User itself, current loc, and user inventory)
	if(clicked_on in DirectAccess())
		if(clicked_with_what)
			clicked_with_what.melee_attack_chain(src, clicked_on, params)

		else
			if(ismob(clicked_on))
				changeNext_move(CLICK_CD_MELEE)
			click_on_without_item(clicked_on, FALSE, modifiers)
		return

	// Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	// In a storage item with a disassociated storage parent
	if(isitem(clicked_on))
		var/obj/item/item_atom = clicked_on
		if((item_atom.item_flags & IN_STORAGE) && (item_atom.loc.flags_1 & HAS_DISASSOCIATED_STORAGE_1))
			click_on_without_item(item_atom, TRUE, modifiers)

	// From here on we only deal in the physical realm
	// Essentially this is here so you can't use telekinesis or shoot your gun at your hud objects
	// However some screen objects must allowed a click to pass through, click catchers and cursor catchers, so ... society
	// Find a better way to filter these out later
	if(istype(clicked_on, /atom/movable/screen)\
		&& !istype(clicked_on, /atom/movable/screen/click_catcher) \
		&& !istype(clicked_on, /atom/movable/screen/fullscreen))
		return

	// -- Attacking with an item --
	if(istype(clicked_with_what))
		click_on_with_item(clicked_on, clicked_with_what, params)

	// -- Unarmed combat (punching) --
	else if(CanReach(clicked_on))
		click_on_without_item(clicked_on, TRUE, modifiers)

	// -- Ranged combat without a weapon --
	else
		if(right_clicking)
			secondary_click_on_without_item_at_range(clicked_on, modifiers)
		else
			click_on_without_item_at_range(clicked_on, modifiers)

/// Is the atom obscured by a PREVENT_CLICK_UNDER_1 object above it
/atom/proc/IsObscured()
	SHOULD_BE_PURE(TRUE)
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.flags_1 & PREVENT_CLICK_UNDER_1 && AM.density && AM.layer > layer)
			return TRUE
	return FALSE

/turf/IsObscured()
	for(var/item in src)
		var/atom/movable/AM = item
		if(AM.flags_1 & PREVENT_CLICK_UNDER_1)
			return TRUE
	return FALSE

/**
 * A backwards depth-limited breadth-first-search to see if the target is
 * logically "in" anything adjacent to us.
 */
/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)

	while (checking.len && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue

			if(isturf(target) || isturf(target.loc) || (target in direct_access) || (ismovable(target) && target.flags_1 & IS_ONTOP_1) || target.loc?.atom_storage) //Directly accessible atoms
				if(Adjacent(target) || (tool && CheckToolReach(src, target, tool.reach))) //Adjacent or reaching attacks
					return TRUE

			closed[target] = TRUE

			if (!target.loc)
				continue

			if(target.loc.atom_storage)
				next += target.loc

		checking = next
	return FALSE

/atom/movable/proc/DirectAccess()
	return list(src, loc)

/mob/DirectAccess(atom/target)
	return ..() + contents

/mob/living/DirectAccess(atom/target)
	return ..() + get_all_contents()

/atom/proc/AllowClick()
	return FALSE

/turf/AllowClick()
	return TRUE

/proc/CheckToolReach(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return
	switch(reach)
		if(0)
			return FALSE
		if(1)
			return FALSE //here.Adjacent(there)
		if(2 to INFINITY)
			var/obj/dummy = new(get_turf(here))
			dummy.pass_flags |= PASSTABLE
			dummy.invisibility = INVISIBILITY_ABSTRACT
			for(var/i in 1 to reach) //Limit it to that many tries
				var/turf/T = get_step(dummy, get_dir(dummy, there))
				if(dummy.CanReach(there))
					qdel(dummy)
					return TRUE
				if(!dummy.Move(T)) //we're blocked!
					qdel(dummy)
					return
			qdel(dummy)

/// Default behavior: ignore double clicks (the second click that makes the doubleclick call already calls for a normal click)
/mob/proc/DblClickOn(atom/A, params)
	return

/**
 * Highest level of item click chain (besides click itself)
 *
 * Ends up translating into melee_attack_chain (tool act, pre_attack, attackby, attack / attack_atom, attacked_by, afterattack)
 * Or instead goes into attack styles (process_attack, execute_attack, finalize_attack, etc)
 * Or neither: If no attack style is executed and the mob is not in attack range of what they clicked, afterattack is called
 *
 * Going into this proc, click CD is NOT SET YET
 */
/mob/proc/click_on_with_item(atom/clicked_on, obj/item/clicked_with_what, params)
	PROTECTED_PROC(TRUE)

	stack_trace("Somehow, a non-living mob ([src], [type]) called click_on_with_item with an item ([clicked_with_what], [clicked_with_what.type])")

/mob/living/click_on_with_item(atom/clicked_on, obj/item/clicked_with_what, params)
	if(IS_BLOCKING(src))
		balloon_alert(src, "can't act while blocking!")
		changeNext_move(0.25 SECONDS)
		return

	var/list/modifiers = params2list(params)
	var/right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/close_enough = CanReach(clicked_on, clicked_with_what)
	if(close_enough && (!combat_mode || !isliving(clicked_on) || (clicked_with_what.item_flags & NOBLUDGEON)))
		// Only stop the swing attempt if the attack chain return TRUE (or AFTERATTACK_PROCESSED_ITEM) at any point
		if(clicked_with_what.melee_attack_chain(src, clicked_on, params))
			return

	if(combat_mode)
		var/datum/attack_style/swing = clicked_with_what.select_attacking_style(src, clicked_on, right_clicking)
		if(swing)
			swing.process_attack(src, clicked_with_what, clicked_on, right_clicking)
			return TRUE

	// Handle afterattack, called regardless of if an attack was done, allowing "ranged click on" interactions for items
	if(!right_clicking || clicked_with_what.afterattack_secondary(clicked_on, src, close_enough, params) == SECONDARY_ATTACK_CALL_NORMAL)
		clicked_with_what.afterattack(clicked_on, src, close_enough, params)


/// Selects what attack style this item is going to use when being used in a swing
/obj/item/proc/select_attacking_style(mob/living/attacker, atom/clicked_on, right_clicking)
	return (right_clicking && alt_attack_style) || attack_style

/**
 * Also known as "Unarmed attack"ing
 *
 * Called with this mob clicks on any atom in touch range (unless telekinesis) whilst not holding an item.
 *
 * Translates into [atom/proc/attack_hand], etc.
 *
 * Note: proximity_flag here is used to distinguish between normal usage (flag=1),
 * and usage when clicking on things telekinetically (flag=0).  This proc will
 * not be called at ranged except with telekinesis.
 *
 * proximity_flag is not currently passed to attack_hand, and is instead used
 * in human click code to allow glove touches only at melee range.
 *
 * modifiers is a lazy list of click modifiers this attack had,
 * used for figuring out different properties of the click, mostly right vs left and such.
 */
/mob/proc/click_on_without_item(atom/A, proximity_flag, list/modifiers)
	PROTECTED_PROC(TRUE)

	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)

/**
 * Also known as a "ranged unarmed attack"
 *
 * Called when this mob clicks on an atom at range whilst not holding any items
 *
 * This currently is just a default for all mobs, involving
 * laser eyes and telekinesis.  You could easily add exceptions
 * for things like ranged glove touches, spitting alien acid/neurotoxin,
 * animals lunging, etc.
 */
/mob/proc/click_on_without_item_at_range(atom/A, modifiers)
	PROTECTED_PROC(TRUE)

	if(SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED, A, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
 * Called when this mob clicks on an atom at range whilst not holding any items (and is right clicking)

 * If the same conditions are met to trigger click_on_without_item_at_range but it is
 * instead initialized via a right click, this will trigger instead.
 * Useful for mobs that have their abilities mapped to right click.
 */
/mob/proc/secondary_click_on_without_item_at_range(atom/target, modifiers)
	PROTECTED_PROC(TRUE)

	if(SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED_SECONDARY, target, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
 * Middle click
 * Mainly used for swapping hands
 */
/mob/proc/MiddleClickOn(atom/A, params)
	. = SEND_SIGNAL(src, COMSIG_MOB_MIDDLECLICKON, A, params)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	swap_hand()

/**
 * Shift click
 * For most mobs, examine.
 * This is overridden in ai.dm
 */
/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return

/atom/proc/ShiftClick(mob/user)
	var/flags = SEND_SIGNAL(user, COMSIG_CLICK_SHIFT, src)
	if(flags & COMSIG_MOB_CANCEL_CLICKON)
		return
	if(user.client && (user.client.eye == user || user.client.eye == user.loc || flags & COMPONENT_ALLOW_EXAMINATE))
		user.examinate(src)

/**
 * Ctrl click
 * For most objects, pull
 */
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	SEND_SIGNAL(user, COMSIG_MOB_CTRL_CLICKED, src)

	if(!isliving(user))
		return

	var/mob/living/living_user = user
	if(living_user.Adjacent(src) && !isliving(src)) // Icky istype src but meh
		living_user.pulled(src)

	else if(world.time >= living_user.next_move)
		var/datum/attack_style/unarmed/grab/grabbies = GLOB.attack_styles[/datum/attack_style/unarmed/grab]
		grabbies.process_attack(living_user, null, src)

/mob/proc/CtrlMiddleClickOn(atom/A)
	if(check_rights_for(client, R_ADMIN))
		client.toggle_tag_datum(A)
	else
		A.CtrlClick(src)
	return

/**
 * Alt click
 * Unused except for AI
 */
/mob/proc/AltClickOn(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, A)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	A.AltClick(src)

/atom/proc/AltClick(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_CLICK_ALT, user) & COMPONENT_CANCEL_CLICK_ALT)
		return
	var/turf/T = get_turf(src)
	if(T && (isturf(loc) || isturf(src)) && user.TurfAdjacent(T) && !HAS_TRAIT(user, TRAIT_MOVE_VENTCRAWLING))
		user.set_listed_turf(T)

///The base proc of when something is right clicked on when alt is held - generally use alt_click_secondary instead
/atom/proc/alt_click_on_secondary(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON_SECONDARY, A)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	A.alt_click_secondary(src)

///The base proc of when something is right clicked on when alt is held
/atom/proc/alt_click_secondary(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_CLICK_ALT_SECONDARY, user) & COMPONENT_CANCEL_CLICK_ALT_SECONDARY)
		return
	if(isobserver(user) && user.client && check_rights_for(user.client, R_DEBUG))
		user.client.toggle_tag_datum(src)
		return

/// Use this instead of [/mob/proc/AltClickOn] where you only want turf content listing without additional atom alt-click interaction
/atom/proc/AltClickNoInteract(mob/user, atom/A)
	var/turf/T = get_turf(A)
	if(T && user.TurfAdjacent(T))
		user.set_listed_turf(T)

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/**
 * Control+Shift click
 * Unused except for AI
 */
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/mob/proc/ShiftMiddleClickOn(atom/A)
	src.pointed(A)
	return

/atom/proc/CtrlShiftClick(mob/user)
	if(!can_interact(user))
		return FALSE
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL_SHIFT, user)
	return

/*
	Misc helpers
	face_atom: turns the mob towards what you clicked on
*/

/// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/atom_to_face)
	if( buckled || stat != CONSCIOUS || !atom_to_face || !x || !y || !atom_to_face.x || !atom_to_face.y )
		return
	var/dx = atom_to_face.x - x
	var/dy = atom_to_face.y - y
	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(atom_to_face.pixel_y > 16)
			setDir(NORTH)
		else if(atom_to_face.pixel_y < -16)
			setDir(SOUTH)
		else if(atom_to_face.pixel_x > 16)
			setDir(EAST)
		else if(atom_to_face.pixel_x < -16)
			setDir(WEST)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH)
		else
			setDir(SOUTH)
	else
		if(dx > 0)
			setDir(EAST)
		else
			setDir(WEST)

//debug
/atom/movable/screen/proc/scale_to(x1,y1)
	if(!y1)
		y1 = x1
	var/matrix/M = new
	M.Scale(x1,y1)
	transform = M

/atom/movable/screen/click_catcher
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"

#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32) //Not using world.icon_size on purpose.

/atom/movable/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/hud/screen_gen.dmi', "catcher")
	var/ox = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_x)
	var/oy = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_y)
	var/px = view_size_x * world.icon_size
	var/py = view_size_y * world.icon_size
	var/sx = min(MAX_SAFE_BYOND_ICON_SCALE_PX, px)
	var/sy = min(MAX_SAFE_BYOND_ICON_SCALE_PX, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M

/atom/movable/screen/click_catcher/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(offset_increased))
	offset_increased(SSmapping, 0, SSmapping.max_plane_offset)

// Draw to the lowest plane level offered
/atom/movable/screen/click_catcher/proc/offset_increased(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	SET_PLANE_W_SCALAR(src, initial(plane), new_offset)

/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) && iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/click_turf = parse_caught_click_modifiers(modifiers, get_turf(usr.client ? usr.client.eye : usr), usr.client)
		if (click_turf)
			modifiers["catcher"] = TRUE
			click_turf.Click(click_turf, control, list2params(modifiers))
	. = 1

/// MouseWheelOn
/mob/proc/MouseWheelOn(atom/A, delta_x, delta_y, params)
	SEND_SIGNAL(src, COMSIG_MOUSE_SCROLL_ON, A, delta_x, delta_y, params)

/mob/dead/observer/MouseWheelOn(atom/A, delta_x, delta_y, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		var/view = 0
		if(delta_y > 0)
			view = -1
		else
			view = 1
		add_view_range(view)

/mob/proc/check_click_intercept(params,A)
	//Client level intercept
	if(client?.click_intercept)
		if(call(client.click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	//Mob level intercept
	if(click_intercept)
		if(call(click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	return FALSE

#undef MAX_SAFE_BYOND_ICON_SCALE_TILES
#undef MAX_SAFE_BYOND_ICON_SCALE_PX
