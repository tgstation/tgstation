/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	var/level = 2
	var/flags = 0
	var/list/fingerprints
	var/list/fingerprintshidden
	var/list/blood_DNA
	var/container_type = 0
	var/admin_spawned = 0	//was this spawned by an admin? used for stat tracking stuff.
	var/datum/reagents/reagents = null

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	//HUD images that this atom can provide.
	var/list/hud_possible

	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	//overlays that should remain on top and not normally be removed, like c4.
	var/list/priority_overlays

	var/list/atom_colours	 //used to store the different colors on an atom
							//its inherent color, the colored paint applied on it, special color effect etc...


/atom/New()
	//atom creation method that preloads variables at creation
	if(use_preloader && (src.type == _preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		_preloader.load(src)
	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	//lighting stuff
	if(opacity && isturf(loc))
		loc.UpdateAffectingLights()

	if(luminosity)
		light = new(src)

	if(SSobj && SSobj.initialized)
		Initialize(FALSE)
	//. = ..() //uncomment if you are dumb enough to add a /datum/New() proc

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
	if(reagents)
		qdel(reagents)
	return ..()

/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5)
	return (!density || !height)

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

/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_logs(user, src, "punched", "hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(istype(A, /atom/movable))
			var/atom/movable/M = A
			if(isliving(M.loc))
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


/atom/proc/Bumped(AM as mob|obj)
	return

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return container_type & OPENCONTAINER

/atom/proc/is_transparent()
	return container_type & TRANSPARENT

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
	if(istype(wires))
		wires.emp_pulse()

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

	if(reagents && (is_open_container() || is_transparent())) //is_open_container() isn't really the right proc for this, but w/e
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
	return

/atom/proc/ex_act(severity, target)
	contents_explosion(severity, target)

/atom/proc/blob_act(obj/structure/blob/B)
	return

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	return

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
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
	if(isspaceturf(get_turf(src)))
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

/atom/proc/acid_act(acidpwr, acid_volume)
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

//Called after New if the world is not loaded with TRUE
//Called from base of New if the world is loaded with FALSE
/atom/proc/Initialize(mapload)
	set waitfor = 0
	return

//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0)
	if(isturf(src))
		var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src)
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

/atom/proc/mech_melee_attack(obj/mecha/M)
	return



/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
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


/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/atom/vv_edit_var(var_name, var_value)
	if(!Debug2)
		admin_spawned = TRUE
	switch(var_name)
		if("luminosity")
			src.SetLuminosity(var_value)
			return//prevent normal setting of this value
	. = ..()
	switch(var_name)
		if("color")
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)

/atom/vv_get_dropdown()
	. = ..()
	. += "---"
	var/turf/curturf = get_turf(src)
	if (curturf)
		.["Jump to"] = "?_src_=holder;adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	.["Add reagent"] = "?_src_=vars;addreagent=\ref[src]"
	.["Trigger EM pulse"] = "?_src_=vars;emp=\ref[src]"
	.["Trigger explosion"] = "?_src_=vars;explode=\ref[src]"

