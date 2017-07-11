/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/bedsheets.dmi'
	icon_state = "sheetwhite"
	item_state = "bedsheet"
	slot_flags = SLOT_NECK
	layer = MOB_LAYER
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	item_color = "white"
	resistance_flags = FLAMMABLE

	dog_fashion = /datum/dog_fashion/head/ghost
	var/list/dream_messages = list("white")

/obj/item/weapon/bedsheet/attack(mob/living/M, mob/user)
	if(!attempt_initiate_surgery(src, M, user))
		..()

/obj/item/weapon/bedsheet/attack_self(mob/user)
	user.drop_item()
	if(layer == initial(layer))
		layer = ABOVE_MOB_LAYER
		to_chat(user, "<span class='notice'>You cover yourself with [src].</span>")
	else
		layer = initial(layer)
		to_chat(user, "<span class='notice'>You smooth [src] out beneath you.</span>")
	add_fingerprint(user)
	return

/obj/item/weapon/bedsheet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters) || I.is_sharp())
		var/obj/item/stack/sheet/cloth/C = new (get_turf(src), 3)
		transfer_fingerprints_to(C)
		C.add_fingerprint(user)
		qdel(src)
		to_chat(user, "<span class='notice'>You tear [src] up.</span>")
	else
		return ..()

/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"
	item_color = "blue"
	dream_messages = list("blue")

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"
	item_color = "green"
	dream_messages = list("green")

/obj/item/weapon/bedsheet/grey
	icon_state = "sheetgrey"
	item_color = "grey"
	dream_messages = list("grey")

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"
	item_color = "orange"
	dream_messages = list("orange")

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"
	item_color = "purple"
	dream_messages = list("purple")

/obj/item/weapon/bedsheet/patriot
	name = "patriotic bedsheet"
	desc = "You've never felt more free than when sleeping on this."
	icon_state = "sheetUSA"
	item_color = "sheetUSA"
	dream_messages = list("America", "freedom", "fireworks", "bald eagles")

/obj/item/weapon/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multicolored blanket. It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	item_color = "rainbow"
	dream_messages = list("red", "orange", "yellow", "green", "blue", "purple", "a rainbow")

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"
	item_color = "red"
	dream_messages = list("red")

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"
	item_color = "yellow"
	dream_messages = list("yellow")

/obj/item/weapon/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	item_color = "mime"
	dream_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")

/obj/item/weapon/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in. It smells faintly of bananas."
	icon_state = "sheetclown"
	item_color = "clown"
	dream_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")

/obj/item/weapon/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	item_color = "captain"
	dream_messages = list("authority", "a golden ID", "sunglasses", "a green disc", "an antique gun", "the captain")

/obj/item/weapon/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	item_color = "director"
	dream_messages = list("authority", "a silvery ID", "a bomb", "a mech", "a facehugger", "maniacal laughter", "the research director")

// for Free Golems.
/obj/item/weapon/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/weapon/bedsheet/medical
	name = "medical blanket"
	desc = "It's a sterilized* blanket commonly used in the Medbay.  *Sterilization is voided if a virologist is present onboard the station."
	icon_state = "sheetmedical"
	item_color = "medical"
	dream_messages = list("healing", "life", "surgery", "a doctor")

/obj/item/weapon/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem. There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	item_color = "cmo"
	dream_messages = list("authority", "a silvery ID", "healing", "life", "surgery", "a cat", "the chief medical officer")

/obj/item/weapon/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem. While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	item_color = "hosred"
	dream_messages = list("authority", "a silvery ID", "handcuffs", "a baton", "a flashbang", "sunglasses", "the head of security")

/obj/item/weapon/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem. For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	item_color = "hop"
	dream_messages = list("authority", "a silvery ID", "obligation", "a computer", "an ID", "a corgi", "the head of personnel")

/obj/item/weapon/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem. It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	item_color = "chief"
	dream_messages = list("authority", "a silvery ID", "the engine", "power tools", "an APC", "a parrot", "the chief engineer")

/obj/item/weapon/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	item_color = "qm"
	dream_messages = list("a grey ID", "a shuttle", "a crate", "a sloth", "the quartermaster")

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"
	item_color = "cargo"
	dream_messages = list("brown")

/obj/item/weapon/bedsheet/black
	icon_state = "sheetblack"
	item_color = "black"
	dream_messages = list("black")

/obj/item/weapon/bedsheet/centcom
	name = "\improper Centcom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	item_color = "centcom"
	dream_messages = list("a unique ID", "authority", "artillery", "an ending")

/obj/item/weapon/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	item_color = "syndie"
	dream_messages = list("a green disc", "a red crystal", "a glowing blade", "a wire-covered ID")

/obj/item/weapon/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this. It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	item_color = "cult"
	dream_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")

/obj/item/weapon/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night. It even glows!"
	icon_state = "sheetwiz"
	item_color = "wiz"
	dream_messages = list("a book", "an explosion", "lightning", "a staff", "a skeleton", "a robe", "magic")

/obj/item/weapon/bedsheet/nanotrasen
	name = "nanotrasen bedsheet"
	desc = "It has the Nanotrasen logo on it and has an aura of duty."
	icon_state = "sheetNT"
	item_color = "nanotrasen"
	dream_messages = list("authority", "an ending")

/obj/item/weapon/bedsheet/ian
	icon_state = "sheetian"
	item_color = "ian"
	dream_messages = list("a dog", "a corgi", "woof", "bark", "arf")


/obj/item/weapon/bedsheet/random
	icon_state = "sheetrainbow"
	item_color = "rainbow"
	name = "random bedsheet"
	desc = "If you're reading this description ingame, something has gone wrong! Honk!"

/obj/item/weapon/bedsheet/random/Initialize()
	. = INITIALIZE_HINT_QDEL
	..()
	var/type = pick(typesof(/obj/item/weapon/bedsheet) - /obj/item/weapon/bedsheet/random)
	new type(loc)

/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 70
	var/amount = 10
	var/list/sheets = list()
	var/obj/item/hidden = null


/obj/structure/bedsheetbin/examine(mob/user)
	..()
	if(amount < 1)
		to_chat(user, "There are no bed sheets in the bin.")
	else if(amount == 1)
		to_chat(user, "There is one bed sheet in the bin.")
	else
		to_chat(user, "There are [amount] bed sheets in the bin.")


/obj/structure/bedsheetbin/update_icon()
	switch(amount)
		if(0)
			icon_state = "linenbin-empty"
		if(1 to 5)
			icon_state = "linenbin-half"
		else
			icon_state = "linenbin-full"

/obj/structure/bedsheetbin/fire_act(exposed_temperature, exposed_volume)
	if(amount)
		amount = 0
		update_icon()
	..()

/obj/structure/bedsheetbin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/bedsheet))
		if(!user.drop_item())
			return
		I.loc = src
		sheets.Add(I)
		amount++
		to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		update_icon()
	else if(amount && !hidden && I.w_class < WEIGHT_CLASS_BULKY)	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot hide it among the sheets!</span>")
			return
		I.loc = src
		hidden = I
		to_chat(user, "<span class='notice'>You hide [I] among the sheets.</span>")



/obj/structure/bedsheetbin/attack_paw(mob/user)
	return attack_hand(user)


/obj/structure/bedsheetbin/attack_hand(mob/user)
	if(user.lying)
		return
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
		to_chat(user, "<span class='notice'>You take [B] out of [src].</span>")
		update_icon()

		if(hidden)
			hidden.loc = user.loc
			to_chat(user, "<span class='notice'>[hidden] falls out of [B]!</span>")
			hidden = null


	add_fingerprint(user)
/obj/structure/bedsheetbin/attack_tk(mob/user)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [B] from [src].</span>")
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null


	add_fingerprint(user)
