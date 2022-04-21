GLOBAL_LIST_INIT(pipe_cleaner_colors, list(
	"blue" = COLOR_STRONG_BLUE,
	"cyan" = COLOR_CYAN,
	"green" = COLOR_DARK_LIME,
	"orange" = COLOR_MOSTLY_PURE_ORANGE,
	"pink" = COLOR_LIGHT_PINK,
	"red" = COLOR_RED,
	"white" = COLOR_WHITE,
	"yellow" = COLOR_YELLOW
	))

//This is the old cable code, but minus any actual powernet logic
//Wireart is fun

///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)
 * 9   1   5
 * \ | /
 * 8 - 0 - 4
 * / | \
 * 10  2   6

If d1 = 0 and d2 = 0, there's no pipe_cleaner
If d1 = 0 and d2 = dir, it's a O-X pipe_cleaner, getting from the center of the tile to dir (knot pipe_cleaner)
If d1 = dir1 and d2 = dir2, it's a full X-X pipe_cleaner, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/pipe_cleaner
	name = "pipe cleaner"
	desc = "A bendable piece of wire covered in fuzz. Fun for arts and crafts!"
	icon = 'icons/obj/power_cond/pipe_cleaner.dmi'
	icon_state = "0-1"
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	color = COLOR_RED
	/// Pipe_cleaner direction 1 (see above)
	var/d1 = 0
	/// pipe_cleaner direction 2 (see above)
	var/d2 = 1
	/// Internal cable stack
	var/obj/item/stack/pipe_cleaner_coil/stored

/obj/structure/pipe_cleaner/yellow
	color = COLOR_YELLOW

/obj/structure/pipe_cleaner/green
	color = COLOR_DARK_LIME

/obj/structure/pipe_cleaner/blue
	color = COLOR_STRONG_BLUE

/obj/structure/pipe_cleaner/pink
	color = COLOR_LIGHT_PINK

/obj/structure/pipe_cleaner/orange
	color = COLOR_MOSTLY_PURE_ORANGE

/obj/structure/pipe_cleaner/cyan
	color = COLOR_CYAN

/obj/structure/pipe_cleaner/white
	color = COLOR_WHITE

// the power pipe_cleaner object
/obj/structure/pipe_cleaner/Initialize(mapload, param_color)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting pipe_cleaner
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext(icon_state, 1, dash))
	d2 = text2num(copytext(icon_state, dash + length(icon_state[dash])))

	if(d1)
		stored = new/obj/item/stack/pipe_cleaner_coil(null, 2, null, null, null, color)
	else
		stored = new/obj/item/stack/pipe_cleaner_coil(null, 1, null, null, null, color)

	color = param_color || color
	if(!color)
		var/list/pipe_cleaner_colors = GLOB.pipe_cleaner_colors
		var/random_color = pick(pipe_cleaner_colors)
		color = pipe_cleaner_colors[random_color]
	update_appearance()

/obj/structure/pipe_cleaner/Destroy() // called when a pipe_cleaner is deleted
	//If we have a stored item at this point, lets just delete it, since that should be
	//handled by deconstruction
	if(stored)
		QDEL_NULL(stored)
	return ..() // then go ahead and delete the pipe_cleaner

/obj/structure/pipe_cleaner/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(loc)
		if(T)
			stored.forceMove(T)
			stored = null
		else
			qdel(stored)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/pipe_cleaner/update_icon_state()
	icon_state = "[d1]-[d2]"
	return ..()

/obj/structure/pipe_cleaner/update_icon()
	. = ..()
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

// Items usable on a pipe_cleaner :
//   - Wirecutters : cut it duh !
//   - pipe cleaner coil : merge pipe cleaners
//
/obj/structure/pipe_cleaner/proc/handlecable(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		cut_pipe_cleaner(user)
		return

	else if(istype(W, /obj/item/stack/pipe_cleaner_coil))
		var/obj/item/stack/pipe_cleaner_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, span_warning("Not enough pipe cleaner!"))
			return
		coil.pipe_cleaner_join(src, user)

	add_fingerprint(user)

/obj/structure/pipe_cleaner/proc/cut_pipe_cleaner(mob/user)
	user.visible_message(span_notice("[user] pulls up the pipe cleaner."), span_notice("You pull up the pipe cleaner."))
	stored.add_fingerprint(user)
	investigate_log("was pulled up by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
	deconstruct()

/obj/structure/pipe_cleaner/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)

/obj/structure/pipe_cleaner/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/pipe_cleaner/proc/update_stored(length = 1, colorC = COLOR_RED)
	stored.amount = length
	stored.color = colorC
	stored.update_appearance()

/obj/structure/pipe_cleaner/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	cut_pipe_cleaner(user)

///////////////////////////////////////////////
// The pipe cleaner coil object, used for laying pipe cleaner
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

/obj/item/stack/pipe_cleaner_coil
	name = "pipe cleaner coil"
	desc = "A coil of pipe cleaners. Good for arts and crafts, not to build with."
	custom_price = PAYCHECK_ASSISTANT * 0.5
	gender = NEUTER //That's a pipe_cleaner coil sounds better than that's some pipe_cleaner coils
	icon = 'icons/obj/power.dmi'
	icon_state = "pipecleaner"
	inhand_icon_state = "pipecleaner"
	worn_icon_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/pipe_cleaner_coil // This is here to let its children merge between themselves
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	mats_per_unit = list(/datum/material/iron=10, /datum/material/glass=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines", "flogs")
	attack_verb_simple = list("whip", "lash", "discipline", "flog")
	singular_name = "pipe cleaner piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list("copper" = 2) //2 copper per pipe_cleaner in the coil
	usesound = 'sound/items/deconstruct.ogg'
	cost = 1
	source = /datum/robot_energy_storage/pipe_cleaner
	color = COLOR_RED

/obj/item/stack/pipe_cleaner_coil/cyborg/attack_self(mob/user)
	var/list/pipe_cleaner_colors = GLOB.pipe_cleaner_colors
	var/list/possible_colors = list()
	for(var/color in pipe_cleaner_colors)
		var/image/pipe_icon = image(icon = src.icon, icon_state = src.icon_state)
		pipe_icon.color = pipe_cleaner_colors[color]
		possible_colors += list("[color]" = pipe_icon)

	var/selected_color = show_radial_menu(user, src, possible_colors, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 40, require_near = TRUE)
	if(!selected_color)
		return
	color = pipe_cleaner_colors[selected_color]
	update_appearance()

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/obj/item/stack/pipe_cleaner_coil/cyborg/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/stack/pipe_cleaner_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message(span_suicide("[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/obj/item/stack/pipe_cleaner_coil/Initialize(mapload, new_amount = null, list/mat_override=null, mat_amt=1, param_color = null)
	. = ..()

	if(param_color)
		color = param_color
	if(!color)
		var/list/pipe_cleaner_colors = GLOB.pipe_cleaner_colors
		var/random_color = pick(pipe_cleaner_colors)
		color = pipe_cleaner_colors[random_color]

	pixel_x = base_pixel_x + rand(-2, 2)
	pixel_y = base_pixel_y + rand(-2, 2)
	update_appearance()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/pipe_cleaner_coil/update_name()
	. = ..()
	name = "pipe cleaner [amount < 3 ? "piece" : "coil"]"

/obj/item/stack/pipe_cleaner_coil/update_icon_state()
	. = ..()
	icon_state = "[initial(inhand_icon_state)][amount < 3 ? amount : ""]"

/obj/item/stack/pipe_cleaner_coil/update_icon()
	. = ..()
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/item/stack/pipe_cleaner_coil/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/obj/item/stack/pipe_cleaner_coil/new_pipe_cleaner = ..()
	if(istype(new_pipe_cleaner))
		new_pipe_cleaner.color = color
		new_pipe_cleaner.update_appearance()

//add pipe_cleaners to the stack
/obj/item/stack/pipe_cleaner_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_appearance()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/pipe_cleaner_coil/proc/get_new_pipe_cleaner(location)
	var/path = /obj/structure/pipe_cleaner
	return new path(location, color)

// called when pipe_cleaner_coil is clicked on a turf
/obj/item/stack/pipe_cleaner_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || !T.can_have_cabling())
		to_chat(user, span_warning("You can only lay pipe cleaners on a solid floor!"))
		return

	if(get_amount() < 1) // Out of pipe_cleaner
		to_chat(user, span_warning("There is no pipe cleaner left!"))
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, span_warning("You can't lay pipe cleaner at a place that far away!"))
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/pipe_cleaner/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, span_warning("There's already a pipe leaner at that position!"))
			return

	var/obj/structure/pipe_cleaner/C = get_new_pipe_cleaner(T)

	//set up the new pipe_cleaner
	C.d1 = 0 //it's a O-X node pipe_cleaner
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_appearance()

	use(1)

	return C

// called when pipe_cleaner_coil is click on an installed obj/pipe_cleaner
// or click on a turf that already contains a "node" pipe_cleaner
/obj/item/stack/pipe_cleaner_coil/proc/pipe_cleaner_join(obj/structure/pipe_cleaner/C, mob/user, showerror = TRUE, forceddir)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T)) // sanity check
		return

	if(get_dist(C, user) > 1) // make sure it's close enough
		to_chat(user, span_warning("You can't lay pipe cleaner at a place that far away!"))
		return


	if(U == T && !forceddir) //if clicked on the turf we're standing on and a direction wasn't supplied, try to put a pipe_cleaner in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	if(forceddir)
		dirn = forceddir

	// one end of the clicked pipe_cleaner is pointing towards us and no direction was supplied
	if((C.d1 == dirn || C.d2 == dirn) && !forceddir)
		if(!U.can_have_cabling()) //checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, span_warning("You can only lay pipe cleaners on catwalks and plating!"))
			return
		else
			// pipe_cleaner is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked pipe_cleaner on our tile

			var/fdirn = turn(dirn, 180) // the opposite direction

			for(var/obj/structure/pipe_cleaner/LC in U) // check to make sure there's not a pipe_cleaner there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, span_warning("There's already a pipe cleaner at that position!"))
					return

			var/obj/structure/pipe_cleaner/NC = get_new_pipe_cleaner(U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_appearance()

			use(1)

			return

	// exisiting pipe_cleaner doesn't point at our position or we have a supplied direction, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full pipe_cleaner pointing from it's old direction to our dirn
		var/nd1 = C.d2 // these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2) // swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/pipe_cleaner/LC in T) // check to make sure there's no matching pipe_cleaner
			if(LC == C) // skip the pipe_cleaner we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) ) // make sure no pipe_cleaner matches either direction
				if (showerror)
					to_chat(user, span_warning("There's already a pipe cleaner at that position!"))

				return


		C.update_appearance()

		C.d1 = nd1
		C.d2 = nd2

		//updates the stored pipe_cleaner coil
		C.update_stored(2, color)

		C.add_fingerprint(user)
		C.update_appearance()

		use(1)

		return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/pipe_cleaner_coil/red
	color = COLOR_RED

/obj/item/stack/pipe_cleaner_coil/yellow
	color = COLOR_YELLOW

/obj/item/stack/pipe_cleaner_coil/blue
	color = COLOR_STRONG_BLUE

/obj/item/stack/pipe_cleaner_coil/green
	color = COLOR_DARK_LIME

/obj/item/stack/pipe_cleaner_coil/pink
	color = COLOR_LIGHT_PINK

/obj/item/stack/pipe_cleaner_coil/orange
	color = COLOR_MOSTLY_PURE_ORANGE

/obj/item/stack/pipe_cleaner_coil/cyan
	color = COLOR_CYAN

/obj/item/stack/pipe_cleaner_coil/white
	color = COLOR_WHITE

/obj/item/stack/pipe_cleaner_coil/random
	color = null

/obj/item/stack/pipe_cleaner_coil/random/five
	amount = 5

/obj/item/stack/pipe_cleaner_coil/cut
	amount = null
	icon_state = "pipecleaner2"

/obj/item/stack/pipe_cleaner_coil/cut/Initialize(mapload)
	if(!amount)
		amount = rand(1,2)
	. = ..()
	pixel_x = base_pixel_x + rand(-2, 2)
	pixel_y = base_pixel_y + rand(-2, 2)
	update_appearance()

/obj/item/stack/pipe_cleaner_coil/cut/red
	color = COLOR_RED

/obj/item/stack/pipe_cleaner_coil/cut/yellow
	color = COLOR_YELLOW

/obj/item/stack/pipe_cleaner_coil/cut/blue
	color = COLOR_STRONG_BLUE

/obj/item/stack/pipe_cleaner_coil/cut/green
	color = COLOR_DARK_LIME

/obj/item/stack/pipe_cleaner_coil/cut/pink
	color = COLOR_LIGHT_PINK

/obj/item/stack/pipe_cleaner_coil/cut/orange
	color = COLOR_MOSTLY_PURE_ORANGE

/obj/item/stack/pipe_cleaner_coil/cut/cyan
	color = COLOR_CYAN

/obj/item/stack/pipe_cleaner_coil/cut/white
	color = COLOR_WHITE

/obj/item/stack/pipe_cleaner_coil/cut/random
	color = null
