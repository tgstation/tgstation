/*
 * Copyright 2021 Gomble (https://github.com/AndrewL97)
 * Changes: Azrun (https://github.com/Azrun)
 * Changes: Sovexe (https://github.com/Sovexe)
 * Licensed under MIT to Goonstation only (https://choosealicense.com/licenses/mit/)
 */



///This was ported from Mojave but its literally just goons system so adding the proper licenses.

/*
	atom.particles



		Particle vars that affect the entire set (generators are not allowed for these)
			Var	Type	Description
			width	num	Size of particle image in pixels
			height
			count	num	Maximum particle count
			spawning	num	Number of particles to spawn per tick (can be fractional)
			bound1	vector	Minimum particle position in x,y,z space; defaults to list(-1000,-1000,-1000)
			bound2	vector	Maximum particle position in x,y,z space; defaults to list(1000,1000,1000)
			gravity	vector	Constant acceleration applied to all particles in this set (pixels per squared tick)
			gradient	color gradient	Color gradient used, if any
			transform	matrix	Transform done to all particles, if any (can be higher than 2D)

		Vars that apply when a particle spawns
			lifespan	num	Maximum life of the particle, in ticks
			fade	num	Fade-out time at end of lifespan, in ticks
			icon	icon	Icon to use, if any; no icon means this particle will be a dot
			Can be assigned a weighted list of icon files, to choose an icon at random
			icon_state	text	Icon state to use, if any
			Can be assigned a weighted list of strings, to choose an icon at random
			color	num or color	Particle color; can be a number if a gradient is used
			color_change	num	Color change per tick; only applies if gradient is used
			position	num	x,y,z position, from center in pixels
			velocity	num	x,y,z velocity, in pixels
			scale	vector (2D)	Scale applied to icon, if used; defaults to list(1,1)
			grow	num	Change in scale per tick; defaults to list(0,0)
			rotation	num	Angle of rotation (clockwise); applies only if using an icon
			spin	num	Change in rotation per tick
			friction	num	Amount of velocity to shed (0 to 1) per tick, also applied to acceleration from drift

		Vars that are evalulated every tick
			drift	vector	Added acceleration every tick; e.g. a circle or sphere generator can be applied to produce snow or ember effects



*/

//This should should have a default at some point
GLOBAL_LIST_INIT(master_particle_info, list())

/// Takes an input string like "A" and turns it into a macro A
#define TEXT_TO_MACRO(Y) if(#Y) return Y

//some helpyers
/datum/particle_editor/proc/ListToMatrix(list/L)

	//Normal Matrixes allow 6
	switch(length(L))
		if(6)
			return matrix(L[1],L[2],L[3],L[4],L[5],L[6])

/datum/particle_editor/proc/stringToList(str, toNum = FALSE, restoreNull = FALSE)
	. = splittext(str,regex(@"(?<!\\),"))
	if(toNum)
		for(var/i = 1; i <= length(.); ++i)
			.[i] = stringToNum(.[i], restoreNull)
	if(length(.) == 1 && (isnull(.[1]) || .[1] == ""))
		. = null

/datum/particle_editor/proc/stringToNum(str, restoreNull = FALSE)
	. = text2num(str)
	if(isnull(.) && restoreNull)
		. = str

/datum/particle_editor/proc/stringToMatrix(str)
	return ListToMatrix(stringToList(str))




/datum/particle_editor
	var/atom/movable/target

/datum/particle_editor/New(atom/target)
	src.target = target

/datum/particle_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/particle_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Particool")
		ui.open()

/datum/particle_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["particle_info"] = GLOB.master_particle_info
	return data

/datum/particle_editor/ui_data()
	var/list/data = list()
	data["target_name"] = target.name
	data["target_particle"] = getParticleVars()
	return data

/datum/particle_editor/proc/getParticleVars()
	. = target.particles ? target.particles.vars : null


//expects an assoc list of name, type, value - type must be in this list
/datum/particle_editor/proc/translate_value(list/L)
	//string/float/int come in as the correct type, so just whack em in

	switch(L["type"])
		if("string") return L["value"]
		if("float") return L["value"]
		if("int") return L["value"]
		if("vector") return L["value"]
		if("vector2") return L["value"]
		if("color") return stringToNum(L["value"], TRUE)
		if("text") return L["value"]
		if("list") return stringToList(L["value"], TRUE, TRUE)
		if("numList") return stringToList(L["value"],TRUE)
		if("matrix") return ListToMatrix(L["value"])
		if("generator") return generateGenerator(L["value"]) // This value should be a new list, if it isn't then we will explode

/datum/particle_editor/proc/generateGenerator(L)

	/*
	Generator type | Result | Description
	num            | num    | A random number between A and B.
	vector         | vector | A random vector on a line between A and B.
	box            | vector | A random vector within a box whose corners are at A and B.
	color          | color  | (string) or color matrix	Result type depends on whether A or B are matrices or not. The result is interpolated between A and B; components are not randomized separately.
	circle         | vector | A random XY-only vector in a ring between radius A and B, centered at 0,0.
	sphere         | vector | A random vector in a spherical shell between radius A and B, centered at 0,0,0.
	square         | vector | A random XY-only vector between squares of sizes A and B. (The length of the square is between A*2 and B*2, centered at 0,0.)
	cube           | vector | A random vector between cubes of sizes A and B. (The length of the cube is between A*2 and B*2, centered at 0,0,0.)
	*/

	// I write code like this because I hate myself
	var/a = length(stringToList(L["a"],TRUE)) > 1 ? stringToList(L["a"],TRUE) : text2num(L["a"])
	var/b = length(stringToList(L["b"],TRUE)) > 1 ? stringToList(L["b"],TRUE) : text2num(L["b"])


	var/rand_type = parse_rand_type(L["rand"])

	switch(L["genType"])
		if("num")    return generator(L["genType"], a, b, rand_type)
		if("vector") return generator(L["genType"], a, b, rand_type)
		if("box")    return generator(L["genType"], a, b, rand_type)
		if("color") //Color can be string or matrix
			a = length(a) > 1 ? a : L["a"]
			b = length(b) > 1 ? b : L["b"]
			return generator(L["genType"], a, b, rand_type)
		if("circle") return generator(L["genType"], a, b, rand_type)
		if("sphere") return generator(L["genType"], a, b, rand_type)
		if("square") return generator(L["genType"], a, b, rand_type)
		if("cube")   return generator(L["genType"], a, b, rand_type)
	return null

/datum/particle_editor/proc/parse_rand_type(rand_type)
	switch(rand_type)
		TEXT_TO_MACRO(UNIFORM_RAND)
		TEXT_TO_MACRO(LINEAR_RAND)
		TEXT_TO_MACRO(NORMAL_RAND)
		TEXT_TO_MACRO(SQUARE_RAND)
	CRASH("Unknown rand type [rand_type]")

/datum/particle_editor/proc/debugOutput(L, nodeName)
	if(istype(L,/list))
		for(var/elem in L)
			if(istype(elem,/list))
				world.log << nodeName
				debugOutput(elem, nodeName + ":LIST" + elem)
			else
				world.log << nodeName + ":" + elem + ":" + text("[]",elem)
	else
		world.log << L

/datum/particle_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	debugOutput(params)

	switch(action)
		if("add_particle")
			target.add_particle()
			. = TRUE
		if("remove_particle")
			target.remove_particle()
			. = TRUE
		if("modify_particle_value")
			target.modify_particle_value(params["new_data"]["name"], translate_value(params["new_data"]))
			. = TRUE
		if("modify_color_value")
			var/new_color = input(usr, "Pick new particle color", "Particool Colors!") as color|null
			if(new_color)
				target.modify_particle_value("color",new_color)
				. = TRUE
		if("modify_icon_value")
			var/icon/new_icon = input("Pick icon:", "Icon") as null|icon
			if(new_icon && target.particles)
				target.modify_particle_value("icon", new_icon)
				. = TRUE


//movable procs n stuff

/atom/movable/proc/add_particle()
	particles = new /particles

/atom/movable/proc/remove_particle()
	particles = null

/atom/movable/proc/modify_particle_value(varName, varVal)
	var/list/default_particle = list(width = 100, ///DO NOT make this list look nicer, maintainers at tg didn't like the fact its like this and its funny so keep it :) - Borbop
									height = 100,
									count = 100,
									spawning = 1,
									bound1 = list(-1000, -1000, -1000),
									bound2 = list(1000, 1000, 1000),
									icon_state = "",
									grow = list(0, 0),
									position = list(0, 0, 0),
									scale = list(1, 1),
									velocity = list(0, 0, 0),
									rotation = 0,
									spin = 0,
									friction = list(0, 0, 0),
									drift = list(0, 0, 0),
									gravity = list(0, 0, 0),
									// The following variables either handle null or will evaluate to 0 via Particool
									// gravity
									// gradient
									// transform
									// lifespan
									// fade
									// fadein
									// icon
									// color
									// color_change
									)

	if(particles)
		if(isnull(varVal) && !isnull(default_particle[varName]))
			varVal = default_particle[varName]
		particles.vars[varName] = varVal

/atom/movable/proc/transition_particle(time, list/new_params, easing, loop)
	if(particles)
		animate(particles, new_params, time = time, easing = easing, loop = loop)





