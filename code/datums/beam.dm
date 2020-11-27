
/** Beam Datum and Effect
 * IF YOU ARE LAZY AND DO NOT WANT TO READ, GO TO THE BOTTOM OF THE FILE AND USE THAT PROC!
 * IF YOU ONLY CARE ABOUT HOW WE'RE DOING THIS, GO TO Draw() AND READ THAT DOC!
 *
 * This is the beam datum! It's a really neat effect for the game in drawing a line from one atom to another.
 * It has two parts:
 * The datum itself which manages redrawing the beam to constantly keep it pointing from the origin to the target.
 * The effect which is what the beams are made out of. They're placed in a line from the origin to target, rotated towards the target and snipped off at the end.
 * These effects are kept in a list and constantly created and destroyed (hence the proc names draw and reset, reset destroying all effects and draw creating more.)
 *
 * You can add more special effects to the beam itself by changing what the drawn beam effects do. For example you can make a vine that pricks people by making the beam_type
 * include a crossed proc that damages the crosser. Examples in venus_human_trap.dm
*/
/datum/beam
	var/atom/origin = null ///where the beam goes from
	var/atom/target = null ///where the beam goes to
	var/list/elements = list() ///list of beam objects. These have their visuals set by the visuals var which is created on starting
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/beam_type = /obj/effect/ebeam //must be subtype

	var/obj/effect/ebeam/visuals //what we add to the ebeam's visual contents. never gets deleted on redrawing.

/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",btype = /obj/effect/ebeam)
	origin = beam_origin
	target = beam_target
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype

/**
 * Proc called by the atom Beam() proc. Sets up signals, and draws the beam for the first time.
 *
 * Arguments:
 * None!
 */
/datum/beam/proc/Start()
	visuals = new beam_type()
	visuals.icon = icon
	visuals.icon_state = icon_state
	Draw()
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, .proc/redrawing)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/redrawing)

/**
 * Triggered by signals set up when the beam is drawn. Removes the old beam, creates a new one.
 *
 * Arguments:
 * mover: either the origin of the beam or the target of the beam that moved.
 * oldloc: from where mover moved.
 * direction: in what direction mover moved from.
 */
/datum/beam/proc/redrawing(atom/movable/mover, atom/oldloc, direction)
	Reset()
	Draw()

/**
 * Deletes the old beam objects from origin to target.
 *
 * You must clean up the old beams before creating new ones! Every draw is a new set of objects, it doesn't touch the old ones. They will sit around pointing from where
 * where one atom WAS to where another atom WAS without knowing if they are still there.
 * Arguments:
 * None!
 */
/datum/beam/proc/Reset()
	for(var/obj/effect/ebeam/B in elements)
		qdel(B)
	elements.Cut()

/datum/beam/Destroy()
	Reset()
	qdel(visuals)
	UnregisterSignal(origin, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target = null
	origin = null
	return ..()

/**
 * Creates the beam effects and places them in a line from the origin to the target. Sets their rotation to make the beams face the target, too.
 *
 * A very long explanation of each step in the draw proc:
 * To start out, we get a few things that we need to calculate where to place and set up the beam effects.
 * The rotation to the target stored in a matrix, translation vector ((hypotenuse from point Y to Z)) (destination X and Y to target and the length in pixels to get there)
 * And N being the amount we've travelled along the hypotenuse. This goes up one tile length towards the target every beam placed
 * If the placement goes beyond the beam's destination, it cuts the icon at the end with a drawbox and given the normal icon. OTHERWISE, it's given the ebeam visuals.
 * -in the future remind me to refactor this part to not use drawbox but instead use a 513 filter to cut off the end, so i can make the entire part use the visuals- armhulen
 * Then we calculate where it's pixel position should be in relation to the origin turf. when it goes over 32, it wraps back to 1 and the object is moved into the new tile.
 * So this part both positions the pixel_x/y AND moves it to the tile it should be in for the beam to be interactable
 * ...aka outside the bounds of the tile, the actual position is changed so cross code still makes sense.
 * And repeat for each ebeam! Sorry if the explanation is bad, but honestly it's all just trigonometry so I hope you hit the books in high school buddy (if you're even out of it)
 *
 * Arguments:
 * None!
 */
/datum/beam/proc/Draw()
	var/Angle = round(Get_Angle(origin,target))
	var/matrix/rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
	var/DY = (32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	var/N = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src))
			break
		var/obj/effect/ebeam/X = new beam_type(origin_turf)
		X.owner = src
		elements += X

		//Assign our single visual ebeam to each ebeam's vis_contents
		//ends are cropped by a transparent box icon of length-N pixel size laid over the visuals obj
		if(N+32>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null,1,(length-N),32,32)
			X.icon = II
		else
			X.vis_contents += visuals
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(N+16)/32)

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			X.y += a
			Pixel_y %= 32

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/datum/beam/owner

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()

/obj/effect/ebeam/singularity_pull()
	return
/obj/effect/ebeam/singularity_act()
	return

/**
 * This is what you use to start a beam. Example: origin.Beam(target, args). Store the return of this proc, you need it to delete the beam.
 *
 * Unless you're making a custom beam effect (see the beam_type argument), you won't actually have to mess with any other procs. Make sure you store the return of this Proc, you'll need it
 * to kill the beam.
 * Arguments:
 * BeamTarget: Where you're beaming from. Where do you get origin? You didn't read the docs, fuck you.
 * icon_state: What the beam's icon_state is. The datum effect isn't the ebeam object, it doesn't hold any icon and isn't type dependent.
 * icon: What the beam's icon file is. Don't change this, man. All beam icons should be in beam.dmi anyways.
 * beam_type: The type of your custom beam. This is for adding other wacky stuff for your beam only. Most likely, you won't (and shouldn't) change it.
 */
/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',beam_type=/obj/effect/ebeam)
	var/datum/beam/newbeam = new(src,BeamTarget,icon,icon_state,beam_type)
	INVOKE_ASYNC(newbeam, /datum/beam/.proc/Start)
	return newbeam
