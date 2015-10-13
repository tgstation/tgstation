var/global/list/available_paintings = list(
	"duck",
	"mario",
	"gradius",
	"kudzu",
	"dwarf",
	"xenolisa",
	"bottles",
	"aymao",
	"flowey",
	"sunset",
	)

/obj/item/mounted/frame/painting
	name = "painting"
	desc = "A blank painting."
	icon = 'icons/obj/paintings.dmi'
	icon_state = "item"
	item_state = "painting"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	flags = FPRINT
	w_type = RECYK_WOOD
	frame_material = /obj/item/stack/sheet/wood
	sheets_refunded = 2
	autoignition_temperature = AUTOIGNITION_WOOD
	var/paint = ""

/obj/item/mounted/frame/painting/New()
	..()
	pixel_x = rand(-6,6)
	pixel_y = rand(-6,6)

	if(!paint)
		paint = pick(available_paintings)

	update_painting()

/obj/item/mounted/frame/painting/proc/update_painting()
	switch(paint)
		if("narsie")
			name = "\improper Papa Narnar"
			desc = "A painting of Nar-Sie. You feel as if it's watching you."
		if("monkey")
			name = "\improper Mr. Deempisi portrait"
			desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
		if("duck")
			name = "\improper Duck"
			desc = "A painting of a duck. It has a crazed look in its eyes."
		if("mario")
			name = "\improper Mario and Coin"
			desc = "A painting of an italian plumber and an oversized golden plate. Apparently he's a video game mascot of sorts."
		if("gradius")
			name = "\improper Vic Viper"
			desc = "A painting of a space ship. It makes you feel like diving right into an alien base and release your blasters right onto its core."
		if("justice")
			name = "\improper Justice"
			desc = "A painting of a golden scale. Those are often found within courtrooms."
		if("kudzu")
			name = "\improper Scythe on Kudzu"
			desc = "A painting of a scythe and some vines."
		if("dwarf")
			name = "\improper Dwarven Miner"
			desc = "A painting of a dwarf mining adamantine. A long lost high-value metal that was said to be impossibly lightweight, strong, and sharp."
		if("xenolisa")
			name = "\improper Xeno Lisa"
			desc = "A painting of a xenomorph queen, wearing some human clothing. The hands are particularly well-painted."
		if("bottles")
			name = "\improper Bottle and Bottle"
			desc = "A painting of two glass bottles filled with blue and red liquids. You can almost feel the intensity of the artistic discussions that led to this creation."
		if("aymao")
			name = "\improper Ay Mao"
			desc = "A painting of the glorious leader of the Grey Democratic Republic. He looks dignified, and a bit high too."
		if("flowey")
			name = "\improper Flowey the Flower"
			desc = "A painting of your best friend. Also SERIAL MURDERER."
		if("sunset")
			name = "\improper Path toward the Sunset"
			desc = "A painting by D.T.Link. The colours fill you with hope and determination."
		else
			name = "painting"
			desc = "a blank painting."

/obj/item/mounted/frame/painting/do_build(turf/on_wall, mob/user)
	user << "<span class='notice'>You hang the [src] on \the [on_wall]...</span>"

	add_fingerprint(user)

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/painting/P = new(user.loc)
	P.icon_state = paint
	P.update_painting()

	transfer_fingerprints(src, P)

	var/pDir = get_dir(user,on_wall)
	if(pDir & NORTH)
		P.pixel_y = 32
	if(pDir & SOUTH)
		P.pixel_y = -32
	if(pDir & EAST)
		P.pixel_x = 32
	if(pDir & WEST)
		P.pixel_x = -32

	playsound(on_wall, 'sound/items/Deconstruct.ogg', 25, 1)

	user.drop_item(src)
	qdel(src)

/obj/item/mounted/frame/painting/blank
	paint = "blank"

/obj/item/mounted/frame/painting/cultify()
	new /obj/item/mounted/frame/painting/narsie(loc)
	..()

/obj/item/mounted/frame/painting/narsie
	paint = "narsie"

/obj/item/mounted/frame/painting/narsie/cultify()
	return

/obj/structure/painting
	name = "painting"
	desc = "A blank painting."
	icon = 'icons/obj/paintings.dmi'
	icon_state = "blank"
	autoignition_temperature = AUTOIGNITION_WOOD

/obj/structure/painting/New()
	..()
	update_painting()

/obj/structure/painting/proc/update_painting()
	switch(icon_state)
		if("narsie")
			name = "\improper Papa Narnar"
			desc = "A painting of Nar-Sie. You feel as if it's watching you."
		if("monkey")
			name = "\improper Mr. Deempisi portrait"
			desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
		if("duck")
			name = "\improper Duck"
			desc = "A painting of a duck. It has a crazed look in its eyes."
		if("mario")
			name = "\improper Mario and Coin"
			desc = "A painting of an italian plumber and an oversized golden plate. Apparently he's a video game mascot of sorts."
		if("gradius")
			name = "\improper Vic Viper"
			desc = "A painting of a space ship. It makes you feel like diving right into an alien base and release your blasters right onto its core."
		if("justice")
			name = "\improper Justice"
			desc = "A painting of a golden scale. Those are often found within courtrooms."
		if("kudzu")
			name = "\improper Scythe on Kudzu"
			desc = "A painting of a scythe and some vines."
		if("dwarf")
			name = "\improper Dwarven Miner"
			desc = "A painting of a dwarf mining adamantine. A long lost high-value metal that was said to be impossibly lightweight, strong, and sharp."
		if("xenolisa")
			name = "\improper Xeno Lisa"
			desc = "A painting of a xenomorph queen, wearing some human clothing. The hands are particularly well-painted."
		if("bottles")
			name = "\improper Bottle and Bottle"
			desc = "A painting of two glass bottles filled with blue and red liquids. You can almost feel the intensity of the artistic discussions that led to this creation."
		if("aymao")
			name = "\improper Ay Mao"
			desc = "A painting of the glorious leader of the Grey Democratic Republic. He looks dignified, and a bit high too."
		if("flowey")
			name = "\improper Flowey the Flower"
			desc = "A painting of your best friend. Also SERIAL MURDERER."
		if("sunset")
			name = "\improper Path toward the Sunset"
			desc = "A painting by D.T.Link. The colours fill you with hope and determination."
		else
			name = "painting"
			desc = "a blank painting."

/obj/structure/painting/attack_hand(mob/user)
	user << "<span class='notice'>You pick up \the [src]...</span>"

	add_fingerprint(user)

	var/obj/item/mounted/frame/painting/P = new(loc)
	P.paint = icon_state
	P.update_painting()

	transfer_fingerprints(src, P)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1)

	P.attack_hand(user)
	qdel(src)

/obj/structure/painting/cultify()
	var/obj/structure/painting/narsie/N = new(loc)
	N.pixel_x = pixel_x
	N.pixel_y = pixel_y
	..()

/obj/structure/painting/narsie
	icon_state = "narsie"

/obj/structure/painting/narsie/cultify()
	return

/obj/structure/painting/random/New()
	..()
	icon_state = pick(available_paintings)
	update_painting()
