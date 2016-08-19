//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state
	var/max_distance = 0
	var/endtime = 0
	var/sleep_time = 3
	var/finished = 0
	var/target_oldloc = null
	var/origin_oldloc = null
	var/static_beam = 0
	var/beam_type = /obj/effect/ebeam //must be subtype

/datum/beam/New(beam_origin,beam_target,beam_icon='icons/effects/beam.dmi',beam_icon_state="b_beam",time=50,maxdistance=10,btype = /obj/effect/ebeam)
	endtime = world.time+time
	origin = beam_origin
	origin_oldloc = origin.loc
	if(isarea(origin_oldloc))
		origin_oldloc = origin
	target = beam_target
	target_oldloc = target.loc
	if(isarea(target_oldloc))
		target_oldloc = target
	if(origin_oldloc == origin && target_oldloc == target)
		static_beam = 1
	max_distance = maxdistance
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype

/datum/beam/proc/Start()
	Draw()
	while(!finished && target && world.time<endtime && get_dist(origin,target)<max_distance && origin.z == target.z)
		if(!static_beam && (origin.loc != origin_oldloc || target.loc != target_oldloc))
			Reset()
			Draw()
		sleep(sleep_time)
	qdel(src)

/datum/beam/proc/End()
	finished = 1

/datum/beam/proc/Reset()
	for(var/obj/effect/ebeam/B in elements)
		qdel(B)

/datum/beam/Destroy()
	Reset()
	target = null
	origin = null
	return ..()

/datum/beam/proc/Draw()
	var/Angle=round(Get_Angle(origin,target))

	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	var/DX=(32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
	var/DY=(32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	var/N=0
	var/length=round(sqrt((DX)**2+(DY)**2))

	for(N,N<length,N+=32)
		var/obj/effect/ebeam/X= new beam_type(origin_oldloc)
		X.owner=src
		elements |= X
		if(N+32>length)
			var/icon/II=new(icon,icon_state)
			II.DrawBox(null,1,(length-N),32,32)
			X.icon=II
		else X.icon=base_icon
		X.transform = rot_matrix
		var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
		if(DX==0) Pixel_x=0
		if(DY==0) Pixel_y=0
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : Ceiling(Pixel_x/32)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : Ceiling(Pixel_y/32)
			X.y += a
			Pixel_y %= 32

		X.pixel_x=Pixel_x
		X.pixel_y=Pixel_y

/obj/effect/ebeam
	var/datum/beam/owner

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()