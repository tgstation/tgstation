var/global/list/del_profiling = list()
var/global/list/gdel_profiling = list()
var/global/list/ghdel_profiling = list()
/atom
	layer = 2

	var/ghost_read  = 1 // All ghosts can read
	var/ghost_write = 0 // Only aghosts can write
	var/blessed=0 // Chaplain did his thing. (set by holywater)

	var/level = 2
	var/flags = FPRINT
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/blood_color
	var/last_bumped = 0
	var/pass_flags = 0
	var/throwpass = 0
	var/germ_level = 0 // The higher the germ level, the more germ on the atom.
	var/pressure_resistance = ONE_ATMOSPHERE

	///Chemistry.
	var/datum/reagents/reagents = null

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	var/list/beams=list()

	// EVENTS
	/////////////////////////////
	// On Destroy()
	var/event/on_destroyed = new()

	// When this object moves. (args: loc)
	var/event/on_moved = new()

	var/labeled //Stupid and ugly way to do it, but the alternative would probably require rewriting everywhere a name is read.
	var/min_harm_label = 0 //Minimum langth of harm-label to be effective. 0 means it cannot be harm-labeled. If any label should work, set this to 1 or 2.
	var/harm_labeled = 0 //Length of current harm-label. 0 if it doesn't have one.
	var/list/harm_label_examine //Messages that appears when examining the item if it is harm-labeled. Message in position 1 is if it is harm-labeled but the label is too short to work, while message in position 2 is if the harm-label works.
	//var/harm_label_icon_state //Makes sense to have this, but I can't sprite. May be added later.

/atom/proc/beam_connect(var/obj/effect/beam/B)
	if(!(B in beams))
		beams.Add(B)
	return 1

/atom/proc/beam_disconnect(var/obj/effect/beam/B)
	beams.Remove(B)

/atom/proc/throw_impact(atom/hit_atom, var/speed)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.hitby(src)

		log_attack("<font color='red'>[hit_atom] ([M.ckey]) was hit by [src] thrown by ([src.fingerprintslast])</font>")

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			step(O, src.dir)
		O.hitby(src,speed)

	else if(isturf(hit_atom))
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.take_organ_damage(20)

/atom/proc/AddToProfiler()
	// Memory usage profiling - N3X.
	if (type in type_instances)
		type_instances[type] = type_instances[type] + 1
	else
		type_instances[type] = 1

/atom/proc/DeleteFromProfiler()
	// Memory usage profiling - N3X.
	if (type in type_instances)
		type_instances[type] = type_instances[type] - 1
	else
		type_instances[type] = 0
		WARNING("Type [type] does not inherit /atom/New().  Please ensure ..() is called, or that the type calls AddToProfiler().")

/atom/Del()
	DeleteFromProfiler()
	..()

/atom/Destroy()
	SetOpacity(0)

	if(reagents)
		reagents.Destroy()
		reagents = null

	// Idea by ChuckTheSheep to make the object even more unreferencable.
	invisibility = 101
	INVOKE_EVENT(on_destroyed, list()) // No args.
	if(istype(beams, /list) && beams.len) beams.len = 0
	/*if(istype(beams) && beams.len)
		for(var/obj/effect/beam/B in beams)
			if(B && B.target == src)
				B.target = null
			if(B.master && B.master.target == src)
				B.master.target = null
		beams.len = 0
	*/

/atom/New()
	. = ..()
	AddToProfiler()

/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai)) // WHYYYY
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return flags & OPENCONTAINER

/*//Convenience proc to see whether a container can be accessed in a certain way.

	proc/can_subract_container()
		return flags & EXTRACT_CONTAINER

	proc/can_add_container()
		return flags & INSERT_CONTAINER
*/


/atom/proc/meteorhit(obj/meteor as obj)
	return

/atom/proc/allow_drop()
	return 1

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(var/severity)
	return

/atom/proc/singuloCanEat()
	return 1

/atom/proc/bullet_act(var/obj/item/projectile/Proj)
	return 0

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return 1
	else if(src in container)
		return 1
	return

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found




/*
Beam code by Gunbuddy

Beam() proc will only allow one beam to come from a source at a time.  Attempting to call it more than
once at a time per source will cause graphical errors.
Also, the icon used for the beam will have to be vertical and 32x32.
The math involved assumes that the icon is vertical to begin with so unless you want to adjust the math,
its easier to just keep the beam vertical.
*/
/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10)
	//BeamTarget represents the target for the beam, basically just means the other end.
	//Time is the duration to draw the beam
	//Icon is obviously which icon to use for the beam, default is beam.dmi
	//Icon_state is what icon state is used. Default is b_beam which is a blue beam.
	//Maxdistance is the longest range the beam will persist before it gives up.
	var/EndTime=world.time+time
	var/broken = 0
	var/obj/item/projectile/beam/lightning/light = getFromPool(/obj/item/projectile/beam/lightning)
	while(BeamTarget&&world.time<EndTime&&get_dist(src,BeamTarget)<maxdistance&&z==BeamTarget.z)

	//If the BeamTarget gets deleted, the time expires, or the BeamTarget gets out
	//of range or to another z-level, then the beam will stop.  Otherwise it will
	//continue to draw.

		//dir=get_dir(src,BeamTarget)	//Causes the source of the beam to rotate to continuosly face the BeamTarget.

		for(var/obj/effect/overlay/beam/O in orange(10,src))	//This section erases the previously drawn beam because I found it was easier to
			if(O.BeamSource==src)				//just draw another instance of the beam instead of trying to manipulate all the
				del O							//pieces to a new orientation.
		var/Angle=round(Get_Angle(src,BeamTarget))
		var/icon/I=new(icon,icon_state)
		I.Turn(Angle)
		var/DX=(32*BeamTarget.x+BeamTarget.pixel_x)-(32*x+pixel_x)
		var/DY=(32*BeamTarget.y+BeamTarget.pixel_y)-(32*y+pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		for(N,N<length,N+=32)
			var/obj/effect/overlay/beam/X=new(loc)
			X.BeamSource=src
			if(N+32>length)
				var/icon/II=new(icon,icon_state)
				II.DrawBox(null,1,(length-N),32,32)
				II.Turn(Angle)
				X.icon=II
			else X.icon=I
			var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
			var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
			if(DX==0) Pixel_x=0
			if(DY==0) Pixel_y=0
			if(Pixel_x>32)
				for(var/a=0, a<=Pixel_x,a+=32)
					X.x++
					Pixel_x-=32
			if(Pixel_x<-32)
				for(var/a=0, a>=Pixel_x,a-=32)
					X.x--
					Pixel_x+=32
			if(Pixel_y>32)
				for(var/a=0, a<=Pixel_y,a+=32)
					X.y++
					Pixel_y-=32
			if(Pixel_y<-32)
				for(var/a=0, a>=Pixel_y,a-=32)
					X.y--
					Pixel_y+=32
			X.pixel_x=Pixel_x
			X.pixel_y=Pixel_y
			var/turf/TT = get_turf(X.loc)
			if(TT.density)
				qdel(X)
				break
			for(var/obj/O in TT)
				if(!O.CanPass(light))
					broken = 1
					break
				else if(O.density)
					broken = 1
					break
			if(broken)
				qdel(X)
				break
		sleep(3)	//Changing this to a lower value will cause the beam to follow more smoothly with movement, but it will also be more laggy.
					//I've found that 3 ticks provided a nice balance for my use.
	for(var/obj/effect/overlay/beam/O in orange(10,src)) if(O.BeamSource==src) qdel(O)

//Woo hoo. Overtime
//All atoms
/atom/proc/examine(mob/user, var/size = "")
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src]."
	if(src.blood_DNA)
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += "<span class='danger'>blood-stained</span> [name]!"

	user << "\icon[src] That's [f_name]" + size
	if(desc)
		user << desc

	if(reagents && is_open_container() && !ismob(src)) //is_open_container() isn't really the right proc for this, but w/e
		if(get_dist(user,src) > 3)
			user << "<span class='info'>You can't make out the contents.</span>"
		else
			user << "It contains:"
			if(reagents.reagent_list.len)
				for(var/datum/reagent/R in reagents.reagent_list)
					user << "<span class='info'>[R.volume] units of [R.name]</span>"
			else
				user << "<span class='info'>Nothing.</span>"
	if(on_fire)
		user << "<span class='danger'>OH SHIT! IT'S ON FIRE!</span>"

	if(min_harm_label && harm_labeled)
		if(harm_labeled < min_harm_label)
			user << harm_label_examine[1]
		else
			user << harm_label_examine[2]
	return

// /atom/proc/MouseDrop_T()
// 	return

/atom/proc/relaymove()
	return

// Severity is actually "distance".
// 1 is pretty much just del(src).
// 2 is moderate damage.
// 3 is light damage.
//
// child is set to the child object that exploded, if available.
/atom/proc/ex_act(var/severity, var/child=null)
	return

/atom/proc/blob_act()
	return

/*
/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return

/atom/proc/attack_animal(mob/user as mob)
	return

/atom/proc/attack_ghost(mob/user as mob)
	var/ghost_flags = 0
	if(ghost_read)
		ghost_flags |= PERMIT_ALL
	if(canGhostRead(user,src,ghost_flags))
		src.attack_ai(user)
	else
		src.examine()
	return

/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

//for aliens, it works the same as monkeys except for alien-> mob interactions which will be defined in the
//appropiate mob files
/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return

/atom/proc/attack_larva(mob/user as mob)
	return

// for slimes
/atom/proc/attack_slime(mob/user as mob)
	return

/atom/proc/hand_h(mob/user as mob)			//human (hand) - restrained
	return

/atom/proc/hand_p(mob/user as mob)			//monkey (paw) - restrained
	return

/atom/proc/hand_a(mob/user as mob)			//AI - restrained
	return

/atom/proc/hand_r(mob/user as mob)			//Cyborg (robot) - restrained
	src.hand_a(user)
	return

/atom/proc/hand_al(mob/user as mob)			//alien - restrained
	src.hand_p(user)
	return

/atom/proc/hand_m(mob/user as mob)			//slime - restrained
	return
*/

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull()
	return

/atom/proc/emag_act()
	return

/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/*
/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!(istype(W, /obj/item/weapon/grab) ) && !(istype(W, /obj/item/weapon/plastique)) && !(istype(W, /obj/item/weapon/reagent_containers/spray)) && !(istype(W, /obj/item/weapon/packageWrap)) && !istype(W, /obj/item/device/detective_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << "\red <B>[src] has been hit by [user] with [W]</B>"
	return
*/
/atom/proc/add_hiddenprint(mob/living/M as mob)
	if(isnull(M)) return
	if(isnull(M.key)) return
	if (!( src.flags ) & FPRINT)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna))
			return 0
		if (H.gloves)
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 0
		if (!( src.fingerprints ))
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 1
	else
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
	return

/atom/proc/add_fingerprint(mob/living/M as mob)
	if(isnull(M)) return
	if(isAI(M)) return
	if(isnull(M.key)) return
	if (!( src.flags ) & FPRINT)
		return
	if (ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if (M_FINGERPRINTS in M.mutations)
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return 0		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
		H.check_dna()

		//Now, deal with gloves.
		if (H.gloves && H.gloves != src)
			if(fingerprintslast != H.key)
				fingerprintshidden += text("\[[]\](Wearing gloves). Real name: [], Key: []",time_stamp(), H.real_name, H.key)
				fingerprintslast = H.key
			H.gloves.add_fingerprint(M)

		//Deal with gloves the pass finger/palm prints.
		if(H.gloves != src)
			if(prob(75) && istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0
			else if(H.gloves && !istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0

		//More adminstuffz
		if(fingerprintslast != H.key)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []",time_stamp(), H.real_name, H.key)
			fingerprintslast = H.key

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		//Hash this shit.
		var/full_print = md5(H.dna.uni_identity)

		// Add the fingerprints
		fingerprints[full_print] = full_print

		return 1
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.key)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []",time_stamp(), M.real_name, M.key)
			fingerprintslast = M.key

	//Cleaning up shit.
	if(fingerprints && !fingerprints.len)
		del(fingerprints)
	return


/atom/proc/transfer_fingerprints_to(var/atom/A)
	if(!istype(A.fingerprints,/list))
		A.fingerprints = list()
	if(!istype(A.fingerprintshidden,/list))
		A.fingerprintshidden = list()

	//skytodo
	//A.fingerprints |= fingerprints            //detective
	//A.fingerprintshidden |= fingerprintshidden    //admin
	if(fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprintshidden && istype(fingerprintshidden))
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin	A.fingerprintslast = fingerprintslast


//returns 1 if made bloody, returns 0 otherwise
/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	.=1
	if(!M)//if the blood is of non-human source
		if(!blood_DNA || !istype(blood_DNA, /list))
			blood_DNA = list()
		blood_color = "#A10808"
		return 1
	if (!( istype(M, /mob/living/carbon/human) ))
		return 0
	if (!istype(M.dna, /datum/dna))
		M.dna = new /datum/dna(null)
		M.dna.real_name = M.real_name
	M.check_dna()
	if (!( src.flags ) & FPRINT)
		return 0
	if(!blood_DNA || !istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()
	blood_color = "#A10808"
	if (M.species)
		blood_color = M.species.blood_color
	//adding blood to humans
	else if (istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		//if this blood isn't already in the list, add it
		if(blood_DNA[H.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
		H.update_inv_gloves()	//handles bloody hands overlays and updating
		return 1 //we applied blood to the item
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M as mob, var/toxvomit = 0)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"


/atom/proc/clean_blood()
	src.germ_level = 0
	if(istype(blood_DNA, /list))
		del(blood_DNA)
		return 1


/atom/proc/get_global_map_pos()
	if(!islist(global_map) || isemptylist(global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	world << "X = [cur_x]; Y = [cur_y]"
	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

/atom/proc/checkpass(passflag)
	return pass_flags&passflag

/datum/proc/setGender(gend = FEMALE)
	if(!("gender" in vars))
		CRASH("Oh shit you stupid nigger the [src] doesn't have a gender variable.")
	if(ishuman(src))
		ASSERT(gend != PLURAL && gend != NEUTER)
	src:gender = gend

/atom/setGender(gend = FEMALE)
	gender = gend

/mob/living/carbon/human/setGender(gend = FEMALE)
	if(gend == PLURAL || gend == NEUTER || (gend != FEMALE && gend != MALE))
		CRASH("SOMEBODY SET A BAD GENDER ON [src] [gend]")
	var/old_gender = src.gender
	src.gender = gend
	testing("Set [src]'s gender to [gend], old gender [old_gender] previous gender [prev_gender]")

/atom/proc/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0