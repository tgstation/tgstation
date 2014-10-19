/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	layer = 4.0
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	_color = "white"

//cutting the bedsheet into rags
/obj/item/weapon/bedsheet/attackby(var/obj/item/I, mob/user as mob)
	var/cut_time=0
	if(istype(I, /obj/item/weapon/scalpel))
		cut_time=20
	else if(istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/butch))
		cut_time=40
	else if(istype(I, /obj/item/weapon/shard))
		cut_time=80
	else if(istype(I, /obj/item/weapon/kitchen/utensil/pknife))
		cut_time=160
	if(cut_time)
		user << "<span  class='notice'>You begin cutting the [src].</span>"
		if(do_after(user, cut_time))
			if(!src) return
			user << "<span  class='notice'>You have cut the [src] into rags.</span>"
			var/turf/location = get_turf(src)
			for(var/x=0; x<=8; x++)
				var/obj/item/weapon/reagent_containers/glass/rag/S = new/obj/item/weapon/reagent_containers/glass/rag/(location)
				S.pixel_x = rand(-5.0, 5)
				S.pixel_y = rand(-5.0, 5)
			del(src)

//todo: hold one if possible?
//todo: coloring and molotov coloring?
//todo: finger prints?
//todo: more cutting tools?
//todo: sharp thing code/game/objects/objs.dm

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	if(layer == initial(layer))
		layer = 5
	else
		layer = initial(layer)
	add_fingerprint(user)
	return


/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"
	_color = "blue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"
	_color = "green"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"
	_color = "orange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"
	_color = "purple"

/obj/item/weapon/bedsheet/rainbow
	icon_state = "sheetrainbow"
	_color = "rainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"
	_color = "red"

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"
	_color = "yellow"

/obj/item/weapon/bedsheet/mime
	icon_state = "sheetmime"
	_color = "mime"

/obj/item/weapon/bedsheet/clown
	icon_state = "sheetclown"
	_color = "clown"

/obj/item/weapon/bedsheet/captain
	icon_state = "sheetcaptain"
	_color = "captain"

/obj/item/weapon/bedsheet/rd
	icon_state = "sheetrd"
	_color = "director"

/obj/item/weapon/bedsheet/medical
	icon_state = "sheetmedical"
	_color = "medical"

/obj/item/weapon/bedsheet/hos
	icon_state = "sheethos"
	_color = "hosred"

/obj/item/weapon/bedsheet/hop
	icon_state = "sheethop"
	_color = "hop"

/obj/item/weapon/bedsheet/ce
	icon_state = "sheetce"
	_color = "chief"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"
	_color = "brown"




/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = 1
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden = null


/obj/structure/bedsheetbin/examine()
	usr << desc
	if(amount < 1)
		usr << "There are no bed sheets in the bin."
		return
	if(amount == 1)
		usr << "There is one bed sheet in the bin."
		return
	usr << "There are [amount] bed sheets in the bin."


/obj/structure/bedsheetbin/update_icon()
	switch(amount)
		if(0)				icon_state = "linenbin-empty"
		if(1 to amount / 2)	icon_state = "linenbin-half"
		else				icon_state = "linenbin-full"


/obj/structure/bedsheetbin/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/bedsheet))
		user.drop_item()
		I.loc = src
		sheets.Add(I)
		amount++
		user << "<span class='notice'>You put [I] in [src].</span>"
	else if(amount && !hidden && I.w_class < 4)	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		user.drop_item()
		I.loc = src
		hidden = I
		user << "<span class='notice'>You hide [I] among the sheets.</span>"



/obj/structure/bedsheetbin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = user.loc
		user.put_in_hands(B)
		user << "<span class='notice'>You take [B] out of [src].</span>"

		if(hidden)
			hidden.loc = user.loc
			user << "<span class='notice'>[hidden] falls out of [B]!</span>"
			hidden = null


	add_fingerprint(user)

/obj/structure/bedsheetbin/attack_tk(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = loc
		user << "<span class='notice'>You telekinetically remove [B] from [src].</span>"
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null


	add_fingerprint(user)

