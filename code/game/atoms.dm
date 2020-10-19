/**
  * The base type for nearly all physical objects in SS13

  * Lots and lots of functionality lives here, although in general we are striving to move
  * as much as possible to the components/elements system
  */
/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND

	///If non-null, overrides a/an/some in all cases
	var/article

	///First atom flags var
	var/flags_1 = NONE
	///Intearaction flags
	var/interaction_flags_atom = NONE

	var/flags_ricochet = NONE

	///When a projectile tries to ricochet off this atom, the projectile ricochet chance is multiplied by this
	var/receive_ricochet_chance_mod = 1
	///When a projectile ricochets off this atom, it deals the normal damage * this modifier to this atom
	var/receive_ricochet_damage_coeff = 0.33

	///Reagents holder
	var/datum/reagents/reagents = null

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	///HUD images that this atom can provide.
	var/list/hud_possible

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	/**
	  * used to store the different colors on an atom
	  *
	  * its inherent color, the colored paint applied on it, special color effect etc...
	  */
	var/list/atom_colours


	/// a very temporary list of overlays to remove
	var/list/remove_overlays
	/// a very temporary list of overlays to add
	var/list/add_overlays

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays
	var/list/managed_vis_overlays
	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc
	var/list/managed_overlays

	///Proximity monitor associated with this atom
	var/datum/proximity_monitor/proximity_monitor
	///Cooldown tick timer for buckle messages
	var/buckle_message_cooldown = 0
	///Last fingerprints to touch this atom
	var/fingerprintslast

	var/list/filter_data //For handling persistent filters

	///Economy cost of item
	var/custom_price
	///Economy cost of item in premium vendor
	var/custom_premium_price
	///Whether spessmen with an ID with an age below AGE_MINOR (20 by default) can buy this item
	var/age_restricted = FALSE

	//List of datums orbiting this atom
	var/datum/component/orbiter/orbiters

	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	/// The icon state intended to be used for the acid component. Used to override the default acid overlay icon state.
	var/custom_acid_overlay = null

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	///The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/list/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

	var/datum/wires/wires = null

	var/list/alternate_appearances

	///Mobs that are currently do_after'ing this atom, to be cleared from on Destroy()
	var/list/targeted_by

	/// Last appearance of the atom for demo saving purposes
	var/image/demo_last_appearance

	///Light systems, both shouldn't be active at the same time.
	var/light_system = STATIC_LIGHT
	///Range of the light in tiles. Zero means no light.
	var/light_range = 0
	///Intensity of the light. The stronger, the less shadows you will see on the lit area.
	var/light_power = 1
	///Hexadecimal RGB string representing the colour of the light. White by default.
	var/light_color = COLOR_WHITE
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	///Bitflags to determine lighting-related atom properties.
	var/light_flags = NONE
	///Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/light_source/light
	///Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/light_sources

	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened

	///Used for changing icon states for different base sprites.
	var/base_icon_state

	///Icon-smoothing behavior.
	var/smoothing_flags = NONE
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
	///Smoothing variable
	var/top_left_corner
	///Smoothing variable
	var/top_right_corner
	///Smoothing variable
	var/bottom_left_corner
	///Smoothing variable
	var/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it.
	var/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself.
	var/list/canSmoothWith = null
	///Reference to atom being orbited
	var/atom/orbit_target

/**
  * Called when an atom is created in byond (built in engine proc)
  *
  * Not a lot happens here in SS13 code, as we offload most of the work to the
  * [Intialization][/atom/proc/Initialize] proc, mostly we run the preloader
  * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
  * result is that the Intialize proc is called.
  *
  * We also generate a tag here if the DF_USE_TAG flag is set on the atom
  */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		world.preloader_load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

/**
  * The primary method that objects are setup in SS13 with
  *
  * we don't use New as we have better control over when this is called and we can choose
  * to delay calls or hook other logic in and so forth
  *
  * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
  * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
  * is also true for loading map templates as well, so they don't Initalize until all objects
  * in the map file are parsed and present in the world
  *
  * If you're creating an object at any point after SSInit has run then this proc will be
  * immediately be called from New.
  *
  * mapload: This parameter is true if the atom being loaded is either being intialized during
  * the Atom subsystem intialization, or if the atom is being loaded from the map template.
  * If the item is being created at runtime any time after the Atom subsystem is intialized then
  * it's false.
  *
  * You must always call the parent of this proc, otherwise failures will occur as the item
  * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
  * the item being completely unclickable)
  *
  * You must not sleep in this proc, or any subprocs
  *
  * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
  * there are no other arguments
  *
  * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
  *
  * Note: the following functions don't call the base for optimization and must copypasta handling:
  * * [/turf/proc/Initialize]
  * * [/turf/open/space/proc/Initialize]
  */
/atom/proc/Initialize(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_CREATED, src) /// Sends a signal that the new atom `src`, has been created at `loc`

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_system == STATIC_LIGHT && light_power && light_range)
		update_light()

	if (length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if (length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	// apply materials properly from the default custom_materials value
	set_custom_materials(custom_materials)

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

/**
  * Late Intialization, for code that should run after all atoms have run Intialization
  *
  * To have your LateIntialize proc be called, your atoms [Initalization][/atom/proc/Initialize]
  *  proc must return the hint
  * [INITIALIZE_HINT_LATELOAD] otherwise you will never be called.
  *
  * useful for doing things like finding other machines on GLOB.machines because you can guarantee
  * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
  * code has been run
  */
/atom/proc/LateInitialize()
	set waitfor = FALSE

/// Put your [AddComponent] calls here
/atom/proc/ComponentInitialize()
	return

/**
  * Top level of the destroy chain for most atoms
  *
  * Cleans up the following:
  * * Removes alternate apperances from huds that see them
  * * qdels the reagent holder from atoms if it exists
  * * clears the orbiters list
  * * clears overlays and priority overlays
  * * clears the light object
  */
/atom/Destroy()
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

	if(reagents)
		qdel(reagents)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	LAZYCLEARLIST(overlays)

	for(var/i in targeted_by)
		var/mob/M = i
		LAZYREMOVE(M.do_afters, src)

	targeted_by = null
	QDEL_NULL(light)

	if(smoothing_flags & SMOOTH_QUEUED)
		SSicon_smooth.remove_from_queues(src)

	return ..()

/atom/proc/handle_ricochet(obj/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	var/a_incidence_s = abs(incidence_s)
	if(a_incidence_s > 90 && a_incidence_s < 270)
		return FALSE
	if((P.flag in list(BULLET, BOMB)) && P.ricochet_incidence_leeway)
		if((a_incidence_s < 90 && a_incidence_s < 90 - P.ricochet_incidence_leeway) || (a_incidence_s > 270 && a_incidence_s -270 > P.ricochet_incidence_leeway))
			return
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

///Can the mover object pass this atom, while heading for the target turf
/atom/proc/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(mover.movement_type & UNSTOPPABLE)
		return TRUE
	. = CanAllowThrough(mover, target)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, target, .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	//SHOULD_BE_PURE(TRUE)
	return !density

/**
  * Is this atom currently located on centcom
  *
  * Specifically, is it on the z level and within the centcom areas
  *
  * You can also be in a shuttleshuttle during endgame transit
  *
  * Used in gamemode to identify mobs who have escaped and for some other areas of the code
  * who don't want atoms where they shouldn't be
  */
/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_reserved_level(T.z))
		for(var/A in SSshuttle.mobile)
			var/obj/docking_port/mobile/M = A
			if(M.launch_status == ENDGAME_TRANSIT)
				for(var/place in M.shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(T in shuttle_area)
						return TRUE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			for(var/place in M.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(T in shuttle_area)
					return TRUE

/**
  * Is the atom in any of the centcom syndicate areas
  *
  * Either in the syndie base on centcom, or any of their shuttles
  *
  * Also used in gamemode code for win conditions
  */
/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

/**
  * Is the atom in an away mission
  *
  * Must be in the away mission z-level to return TRUE
  *
  * Also used in gamemode code for win conditions
  */
/atom/proc/onAwayMission()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_away_level(T.z))
		return TRUE

	return FALSE



///This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)

/**
  * Ensure a list of atoms/reagents exists inside this atom
  *
  * Goes throught he list of passed in parts, if they're reagents, adds them to our reagent holder
  * creating the reagent holder if it exists.
  *
  * If the part is a moveable atom and the  previous location of the item was a mob/living,
  * it calls the inventory handler transferItemToLoc for that mob/living and transfers the part
  * to this atom
  *
  * Otherwise it simply forceMoves the atom into this atom
  */
/atom/proc/CheckParts(list/parts_list, datum/crafting_recipe/R)
	SEND_SIGNAL(src, COMSIG_ATOM_CHECKPARTS, parts_list, R)
	if(parts_list)
		for(var/A in parts_list)
			if(istype(A, /datum/reagent))
				if(!reagents)
					reagents = new()
				reagents.reagent_list.Add(A)
				reagents.conditional_update()
			else if(ismovable(A))
				var/atom/movable/M = A
				if(isliving(M.loc))
					var/mob/living/L = M.loc
					L.transferItemToLoc(M, src)
				else
					M.forceMove(src)
		parts_list.Cut()

///Hook for multiz???
/atom/proc/update_multiz(prune_on_fail = FALSE)
	return FALSE

///Take air from the passed in gas mixture datum
/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

///Remove air from this atom
/atom/proc/remove_air(amount)
	return null

///Return the current air environment in this atom
/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

///Check if this atoms eye is still alive (probably)
/atom/proc/check_eye(mob/user)
	return

/atom/proc/Bumped(atom/movable/AM)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, AM)

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (INJECTABLE | REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (DRAWABLE | DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (reagents.flags & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (reagents.flags & DRAINABLE)

/** Handles exposing this atom to a list of reagents.
  *
  * Sends COMSIG_ATOM_EXPOSE_REAGENTS
  * Calls expose_atom() for every reagent in the reagent list.
  *
  * Arguments:
  * - [reagents][/list]: The list of reagents the atom is being exposed to.
  * - [source][/datum/reagents]: The reagent holder the reagents are being sourced from.
  * - methods: How the atom is being exposed to the reagents. Bitflags.
  * - volume_modifier: Volume multiplier.
  * - show_message: Whether to display anything to mobs when they are exposed.
  */
/atom/proc/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = SEND_SIGNAL(src, COMSIG_ATOM_EXPOSE_REAGENTS, reagents, source, methods, volume_modifier, show_message)
	if(. & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_atom(src, reagents[R])

/// Are you allowed to drop this atom
/atom/proc/AllowDrop()
	return FALSE

/atom/proc/CheckExit()
	return 1

///Is this atom within 1 tile of another atom
/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/**
  * React to an EMP of the given severity
  *
  * Default behaviour is to send the [COMSIG_ATOM_EMP_ACT] signal
  *
  * If the signal does not return protection, and there are attached wires then we call
  * [emp_pulse][/datum/wires/proc/emp_pulse] on the wires
  *
  * We then return the protection value
  */
/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse()
	return protection // Pass the protection value collected here upwards

/**
  * React to a hit by a projectile object
  *
  * Default behaviour is to send the [COMSIG_ATOM_BULLET_ACT] and then call [on_hit][/obj/projectile/proc/on_hit] on the projectile
  */
/atom/proc/bullet_act(obj/projectile/P, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

///Return true if we're inside the passed in atom
/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/**
  * Get the name of this object for examine
  *
  * You can override what is returned from this proc by registering to listen for the
  * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
  */
/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/**
  * Called when a mob examines (shift click or verb) this atom
  *
  * Default behaviour is to get the name and icon of the object and it's reagents where
  * the [TRANSPARENT] flag is set on the reagents holder
  *
  * Produces a signal [COMSIG_PARENT_EXAMINE]
  */
/atom/proc/examine(mob/user)
	. = list("[get_examine_string(user, TRUE)].")

	if(desc)
		. += desc

	if(custom_materials)
		var/list/materials_list = list()
		for(var/i in custom_materials)
			var/datum/material/M = i
			materials_list += "[M.name]"
		. += "<u>It is made out of [english_list(materials_list)]</u>."
	if(reagents)
		if(reagents.flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list))
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[R.volume] units of [R.name]"
				else //Otherwise, just show the total volume
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					. += "[total_volume] units of various reagents"
			else
				. += "Nothing."
		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>"
			else
				. += "<span class='danger'>It's empty.</span>"

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)
/**
  * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_TIME (default 1.5 seconds)
  *
  * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
  * moments, while allowing people to manually double-examine to take a closer look
  *
  * Produces a signal [COMSIG_PARENT_EXAMINE_MORE]
  */
/atom/proc/examine_more(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_MORE, user, .)
	if(!LAZYLEN(.)) // lol ..length
		return list("<span class='notice'><i>You examine [src] closer, but find nothing of interest...</i></span>")

/// Updates the icon of the atom
/atom/proc/update_icon()
	SIGNAL_HANDLER

	var/signalOut = SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON)
	. = FALSE

	if(!(signalOut & COMSIG_ATOM_NO_UPDATE_ICON_STATE))
		update_icon_state()
		. = TRUE

	if(!(signalOut & COMSIG_ATOM_NO_UPDATE_OVERLAYS))
		var/list/new_overlays = update_overlays()
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			managed_overlays = new_overlays
			add_overlay(new_overlays)
		. = TRUE

	SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, signalOut, .)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/**
  * An atom we are buckled or is contained within us has tried to move
  *
  * Default behaviour is to send a warning that the user can't move while buckled as long
  * as the [buckle_message_cooldown][/atom/var/buckle_message_cooldown] has expired (50 ticks)
  */
/atom/proc/relaymove(mob/living/user, direction)
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>You can't move while buckled to [src]!</span>")
	return

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
  * React to being hit by an explosion
  *
  * Default behaviour is to call [contents_explosion][/atom/proc/contents_explosion] and send the [COMSIG_ATOM_EX_ACT] signal
  */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)

/**
  * React to a hit by a blob objecd
  *
  * default behaviour is to send the [COMSIG_ATOM_BLOB_ACT] signal
  */
/atom/proc/blob_act(obj/structure/blob/B)
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)
	return

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/**
  * React to being hit by a thrown object
  *
  * Default behaviour is to call [hitby_react][/atom/proc/hitby_react] on ourselves after 2 seconds if we are dense
  * and under normal gravity.
  *
  * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
  * deleted shortly after hitting something (during explosions or other massive events that
  * throw lots of items around - singularity being a notable example)
  */
/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/**
  * We have have actually hit the passed in atom
  *
  * Default behaviour is to move back from the item that hit us
  */
/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

///Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube, paralyze, force_drop)
	return

///returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	return list("ANIMAL DNA" = "Y-")

///Get the mobs dna list
/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

/mob/living/silicon/get_blood_dna_list()
	return

///to add a mob's dna info into an object's blood_dna list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = blood_DNA_length()
	add_blood_DNA(new_blood_dna)
	if(blood_DNA_length() == old_length)
		return FALSE
	return TRUE

///to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna)

///Is this atom in space
/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

///Used for making a sound when a mob involuntarily falls into the ground.
/atom/proc/handle_fall(mob/faller)
	return

///Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
  * Respond to the singularity pulling on us
  *
  * Default behaviour is to send [COMSIG_ATOM_SING_PULL] and return
  */
/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)


/**
  * Respond to acid being used on our atom
  *
  * Default behaviour is to send [COMSIG_ATOM_ACID_ACT] and return
  */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)
	return FALSE

/**
  * Respond to an emag being used on our atom
  *
  * Default behaviour is to send [COMSIG_ATOM_EMAG_ACT] and return
  */
/atom/proc/emag_act(mob/user, obj/item/card/emag/E)
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user, E)

/**
  * Respond to a radioactive wave hitting this atom
  *
  * Default behaviour is to send [COMSIG_ATOM_RAD_ACT] and return
  */
/atom/proc/rad_act(strength)
	SEND_SIGNAL(src, COMSIG_ATOM_RAD_ACT, strength)

/**
  * Respond to narsie eating our atom
  *
  * Default behaviour is to send [COMSIG_ATOM_NARSIE_ACT] and return
  */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)


///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE


/**
  * Respond to an RCD acting on our item
  *
  * Default behaviour is to send [COMSIG_ATOM_RCD_ACT] and return FALSE
  */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/**
  * Respond to an electric bolt action on our item
  *
  * Default behaviour is to return, we define here to allow for cleaner code later on
  */
/atom/proc/zap_act(power, zap_flags)
	return

/**
  * Implement the behaviour for when a user click drags a storage object to your atom
  *
  * This behaviour is usually to mass transfer, but this is no longer a used proc as it just
  * calls the underyling /datum/component/storage dump act if a component exists
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(GetComponent(/datum/component/storage))
		return component_storage_contents_dump_act(src_object, user)
	return FALSE

/**
  * Implement the behaviour for when a user click drags another storage item to you
  *
  * In this case we get as many of the tiems from the target items compoent storage and then
  * put everything into ourselves (or our storage component)
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/component_storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	while (do_after(user, 10, TRUE, src, FALSE, CALLBACK(STR, /datum/component/storage.proc/handle_mass_item_insertion, things, src_object, user, progress)))
		stoplag(1)
	progress.end_progress()
	to_chat(user, "<span class='notice'>You dump as much of [src_object.parent]'s contents [STR.insert_preposition]to [src] as you can.</span>")
	STR.orient2hud(user)
	src_object.orient2hud(user)
	if(user.active_storage) //refresh the HUD to show the transfered contents
		user.active_storage.close(user)
		user.active_storage.show_to(user)
	return TRUE

///Get the best place to dump the items contained in the source storage item?
/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/**
  * This proc is called when an atom in our contents has it's [Destroy][/atom/proc/Destroy] called
  *
  * Default behaviour is to simply send [COMSIG_ATOM_CONTENTS_DEL]
  */
/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/**
  * called when the turf the atom resides on is ChangeTurfed
  *
  * Default behaviour is to loop through atom contents and call their HandleTurfChange() proc
  */
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)

/**
  * the vision impairment to give to the mob whose perspective is set to that atom
  *
  * (e.g. an unfocused camera giving you an impaired vision when looking through it)
  */
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

/**
  * the sight changes to give to the mob whose perspective is set to that atom
  *
  * (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
  */
/atom/proc/update_remote_sight(mob/living/user)
	return


/**
  * Hook for running code when a dir change occurs
  *
  * Not recommended to use, listen for the [COMSIG_ATOM_DIR_CHANGE] signal instead (sent by this proc)
  */
/atom/proc/setDir(newdir)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/**
  * Called when the atom log's in or out
  *
  * Default behaviour is to call on_log on the location this atom is in
  */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	color = null
	if(!atom_colours)
		return
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return


/**
  * Wash this atom
  *
  * This will clean it off any temporary stuff like blood. Override this in your item to add custom cleaning behavior.
  * Returns true if any washing was necessary and thus performed
  * Arguments:
  * * clean_types: any of the CLEAN_ constants
  */
/atom/proc/wash(clean_types)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, clean_types) & COMPONENT_CLEANED)
		. = TRUE

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOUR_PRIORITY && atom_colours[WASHABLE_COLOUR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return TRUE

/**
  * call back when a var is edited on this atom
  *
  * Can be used to implement special handling of vars
  *
  * At the atom level, if you edit a var named "color" it will add the atom colour with
  * admin level priority to the atom colours list
  *
  * Also, if GLOB.Debug2 is FALSE, it sets the [ADMIN_SPAWNED_1] flag on [flags_1][/atom/var/flags_1], which signifies
  * the object has been admin edited
  */
/atom/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, light_range))
			if(light_system == STATIC_LIGHT)
				set_light(l_range = var_value)
			else
				set_light_range(var_value)
			. =  TRUE
		if(NAMEOF(src, light_power))
			if(light_system == STATIC_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			. =  TRUE
		if(NAMEOF(src, light_color))
			if(light_system == STATIC_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			. =  TRUE
		if(NAMEOF(src, light_on))
			set_smoothed_icon_state(var_value)
			. =  TRUE
		if(NAMEOF(src, light_flags))
			set_light_flags(var_value)
			. =  TRUE
		if(NAMEOF(src, smoothing_junction))
			set_smoothed_icon_state(var_value)
			. =  TRUE
		if(NAMEOF(src, opacity))
			set_opacity(var_value)
			. =  TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1

	. = ..()

	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)


/**
  * Return the markup to for the dropdown list for the VV panel for this atom
  *
  * Override in subtypes to add custom VV handling in the VV panel
  */
/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(!ismovable(src))
		var/turf/curturf = get_turf(src)
		if(curturf)
			. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_RADIATE, "Radiate")

/atom/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADD_REAGENT] && check_rights(R_VAREDIT))
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num|null
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/chosen_id
			switch(alert(usr, "Choose a method.", "Add Reagents", "Search", "Choose from a list", "I'm feeling lucky"))
				if("Search")
					var/valid_id
					while(!valid_id)
						chosen_id = input(usr, "Enter the ID of the reagent you want to add.", "Search reagents") as null|text
						if(isnull(chosen_id)) //Get me out of here!
							break
						if (!ispath(text2path(chosen_id)))
							chosen_id = pick_closest_path(chosen_id, make_types_fancy(subtypesof(/datum/reagent)))
							if (ispath(chosen_id))
								valid_id = TRUE
						else
							valid_id = TRUE
						if(!valid_id)
							to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")
				if("Choose from a list")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in sortList(subtypesof(/datum/reagent), /proc/cmp_typepaths_asc)
				if("I'm feeling lucky")
					chosen_id = pick(subtypesof(/datum/reagent))
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num|null
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to [src]</span>")
	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)
	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)
	if(href_list[VV_HK_RADIATE] && check_rights(R_FUN))
		var/strength = input(usr, "Choose the radiation strength.", "Choose the strength.") as num|null
		if(!isnull(strength))
			AddComponent(/datum/component/radioactive, strength, src)
	if(href_list[VV_HK_MODIFY_TRANSFORM] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = transform
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
				if(!isnull(angle))
					transform = M.Turn(angle)
	if(href_list[VV_HK_AUTO_RENAME] && check_rights(R_VAREDIT))
		var/newname = input(usr, "What do you want to rename this to?", "Automatic Rename") as null|text
		if(newname)
			vv_auto_rename(newname)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

///Where atoms should drop if taken from this atom
/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()

/atom/proc/vv_auto_rename(newname)
	name = newname

/**
  * An atom has entered this atom's contents
  *
  * Default behaviour is to send the [COMSIG_ATOM_ENTERED]
  */
/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/**
  * An atom is attempting to exit this atom's contents
  *
  * Default behaviour is to send the [COMSIG_ATOM_EXIT]
  *
  * Return value should be set to FALSE if the moving atom is unable to leave,
  * otherwise leave value the result of the parent call
  */
/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/**
  * An atom has exited this atom's contents
  *
  * Default behaviour is to send the [COMSIG_ATOM_EXITED]
  */
/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

///Return atom temperature
/atom/proc/return_temperature()
	return

/**
  *Tool behavior procedure. Redirects to tool-specific procs by default.
  *
  * You can override it to catch all tool interactions, for use in complex deconstruction procs.
  *
  * Must return  parent proc ..() in the end if overridden
  */
/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	var/list/processing_recipes = list() //List of recipes that can be mutated by sending the signal
	var/signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, I, processing_recipes)
	if(processing_recipes.len)
		process_recipes(user, I, processing_recipes)
	if(QDELETED(I))
		return TRUE
	switch(tool_type)
		if(TOOL_CROWBAR)
			. = crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			. = multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			. = screwdriver_act(user, I)
		if(TOOL_WRENCH)
			. = wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			. = wirecutter_act(user, I)
		if(TOOL_WELDER)
			. = welder_act(user, I)
		if(TOOL_ANALYZER)
			. = analyzer_act(user, I)
	if(. || signal_result & COMPONENT_BLOCK_TOOL_ATTACK) //Either the proc or the signal handled the tool's events in some way.
		return TRUE


/atom/proc/process_recipes(mob/living/user, obj/item/I, list/processing_recipes)
	//Only one recipe? use the first
	if(processing_recipes.len == 1)
		StartProcessingAtom(user, I, processing_recipes[1])
		return
	//Otherwise, select one with a radial
	ShowProcessingGui(user, I, processing_recipes)

///Creates the radial and processes the selected option
/atom/proc/ShowProcessingGui(mob/living/user, obj/item/I, list/possible_options)
	var/list/choices_to_options = list() //Dict of object name | dict of object processing settings
	var/list/choices = list()

	for(var/i in possible_options)
		var/list/current_option = i
		var/atom/current_option_type = current_option[TOOL_PROCESSING_RESULT]
		choices_to_options[initial(current_option_type.name)] = current_option
		var/image/option_image = image(icon = initial(current_option_type.icon), icon_state = initial(current_option_type.icon_state))
		choices += list("[initial(current_option_type.name)]" = option_image)

	var/pick = show_radial_menu(user, src, choices, radius = 36, require_near = TRUE)

	StartProcessingAtom(user, I, choices_to_options[pick])


/atom/proc/StartProcessingAtom(mob/living/user, obj/item/I, list/chosen_option)
	to_chat(user, "<span class='notice'>You start working on [src]</span>")
	if(I.use_tool(src, user, chosen_option[TOOL_PROCESSING_TIME], volume=50))
		var/atom/atom_to_create = chosen_option[TOOL_PROCESSING_RESULT]
		for(var/i = 1 to chosen_option[TOOL_PROCESSING_AMOUNT])
			var/atom/created_atom = new atom_to_create(loc)
			SEND_SIGNAL(created_atom, COMSIG_ATOM_CREATEDBY_PROCESSING, src, chosen_option)
			created_atom.OnCreatedFromProcessing(user, I, chosen_option, src)
		to_chat(user, "<span class='notice'>You manage to create [chosen_option[TOOL_PROCESSING_AMOUNT]] [initial(atom_to_create.name)] from [src]</span>")
		qdel(src)
		return

/atom/proc/OnCreatedFromProcessing(mob/living/user, obj/item/I, list/chosen_option, atom/original_atom)
	return

//! Tool-specific behavior procs.
///

///Crowbar act
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

///Multitool act
/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

///Check if the multitool has an item in it's data buffer
/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!istype(I, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, "<span class='warning'>[I] has no data buffer!</span>")
		return FALSE
	return TRUE

///Screwdriver act
/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return

///Wrench act
/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

///Wirecutter act
/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

///Welder act
/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

///Analyzer act
/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return

///Generate a tag for this atom
/atom/proc/GenerateTag()
	return

///Connect this atom to a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return

/// Generic logging helper
/atom/proc/log_message(message, message_type, color=null, log_globally=TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [loc_name(src)]"
	switch(message_type)
		if(LOG_ATTACK)
			log_attack(log_text)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_PDA)
			log_pda(log_text)
		if(LOG_CHAT)
			log_chat(log_text)
		if(LOG_COMMENT)
			log_comment(log_text)
		if(LOG_TELECOMMS)
			log_telecomms(log_text)
		if(LOG_ECON)
			log_econ(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_adminsay(log_text)
		if(LOG_OWNERSHIP)
			log_game(log_text)
		if(LOG_GAME)
			log_game(log_text)
		if(LOG_MECHA)
			log_mecha(log_text)
		if(LOG_SHUTTLE)
			log_shuttle(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)

/// Helper for logging chat messages or other logs with arbitrary inputs (e.g. announcements)
/atom/proc/log_talk(message, message_type, tag=null, log_globally=TRUE, forced_by=null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix]\"[message]\"[suffix]", message_type, log_globally=log_globally)

/// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, message_type, tag="[tag] from [key_name(source)]", log_globally=FALSE)

/**
  * Log a combat message in the attack log
  *
  * Arguments:
  * * atom/user - argument is the actor performing the action
  * * atom/target - argument is the target of the action
  * * what_done - is a verb describing the action (e.g. punched, throwed, kicked, etc.)
  * * atom/object - is a tool with which the action was made (usually an item)
  * * addition - is any additional text, which will be appended to the rest of the log line
  */
/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [object]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if(user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_ATTACK, color="orange", log_globally=FALSE)

/**
  * log_wound() is for when someone is *attacked* and suffers a wound. Note that this only captures wounds from damage, so smites/forced wounds aren't logged, as well as demotions like cuts scabbing over
  *
  * Note that this has no info on the attack that dealt the wound: information about where damage came from isn't passed to the bodypart's damaged proc. When in doubt, check the attack log for attacks at that same time
  * TODO later: Add logging for healed wounds, though that will require some rewriting of healing code to prevent admin heals from spamming the logs. Not high priority
  *
  * Arguments:
  * * victim- The guy who got wounded
  * * suffered_wound- The wound, already applied, that we're logging. It has to already be attached so we can get the limb from it
  * * dealt_damage- How much damage is associated with the attack that dealt with this wound.
  * * dealt_wound_bonus- The wound_bonus, if one was specified, of the wounding attack
  * * dealt_bare_wound_bonus- The bare_wound_bonus, if one was specified *and applied*, of the wounding attack. Not shown if armor was present
  * * base_roll- Base wounding ability of an attack is a random number from 1 to (dealt_damage ** WOUND_DAMAGE_EXPONENT). This is the number that was rolled in there, before mods
  */
/proc/log_wound(atom/victim, datum/wound/suffered_wound, dealt_damage, dealt_wound_bonus, dealt_bare_wound_bonus, base_roll)
	if(QDELETED(victim) || !suffered_wound)
		return
	var/message = "has suffered: [suffered_wound][suffered_wound.limb ? " to [suffered_wound.limb.name]" : null]"// maybe indicate if it's a promote/demote?

	if(dealt_damage)
		message += " | Damage: [dealt_damage]"
		// The base roll is useful since it can show how lucky someone got with the given attack. For example, dealing a cut
		if(base_roll)
			message += " (rolled [base_roll]/[dealt_damage ** WOUND_DAMAGE_EXPONENT])"

	if(dealt_wound_bonus)
		message += " | WB: [dealt_wound_bonus]"

	if(dealt_bare_wound_bonus)
		message += " | BWB: [dealt_bare_wound_bonus]"

	victim.log_message(message, LOG_ATTACK, color="blue")

/atom/movable/proc/add_filter(name,priority,list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/atom/movable/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, /proc/cmp_filter_data_priority, TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))

/obj/item/update_filters()
	. = ..()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/atom/movable/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

/atom/movable/proc/remove_filter(name)
	if(filter_data && filter_data[name])
		filter_data -= name
		update_filters()

/atom/proc/intercept_zImpact(atom/movable/AM, levels = 1)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, AM, levels)

///Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)
	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(i)
			custom_material.on_removed(src, custom_materials[i], material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	if(!(material_flags & MATERIAL_NO_EFFECTS))
		for(var/x in materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(x)
			custom_material.on_applied(src, materials[x] * multiplier * material_modifier, material_flags)

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

/**Returns the material composition of the atom.
  *
  * Used when recycling items, specifically to turn alloys back into their component mats.
  *
  * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
  * with people converting the entire stations material supply into alloys.
  *
  * Arguments:
  * - flags: A set of flags determining how exactly the materials are broken down.
  */
/atom/proc/get_material_composition(breakdown_flags=NONE)
	. = list()
	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = SSmaterials.GetMaterialRef(mat)
		var/list/material_comp = material.return_composition(cached_materials[material], breakdown_flags)
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]

/**
  * Returns true if this atom has gravity for the passed in turf
  *
  * Sends signals [COMSIG_ATOM_HAS_GRAVITY] and [COMSIG_TURF_HAS_GRAVITY], both can force gravity with
  * the forced gravity var
  *
  * Gravity situations:
  * * No gravity if you're not in a turf
  * * No gravity if this atom is in is a space turf
  * * Gravity if the area it's in always has gravity
  * * Gravity if there's a gravity generator on the z level
  * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
  * * otherwise no gravity
  */
/atom/proc/has_gravity(turf/T)
	if(!T || !isturf(T))
		T = get_turf(src)

	if(!T)
		return 0

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, T, forced_gravity)
	if(!forced_gravity.len)
		SEND_SIGNAL(T, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(forced_gravity.len)
		var/max_grav
		for(var/i in forced_gravity)
			max_grav = max(max_grav, i)
		return max_grav

	if(isspaceturf(T)) // Turf never has gravity
		return 0
	if(istype(T, /turf/open/transparent/openspace)) //openspace in a space area doesn't get gravity
		if(istype(get_area(T), /area/space))
			return 0

	var/area/A = get_area(T)
	if(A.has_gravity) // Areas which always has gravity
		return A.has_gravity
	else
		// There's a gravity generator on our z level
		if(GLOB.gravity_generators["[T.z]"])
			var/max_grav = 0
			for(var/obj/machinery/gravity_generator/main/G in GLOB.gravity_generators["[T.z]"])
				max_grav = max(G.setting,max_grav)
			return max_grav
	return SSmapping.level_trait(T.z, ZTRAIT_GRAVITY)

/**
  * Causes effects when the atom gets hit by a rust effect from heretics
  *
  * Override this if you want custom behaviour in whatever gets hit by the rust
  */
/atom/proc/rust_heretic_act()
	return

/**
  * Used to set something as 'open' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setOpened()
	return

/**
  * Used to set something as 'closed' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setClosed()
	return


///Called when something resists while this atom is its loc
/atom/proc/container_resist_act(mob/living/user)

/**
  * Used to attempt to charge an object with a payment component.
  *
  * Use this if an atom needs to attempt to charge another atom.
  */
/atom/proc/attempt_charge(atom/sender, atom/target, extra_fees = 0)
	return SEND_SIGNAL(sender, COMSIG_OBJ_ATTEMPT_CHARGE, target, extra_fees)

///Passes Stat Browser Panel clicks to the game and calls client click on an atom
/atom/Topic(href, list/href_list)
	. = ..()
	if(!usr?.client)
		return
	var/client/usr_client = usr.client
	var/list/paramslist = list()
	if(href_list["statpanel_item_shiftclick"])
		paramslist["shift"] = "1"
	if(href_list["statpanel_item_ctrlclick"])
		paramslist["ctrl"] = "1"
	if(href_list["statpanel_item_altclick"])
		paramslist["alt"] = "1"
	if(href_list["statpanel_item_click"])
		// first of all make sure we valid
		var/mouseparams = list2params(paramslist)
		usr_client.Click(src, loc, null, mouseparams)
		return TRUE

/**
  * Recursive getter method to return a list of all ghosts orbitting this atom
  *
  * This will work fine without manually passing arguments.
  */
/atom/proc/get_all_orbiters(list/processed, source = TRUE)
	var/list/output = list()
	if (!processed)
		processed = list()
	if (src in processed)
		return output
	if (!source)
		output += src
	processed += src
	for (var/o in orbiters?.orbiter_list)
		var/atom/atom_orbiter = o
		output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output
