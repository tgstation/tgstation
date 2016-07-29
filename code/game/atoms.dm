<<<<<<< HEAD
/atom
	layer = TURF_LAYER
	var/level = 2
	var/flags = 0
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/admin_spawned = 0	//was this spawned by an admin? used for stat tracking stuff.

	///Chemistry.
	var/datum/reagents/reagents = null

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	//HUD images that this atom can provide.
	var/list/hud_possible

	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	//overlays that should remain on top and not normally be removed, like c4.
	var/list/priority_overlays

/atom/Destroy()
	if(alternate_appearances)
		for(var/aakey in alternate_appearances)
			var/datum/alternate_appearance/AA = alternate_appearances[aakey]
			qdel(AA)
		alternate_appearances = null
	if(viewing_alternate_appearances)
		for(var/aakey in viewing_alternate_appearances)
			for(var/aa in viewing_alternate_appearances[aakey])
				var/datum/alternate_appearance/AA = aa
				AA.hide(list(src))
	return ..()


/atom/proc/onCentcom()
	var/turf/T = get_turf(src)
	if(!T)
		return 0

	if(T.z != ZLEVEL_CENTCOM)//if not, don't bother
		return 0

	//check for centcomm shuttles
	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED && T in M.areaInstance)
			return 1

	//finally check for centcom itself
	return istype(T.loc,/area/centcom)

/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return 0

	if(T.z != ZLEVEL_CENTCOM)//if not, don't bother
		return 0

	if(istype(T.loc,/area/shuttle/syndicate) || istype(T.loc,/area/syndicate_mothership))
		return 1

	return 0

/atom/proc/attack_hulk(mob/living/carbon/human/hulk, do_attack_animation = 0)
	if(do_attack_animation)
		hulk.changeNext_move(CLICK_CD_MELEE)
		add_logs(hulk, src, "punched", "hulk powers")
		hulk.do_attack_animation(src)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(istype(A, /atom/movable))
			var/atom/movable/M = A
			if(istype(M.loc, /mob/living))
				var/mob/living/L = M.loc
				L.unEquip(M)
			M.loc = src

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(mob/user)
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

/atom/proc/can_subract_container()
	return flags & EXTRACT_CONTAINER

/atom/proc/can_add_container()
	return flags & INSERT_CONTAINER
*/


/atom/proc/allow_drop()
	return 1

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(severity)
	return

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return 1
	else if(src in container)
		return 1

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *       list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
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


/atom/proc/examine(mob/user)
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src]."
	if(src.blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += "<span class='danger'>blood-stained</span> [name]!"

	user << "\icon[src] That's [f_name]"

	if(desc)
		user << desc
	// *****RM
	//user << "[name]: Dn:[density] dir:[dir] cont:[contents] icon:[icon] is:[icon_state] loc:[loc]"

	if(reagents && is_open_container()) //is_open_container() isn't really the right proc for this, but w/e
		user << "It contains:"
		if(reagents.reagent_list.len)
			if(user.can_see_reagents()) //Show each individual reagent
				for(var/datum/reagent/R in reagents.reagent_list)
					user << "[R.volume] units of [R.name]"
			else //Otherwise, just show the total volume
				var/total_volume = 0
				for(var/datum/reagent/R in reagents.reagent_list)
					total_volume += R.volume
				user << "[total_volume] units of various reagents"
		else
			user << "Nothing."

/atom/proc/relaymove()
	return

/atom/proc/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

/atom/proc/ex_act(severity, target)
	contents_explosion(severity, target)

/atom/proc/blob_act(obj/effect/blob/B)
	return

/atom/proc/fire_act()
	return

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		spawn(2) //very short wait, so we can actually see the impact.
			if(AM && isturf(AM.loc))
				step(AM, turn(AM.dir, 180))

var/list/blood_splatter_icons = list()

/atom/proc/blood_splatter_index()
	return "\ref[initial(icon)]-[initial(icon_state)]"

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	return list("ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return 0
	if(!blood_DNA)	//if our list of DNA doesn't exist yet, initialise it.
		blood_DNA = list()
	var/old_length = blood_DNA.len
	blood_DNA |= new_blood_dna
	if(blood_DNA.len == old_length)
		return 0
	return 1

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!blood_DNA)
		blood_DNA = list()
	var/old_length = blood_DNA.len
	blood_DNA |= blood_dna
	if(blood_DNA.len > old_length)
		return 1//some new blood DNA was added


//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return 0
	return add_blood(blood_dna)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna)
	return 0

/obj/add_blood(list/blood_dna)
	return transfer_blood_dna(blood_dna)

/obj/item/add_blood(list/blood_dna)
	var/blood_count = !blood_DNA ? 0 : blood_DNA.len
	if(!..())
		return 0
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return 1 //we applied blood to the item

/obj/item/proc/add_blood_overlay()
	if(initial(icon) && initial(icon_state))
		//try to find a pre-processed blood-splatter. otherwise, make a new one
		var/index = blood_splatter_index()
		var/icon/blood_splatter_icon = blood_splatter_icons[index]
		if(!blood_splatter_icon)
			blood_splatter_icon = icon(initial(icon), initial(icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
			blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
			blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
			blood_splatter_icon = fcopy_rsc(blood_splatter_icon)
			blood_splatter_icons[index] = blood_splatter_icon
		add_overlay(blood_splatter_icon)

/obj/item/clothing/gloves/add_blood(list/blood_dna)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood(list/blood_dna)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	return 1 //we bloodied the floor

/mob/living/carbon/human/add_blood(list/blood_dna)
	if(wear_suit)
		wear_suit.add_blood(blood_dna)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(blood_dna)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna)
	else
		transfer_blood_dna(blood_dna)
	bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return 1

/atom/proc/clean_blood()
	if(istype(blood_DNA, /list))
		blood_DNA = null
		return 1

/atom/proc/wash_cream()
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

/atom/proc/isinspace()
	if(istype(get_turf(src), /turf/open/space))
		return 1
	else
		return 0

/atom/proc/handle_fall()
	return

/atom/proc/handle_slip()
	return
/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull()
	return

/atom/proc/acid_act(acidpwr, toxpwr, acid_volume)
	return

/atom/proc/emag_act()
	return

/atom/proc/narsie_act()
	return

/atom/proc/ratvar_act()
	return

/atom/proc/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
    return 0

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)

// Byond seemingly calls stat, each tick.
// Calling things each tick can get expensive real quick.
// So we slow this down a little.
// See: http://www.byond.com/docs/ref/info.html#/client/proc/Stat
/atom/Stat()
	. = ..()
	sleep(1)
	stoplag()

//This is called just before maps and objects are initialized, use it to spawn other mobs/objects
//effects at world start up without causing runtimes
/atom/proc/spawn_atom_to_world()

//This will be called after the map and objects are loaded
/atom/proc/initialize()
	return

//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0)
	if(istype(src,/turf) )
		var/obj/effect/decal/cleanable/vomit/V = PoolOrNew(/obj/effect/decal/cleanable/vomit, src)
		// Make toxins vomit look different
		if(toxvomit)
			V.icon_state = "vomittox_[pick(1,4)]"
		if(M.reagents)
			clear_reagents_to_vomit_pool(M,V)

/atom/proc/clear_reagents_to_vomit_pool(mob/living/carbon/M, obj/effect/decal/cleanable/vomit/V)
	M.reagents.trans_to(V, M.reagents.total_volume / 10)
	for(var/datum/reagent/R in M.reagents.reagent_list)                //clears the stomach of anything that might be digested as food
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/nutri_check = R
			if(nutri_check.nutriment_factor >0)
				M.reagents.remove_reagent(R.id,R.volume)


//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	dir = newdir

/atom/on_varedit(modified_var)
	if(!Debug2)
		admin_spawned = TRUE
=======
var/global/list/del_profiling = list()
var/global/list/gdel_profiling = list()
var/global/list/ghdel_profiling = list()
/atom
	layer = 2

	var/ghost_read  = 1 // All ghosts can read
	var/ghost_write = 0 // Only aghosts can write
	var/blessed=0 // Chaplain did his thing. (set by bless() proc, which is called by holywater)

	var/level = 2
	var/flags = FPRINT
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/blood_color
	var/pass_flags = 0
	var/throwpass = 0
	var/germ_level = 0 // The higher the germ level, the more germ on the atom.
	var/pressure_resistance = ONE_ATMOSPHERE
	var/penetration_dampening = 5 //drains some of a projectile's penetration power whenever it goes through the atom

	///Chemistry.
	var/datum/reagents/reagents = null

	//Material datums - the fun way of doing things in a laggy manner
	var/datum/materials/materials = null
	var/list/starting_materials //starting set of mats - used in New(), you can set this to an empty list to have the datum be generated but not filled

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	var/list/beams

	// EVENTS
	/////////////////////////////
	// On Destroy()
	var/event/on_destroyed

	// When this object moves. (args: loc)
	var/event/on_moved

	var/labeled //Stupid and ugly way to do it, but the alternative would probably require rewriting everywhere a name is read.
	var/min_harm_label = 0 //Minimum langth of harm-label to be effective. 0 means it cannot be harm-labeled. If any label should work, set this to 1 or 2.
	var/harm_labeled = 0 //Length of current harm-label. 0 if it doesn't have one.
	var/list/harm_label_examine //Messages that appears when examining the item if it is harm-labeled. Message in position 1 is if it is harm-labeled but the label is too short to work, while message in position 2 is if the harm-label works.
	//var/harm_label_icon_state //Makes sense to have this, but I can't sprite. May be added later.
	var/list/last_beamchecks // timings for beam checks.
	var/ignoreinvert = 0
	var/forceinvertredraw = 0
	var/tempoverlay
	var/timestopped

	appearance_flags = TILE_BOUND

/atom/proc/beam_connect(var/obj/effect/beam/B)
	if(!last_beamchecks) last_beamchecks = list()
	if(!beams) beams = list()
	if(!(B in beams))
		beams.Add(B)
	return 1

/atom/proc/beam_disconnect(var/obj/effect/beam/B)
	beams.Remove(B)

/atom/proc/apply_beam_damage(var/obj/effect/beam/B)
	return 1

/atom/proc/handle_beams()
	return 1

/atom/proc/shake(var/xy, var/intensity, mob/user) //Zth. SHAKE IT. Vending machines' kick uses this
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y

	switch(xy)
		if(1)
			src.pixel_x += rand(-intensity, intensity)
		if(2)
			src.pixel_y += rand(-intensity, intensity)
		if(3)
			src.pixel_x += rand(-intensity, intensity)
			src.pixel_y += rand(-intensity, intensity)

	spawn(2)
	src.pixel_x = old_pixel_x
	src.pixel_y = old_pixel_y

// NOTE FROM AMATEUR CODER WHO STRUGGLED WITH RUNTIMES
// throw_impact is called multiple times when an item is thrown: see /atom/movable/proc/hit_check at atoms_movable.dm
// Do NOT delete an item as part of it's throw_impact unless you've checked the hit_atom is a turf, as that's effectively the last time throw_impact is called in a single throw.
// Otherwise, shit will runtime in the subsequent throw_impact calls.
/atom/proc/throw_impact(atom/hit_atom, var/speed, user)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.hitby(src,speed,src.dir)
		log_attack("<font color='red'>[hit_atom] ([M ? M.ckey : "what"]) was hit by [src] thrown by ([src.fingerprintslast])</font>")

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
				M.take_organ_damage(10)

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
	if(reagents)
		qdel(reagents)
		reagents = null

	if(materials)
		returnToPool(materials)

	// Idea by ChuckTheSheep to make the object even more unreferencable.
	invisibility = 101
	INVOKE_EVENT(on_destroyed, list()) // No args.
	if(on_moved)
		on_moved.holder = null
		on_moved = null
	if(on_destroyed)
		on_destroyed.holder = null
		on_destroyed = null
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
	on_destroyed = new("owner"=src)
	on_moved = new("owner"=src)
	. = ..()
	if(starting_materials)
		materials = getFromPool(/datum/materials, src)
		for(var/matID in starting_materials)
			materials.addAmount(matID, starting_materials[matID])
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

// As a rule of thumb, should smoke be able to pop out from inside this object?
// Currently only used for chemical reactions, see Chemistry-Recipes.dm
/atom/proc/is_airtight()
	return 0

/*//Convenience proc to see whether a container can be accessed in a certain way.

	proc/can_subract_container()
		return flags & EXTRACT_CONTAINER

	proc/can_add_container()
		return flags & INSERT_CONTAINER
*/

/atom/proc/allow_drop()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj) //IF you want to use this, the atom must have the PROXMOVE flag, and the moving atom must also have the PROXMOVE flag currently to help with lag
	return

/atom/proc/emp_act(var/severity)
	return

/atom/proc/kick_act(mob/living/carbon/human/user) //Called when this atom is kicked. If returns 1, normal click action will be performed after calling this (so attack_hand() in most cases)
	return 1

/atom/proc/bite_act(mob/living/carbon/human/user) //Called when this atom is bitten. If returns 1, same as kick_act()
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

/atom/proc/projectile_check()
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
 *	atom/proc/contains_atom_from_list(var/list/L)
 *	Basically same as above but it takes a list of paths (like list(/mob/living/,/obj/machinery/something,...))
 * RETURNS: a found atom
 */
/atom/proc/contains_atom_from_list(var/list/L)
	for(var/atom/A in src)
		for(var/T in L)
			if(istype(A,T))
				return A
		if(A.contents.len)
			var/atom/R = A.contains_atom_from_list(L)
			if(R)
				return R
	return 0


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
				returnToPool(O)					//pieces to a new orientation.
		var/Angle=round(Get_Angle(src,BeamTarget))
		var/icon/I=new(icon,icon_state)
		I.Turn(Angle)
		var/DX=(32*BeamTarget.x+BeamTarget.pixel_x)-(32*x+pixel_x)
		var/DY=(32*BeamTarget.y+BeamTarget.pixel_y)-(32*y+pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		for(N,N<length,N+=32)
			var/obj/effect/overlay/beam/X=getFromPool(/obj/effect/overlay/beam,loc)
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
				if(!O.Cross(light))
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
	for(var/obj/effect/overlay/beam/O in orange(10,src)) if(O.BeamSource==src) returnToPool(O)

//Woo hoo. Overtime
//All atoms
/atom/proc/examine(mob/user, var/size = "")
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src]."
	if(src.blood_DNA && src.blood_DNA.len)
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += "<span class='danger'>blood-stained</span> [name]!"

	to_chat(user, "[bicon(src)] That's [f_name]" + size)
	if(desc)
		to_chat(user, desc)

	if(reagents && is_open_container() && !ismob(src)) //is_open_container() isn't really the right proc for this, but w/e
		if(get_dist(user,src) > 3)
			to_chat(user, "<span class='info'>You can't make out the contents.</span>")
		else
			to_chat(user, "It contains:")
			if(!user.hallucinating())
				if(reagents.reagent_list.len)
					for(var/datum/reagent/R in reagents.reagent_list)
						to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
				else
					to_chat(user, "<span class='info'>Nothing.</span>")

			else //Show stupid things to hallucinating mobs
				var/list/fake_reagents = list("Water", "Orange juice", "Banana juice", "Tungsten", "Chloral Hydrate", "Helium",\
					"Sea water", "Energy drink", "Gushin' Granny", "Salt", "Sugar", "something yellow", "something red", "something blue",\
					"something suspicious", "something smelly", "something sweet", "Soda", "something that reminds you of home",\
					"Chef's Special")
				for(var/i, i < rand(1,10), i++)
					var/fake_amount = rand(1,30)
					var/fake_reagent = pick(fake_reagents)
					fake_reagents -= fake_reagent

					to_chat(user, "<span class='info'>[fake_amount] units of [fake_reagent]</span>")
	if(on_fire)
		user.simple_message("<span class='danger'>OH SHIT! IT'S ON FIRE!</span>",\
			"<span class='info'>It's on fire, man.</span>")

	if(min_harm_label && harm_labeled)
		if(harm_labeled < min_harm_label)
			to_chat(user, harm_label_examine[1])
		else
			to_chat(user, harm_label_examine[2])
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

/atom/proc/mech_drill_act(var/severity, var/child=null)
	return ex_act(severity, child)

/atom/proc/blob_act(destroy = 0)
	//DEBUG to_chat(pick(player_list),"blob_act() on [src] ([src.type])")
	if(flags & INVULNERABLE)
		return
	anim(target = loc, a_icon = 'icons/mob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = 12)
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

//Called when a shuttle collides with an atom
/atom/proc/shuttle_act(var/datum/shuttle/S)
	return

//Called on every object in a shuttle which rotates
/atom/proc/shuttle_rotate(var/angle)
	src.dir = turn(src.dir, -angle)

	if(canSmoothWith) //Smooth the smoothable
		spawn //Usually when this is called right after an atom is moved. Not having this "spawn" here will cause this atom to look for its neighbours BEFORE they have finished moving, causing bad stuff.
			relativewall()
			relativewall_neighbours()

	if(pixel_x || pixel_y)
		var/cosine	= cos(angle)
		var/sine	= sin(angle)
		var/newX = (cosine	* pixel_x) + (sine	* pixel_y)
		var/newY = -(sine	* pixel_x) + (cosine* pixel_y)

		pixel_x = newX
		pixel_y = newY

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
				to_chat(O, "<span class='danger'>[src] has been hit by [user] with [W]</span>")
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

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0, active = 0, steal_reagents_from_mob = 1)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this
		if(active)
			this = new /obj/effect/decal/cleanable/vomit/active(src)
		else
			this = new /obj/effect/decal/cleanable/vomit(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"

		if(active && steal_reagents_from_mob && M && M.reagents)
			M.reagents.trans_to(this, M.reagents.total_volume * 0.1)


/atom/proc/clean_blood()
	src.germ_level = 0
	if(istype(blood_DNA, /list))
		//del(blood_DNA)
		blood_DNA.len = 0
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
//	to_chat(world, "X = [cur_x]; Y = [cur_y]")
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

/atom/proc/change_area(var/area/oldarea, var/area/newarea)
	if(istype(oldarea))
		oldarea = "[oldarea.name]"
	if(istype(newarea))
		newarea = "[newarea.name]"

//Called in /spell/aoe_turf/boo/cast() (code/modules/mob/dead/observer/spells.dm)
/atom/proc/spook()
	if(blessed)
		return 0
	return 1

//Called on holy_water's reaction_obj()
/atom/proc/bless()
	blessed = 1

/atom/proc/update_icon()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
