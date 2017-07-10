
///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	desc = "Only for the finest of art!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "easel"
	density = 1
	resistance_flags = FLAMMABLE
	max_integrity = 60
	var/obj/item/weapon/canvas/painting = null


//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/canvas))
		var/obj/item/weapon/canvas/C = I
		user.dropItemToGround(C)
		painting = C
		C.loc = get_turf(src)
		C.layer = layer+0.1
		user.visible_message("<span class='notice'>[user] puts \the [C] on \the [src].</span>","<span class='notice'>You place \the [C] on \the [src].</span>")
	else
		return ..()


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/T = get_turf(src)
	..()
	if(painting && painting.loc == T) //Only move if it's near us.
		painting.loc = get_turf(src)
	else
		painting = null


//////////////
// CANVASES //
//////////////

#define AMT_OF_CANVASES	4 //Keep this up to date or shit will break.

//To safe memory on making /icons we cache the blanks..
GLOBAL_LIST_INIT(globalBlankCanvases, new(AMT_OF_CANVASES))

/obj/item/weapon/canvas
	name = "canvas"
	desc = "Draw out your soul on this canvas!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "11x11"
	resistance_flags = FLAMMABLE
	var/whichGlobalBackup = 1 //List index

/obj/item/weapon/canvas/nineteenXnineteen
	icon_state = "19x19"
	whichGlobalBackup = 2

/obj/item/weapon/canvas/twentythreeXnineteen
	icon_state = "23x19"
	whichGlobalBackup = 3

/obj/item/weapon/canvas/twentythreeXtwentythree
	icon_state = "23x23"
	whichGlobalBackup = 4


//Find the right size blank canvas
/obj/item/weapon/canvas/proc/getGlobalBackup()
	. = null
	if(GLOB.globalBlankCanvases[whichGlobalBackup])
		. = GLOB.globalBlankCanvases[whichGlobalBackup]
	else
		var/icon/I = icon(initial(icon),initial(icon_state))
		GLOB.globalBlankCanvases[whichGlobalBackup] = I
		. = I



//One pixel increments
/obj/item/weapon/canvas/attackby(obj/item/I, mob/user, params)
	//Click info
	var/list/click_params = params2list(params)
	var/pixX = text2num(click_params["icon-x"])
	var/pixY = text2num(click_params["icon-y"])

	//Should always be true, otherwise you didn't click the object, but let's check because SS13~
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return

	//Cleaning one pixel with a soap or rag
	if(istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag))
		//Pixel info created only when needed
		var/icon/masterpiece = icon(icon,icon_state)
		var/thePix = masterpiece.GetPixel(pixX,pixY)
		var/icon/Ico = getGlobalBackup()
		if(!Ico)
			qdel(masterpiece)
			return

		var/theOriginalPix = Ico.GetPixel(pixX,pixY)
		if(thePix != theOriginalPix) //colour changed
			DrawPixelOn(theOriginalPix,pixX,pixY)
		qdel(masterpiece)

	//Drawing one pixel with a crayon
	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		DrawPixelOn(C.paint_color, pixX, pixY)
	else
		return ..()


//Clean the whole canvas
/obj/item/weapon/canvas/attack_self(mob/user)
	if(!user)
		return
	var/icon/blank = getGlobalBackup()
	if(blank)
		//it's basically a giant etch-a-sketch
		icon = blank
		user.visible_message("<span class='notice'>[user] cleans the canvas.</span>","<span class='notice'>You clean the canvas.</span>")



#undef AMT_OF_CANVASES
