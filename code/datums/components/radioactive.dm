/*
** Radiation field is a simulation of ionizing radiation.  Basicly, its an
** invisiable lamp that will kill you and power the station.  While the
** waves were fine, they added a bit of stress on the servers.  Especialy
** when a bunch of idiots contaminated themslves or stacked a bunch of
** urainuam folding chairs.  So instead a field is made using the code
** from shield gen.  So instead of random datums created and shooting
** from a source, a field will follow around from this source.
** putting it all here in the component simplifys things
*/


#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// Is the parrent a source of radiation?
	/// if so, we never run out of contaimation
	var/is_source
	/// How strong it was originaly
	var/intensity
	/// How much contaminated material it still has
	var/remaining_contam
	/// Higher than 1 makes it drop off faster, 0.5 makes it drop off half etc
	var/range_modifier
	/// Whether or not this radiation wave can create contaminated objects
	var/can_contaminate
	/// halflife in ticks
	var/hl3_release_date
	/// field strengh caculation
	var/list/field_strength

/datum/component/radioactive/Initialize(_intensity=0, _is_source, _half_life=RAD_HALF_LIFE, _can_contaminate=TRUE,_range_modifier=RAD_DISTANCE_COEFFICIENT)
	intensity = _intensity
	is_source = _is_source
	hl3_release_date = _half_life
	can_contaminate = _can_contaminate
	range_modifier = _range_modifier
	remaining_contam = intensity
	field_strength = caculate_field_range(intensity)

	if(istype(parent, /atom))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/rad_examine)
		if(istype(parent, /obj/item))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/rad_attack)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, .proc/rad_attack)
	else
		return COMPONENT_INCOMPATIBLE

	if(intensity > RAD_MINIMUM_CONTAMINATION)
		SSradiation.warn(src)

	START_PROCESSING(SSradiation, src)

/datum/componnet/proc/caculate_field_range(strength)
	. = list()
	var/steps = 1
	while(strength >  RAD_BACKGROUND_RADIATION)
		if(steps>1)
			strength = INVERSE_SQUARE(strength, max(range_modifier*steps, 1), 1)
		. += strength

/datum/component/radioactive/Destroy()

	STOP_PROCESSING(SSradiation, src)
	return ..()

// 15 degress radian
// why not higher?  We might miss tiles on the outer raduis
// will figure this out after I do some profiling
#define CIRCLE_INC 0.261799 // 15 degrees radian
// code copy from line of sight
// We are basicly drawing a line from the center point to the outer point
// of where radiation ends
#define SIGNV(X) (((X)<0)?-1:1)
#define X1 centerturf.x
#define Y1 centerturf.y
#define X2 far_x
#define Y2 far_y
#define PX1=16.5
#define PY1=16.5
#define PX2=16.5
#define PY2=16.5

/datum/component/radioactive/proc/create_field()
	var/ray_strength_precaluated =  caculate_field_range(remaining_contam)
	var/turf/centerturf = get_turf(parent)
	var/list/turfs = new/list()
	var/radius = field_strength.len
	var/rsq = max_length * (max_length+0.5)
	var/far_x
	var/far_y
	var/far_z = centerturf.z
	var/turf/T
	// NOTE, profile this if its better to cache this in a list
	for(var/rad = 0; r < 2.0; r += CIRCLE_INC)
		far_x = round(radius*cos(rad) + centerturf.x + 0.5)
		far_y = round(radius*sin(rad) + centerturf.y + 0.5)
		T = locate(far_x, far_y, far_z)
		if(!T || turfs[T])
			continue  	// If the turf dosn't exist or is free
		var/rad_blocking = 0
		var/steps = 1
		var/ray_strength = ray_strength_precaluated[steps]
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIGN(X2-X1)
		var/signY = SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			ray_strength = ray_strength_precaluated[steps]

		ray_strength = INVERSE_SQUARE(intensity, max(range_modifier*steps, 1), 1)
	else
		ray_strength = remaining_contam
			if(T.opacity)
				return 0


#undef X1
#undef Y1
#undef X2
#undef Y2
#undef PX1
#undef PY1
#undef PX2
#undef PY2
#define SIGNV(X) (((X)<0)?-1:1)


/datum/component/radioactive/process()
	var/list/affected_tiles = circlerange(parent, field_strength.len)
	for(var/turf/T in orange(, parent))
		affected_tiles[T] = 0
	var/dist
	var/dir
	for(var/turf/K in affected_tiles)
		dist = get_dist_euclidian (K, parent)


	for(var/i in 1 to field_strength.len)



		get_dist
		if(isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(machine_stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

	// Why is strength/4?  So say you are comtaminated with 4000 mev.
	// Even if you are a few tiles away, even with a *2 to the coefficent you
	// still get a freaking high dose.  Right next to the guy and your getting most
	// of it.  But at /4, the contamination you will get will only be 1000
	// Managable by any of the lower level drugs.
	radiation_pulse(parent, strength/4, RAD_DISTANCE_COEFFICIENT*2, FALSE, can_contaminate)

	if(is_source || !hl3_release_date)
		return
	strength -= strength / hl3_release_date
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(src)
		return PROCESS_KILL

/datum/component/radioactive/InheritComponent(datum/component/C, i_am_original, _strength, _source, _half_life, _can_contaminate)
	if(!i_am_original)
		return
	if(!hl3_release_date) // Permanently radioactive things don't get to grow stronger
		return
	if(C)
		var/datum/component/radioactive/other = C
		strength = max(strength, other.strength)
	else
		strength = max(strength, _strength)

/datum/component/radioactive/proc/rad_examine(datum/source, mob/user, atom/thing)
	var/atom/master = parent
	var/list/out = list()
	if(get_dist(master, user) <= 1)
		out += "The air around [master] feels warm"
	switch(strength)
		if(RAD_AMOUNT_LOW to RAD_AMOUNT_MEDIUM)
			out += "[length(out) ? " and it " : "[master] "]feels weird to look at."
		if(RAD_AMOUNT_MEDIUM to RAD_AMOUNT_HIGH)
			out += "[length(out) ? " and it " : "[master] "]seems to be glowing a bit."
		if(RAD_AMOUNT_HIGH to INFINITY) //At this level the object can contaminate other objects
			out += "[length(out) ? " and it " : "[master] "]hurts to look at."
	if(!LAZYLEN(out))
		return
	out += "."
	to_chat(user, "<span class ='warning'>[out.Join()]</span>")

/datum/component/radioactive/proc/rad_attack(datum/source, atom/movable/target, mob/living/user)
	radiation_pulse(parent, strength/20)
	target.rad_act(strength/2)
	if(!hl3_release_date)
		return
	strength -= strength / hl3_release_date

#undef RAD_AMOUNT_LOW
#undef RAD_AMOUNT_MEDIUM
#undef RAD_AMOUNT_HIGH
#undef RAD_AMOUNT_EXTREME
