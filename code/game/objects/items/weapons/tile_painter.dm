#define PAINT_FLOOR 		1
#define PAINT_PLATING 		2
#define PAINT_REINFORCED 	3
#define PAINT_ALL           0

#define DIR_ONE 	1	//for those tiles with only one direction
#define DIR_ORTHO 	2	//orthogonal (south, west, north, east)
#define DIR_ALL 	3	//all the directions


/datum/paint_info
	var/dir = SOUTH
	var/icon/icon = 'icons/turf/floors.dmi'
	var/icon_state = "floor"
	var/ftype as num		//the floor type required for this paint job
	var/adirs 				//available dirs for this floor type

/datum/paint_info/New(var/padir, var/picon)
	src.adirs = padir
	src.dir = SOUTH
	src.icon_state = picon
	src.ftype = PAINT_FLOOR

/datum/paint_info/New(var/padir, var/picon, var/ptype)
	if(ptype == null) ptype = PAINT_FLOOR //DM really can't resolve this?
	src.dir = SOUTH
	src.icon_state = picon
	src.ftype = ptype
	src.adirs = padir

/datum/paint_info/proc/validate(var/turf/simulated/floor/test)
	//This is used to give the user a hint that he's a massive retard for using a floor painter on the carpet
	switch(ftype)
		if(PAINT_FLOOR) //why is it named plasteel anyway?
			if(!(istype(test.floor_tile,/obj/item/stack/tile/plasteel)))
				return 0 //if it's carpet, wood or some other stuff, we aren't going to paint that
			if(istype(test, /turf/simulated/floor/engine))
				return 0 	//reinforced floor has plasteel in floor_tile too
							//but that isn't a regular floor
		if(PAINT_PLATING)
			if(!istype(test,/turf/simulated/floor/plating))
				return 0
		if(PAINT_REINFORCED)
			if(!istype(test,/turf/simulated/floor/engine))
				return 0

	if(istype(test, /turf/simulated/floor/mech_bay_recharge_floor))
		return 0
	return 1

/datum/paint_info/proc/apply(var/turf/simulated/floor/T, var/pname, var/pdesc)
	//warning("[type]: Running /datum/paint_info/proc/apply.")
	T.icon_state = icon_state
	T.icon_regular_floor = icon_state	//required to 'save' the new floor type so if someone crowbars it and puts it back it won't revert to the original state
	T.dir = dir
	T.desc = pdesc //so if you paint over a plaque with a floor the tile loses its description
	if(pname != "")
		T.name = pname
	T.ClearDecals()

/datum/paint_info/decal
	icon = 'icons/effects/warning_stripes.dmi'
	ftype = PAINT_ALL

/datum/paint_info/decal/apply(var/turf/simulated/floor/T, var/pname, var/pdesc)
	T.AddDecal(image(icon, icon_state = icon_state, dir = dir))


//The list of all available floor design groups

var/global/list/paint_variants = list(
	"Decals" = list(
		// Stripes
		new /datum/paint_info/decal(DIR_ALL,   "old"),
		new /datum/paint_info/decal(DIR_ONE,   "all"),

		// Loading areas (TODO: colorable)
		new /datum/paint_info/decal(DIR_ORTHO, "corner"),
		new /datum/paint_info/decal(DIR_ONE,   "unloading"),
		new /datum/paint_info/decal(DIR_ONE,   "bot"),
		new /datum/paint_info/decal(DIR_ORTHO, "loadingarea"),
		new /datum/paint_info/decal(DIR_ONE,   "no"),

		// Atmos lettering
		new /datum/paint_info/decal(DIR_ORTHO, "oxygen"),
		new /datum/paint_info/decal(DIR_ORTHO, "carbon_dioxide"),
		new /datum/paint_info/decal(DIR_ORTHO, "nitrous_oxide"),
		new /datum/paint_info/decal(DIR_ORTHO, "air"),
		new /datum/paint_info/decal(DIR_ORTHO, "plasma"),
		new /datum/paint_info/decal(DIR_ORTHO, "zoo"),

		// Numbers
		new /datum/paint_info/decal(DIR_ORTHO, "1"),
		new /datum/paint_info/decal(DIR_ORTHO, "2"),
		new /datum/paint_info/decal(DIR_ORTHO, "3"),
		new /datum/paint_info/decal(DIR_ORTHO, "4"),
		new /datum/paint_info/decal(DIR_ORTHO, "5"),
		new /datum/paint_info/decal(DIR_ORTHO, "6"),
		new /datum/paint_info/decal(DIR_ORTHO, "7"),
		new /datum/paint_info/decal(DIR_ORTHO, "8"),
		new /datum/paint_info/decal(DIR_ORTHO, "9"),
		new /datum/paint_info/decal(DIR_ORTHO, "0"),
	),
	"Gray" = list(new /datum/paint_info(DIR_ONE,"floor"),
	new /datum/paint_info(DIR_ALL,"black"),
	new /datum/paint_info(DIR_ORTHO,"blackcorner")),

	"Neutral" = list(new /datum/paint_info(DIR_ALL,"neutral"),
	new /datum/paint_info(DIR_ORTHO,"neutralcorner"),
	new /datum/paint_info(DIR_ONE,"neutralfull")),

	"White" = list(new /datum/paint_info(DIR_ONE,"white"),
	new /datum/paint_info(DIR_ALL,"whitehall"),
	new /datum/paint_info(DIR_ORTHO,"whitecorner")),

	"Red" = list(new /datum/paint_info(DIR_ONE,"redfull"),
	new /datum/paint_info(DIR_ALL,"red"),
	new /datum/paint_info(DIR_ORTHO,"redcorner")),

	"Green" = list(new /datum/paint_info(DIR_ONE,"greenfull"),
	new /datum/paint_info(DIR_ALL,"green"),
	new /datum/paint_info(DIR_ORTHO,"greencorner")),

	"Blue" = list(new /datum/paint_info(DIR_ONE,"bluefull"),
	new /datum/paint_info(DIR_ALL,"blue"),
	new /datum/paint_info(DIR_ORTHO,"bluecorner")),

	"Yellow" = list(new /datum/paint_info(DIR_ONE,"yellowfull"),
	new /datum/paint_info(DIR_ALL,"yellow"),
	new /datum/paint_info(DIR_ORTHO,"yellowcorner")),

	"Purple" = list(new /datum/paint_info(DIR_ONE,"purplefull"),
	new /datum/paint_info(DIR_ALL,"purple"),
	new /datum/paint_info(DIR_ORTHO,"purplecorner")),

	"Orange" = list(new /datum/paint_info(DIR_ONE,"orangefull"),
	new /datum/paint_info(DIR_ALL,"orange"),
	new /datum/paint_info(DIR_ORTHO,"orangecorner")),

	"Brown" = list(new /datum/paint_info(DIR_ONE,"dark brown full"),
	new /datum/paint_info(DIR_ALL,"brown"),
	new /datum/paint_info(DIR_ORTHO,"browncorner")),

	"Red and yellow" = list(new /datum/paint_info(DIR_ONE,"redyellowfull"),
	new /datum/paint_info(DIR_ALL,"redyellow")),

	"Red and blue" = list(new /datum/paint_info(DIR_ONE,"redbluefull"),
	new /datum/paint_info(DIR_ALL,"redblue")),

	"Red and green" = list(new /datum/paint_info(DIR_ONE,"redgreenfull"),
	new /datum/paint_info(DIR_ALL,"redgreen")),

	"Green and yellow" = list(new /datum/paint_info(DIR_ONE,"greenyellowfull"),
	new /datum/paint_info(DIR_ALL,"greenyellow")),

	"Green and blue" = list(new /datum/paint_info(DIR_ONE,"greenbluefull"),
	new /datum/paint_info(DIR_ALL,"greenblue")),

	"Blue and yellow" = list(new /datum/paint_info(DIR_ONE,"blueyellowfull"),
	new /datum/paint_info(DIR_ALL,"blueyellow")),

	"White red" = list(new /datum/paint_info(DIR_ONE,"whiteredfull"),
	new /datum/paint_info(DIR_ALL,"whitered"),
	new /datum/paint_info(DIR_ORTHO,"whiteredcorner")),

	"White green" = list(new /datum/paint_info(DIR_ONE,"whitegreenfull"),
	new /datum/paint_info(DIR_ALL,"whitegreen"),
	new /datum/paint_info(DIR_ORTHO,"whitegreencorner")),

	"White blue" = list(new /datum/paint_info(DIR_ONE,"whitebluefull"),
	new /datum/paint_info(DIR_ALL,"whiteblue"),
	new /datum/paint_info(DIR_ORTHO,"whitebluecorner"),
	new /datum/paint_info(DIR_ONE,"cmo")),

	"White yellow" = list(new /datum/paint_info(DIR_ONE,"whiteyellowfull"),
	new /datum/paint_info(DIR_ALL,"whiteyellow"),
	new /datum/paint_info(DIR_ORTHO,"whiteyellowcorner")),

	"White purple" = list(new /datum/paint_info(DIR_ONE,"whitepurplefull"),
	new /datum/paint_info(DIR_ALL,"whitepurple"),
	new /datum/paint_info(DIR_ORTHO,"whitepurplecorner")),

	"Arrival" = list(new /datum/paint_info(DIR_ALL,"arrival")),

	"Escape" = list(new /datum/paint_info(DIR_ALL,"escape")),

	"Dark" = list(new /datum/paint_info(DIR_ONE,"dark"),
	new /datum/paint_info(DIR_ALL,"dark floor stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark floor corner")),

	"Dark red" = list(new /datum/paint_info(DIR_ONE,"dark red full"),
	new /datum/paint_info(DIR_ALL,"dark red stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark red corner")),

	"Dark blue" = list(new /datum/paint_info(DIR_ONE,"dark blue full"),
	new /datum/paint_info(DIR_ALL,"dark blue stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark blue corner")),

	"Dark green" = list(new /datum/paint_info(DIR_ONE,"dark green full"),
	new /datum/paint_info(DIR_ALL,"dark green stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark green corner")),

	"Dark purple" = list(new /datum/paint_info(DIR_ONE,"dark purple full"),
	new /datum/paint_info(DIR_ALL,"dark purple stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark purple corner")),

	"Dark yellow" = list(new /datum/paint_info(DIR_ONE,"dark yellow full"),
	new /datum/paint_info(DIR_ALL,"dark yellow stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark yellow corner")),

	"Dark orange" = list(new /datum/paint_info(DIR_ONE,"dark orange full"),
	new /datum/paint_info(DIR_ALL,"dark orange stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark orange corner")),

	"Dark orange" = list(new /datum/paint_info(DIR_ONE,"dark orange full"),
	new /datum/paint_info(DIR_ALL,"dark orange stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark orange corner")),

	"Dark vault" = list(new /datum/paint_info(DIR_ONE,"dark vault full"),
	new /datum/paint_info(DIR_ALL,"dark vault stripe"),
	new /datum/paint_info(DIR_ORTHO,"dark vault corner"),
	new /datum/paint_info(DIR_ORTHO,"dark-markings")),

	"Markings" = list(new /datum/paint_info(DIR_ONE,"delivery"),
	new /datum/paint_info(DIR_ONE,"bot"),
	new /datum/paint_info(DIR_ONE,"whitedelivery"),
	new /datum/paint_info(DIR_ONE,"whitebot"),
	new /datum/paint_info(DIR_ONE,"enginedelivery", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ONE,"enginebot", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ONE,"plaque")),

	"Loading area" = list(new /datum/paint_info(DIR_ORTHO,"loadingarea"),
	new /datum/paint_info(DIR_ORTHO,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ORTHO,"dark loading")),

	"Warning" = list(new /datum/paint_info(DIR_ALL,"warning"),
	new /datum/paint_info(DIR_ORTHO,"warningcorner")),

	"White warning" = list(new /datum/paint_info(DIR_ALL,"warnwhite"),
	new /datum/paint_info(DIR_ORTHO,"warnwhitecorner")),

	"Reinforced warning" = list(new /datum/paint_info(DIR_ALL,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ORTHO,"enginewarncorner", PAINT_REINFORCED)),

	"Plating warning" = list(new /datum/paint_info(DIR_ALL,"warnplate", PAINT_PLATING),
	new /datum/paint_info(DIR_ORTHO,"warnplatecorner", PAINT_PLATING)),

	"Chapel" = list(new /datum/paint_info(DIR_ALL,"chapel")),

	"SS13 logo" = list(new /datum/paint_info(DIR_ONE,"L1"),
	new /datum/paint_info(DIR_ONE,"L2"),
	new /datum/paint_info(DIR_ONE,"L3"),
	new /datum/paint_info(DIR_ONE,"L4"),
	new /datum/paint_info(DIR_ONE,"L5"),
	new /datum/paint_info(DIR_ONE,"L6"),
	new /datum/paint_info(DIR_ONE,"L7"),
	new /datum/paint_info(DIR_ONE,"L8"),
	new /datum/paint_info(DIR_ONE,"L9"),
	new /datum/paint_info(DIR_ONE,"L10"),
	new /datum/paint_info(DIR_ONE,"L11"),
	new /datum/paint_info(DIR_ONE,"L12"),
	new /datum/paint_info(DIR_ONE,"L13"),
	new /datum/paint_info(DIR_ONE,"L14"),
	new /datum/paint_info(DIR_ONE,"L15"),
	new /datum/paint_info(DIR_ONE,"L16")),

	"Derelict logo" = list(new /datum/paint_info(DIR_ONE,"derelict1"),
	new /datum/paint_info(DIR_ONE,"derelict2"),
	new /datum/paint_info(DIR_ONE,"derelict3"),
	new /datum/paint_info(DIR_ONE,"derelict4"),
	new /datum/paint_info(DIR_ONE,"derelict5"),
	new /datum/paint_info(DIR_ONE,"derelict6"),
	new /datum/paint_info(DIR_ONE,"derelict7"),
	new /datum/paint_info(DIR_ONE,"derelict8"),
	new /datum/paint_info(DIR_ONE,"derelict9"),
	new /datum/paint_info(DIR_ONE,"derelict10"),
	new /datum/paint_info(DIR_ONE,"derelict11"),
	new /datum/paint_info(DIR_ONE,"derelict12"),
	new /datum/paint_info(DIR_ONE,"derelict13"),
	new /datum/paint_info(DIR_ONE,"derelict14"),
	new /datum/paint_info(DIR_ONE,"derelict15"),
	new /datum/paint_info(DIR_ONE,"derelict16")),

	"Other" = list(new /datum/paint_info(DIR_ONE,"dark"),
	new /datum/paint_info(DIR_ONE,"bar"),
	new /datum/paint_info(DIR_ONE,"cafeteria"),
	new /datum/paint_info(DIR_ONE,"checker"),
	new /datum/paint_info(DIR_ONE,"barber"),
	new /datum/paint_info(DIR_ONE,"grimy"),
	new /datum/paint_info(DIR_ONE,"hydrofloor"),
	new /datum/paint_info(DIR_ONE,"showroomfloor"),
	new /datum/paint_info(DIR_ONE,"freezerfloor"),
	new /datum/paint_info(DIR_ONE,"bcircuit"),
	new /datum/paint_info(DIR_ONE,"gcircuit"),
	new /datum/paint_info(DIR_ONE,"solarpanel"))
)

/obj/item/weapon/tile_painter
	name = "tile painter"
	desc = "A device used to paint floors in various colors and fashions."
	icon = 'icons/obj/items.dmi'
	icon_state = "rpd" //placeholder art, someone please sprite it
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 15000
	g_amt = 7500
	w_type = RECYK_ELECTRONIC
	origin_tech = "engineering=2;materials=1"
	var/working = 0
	var/datum/paint_info/selected
	var/category = ""

/obj/item/weapon/tile_painter/New()
	selected = new /datum/paint_info(SOUTH,"floor")
	..()

/obj/item/weapon/tile_painter/Destroy() //do I even have to do that
	selected = null

/obj/item/weapon/tile_painter/attack_self(mob/user as mob)
	show_menu(user)

/obj/item/weapon/tile_painter/proc/render_tile(var/icon/basestate, var/mob/user, var/datum/paint_info/I, var/cdir=SOUTH)
	// Send user the image
	user << browse_rsc(new /icon(basestate, dir=cdir), "[I.icon_state][cdir].png")
	// Determine if we're actually selecting this
	var/is_selected = selected.icon==I.icon && selected.icon_state == I.icon_state && selected.dir==cdir
	var/class=""
	if(is_selected)
		class=" class=\"selected\""

	// Make HTML.
	return "<a href=\"?src=\ref[src];set_dir=[cdir];set_state=[I.icon_state];set_type=\ref[I]\"[class]><img src='[I.icon_state][cdir].png'></a>"

/obj/item/weapon/tile_painter/proc/populate_selection(mob/user as mob, var/datum/paint_info/I)
	var/data = ""
	var/icon/basestate = new /icon(I.icon, I.icon_state)
	switch(I.adirs)
		if(DIR_ONE)
			data += render_tile(basestate,user,I)
		if(DIR_ORTHO)
			for(var/d in cardinal) // cardinal is N,S,E,W (see global.dm)
				data += render_tile(basestate,user,I,d)
		if(DIR_ALL)
			for(var/d in alldirs) // All 2D directions
				data += render_tile(basestate,user,I,d)

	return data

/obj/item/weapon/tile_painter/proc/show_menu(mob/user as mob)
	if(!user || !src) return 0

	var/data = {"<h2>Tile Painter</h2>
		<style type="text/css">
			html {
				font-family:sans-serif;
				font-size:small;
			}
			a{
				color:#0066cc;
				text-decoration:none;
			}

			a img {
				border:1px solid #0066cc;
				background: #99B2CC;
			}

			a.color {
				padding: 5px 10px;
				font-size: large;
				font-weight: bold;
				border:1px solid white;
			}

			a.selected img,
			a:hover {
				background: #0066cc;
				color: #ffffff;
			}
		</style>"}

	if(category == "")

		data += "<p>List of available tile groups:</p>"
		data += "<p>"

		for(var/iterator in paint_variants)
			data += "<a href=\"?src=\ref[src];select=[iterator]\">[iterator] (view)</a><br>"

		data += "</p>"

	else

		var/list/tiles = paint_variants[category]
		data += "<p><b>[category]</b></p>"
		data += "<p>"
		for(var/i = 1; i <= tiles.len; i++)
			var/datum/paint_info/I = tiles[i]
			data += populate_selection(user, I)

		data += "<br><br><a href=\"?src=\ref[src];select=null\">Back</a>"
		data += "</p>"

	var/menu = {"
<html>
	<head>
		<title>Tile Painter</title>
	</head>
	<body>
	[data]
	</body>
</html>
"}
	user << browse(menu, "window=tilepainter")
	onclose(user, "tilepainter")
	return

/obj/item/weapon/tile_painter/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		usr << browse(null, "window=tilepainter")
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["select"])
		if(href_list["select"] == "null") category = ""
		else category = href_list["select"]
		show_menu(usr)

	//if we got this, that means we got set_state as well
	if(href_list["set_dir"])
		selected = locate(href_list["set_type"])
		selected.dir = text2num(href_list["set_dir"])

/obj/item/weapon/tile_painter/afterattack(atom/A, mob/user)
	if(!in_range(A,user))
		return
	if(loc != user)
		return
	if(!isrobot(user) && !ishuman(user))
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0

	if(!(istype(A, /turf/simulated/floor)) || istype(A, /turf/simulated/floor/plating/airless/catwalk)) //fuck catwalks
		return 0

	var/turf/simulated/floor/test = get_turf(A) //it should be the simulated floor type
	//world.log << "[src]:  selected=[selected.type]"
	if(!selected.validate(test))
		user << "<span class='warning'>An error indicator on [src] flicks on for a moment. Perhaps you're using it on the wrong floor type?</span>"
		return 0

	var/pdesc = ""
	var/pname = ""
	switch(selected.ftype)
		if(PAINT_FLOOR)      pname = "floor" //restoring the name of our new tile, usually if you place a floor tile on a plating it's still called "plating" for now
		if(PAINT_REINFORCED) pname = "reinforced floor"	//also getting rid of the plaque if it's there
		if(PAINT_PLATING)    pname = "plating"

	if(selected.icon_state == "plaque") //some juice
		pdesc = input(user,"What do you want to be described on this plaque?", "Plaque description")
		pname = "Commemorative Plaque"

	user << "Painting floor..."
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	if(do_after(user, 20))
		activate()
		var/turf/simulated/floor/T = get_turf(A)
		selected.apply(T,pname,pdesc)
		return 1
	return 0


/obj/item/weapon/tile_painter/proc/activate()
	playsound(get_turf(src), 'sound/effects/extinguish.ogg', 50, 1)	//pssshtt