//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list() //list of beams
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/beam_type = /obj/effect/ebeam //must be subtype
	var/obj/effect/ebeam/visuals //what we add to the ebeam's visual contents. never gets deleted on redrawing.

/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=50,btype = /obj/effect/ebeam)
	origin = beam_origin
	target = beam_target
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype
	if(time < INFINITY)
		QDEL_IN(src, time)

/datum/beam/proc/Start()
	visuals = new beam_type()
	visuals.icon = icon
	visuals.icon_state = icon_state
	Draw()
	RegisterSignal(origin, COMSIG_MOVABLE_MOVED, .proc/redrawing)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/redrawing)

/datum/beam/proc/redrawing(atom/movable/mover, atom/oldloc, direction)
	Reset()
	Draw()

/datum/beam/proc/afterDraw()
	return

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

/datum/beam/proc/Draw()
	var/Angle = round(Get_Angle(origin,target))
	var/matrix/rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)
	var/DX
	var/DY
	var/atom/movable/targetp
	var/atom/movable/originp
	//Translation vector for origin and target
	if(!ismovable(target) || !ismovable(origin))
		DX = (32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
		DY = (32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	else if(ismovable(target) && ismovable(origin))
		targetp = target
		originp = origin
		DX = (32*targetp.x+targetp.step_x)-(32*originp.x+originp.step_x)
		DY = (32*targetp.y+targetp.step_y)-(32*originp.y+originp.step_y)
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
		if(N+32>length) //went past the target, needs to be cut short
			var/icon/II = new(icon, icon_state) //the way to keep this the same as the vis_contents is unreasonable right now, maybe in the far future.
			II.DrawBox(null,1,(length-N),32,32)//anyway we cut the icon on the ebeam to end at the target instead of overshooting
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
		if(originp && targetp)
			var/_step_x = abs(originp.step_x + targetp.step_x) / 2
			var/_step_y = abs(originp.step_y + targetp.step_y) / 2
			X.forceStep(null, _step_x, _step_y)
		CHECK_TICK
	afterDraw()

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

/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50,beam_type=/obj/effect/ebeam)
	var/datum/beam/newbeam = new(src,BeamTarget,icon,icon_state,time,beam_type)
	INVOKE_ASYNC(newbeam, /datum/beam/.proc/Start)
	return newbeam
