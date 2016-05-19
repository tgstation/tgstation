#define PAINT_ALL        0
#define PAINT_FLOOR      1
#define PAINT_PLATING    2
#define PAINT_REINFORCED 3

#define DIR_ONE   1   // For those tiles with only one direction.
#define DIR_ORTHO 2   // Orthogonal (south, west, north, east).
#define DIR_ALL   3   // All the directions.

#define PAINT_ASK_DESC   1

/datum/rcd_schematic/tile
	name				= "Decals"
	category			= "Painting"

	flags				= RCD_GET_TURF

	var/datum/paint_info/selection
	var/selected_dir	= 2

/datum/rcd_schematic/tile/register_assets()
	var/list/our_list = get_our_list()
	if(!our_list)
		return

	for(var/datum/paint_info/P in our_list)
		for(var/ndir in get_dir_list_by_dir_type(P.adirs))
			register_asset("[P.file_name][P.icon_state]_[ndir].png", new/icon(P.icon, P.icon_state, ndir))

/datum/rcd_schematic/tile/send_assets(var/client/client)
	var/list/our_list = get_our_list()
	if(!our_list)
		return

	var/list/to_send = list()
	for(var/datum/paint_info/P in our_list)
		for(var/ndir in get_dir_list_by_dir_type(P.adirs))
			to_send += "[P.file_name][P.icon_state]_[ndir].png"

	send_asset_list(client, to_send)

/datum/rcd_schematic/tile/proc/get_dir_list_by_dir_type(var/adir)
	switch(adir)
		if(DIR_ONE)
			return list(SOUTH)

		if(DIR_ORTHO)
			return cardinal

		if(DIR_ALL)
			return alldirs

/datum/rcd_schematic/tile/get_HTML()
	. = list()
	. += "<p>"

	var/list/our_list = get_our_list()
	for(var/datum/paint_info/P in our_list)
		for(var/dir in get_dir_list_by_dir_type(P.adirs))
			var/selected = ""
			if(selection == P && dir == selected_dir)
				selected = " class='selected'"

			. += "<a href='?src=\ref[master.interface];select_paint=[our_list.Find(P)];set_dir=[dir]'[selected]><img src='[P.file_name][P.icon_state]_[dir].png'/></a>"

	. += "</p>"
	. = jointext(.,"")

/datum/rcd_schematic/tile/Topic(var/href, var/href_list)
	if(href_list["select_paint"])
		var/list/our_list = get_our_list()
		var/idx = Clamp(round(text2num(href_list["select_paint"])), 1, our_list.len)

		selection = our_list[idx]
		if(!(selected_dir in get_dir_list_by_dir_type(selection.adirs)))
			selected_dir = 2

		master.update_options_menu()
		. = 1

	if(href_list["set_dir"])
		var/dir = text2num(href_list["set_dir"])
		if(!(dir in get_dir_list_by_dir_type(selection.adirs)))
			return 1

		selected_dir = dir

/datum/rcd_schematic/tile/attack(var/atom/A, var/mob/user)
	if (!selection)
		return 1

	if (!selection.validate(A))
		return "maybe you're using it on the wrong floor type?"

	var/nname = selection.name
	var/thisdir = selected_dir

	var/ndesc = ""
	if (selection.flags & PAINT_ASK_DESC)
		ndesc = sanitize(input(user, "What do you want to be described on this [nname]?", "[capitalize(nname)] description"))

	to_chat(user, "Painting floor...")
	//playsound(get_turf(master), 'sound/AI/animes.ogg', 50, 1)
	playsound(get_turf(master), 'sound/effects/spray3.ogg', 15, 1)
	if (!do_after(user, A, 20))
		return 1

	playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)

	selection.apply(A, nname, ndesc, thisdir)

//Gets the list of paint info datums.
/datum/rcd_schematic/tile/proc/get_our_list()
	return paint_variants[name]

/datum/paint_info
	var/icon/icon  = 'icons/turf/floors.dmi'
	var/icon_state = "floor"
	var/ftype      = PAINT_FLOOR		//The floor type required for this paint job.
	var/adirs      = DIR_ONE			//Available dirs for this floor type.
	var/file_name  = "tile_painter_"	//The file data gets added after this, used to seperate the decals and floor types.
	var/flags      = 0
	var/name

/datum/paint_info/New(var/padir, var/picon, var/ptype, var/nflags = 0, var/nname)
	if (ptype)
		ftype      = ptype

	if (padir)
		adirs      = padir

	if (picon)
		icon_state = picon

	flags = nflags

	if (nname)
		name = nname
	else
		switch (ftype)
			if (PAINT_FLOOR)      name = "floor"
			if (PAINT_REINFORCED) name = "reinforced floor"
			if (PAINT_PLATING)    name = "plating"

//This is used to give the user a hint that he's a massive retard for using a floor painter on the carpet
/datum/paint_info/proc/validate(var/turf/simulated/floor/test)
	switch (ftype)
		if (PAINT_FLOOR) //why is it named plasteel anyway?
			if (!(istype(test.floor_tile,/obj/item/stack/tile/plasteel)))
				return 0 //if it's carpet, wood or some other stuff, we aren't going to paint that
			if (istype(test, /turf/simulated/floor/engine))
				return 0 	//reinforced floor has plasteel in floor_tile too
							//but that isn't a regular floor
		if (PAINT_PLATING)
			if (!istype(test,/turf/simulated/floor/plating))
				return 0

		if (PAINT_REINFORCED)
			if (!istype(test,/turf/simulated/floor/engine))
				return 0

	return 1

/datum/paint_info/proc/apply(var/turf/simulated/floor/T, var/pname, var/pdesc, var/dir)
	T.icon_state = icon_state
	T.icon_regular_floor = icon_state	//required to 'save' the new floor type so if someone crowbars it and puts it back it won't revert to the original state
	T.dir = dir
	T.desc = pdesc						//so if you paint over a plaque with a floor the tile loses its description
	if(pname)
		T.name = pname

	T.ClearDecals()

/datum/paint_info/decal
	icon		= 'icons/effects/warning_stripes.dmi'
	ftype		= PAINT_ALL
	file_name	= "tile_painter_d_"

/datum/paint_info/decal/apply(var/turf/simulated/floor/T, var/pname, var/pdesc, var/dir)
	T.AddDecal(image(icon, icon_state = icon_state, dir = dir))

//The list of all available floor design groups.

/datum/rcd_schematic/tile/gray
	name = "Gray"

/datum/rcd_schematic/tile/neutral
	name = "Neutral"

/datum/rcd_schematic/tile/white
	name = "White"

/datum/rcd_schematic/tile/red
	name = "Red"

/datum/rcd_schematic/tile/green
	name = "Green"

/datum/rcd_schematic/tile/blue
	name = "Blue"

/datum/rcd_schematic/tile/yellow
	name = "Yellow"

/datum/rcd_schematic/tile/purple
	name = "Purple"

/datum/rcd_schematic/tile/orange
	name = "Orange"

/datum/rcd_schematic/tile/brown
	name = "Brown"

/datum/rcd_schematic/tile/red_yellow
	name = "Red and yellow"

/datum/rcd_schematic/tile/red_blue
	name = "Red and blue"

/datum/rcd_schematic/tile/red_green
	name = "Red and green"

/datum/rcd_schematic/tile/green_yellow
	name = "Green and yellow"

/datum/rcd_schematic/tile/green_blue
	name = "Green and blue"

/datum/rcd_schematic/tile/blue_yellow
	name = "Blue and yellow"

/datum/rcd_schematic/tile/white_red
	name = "White red"

/datum/rcd_schematic/tile/white_green
	name = "White green"

/datum/rcd_schematic/tile/white_blue
	name = "White blue"

/datum/rcd_schematic/tile/white_yellow
	name = "White yellow"

/datum/rcd_schematic/tile/white_purple
	name = "White purple"

/datum/rcd_schematic/tile/arrival
	name = "Arrival"

/datum/rcd_schematic/tile/escape
	name = "Escape"

/datum/rcd_schematic/tile/dark
	name = "Dark"

/datum/rcd_schematic/tile/dark_red
	name = "Dark red"

/datum/rcd_schematic/tile/dark_blue
	name = "Dark blue"

/datum/rcd_schematic/tile/dark_green
	name = "Dark green"

/datum/rcd_schematic/tile/dark_purple
	name = "Dark purple"

/datum/rcd_schematic/tile/dark_yellow
	name = "Dark yellow"

/datum/rcd_schematic/tile/dark_orange
	name = "Dark orange"

/datum/rcd_schematic/tile/dark_vault
	name = "Dark vault"

/datum/rcd_schematic/tile/markings
	name = "Markings"

/datum/rcd_schematic/tile/loading
	name = "Loading area"

/datum/rcd_schematic/tile/warning
	name = "Warning"

/datum/rcd_schematic/tile/warning_white
	name = "White warning"

/datum/rcd_schematic/tile/warning_reinforced
	name = "Reinforced warning"

/datum/rcd_schematic/tile/warning_plating
	name = "Plating warning"

/datum/rcd_schematic/tile/chapel
	name = "Chapel"

/datum/rcd_schematic/tile/ss13_logo
	name = "SS13 logo"

/datum/rcd_schematic/tile/derelict_logo
	name = "Derelict logo"

/datum/rcd_schematic/tile/other
	name = "Other"

//Ririchiyo's potatobox grid.
/datum/rcd_schematic/tile/all
	name = "All"

//We override this so we DON'T register assets twice, registering is handled in the specific ones.
/datum/rcd_schematic/tile/all/register_assets()
	return

//We get EVERY paint info datum.
/datum/rcd_schematic/tile/all/get_our_list()
	. = list()
	for(var/key in paint_variants)
		for(var/datum/paint_info/P in paint_variants[key])
			. += P


var/global/list/paint_variants = list(
	"Decals" = list(
		// Stripes
		new /datum/paint_info/decal(DIR_ALL,	"warning"),
		new /datum/paint_info/decal(DIR_ONE,	"all"),

		// Loading areas (TODO: colourable)
		new /datum/paint_info/decal(DIR_ORTHO,	"warning_corner"),
		new /datum/paint_info/decal(DIR_ONE,	"unloading"),
		new /datum/paint_info/decal(DIR_ONE,	"bot"),
		new /datum/paint_info/decal(DIR_ORTHO,	"loading_area"),
		new /datum/paint_info/decal(DIR_ONE,	"no"),

		// Atmos lettering
		new /datum/paint_info/decal(DIR_ORTHO,	"oxygen"),
		new /datum/paint_info/decal(DIR_ORTHO,	"nitrogen"),
		new /datum/paint_info/decal(DIR_ORTHO,	"carbon_dioxide"),
		new /datum/paint_info/decal(DIR_ORTHO,	"nitrous_oxide"),
		new /datum/paint_info/decal(DIR_ORTHO,	"air"),
		new /datum/paint_info/decal(DIR_ORTHO,	"plasma"),
		new /datum/paint_info/decal(DIR_ORTHO,	"zoo"),

		// Numbers
		new /datum/paint_info/decal(DIR_ORTHO,	"1"),
		new /datum/paint_info/decal(DIR_ORTHO,	"2"),
		new /datum/paint_info/decal(DIR_ORTHO,	"3"),
		new /datum/paint_info/decal(DIR_ORTHO,	"4"),
		new /datum/paint_info/decal(DIR_ORTHO,	"5"),
		new /datum/paint_info/decal(DIR_ORTHO,	"6"),
		new /datum/paint_info/decal(DIR_ORTHO,	"7"),
		new /datum/paint_info/decal(DIR_ORTHO,	"8"),
		new /datum/paint_info/decal(DIR_ORTHO,	"9"),
		new /datum/paint_info/decal(DIR_ORTHO,	"0"),

		// Path markers
		new /datum/paint_info/decal(DIR_ORTHO,	"1"),
		new /datum/paint_info/decal(DIR_ORTHO,	"1"),
		new /datum/paint_info/decal(DIR_ORTHO,	"1"),
		new /datum/paint_info/decal(DIR_ORTHO,	"1"),
	),
	"Gray" = list(
		new /datum/paint_info(DIR_ONE,		"floor"),
		new /datum/paint_info(DIR_ALL,		"black"),
		new /datum/paint_info(DIR_ORTHO,	"blackcorner")
	),

	"Neutral" = list(
		new /datum/paint_info(DIR_ALL,		"neutral"),
		new /datum/paint_info(DIR_ORTHO,	"neutralcorner"),
		new /datum/paint_info(DIR_ONE,		"neutralfull")
	),

	"White" = list(
		new /datum/paint_info(DIR_ONE,		"white"),
		new /datum/paint_info(DIR_ALL,		"whitehall"),
		new /datum/paint_info(DIR_ORTHO,	"whitecorner")
	),

	"Red" = list(
		new /datum/paint_info(DIR_ONE,		"redfull"),
		new /datum/paint_info(DIR_ALL,		"red"),
		new /datum/paint_info(DIR_ORTHO,	"redcorner")
	),

	"Green" = list(
		new /datum/paint_info(DIR_ONE,		"greenfull"),
		new /datum/paint_info(DIR_ALL,		"green"),
		new /datum/paint_info(DIR_ORTHO,	"greencorner")
	),

	"Blue" = list(
		new /datum/paint_info(DIR_ONE,		"bluefull"),
		new /datum/paint_info(DIR_ALL,		"blue"),
		new /datum/paint_info(DIR_ORTHO,	"bluecorner")
	),

	"Yellow" = list(
		new /datum/paint_info(DIR_ONE,		"yellowfull"),
		new /datum/paint_info(DIR_ALL,		"yellow"),
		new /datum/paint_info(DIR_ORTHO,	"yellowcorner")
	),

	"Purple" = list(
		new /datum/paint_info(DIR_ONE,		"purplefull"),
		new /datum/paint_info(DIR_ALL,		"purple"),
		new /datum/paint_info(DIR_ORTHO,	"purplecorner")
	),

	"Orange" = list(
		new /datum/paint_info(DIR_ONE,		"orangefull"),
		new /datum/paint_info(DIR_ALL,		"orange"),
		new /datum/paint_info(DIR_ORTHO,	"orangecorner")
	),

	"Brown" = list(
		new /datum/paint_info(DIR_ONE,		"dark brown full"),
		new /datum/paint_info(DIR_ALL,		"brown"),
		new /datum/paint_info(DIR_ORTHO,	"browncorner")
	),

	"Red and yellow" = list(
		new /datum/paint_info(DIR_ONE,		"redyellowfull"),
		new /datum/paint_info(DIR_ALL,		"redyellow")
	),

	"Red and blue" = list(
		new /datum/paint_info(DIR_ONE,		"redbluefull"),
		new /datum/paint_info(DIR_ALL,		"redblue")
	),

	"Red and green" = list(
		new /datum/paint_info(DIR_ONE,		"redgreenfull"),
		new /datum/paint_info(DIR_ALL,		"redgreen")
	),

	"Green and yellow" = list(
		new /datum/paint_info(DIR_ONE,		"greenyellowfull"),
		new /datum/paint_info(DIR_ALL,		"greenyellow")
	),

	"Green and blue" = list(
		new /datum/paint_info(DIR_ONE,		"greenbluefull"),
		new /datum/paint_info(DIR_ALL,		"greenblue")
	),

	"Blue and yellow" = list(
		new /datum/paint_info(DIR_ONE,		"blueyellowfull"),
		new /datum/paint_info(DIR_ALL,		"blueyellow")
	),

	"White red" = list(
		new /datum/paint_info(DIR_ONE,		"whiteredfull"),
		new /datum/paint_info(DIR_ALL,		"whitered"),
		new /datum/paint_info(DIR_ORTHO,	"whiteredcorner")
	),

	"White green" = list(
		new /datum/paint_info(DIR_ONE,		"whitegreenfull"),
		new /datum/paint_info(DIR_ALL,		"whitegreen"),
		new /datum/paint_info(DIR_ORTHO,	"whitegreencorner")
	),

	"White blue" = list(
		new /datum/paint_info(DIR_ONE,		"whitebluefull"),
		new /datum/paint_info(DIR_ALL,		"whiteblue"),
		new /datum/paint_info(DIR_ORTHO,	"whitebluecorner"),
		new /datum/paint_info(DIR_ONE,		"cmo")
	),

	"White yellow" = list(
		new /datum/paint_info(DIR_ONE,		"whiteyellowfull"),
		new /datum/paint_info(DIR_ALL,		"whiteyellow"),
		new /datum/paint_info(DIR_ORTHO,	"whiteyellowcorner")
	),

	"White purple" = list(
		new /datum/paint_info(DIR_ONE,		"whitepurplefull"),
		new /datum/paint_info(DIR_ALL,		"whitepurple"),
		new /datum/paint_info(DIR_ORTHO,	"whitepurplecorner")
	),

	"Arrival" = list(
		new /datum/paint_info(DIR_ALL,		"arrival")
	),

	"Escape" = list(
		new /datum/paint_info(DIR_ALL,		"escape")
	),

	"Dark" = list(
		new /datum/paint_info(DIR_ONE,		"dark"),
		new /datum/paint_info(DIR_ALL,		"dark floor stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark floor corner")
	),

	"Dark red" = list(
		new /datum/paint_info(DIR_ONE,		"dark red full"),
		new /datum/paint_info(DIR_ALL,		"dark red stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark red corner")
	),

	"Dark blue" = list(
		new /datum/paint_info(DIR_ONE,		"dark blue full"),
		new /datum/paint_info(DIR_ALL,		"dark blue stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark blue corner")
	),

	"Dark green" = list(
		new /datum/paint_info(DIR_ONE,		"dark green full"),
		new /datum/paint_info(DIR_ALL,		"dark green stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark green corner")
	),

	"Dark purple" = list(
		new /datum/paint_info(DIR_ONE,		"dark purple full"),
		new /datum/paint_info(DIR_ALL,		"dark purple stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark purple corner")
	),

	"Dark yellow" = list(
		new /datum/paint_info(DIR_ONE,		"dark yellow full"),
		new /datum/paint_info(DIR_ALL,		"dark yellow stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark yellow corner")
	),

	"Dark orange" = list(
		new /datum/paint_info(DIR_ONE,		"dark orange full"),
		new /datum/paint_info(DIR_ALL,		"dark orange stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark orange corner")
	),

	"Dark vault" = list(
		new /datum/paint_info(DIR_ONE,		"dark vault full"),
		new /datum/paint_info(DIR_ALL,		"dark vault stripe"),
		new /datum/paint_info(DIR_ORTHO,	"dark vault corner"),
		new /datum/paint_info(DIR_ORTHO,	"dark-markings")
	),

	"Markings" = list(
		new /datum/paint_info(DIR_ONE,		"delivery"),
		new /datum/paint_info(DIR_ONE,		"bot"),
		new /datum/paint_info(DIR_ONE,		"whitedelivery"),
		new /datum/paint_info(DIR_ONE,		"whitebot"),
		new /datum/paint_info(DIR_ONE,		"enginedelivery",		PAINT_REINFORCED),
		new /datum/paint_info(DIR_ONE,		"enginebot",			PAINT_REINFORCED),
		new /datum/paint_info(DIR_ONE,		"plaque",               PAINT_FLOOR, PAINT_ASK_DESC, "commemorative plaque")
	),

	"Loading area" = list(
		new /datum/paint_info(DIR_ORTHO,	"loadingarea"),
		new /datum/paint_info(DIR_ORTHO,	"engineloadingarea",	PAINT_REINFORCED),
		new /datum/paint_info(DIR_ORTHO,	"dark loading")
	),

	"Warning" = list(
		new /datum/paint_info(DIR_ALL,		"warning"),
		new /datum/paint_info(DIR_ORTHO,	"warningcorner")
	),

	"White warning" = list(
		new /datum/paint_info(DIR_ALL,		"warnwhite"),
		new /datum/paint_info(DIR_ORTHO,	"warnwhitecorner")
	),

	"Reinforced warning" = list(
		new /datum/paint_info(DIR_ALL,		"enginewarn",			PAINT_REINFORCED),
		new /datum/paint_info(DIR_ORTHO,	"enginewarncorner",		PAINT_REINFORCED)
	),

	"Plating warning" = list(
		new /datum/paint_info(DIR_ALL,		"warnplate",			PAINT_PLATING),
		new /datum/paint_info(DIR_ORTHO,	"warnplatecorner",		PAINT_PLATING)
	),

	"Chapel" = list(
		new /datum/paint_info(DIR_ALL,		"chapel")
	),

	"SS13 logo" = list(
		new /datum/paint_info(DIR_ONE,		"L1"),
		new /datum/paint_info(DIR_ONE,		"L3"),
		new /datum/paint_info(DIR_ONE,		"L5"),
		new /datum/paint_info(DIR_ONE,		"L7"),
		new /datum/paint_info(DIR_ONE,		"L9"),
		new /datum/paint_info(DIR_ONE,		"L11"),
		new /datum/paint_info(DIR_ONE,		"L13"),
		new /datum/paint_info(DIR_ONE,		"L15"),
		new /datum/paint_info(DIR_ONE,		"L2"),
		new /datum/paint_info(DIR_ONE,		"L4"),
		new /datum/paint_info(DIR_ONE,		"L6"),
		new /datum/paint_info(DIR_ONE,		"L8"),
		new /datum/paint_info(DIR_ONE,		"L10"),
		new /datum/paint_info(DIR_ONE,		"L12"),
		new /datum/paint_info(DIR_ONE,		"L14"),
		new /datum/paint_info(DIR_ONE,		"L16")
	),

	"Derelict logo" = list(
		new /datum/paint_info(DIR_ONE,		"derelict9"),
		new /datum/paint_info(DIR_ONE,		"derelict10"),
		new /datum/paint_info(DIR_ONE,		"derelict11"),
		new /datum/paint_info(DIR_ONE,		"derelict12"),
		new /datum/paint_info(DIR_ONE,		"derelict13"),
		new /datum/paint_info(DIR_ONE,		"derelict14"),
		new /datum/paint_info(DIR_ONE,		"derelict15"),
		new /datum/paint_info(DIR_ONE,		"derelict16"),
		new /datum/paint_info(DIR_ONE,		"derelict1"),
		new /datum/paint_info(DIR_ONE,		"derelict2"),
		new /datum/paint_info(DIR_ONE,		"derelict3"),
		new /datum/paint_info(DIR_ONE,		"derelict4"),
		new /datum/paint_info(DIR_ONE,		"derelict5"),
		new /datum/paint_info(DIR_ONE,		"derelict6"),
		new /datum/paint_info(DIR_ONE,		"derelict7"),
		new /datum/paint_info(DIR_ONE,		"derelict8")
	),

	"Other" = list(
		new /datum/paint_info(DIR_ONE,		"dark"),
		new /datum/paint_info(DIR_ONE,		"bar"),
		new /datum/paint_info(DIR_ONE,		"cafeteria"),
		new /datum/paint_info(DIR_ONE,		"checker"),
		new /datum/paint_info(DIR_ONE,		"barber"),
		new /datum/paint_info(DIR_ONE,		"grimy"),
		new /datum/paint_info(DIR_ONE,		"hydrofloor"),
		new /datum/paint_info(DIR_ONE,		"showroomfloor"),
		new /datum/paint_info(DIR_ONE,		"freezerfloor"),
		new /datum/paint_info(DIR_ONE,		"bcircuit"),
		new /datum/paint_info(DIR_ONE,		"gcircuit"),
		new /datum/paint_info(DIR_ONE,		"solarpanel")
	)
)

#undef PAINT_ALL
#undef PAINT_FLOOR
#undef PAINT_PLATING
#undef PAINT_REINFORCED

#undef DIR_ONE
#undef DIR_ORTHO
#undef DIR_ALL

#undef PAINT_ASK_DESC
