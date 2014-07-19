#define PAINT_FLOOR 		1
#define PAINT_PLATING 		2
#define PAINT_REINFORCED 	3

#define DIR_ONE 	1
#define DIR_ORTO 	2
#define DIR_ALL 	3


/datum/paint_info
	var/dir = SOUTH
	var/icon_state = "floor"
	var/ftype as num		//the floor type required for this paint job
							//I also had problems with this casting itself to a string
	var/adirs //available dirs for this floor type

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


//This list contains all possible variants of paint jobs
//It's long as fuck and of course could be shrunk a lot, but there are some exception to some tiles which can overcomplicate things
//So I'll leave it as this for now -- Tehsapper

var/global/list/paint_variants = list(
	"Gray" = list(new /datum/paint_info(DIR_ONE,"floor"),
	new /datum/paint_info(DIR_ALL,"black"),
	new /datum/paint_info(DIR_ORTO,"blackcorner")),
	
	"Neutral" = list(new /datum/paint_info(DIR_ALL,"neutral"),
	new /datum/paint_info(DIR_ORTO,"neutralcorner"),
	new /datum/paint_info(DIR_ONE,"neutralfull")),

	"White" = list(new /datum/paint_info(DIR_ONE,"white"),
	new /datum/paint_info(DIR_ALL,"whitehall"),
	new /datum/paint_info(DIR_ORTO,"whitecorner")),

	"Red" = list(new /datum/paint_info(DIR_ONE,"redfull"),
	new /datum/paint_info(DIR_ALL,"red"),
	new /datum/paint_info(DIR_ORTO,"redcorner")),

	"Green" = list(new /datum/paint_info(DIR_ONE,"greenfull"),
	new /datum/paint_info(DIR_ALL,"green"),
	new /datum/paint_info(DIR_ORTO,"greencorner")),

	"Blue" = list(new /datum/paint_info(DIR_ONE,"bluefull"),
	new /datum/paint_info(DIR_ALL,"blue"),
	new /datum/paint_info(DIR_ORTO,"bluecorner")),

	"Yellow" = list(new /datum/paint_info(DIR_ONE,"yellowfull"),
	new /datum/paint_info(DIR_ALL,"yellow"),
	new /datum/paint_info(DIR_ORTO,"yellowcorner")),

	"Purple" = list(new /datum/paint_info(DIR_ONE,"purplefull"),
	new /datum/paint_info(DIR_ALL,"purple"),
	new /datum/paint_info(DIR_ORTO,"purplecorner")),

	"Orange" = list(new /datum/paint_info(DIR_ONE,"orangefull"),
	new /datum/paint_info(DIR_ALL,"orange"),
	new /datum/paint_info(DIR_ORTO,"orangecorner")),

	"Brown" = list(new /datum/paint_info(DIR_ONE,"dark brown full"),
	new /datum/paint_info(DIR_ALL,"brown"),
	new /datum/paint_info(DIR_ORTO,"browncorner")),

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
	new /datum/paint_info(DIR_ORTO,"whiteredcorner")),

	"White green" = list(new /datum/paint_info(DIR_ONE,"whitegreenfull"),
	new /datum/paint_info(DIR_ALL,"whitegreen"),
	new /datum/paint_info(DIR_ORTO,"whitegreencorner")),

	"White blue" = list(new /datum/paint_info(DIR_ONE,"whitebluefull"),
	new /datum/paint_info(DIR_ALL,"whiteblue"),
	new /datum/paint_info(DIR_ORTO,"whitebluecorner"),
	new /datum/paint_info(DIR_ONE,"cmo")),

	"White yellow" = list(new /datum/paint_info(DIR_ONE,"whiteyellowfull"),
	new /datum/paint_info(DIR_ALL,"whiteyellow"),
	new /datum/paint_info(DIR_ORTO,"whiteyellowcorner")),

	"White purple" = list(new /datum/paint_info(DIR_ONE,"whitepurplefull"),
	new /datum/paint_info(DIR_ALL,"whitepurple"),
	new /datum/paint_info(DIR_ORTO,"whitepurplecorner")),

	"Arrival" = list(new /datum/paint_info(DIR_ALL,"arrival")),

	"Escape" = list(new /datum/paint_info(DIR_ALL,"escape")),
	
	"Dark" = list(new /datum/paint_info(DIR_ONE,"dark"),
	new /datum/paint_info(DIR_ALL,"dark floor stripe"),
	new /datum/paint_info(DIR_ORTO,"dark floor corner")),
	
	"Dark red" = list(new /datum/paint_info(DIR_ONE,"dark red full"),
	new /datum/paint_info(DIR_ALL,"dark red stripe"),
	new /datum/paint_info(DIR_ORTO,"dark red corner")),
	
	"Dark blue" = list(new /datum/paint_info(DIR_ONE,"dark blue full"),
	new /datum/paint_info(DIR_ALL,"dark blue stripe"),
	new /datum/paint_info(DIR_ORTO,"dark blue corner")),
	
	"Dark green" = list(new /datum/paint_info(DIR_ONE,"dark green full"),
	new /datum/paint_info(DIR_ALL,"dark green stripe"),
	new /datum/paint_info(DIR_ORTO,"dark green corner")),
	
	"Dark purple" = list(new /datum/paint_info(DIR_ONE,"dark purple full"),
	new /datum/paint_info(DIR_ALL,"dark purple stripe"),
	new /datum/paint_info(DIR_ORTO,"dark purple corner")),
	
	"Dark yellow" = list(new /datum/paint_info(DIR_ONE,"dark yellow full"),
	new /datum/paint_info(DIR_ALL,"dark yellow stripe"),
	new /datum/paint_info(DIR_ORTO,"dark yellow corner")),
	
	"Dark orange" = list(new /datum/paint_info(DIR_ONE,"dark orange full"),
	new /datum/paint_info(DIR_ALL,"dark orange stripe"),
	new /datum/paint_info(DIR_ORTO,"dark orange corner")),
	
	"Dark orange" = list(new /datum/paint_info(DIR_ONE,"dark orange full"),
	new /datum/paint_info(DIR_ALL,"dark orange stripe"),
	new /datum/paint_info(DIR_ORTO,"dark orange corner")),
	
	"Dark vault" = list(new /datum/paint_info(DIR_ONE,"dark vault full"),
	new /datum/paint_info(DIR_ALL,"dark vault stripe"),
	new /datum/paint_info(DIR_ORTO,"dark vault corner"),
	new /datum/paint_info(DIR_ORTO,"dark-markings")),

	"Markings" = list(new /datum/paint_info(DIR_ONE,"delivery"),
	new /datum/paint_info(DIR_ONE,"bot"),
	new /datum/paint_info(DIR_ONE,"whitedelivery"),
	new /datum/paint_info(DIR_ONE,"whitebot"),
	new /datum/paint_info(DIR_ONE,"enginedelivery", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ONE,"enginebot", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ONE,"plaque")),

	"Loading area" = list(new /datum/paint_info(DIR_ORTO,"loadingarea"),
	new /datum/paint_info(DIR_ORTO,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ORTO,"dark loading")),

	"Warning" = list(new /datum/paint_info(DIR_ALL,"warning"),
	new /datum/paint_info(DIR_ORTO,"warningcorner")),

	"White warning" = list(new /datum/paint_info(DIR_ALL,"warnwhite"),
	new /datum/paint_info(DIR_ORTO,"warnwhitecorner")),

	"Reinforced warning" = list(new /datum/paint_info(DIR_ALL,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(DIR_ORTO,"enginewarncorner", PAINT_REINFORCED)),

	"Plating warning" = list(new /datum/paint_info(DIR_ALL,"warnplate", PAINT_PLATING),
	new /datum/paint_info(DIR_ORTO,"warnplatecorner", PAINT_PLATING)),

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
	name = "floor painter"
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
	g_amt = 20000
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

/obj/item/weapon/tile_painter/proc/populate_selection(mob/user as mob, var/datum/paint_info/I)
	/var/data
	data = ""
	switch(I.adirs)
		if(DIR_ONE)
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, I.dir), "[I.icon_state][I.dir].png")
			data += "<a href=\"?src=\ref[src];set_dir=[I.dir];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][I.dir].png'></a>"
		if(DIR_ORTO)
			for(var/i = 1; i <= 8; i *= 2)
				user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, i), "[I.icon_state][i].png")
				data += "<a href=\"?src=\ref[src];set_dir=[i];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][i].png'></a>"
		if(DIR_ALL)
			for(var/i = 1; i <= 8; i *= 2)
				user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, i), "[I.icon_state][i].png")
				data += "<a href=\"?src=\ref[src];set_dir=[i];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][i].png'></a>"
			
			//This is pretty awful but I can't think of a better way
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, NORTHWEST), "[I.icon_state][NORTHWEST].png")
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, NORTHEAST), "[I.icon_state][NORTHEAST].png")
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, SOUTHWEST), "[I.icon_state][SOUTHWEST].png")
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, SOUTHEAST), "[I.icon_state][SOUTHEAST].png")
			
			data += "<a href=\"?src=\ref[src];set_dir=[NORTHWEST];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][NORTHWEST].png'></a>"
			data += "<a href=\"?src=\ref[src];set_dir=[NORTHEAST];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][NORTHEAST].png'></a>"
			data += "<a href=\"?src=\ref[src];set_dir=[SOUTHWEST];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][SOUTHWEST].png'></a>"
			data += "<a href=\"?src=\ref[src];set_dir=[SOUTHEAST];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][SOUTHEAST].png'></a>"
	
	return data
	
/obj/item/weapon/tile_painter/proc/show_menu(mob/user as mob)
	if(!user || !src) return 0

	var/data = {"<h2>Tile Painter</h2>"}

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
		selected.dir = text2num(href_list["set_dir"])
		selected.icon_state = href_list["set_state"]
		selected.ftype = text2num(href_list["set_type"])

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

	var/fail = 0 //I dislike goto's
	//This is used to give the user a hint that he's a massive retard for using a floor painter on the carpet

	var/turf/simulated/floor/test = get_turf(A) //it should be the simulated floor type
	if(selected.ftype == PAINT_FLOOR) //why is it named plasteel anyway?
		if(!(istype(test.floor_tile,/obj/item/stack/tile/plasteel))) fail = 1 //if it's carpet, wood or some other stuff, we aren't going to paint that
		if(istype(test, /turf/simulated/floor/engine)) fail = 1 	//reinforced floor has plasteel in floor_tile too
																//but that isn't a regular floor
	if(!(istype(test,/turf/simulated/floor/plating)) && (selected.ftype == PAINT_PLATING))
		fail = 1

	if(!(istype(test,/turf/simulated/floor/engine)) && (selected.ftype == PAINT_REINFORCED))
		fail = 1

	if(istype(test, /turf/simulated/floor/mech_bay_recharge_floor))
		fail = 1 //we don't want to break it too

	if(fail == 1)
		user << "An error indicator on [src] flicks on for a moment. Perhaps you're using it on the wrong floor type?"
		return 0

	var/pdesc = ""
	var/pname = ""
	switch(selected.ftype)
		if(PAINT_FLOOR) pname = "floor" //restoring the name of our new tile, usually if you place a floor tile on a plating it's still called "plating" for now
		if(PAINT_REINFORCED) pname = "reinforced floor"	//also getting rid of the plaque if it's there
		if(PAINT_PLATING) pname = "plating"

	if(selected.icon_state == "plaque") //some juice
		pdesc = input(user,"What do you want to be described on this plaque?", "Plaque description")
		pname = "Commerative Plaque"

	user << "Painting floor..."
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	if(do_after(user, 20))
		activate()

		var/turf/simulated/floor/T = get_turf(A)
		T.icon_state = selected.icon_state
		T.icon_regular_floor = selected.icon_state	//required to 'save' the new floor type so if someone crowbars it and puts it back it won't revert to the original state
		T.dir = selected.dir
		T.desc = pdesc //so if you paint over a plaque with a floor the tile loses its description
		if(!(pname == "")) T.name = pname
		return 1
	return 0


/obj/item/weapon/tile_painter/proc/activate()
	playsound(get_turf(src), 'sound/effects/extinguish.ogg', 50, 1)	//pssshtt