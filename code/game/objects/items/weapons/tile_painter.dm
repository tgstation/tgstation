#define PAINT_FLOOR 		1
#define PAINT_PLATING 		2
#define PAINT_REINFORCED 	3

/datum/paint_info
	var/dir = SOUTH
	var/icon_state = "floor"
	var/ftype = PAINT_FLOOR

/datum/paint_info/New(var/pdir, var/picon)
	src.dir = pdir
	src.icon_state = picon
	src.ftype = PAINT_FLOOR

/datum/paint_info/New(var/pdir, var/picon, var/ptype)
	src.dir = pdir
	src.icon_state = picon
	if(!(ptype == null)) src.ftype = ptype
	else src.ftype = PAINT_FLOOR

//This list contains all possible variants of paint jobs
//It's long as fuck and of course could be shrunk a lot, but there are some exception to some tiles which can overcomplicate things
//So I'll leave it as this for now -- Tehsapper

var/global/list/paint_variants = list(
	"Gray" = list(new /datum/paint_info(2,"floor")),

	"White" = list(new /datum/paint_info(2,"white"),
	new /datum/paint_info(SOUTH,"whitehall"),
	new /datum/paint_info(WEST,"whitehall"),
	new /datum/paint_info(NORTH,"whitehall"),
	new /datum/paint_info(EAST,"whitehall"),
	new /datum/paint_info(SOUTHWEST,"whitehall"),
	new /datum/paint_info(SOUTHEAST,"whitehall"),
	new /datum/paint_info(NORTHWEST,"whitehall"),
	new /datum/paint_info(NORTHEAST,"whitehall"),
	new /datum/paint_info(SOUTH,"whitecorner"),
	new /datum/paint_info(WEST,"whitecorner"),
	new /datum/paint_info(NORTH,"whitecorner"),
	new /datum/paint_info(EAST,"whitecorner")),

	"Red" = list(new /datum/paint_info(2,"redfull"),
	new /datum/paint_info(SOUTH,"red"),
	new /datum/paint_info(WEST,"red"),
	new /datum/paint_info(NORTH,"red"),
	new /datum/paint_info(EAST,"red"),
	new /datum/paint_info(SOUTHWEST,"red"),
	new /datum/paint_info(SOUTHEAST,"red"),
	new /datum/paint_info(NORTHWEST,"red"),
	new /datum/paint_info(NORTHEAST,"red"),
	new /datum/paint_info(SOUTH,"redcorner"),
	new /datum/paint_info(WEST,"redcorner"),
	new /datum/paint_info(NORTH,"redcorner"),
	new /datum/paint_info(EAST,"redcorner")),

	"Green" = list(new /datum/paint_info(2,"greenfull"),
	new /datum/paint_info(SOUTH,"green"),
	new /datum/paint_info(WEST,"green"),
	new /datum/paint_info(NORTH,"green"),
	new /datum/paint_info(EAST,"green"),
	new /datum/paint_info(SOUTHWEST,"green"),
	new /datum/paint_info(SOUTHEAST,"green"),
	new /datum/paint_info(NORTHWEST,"green"),
	new /datum/paint_info(NORTHEAST,"green"),
	new /datum/paint_info(SOUTH,"greencorner"),
	new /datum/paint_info(WEST,"greencorner"),
	new /datum/paint_info(NORTH,"greencorner"),
	new /datum/paint_info(EAST,"greencorner")),

	"Blue" = list(new /datum/paint_info(2,"bluefull"),
	new /datum/paint_info(SOUTH,"blue"),
	new /datum/paint_info(WEST,"blue"),
	new /datum/paint_info(NORTH,"blue"),
	new /datum/paint_info(EAST,"blue"),
	new /datum/paint_info(SOUTHWEST,"blue"),
	new /datum/paint_info(SOUTHEAST,"blue"),
	new /datum/paint_info(NORTHWEST,"blue"),
	new /datum/paint_info(NORTHEAST,"blue"),
	new /datum/paint_info(SOUTH,"bluecorner"),
	new /datum/paint_info(WEST,"bluecorner"),
	new /datum/paint_info(NORTH,"bluecorner"),
	new /datum/paint_info(EAST,"bluecorner")),

	"Yellow" = list(new /datum/paint_info(2,"yellowfull"),
	new /datum/paint_info(SOUTH,"yellow"),
	new /datum/paint_info(WEST,"yellow"),
	new /datum/paint_info(NORTH,"yellow"),
	new /datum/paint_info(EAST,"yellow"),
	new /datum/paint_info(SOUTHWEST,"yellow"),
	new /datum/paint_info(SOUTHEAST,"yellow"),
	new /datum/paint_info(NORTHWEST,"yellow"),
	new /datum/paint_info(NORTHEAST,"yellow"),
	new /datum/paint_info(SOUTH,"yellowcorner"),
	new /datum/paint_info(WEST,"yellowcorner"),
	new /datum/paint_info(NORTH,"yellowcorner"),
	new /datum/paint_info(EAST,"yellowcorner")),

	"Purple" = list(new /datum/paint_info(2,"purplefull"),
	new /datum/paint_info(SOUTH,"purple"),
	new /datum/paint_info(WEST,"purple"),
	new /datum/paint_info(NORTH,"purple"),
	new /datum/paint_info(EAST,"purple"),
	new /datum/paint_info(SOUTHWEST,"purple"),
	new /datum/paint_info(SOUTHEAST,"purple"),
	new /datum/paint_info(NORTHWEST,"purple"),
	new /datum/paint_info(NORTHEAST,"purple"),
	new /datum/paint_info(SOUTH,"purplecorner"),
	new /datum/paint_info(WEST,"purplecorner"),
	new /datum/paint_info(NORTH,"purplecorner"),
	new /datum/paint_info(EAST,"purplecorner")),

	"Orange" = list(new /datum/paint_info(2,"orangefull"),
	new /datum/paint_info(SOUTH,"orange"),
	new /datum/paint_info(WEST,"orange"),
	new /datum/paint_info(NORTH,"orange"),
	new /datum/paint_info(EAST,"orange"),
	new /datum/paint_info(SOUTHWEST,"orange"),
	new /datum/paint_info(SOUTHEAST,"orange"),
	new /datum/paint_info(NORTHWEST,"orange"),
	new /datum/paint_info(NORTHEAST,"orange"),
	new /datum/paint_info(SOUTH,"orangecorner"),
	new /datum/paint_info(WEST,"orangecorner"),
	new /datum/paint_info(NORTH,"orangecorner"),
	new /datum/paint_info(EAST,"orangecorner")),

	"Brown" = list(new /datum/paint_info(2,"dark brown full"),
	new /datum/paint_info(SOUTH,"brown"),
	new /datum/paint_info(WEST,"brown"),
	new /datum/paint_info(NORTH,"brown"),
	new /datum/paint_info(EAST,"brown"),
	new /datum/paint_info(SOUTHWEST,"brown"),
	new /datum/paint_info(SOUTHEAST,"brown"),
	new /datum/paint_info(NORTHWEST,"brown"),
	new /datum/paint_info(NORTHEAST,"brown"),
	new /datum/paint_info(SOUTH,"browncorner"),
	new /datum/paint_info(WEST,"browncorner"),
	new /datum/paint_info(NORTH,"browncorner"),
	new /datum/paint_info(EAST,"browncorner")),

	"Red and yellow" = list(new /datum/paint_info(2,"redyellowfull"),
	new /datum/paint_info(SOUTH,"redyellow"),
	new /datum/paint_info(WEST,"redyellow"),
	new /datum/paint_info(NORTH,"redyellow"),
	new /datum/paint_info(EAST,"redyellow"),
	new /datum/paint_info(SOUTHWEST,"redyellow"),
	new /datum/paint_info(SOUTHEAST,"redyellow"),
	new /datum/paint_info(NORTHWEST,"redyellow"),
	new /datum/paint_info(NORTHEAST,"redyellow")),

	"Red and blue" = list(new /datum/paint_info(2,"redbluefull"),
	new /datum/paint_info(SOUTH,"redblue"),
	new /datum/paint_info(WEST,"redblue"),
	new /datum/paint_info(NORTH,"redblue"),
	new /datum/paint_info(EAST,"redblue"),
	new /datum/paint_info(SOUTHWEST,"redblue"),
	new /datum/paint_info(SOUTHEAST,"redblue"),
	new /datum/paint_info(NORTHWEST,"redblue"),
	new /datum/paint_info(NORTHEAST,"redblue")),

	"Red and green" = list(new /datum/paint_info(2,"redgreenfull"),
	new /datum/paint_info(SOUTH,"redgreen"),
	new /datum/paint_info(WEST,"redgreen"),
	new /datum/paint_info(NORTH,"redgreen"),
	new /datum/paint_info(EAST,"redgreen"),
	new /datum/paint_info(SOUTHWEST,"redgreen"),
	new /datum/paint_info(SOUTHEAST,"redgreen"),
	new /datum/paint_info(NORTHWEST,"redgreen"),
	new /datum/paint_info(NORTHEAST,"redgreen")),

	"Green and yellow" = list(new /datum/paint_info(2,"greenyellowfull"),
	new /datum/paint_info(SOUTH,"greenyellow"),
	new /datum/paint_info(WEST,"greenyellow"),
	new /datum/paint_info(NORTH,"greenyellow"),
	new /datum/paint_info(EAST,"greenyellow"),
	new /datum/paint_info(SOUTHWEST,"greenyellow"),
	new /datum/paint_info(SOUTHEAST,"greenyellow"),
	new /datum/paint_info(NORTHWEST,"greenyellow"),
	new /datum/paint_info(NORTHEAST,"greenyellow")),

	"Green and blue" = list(new /datum/paint_info(2,"greenbluefull"),
	new /datum/paint_info(SOUTH,"greenblue"),
	new /datum/paint_info(WEST,"greenblue"),
	new /datum/paint_info(NORTH,"greenblue"),
	new /datum/paint_info(EAST,"greenblue"),
	new /datum/paint_info(SOUTHWEST,"greenblue"),
	new /datum/paint_info(SOUTHEAST,"greenblue"),
	new /datum/paint_info(NORTHWEST,"greenblue"),
	new /datum/paint_info(NORTHEAST,"greenblue")),

	"Blue and yellow" = list(new /datum/paint_info(2,"blueyellowfull"),
	new /datum/paint_info(SOUTH,"blueyellow"),
	new /datum/paint_info(WEST,"blueyellow"),
	new /datum/paint_info(NORTH,"blueyellow"),
	new /datum/paint_info(EAST,"blueyellow"),
	new /datum/paint_info(SOUTHWEST,"blueyellow"),
	new /datum/paint_info(SOUTHEAST,"blueyellow"),
	new /datum/paint_info(NORTHWEST,"blueyellow"),
	new /datum/paint_info(NORTHEAST,"blueyellow")),

	"White red" = list(new /datum/paint_info(2,"whiteredfull"),
	new /datum/paint_info(SOUTH,"whitered"),
	new /datum/paint_info(WEST,"whitered"),
	new /datum/paint_info(NORTH,"whitered"),
	new /datum/paint_info(EAST,"whitered"),
	new /datum/paint_info(SOUTHWEST,"whitered"),
	new /datum/paint_info(SOUTHEAST,"whitered"),
	new /datum/paint_info(NORTHWEST,"whitered"),
	new /datum/paint_info(NORTHEAST,"whitered")),

	"White green" = list(new /datum/paint_info(2,"whitegreenfull"),
	new /datum/paint_info(SOUTH,"whitegreen"),
	new /datum/paint_info(WEST,"whitegreen"),
	new /datum/paint_info(NORTH,"whitegreen"),
	new /datum/paint_info(EAST,"whitegreen"),
	new /datum/paint_info(SOUTHWEST,"whitegreen"),
	new /datum/paint_info(SOUTHEAST,"whitegreen"),
	new /datum/paint_info(NORTHWEST,"whitegreen"),
	new /datum/paint_info(NORTHEAST,"whitegreen"),
	new /datum/paint_info(SOUTH,"whitegreencorner"),
	new /datum/paint_info(WEST,"whitegreencorner"),
	new /datum/paint_info(NORTH,"whitegreencorner"),
	new /datum/paint_info(EAST,"whitegreencorner")),

	"White blue" = list(new /datum/paint_info(2,"whitebluefull"),
	new /datum/paint_info(SOUTH,"whiteblue"),
	new /datum/paint_info(WEST,"whiteblue"),
	new /datum/paint_info(NORTH,"whiteblue"),
	new /datum/paint_info(EAST,"whiteblue"),
	new /datum/paint_info(SOUTHWEST,"whiteblue"),
	new /datum/paint_info(SOUTHEAST,"whiteblue"),
	new /datum/paint_info(NORTHWEST,"whiteblue"),
	new /datum/paint_info(NORTHEAST,"whiteblue"),
	new /datum/paint_info(SOUTH,"whitebluecorner"),
	new /datum/paint_info(WEST,"whitebluecorner"),
	new /datum/paint_info(NORTH,"whitebluecorner"),
	new /datum/paint_info(EAST,"whitebluecorner"),
	new /datum/paint_info(2,"cmo")),

	"White yellow" = list(new /datum/paint_info(2,"whiteyellowfull"),
	new /datum/paint_info(SOUTH,"whiteyellow"),
	new /datum/paint_info(WEST,"whiteyellow"),
	new /datum/paint_info(NORTH,"whiteyellow"),
	new /datum/paint_info(EAST,"whiteyellow"),
	new /datum/paint_info(SOUTHWEST,"whiteyellow"),
	new /datum/paint_info(SOUTHEAST,"whiteyellow"),
	new /datum/paint_info(NORTHWEST,"whiteyellow"),
	new /datum/paint_info(NORTHEAST,"whiteyellow"),
	new /datum/paint_info(SOUTH,"whiteyellowcorner"),
	new /datum/paint_info(WEST,"whiteyellowcorner"),
	new /datum/paint_info(NORTH,"whiteyellowcorner"),
	new /datum/paint_info(EAST,"whiteyellowcorner")),

	"White purple" = list(new /datum/paint_info(2,"whitepurplefull"),
	new /datum/paint_info(SOUTH,"whitepurple"),
	new /datum/paint_info(WEST,"whitepurple"),
	new /datum/paint_info(NORTH,"whitepurple"),
	new /datum/paint_info(EAST,"whitepurple"),
	new /datum/paint_info(SOUTHWEST,"whitepurple"),
	new /datum/paint_info(SOUTHEAST,"whitepurple"),
	new /datum/paint_info(NORTHWEST,"whitepurple"),
	new /datum/paint_info(NORTHEAST,"whitepurple"),
	new /datum/paint_info(SOUTH,"whitepurplecorner"),
	new /datum/paint_info(WEST,"whitepurplecorner"),
	new /datum/paint_info(NORTH,"whitepurplecorner"),
	new /datum/paint_info(EAST,"whitepurplecorner")),

	"Arrival" = list(new /datum/paint_info(SOUTH,"arrival"),
	new /datum/paint_info(WEST,"arrival"),
	new /datum/paint_info(NORTH,"arrival"),
	new /datum/paint_info(EAST,"arrival"),
	new /datum/paint_info(SOUTHWEST,"arrival"),
	new /datum/paint_info(SOUTHEAST,"arrival"),
	new /datum/paint_info(NORTHWEST,"arrival"),
	new /datum/paint_info(NORTHEAST,"arrival")),

	"Escape" = list(new /datum/paint_info(SOUTH,"escape"),
	new /datum/paint_info(WEST,"escape"),
	new /datum/paint_info(NORTH,"escape"),
	new /datum/paint_info(EAST,"escape"),
	new /datum/paint_info(SOUTHWEST,"escape"),
	new /datum/paint_info(SOUTHEAST,"escape"),
	new /datum/paint_info(NORTHWEST,"escape"),
	new /datum/paint_info(NORTHEAST,"escape")),

	"Markings" = list(new /datum/paint_info(SOUTH,"delivery"),
	new /datum/paint_info(SOUTH,"bot"),
	new /datum/paint_info(SOUTH,"whitedelivery"),
	new /datum/paint_info(SOUTH,"whitebot"),
	new /datum/paint_info(SOUTH,"enginedelivery", PAINT_REINFORCED),
	new /datum/paint_info(SOUTH,"enginebot", PAINT_REINFORCED),
	new /datum/paint_info(SOUTH,"plaque")),

	"Loading area" = list(new /datum/paint_info(SOUTH,"loadingarea"),
	new /datum/paint_info(WEST,"loadingarea"),
	new /datum/paint_info(NORTH,"loadingarea"),
	new /datum/paint_info(EAST,"loadingarea"),
	new /datum/paint_info(SOUTH,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(WEST,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(NORTH,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(EAST,"engineloadingarea", PAINT_REINFORCED),
	new /datum/paint_info(SOUTH,"dark loading"),
	new /datum/paint_info(WEST,"dark loading"),
	new /datum/paint_info(NORTH,"dark loading"),
	new /datum/paint_info(EAST,"dark loading"),),

	"Warning" = list(new /datum/paint_info(SOUTH,"warning"),
	new /datum/paint_info(WEST,"warning"),
	new /datum/paint_info(NORTH,"warning"),
	new /datum/paint_info(EAST,"warning"),
	new /datum/paint_info(SOUTHWEST,"warning"),
	new /datum/paint_info(SOUTHEAST,"warning"),
	new /datum/paint_info(NORTHWEST,"warning"),
	new /datum/paint_info(NORTHEAST,"warning"),
	new /datum/paint_info(SOUTH,"warningcorner"),
	new /datum/paint_info(WEST,"warningcorner"),
	new /datum/paint_info(NORTH,"warningcorner"),
	new /datum/paint_info(EAST,"warningcorner")),

	"White warning" = list(new /datum/paint_info(SOUTH,"warnwhite"),
	new /datum/paint_info(WEST,"warnwhite"),
	new /datum/paint_info(NORTH,"warnwhite"),
	new /datum/paint_info(EAST,"warnwhite"),
	new /datum/paint_info(SOUTHWEST,"warnwhite"),
	new /datum/paint_info(SOUTHEAST,"warnwhite"),
	new /datum/paint_info(NORTHWEST,"warnwhite"),
	new /datum/paint_info(NORTHEAST,"warnwhite"),
	new /datum/paint_info(SOUTH,"warnwhitecorner"),
	new /datum/paint_info(WEST,"warnwhitecorner"),
	new /datum/paint_info(NORTH,"warnwhitecorner"),
	new /datum/paint_info(EAST,"warnwhitecorner")),

	"Reinforced warning" = list(new /datum/paint_info(SOUTH,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(WEST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(NORTH,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(EAST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(SOUTHWEST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(SOUTHEAST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(NORTHWEST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(NORTHEAST,"enginewarn", PAINT_REINFORCED),
	new /datum/paint_info(SOUTH,"enginewarncorner", PAINT_REINFORCED),
	new /datum/paint_info(WEST,"enginewarncorner", PAINT_REINFORCED),
	new /datum/paint_info(NORTH,"enginewarncorner", PAINT_REINFORCED),
	new /datum/paint_info(EAST,"enginewarncorner", PAINT_REINFORCED)),

	"Plating warning" = list(new /datum/paint_info(SOUTH,"warnplate", PAINT_PLATING),
	new /datum/paint_info(WEST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(NORTH,"warnplate", PAINT_PLATING),
	new /datum/paint_info(EAST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(SOUTHWEST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(SOUTHEAST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(NORTHWEST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(NORTHEAST,"warnplate", PAINT_PLATING),
	new /datum/paint_info(SOUTH,"warnplatecorner", PAINT_PLATING),
	new /datum/paint_info(WEST,"warnplatecorner", PAINT_PLATING),
	new /datum/paint_info(NORTH,"warnplatecorner", PAINT_PLATING),
	new /datum/paint_info(EAST,"warnplatecorner", PAINT_PLATING)),

	"Chapel" = list(new /datum/paint_info(SOUTH,"chapel"),
	new /datum/paint_info(WEST,"chapel"),
	new /datum/paint_info(NORTH,"chapel"),
	new /datum/paint_info(EAST,"chapel"),
	new /datum/paint_info(SOUTHWEST,"chapel"),
	new /datum/paint_info(SOUTHEAST,"chapel"),
	new /datum/paint_info(NORTHWEST,"chapel"),
	new /datum/paint_info(NORTHEAST,"chapel")),

	"SS13 logo" = list(new /datum/paint_info(2,"L1"),
	new /datum/paint_info(2,"L2"),
	new /datum/paint_info(2,"L3"),
	new /datum/paint_info(2,"L4"),
	new /datum/paint_info(2,"L5"),
	new /datum/paint_info(2,"L6"),
	new /datum/paint_info(2,"L7"),
	new /datum/paint_info(2,"L8"),
	new /datum/paint_info(2,"L9"),
	new /datum/paint_info(2,"L10"),
	new /datum/paint_info(2,"L11"),
	new /datum/paint_info(2,"L12"),
	new /datum/paint_info(2,"L13"),
	new /datum/paint_info(2,"L14"),
	new /datum/paint_info(2,"L15"),
	new /datum/paint_info(2,"L16")),

	"Derelict logo" = list(new /datum/paint_info(2,"derelict1"),
	new /datum/paint_info(2,"derelict2"),
	new /datum/paint_info(2,"derelict3"),
	new /datum/paint_info(2,"derelict4"),
	new /datum/paint_info(2,"derelict5"),
	new /datum/paint_info(2,"derelict6"),
	new /datum/paint_info(2,"derelict7"),
	new /datum/paint_info(2,"derelict8"),
	new /datum/paint_info(2,"derelict9"),
	new /datum/paint_info(2,"derelict10"),
	new /datum/paint_info(2,"derelict11"),
	new /datum/paint_info(2,"derelict12"),
	new /datum/paint_info(2,"derelict13"),
	new /datum/paint_info(2,"derelict14"),
	new /datum/paint_info(2,"derelict15"),
	new /datum/paint_info(2,"derelict16")),

	"Other" = list(new /datum/paint_info(2,"dark"),
	new /datum/paint_info(2,"bar"),
	new /datum/paint_info(2,"cafeteria"),
	new /datum/paint_info(2,"checker"),
	new /datum/paint_info(2,"grimy"),
	new /datum/paint_info(2,"hydrofloor"),
	new /datum/paint_info(2,"showroomfloor"),
	new /datum/paint_info(2,"freezerfloor"),
	new /datum/paint_info(2,"bcircuit"),
	new /datum/paint_info(2,"gcircuit"),
	new /datum/paint_info(2,"solarpanel"))
)

/obj/item/weapon/tile_painter
	name = "floor painter"
	desc = "A device used to paint floors in various colors and fashions."
	icon = 'icons/obj/items.dmi'
	icon_state = "rpd"
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
			user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, I.dir), "[I.icon_state][I.dir].png")
			data += "<a href=\"?src=\ref[src];set_dir=[I.dir];set_state=[I.icon_state];set_type=[I.ftype]\"><img src='[I.icon_state][I.dir].png'></a>"
		data += "<br><a href=\"?src=\ref[src];select=null\">Back</a>"
		data += "</p>"
	/*var/iterat
	for(iterat = 1, iterat <= paint_variants.len, iterat++)
		//user << "Iterat = [iterat]"
		var/datum/paint_info/I = paint_variants[iterat]
		user << browse_rsc(icon('icons/turf/floors.dmi', I.icon_state, I.dir), "tmp_floor[iterat].png")
		data += "<a href=\"?src=\ref[src];settype=[iterat]\"><img src='tmp_floor[iterat].png'></a>"
	data += "</p>"*/
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
		selected.ftype = href_list["set_type"]

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
		//user << "Not a floor at all!"

	var/fail = 0 //I dislike goto's
	//This is used to give the user a hint that he's a massive retard for using a floor painter on the carpet

	var/turf/simulated/floor/test = get_turf(A) //it should be the simulated floor type
	if(!(istype(test.floor_tile,/obj/item/stack/tile/plasteel)) && selected.ftype == "1") //why is it named plasteel anyway?
		fail = 1 //if it's carpet, wood or some other stuff, we aren't going to paint that

	if(!(istype(test,/turf/simulated/floor/plating)) && (selected.ftype == "2"))
		user << "This is a plating paint, and that's not plating"
		fail = 1

	if(!(istype(test,/turf/simulated/floor/engine)) && (selected.ftype == "3"))
		user << "This is a reinforced paint, and that's not reinforced floor"
		fail = 1

	if(istype(test, /turf/simulated/floor/mech_bay_recharge_floor))
		fail = 1 //we don't want to break it too

	if(fail == 1)
		user << "An error indicator on [src] flicks on for a moment. Perhaps you're using it on the wrong floor type?"
		return 0

	var/pdesc = ""
	var/pname = ""
	switch(selected.ftype)
		if("1") pname = "floor" //restoring the name of our new tile, usually if you place a floor tile on a plating it's still called "plating" for now
		if("3") pname = "reinforced floor"
		if("2") pname = "plating"

	if(selected.icon_state == "plaque") //some juice
		pdesc = input(user,"What do you want to be written on this plaque?", "Plaque description")
		pname = "Plaque"

	user << "Painting floor..."
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	if(do_after(user, 20))
		activate()

		var/turf/simulated/floor/T = get_turf(A)
		T.icon_state = selected.icon_state
		T.icon_regular_floor = selected.icon_state
		T.dir = selected.dir
		T.desc = pdesc //so if you paint over a plaque with a floor the tile loses its description
		if(!(pname == "")) T.name = pname
		return 1
	return 0


/obj/item/weapon/tile_painter/proc/activate()
	playsound(get_turf(src), 'sound/effects/extinguish.ogg', 50, 1)