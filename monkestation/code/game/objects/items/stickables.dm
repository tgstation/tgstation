//Base Stickable Object
/obj/item/stickable
	name = "Stickable Object"
	desc = "If you're reading this, a coder did something very wrong."
	icon = 'monkestation/icons/obj/misc/stickables.dmi'
	icon_state = "sticker"
	w_class = WEIGHT_CLASS_TINY
	var/target_icon = 'monkestation/icons/obj/misc/stickables.dmi' 	//Separating out the icon and target icon means
	var/list/possible_icon_states									//you can have a sticker with a different sprite than what you see in your hand.
	var/current_icon												//This also allows adminbus stickers with odd icons

/obj/item/stickable/examine(mob/user)
	. = ..()
	if(possible_icon_states)
		. +=  "\n[current_icon] is currently selected, <span class='notice'>Use in hand to switch the sticker selected.</span>"

//Sticker selection
/obj/item/stickable/attack_self(mob/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/obj/item/stickable/selecting = src
	if(selecting.possible_icon_states)
		current_icon = input(user,"Morph your Sticker.", "Selectable Stickers") in selecting.possible_icon_states

//Thrown Stickers
/obj/item/stickable/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/actual_target
	var/selected_layer
	var/X_location = rand(-8,8)
	var/Y_location = rand(-8,8)

	if(ismob(hit_atom) || isturf(hit_atom))
		var/atom/movable/selected = hit_atom
		selected_layer = hit_atom.layer+1
		var/obj/item/stickable/dummy = locate(/obj/item/stickable) in selected.vis_contents
		if(dummy)
			src.forceMove(dummy)
			src.vis_flags = VIS_INHERIT_ID
			actual_target = dummy
		else if(!dummy)
			var/obj/item/stickable/dummy_holder/stuck = new
			selected.vis_contents += stuck
			src.forceMove(stuck)
			src.vis_flags = VIS_INHERIT_ID
			actual_target = stuck
	else
		return

	hit_atom.visible_message("<span class='warning'>[hit_atom] is stuck by a [src]!<span>")

	on_stick(actual_target, X_location, Y_location, selected_layer)

//"Attack" handling
/obj/item/stickable/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		var/actual_target
		var/X_location
		var/Y_location
		var/selected_layer

		if(istype(target, /mob) || istype(target, /turf) || istype(target, /obj))
			var/atom/movable/selected = target
			selected_layer = target.layer+1
			var/obj/item/stickable/dummy = locate(/obj/item/stickable) in selected.vis_contents
			if(dummy)
				src.forceMove(dummy)
				src.vis_flags = VIS_INHERIT_ID
				actual_target = dummy
			else if(!dummy)
				var/obj/item/stickable/dummy_holder/stuck = new
				selected.vis_contents += stuck
				src.forceMove(stuck)
				src.vis_flags = VIS_INHERIT_ID
				actual_target = stuck
		else
			return

		var/list/click_params = params2list(click_parameters)
		if(click_params && click_params["icon-x"] && click_params["icon-y"])
			X_location = text2num(click_params["icon-x"]) - 16
			Y_location = text2num(click_params["icon-y"]) - 16

		user.visible_message("<span class='warning'>[user] sticks [src] onto [target]!<span>")

		on_stick(actual_target, X_location, Y_location, selected_layer)

//Dummy Stickable
/obj/item/stickable/dummy_holder
	name = "Dummy Sticker Holder"
	desc = "If you see this, contact a coder."
	icon_state = "NULL"
	vis_flags = VIS_INHERIT_ID

//Actual overlay handling
/obj/item/stickable/proc/on_stick(target, X_location, Y_location, selected_layer)
	var/obj/item/stickable/dummy_holder/stick_target = target
	var/image/stuck = image(src.target_icon, target, src.current_icon, selected_layer)

	stuck.pixel_x = X_location
	stuck.pixel_y = Y_location
	stick_target.overlays += stuck

////////////////////////
//Sticker Roll Defines//
////////////////////////

//Base roll of stickers
//Don't spawn unless you hand-edit the sticker_type.
/obj/item/sticker_roll
	name = "Bag of Stickers"
	desc = "Wait, there's nothing in here! Damn coders!"
	icon = 'monkestation/icons/obj/misc/stickables.dmi'
	icon_state = "icons"
	var/sticker_type		//A path to the type of sticker inside
	var/sticker_count = 25 	//Count of stickers inside the bag

//Sticker Roll Examination (Count & Type)
/obj/item/sticker_roll/examine(mob/user)
	. = ..()
	. += "\nThere are [sticker_count] remaining in the roll."

//Taking stickers from the bag
/obj/item/sticker_roll/attack_hand(mob/user)
	sticker_count--
	user.put_in_hands(new sticker_type)
	if(!sticker_count)
		to_chat(user,"<span class='warning'>You take the last sticker in the roll.</span>")
		qdel(src)
		return
	to_chat(user,"<span class='notice'>You grab a sticker.</span>")

//Picking up the roll
//Functions like a deck of cards.
/obj/item/sticker_roll/MouseDrop(atom/over)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || !(M.mobility_flags & MOBILITY_PICKUP))
		return
	if(Adjacent(usr))
		if(over == M && loc != M)
			M.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the roll of stickers.</span>")

		else if(istype(over, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over
			if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
				to_chat(usr, "<span class='notice'>You pick up the roll of stickers.</span>")

	else
		to_chat(usr, "<span class='warning'>You can't reach it from here!</span>")

////////////////////
//Stickers & Rolls//
////////////////////

//Remember, sticker rolls are "/obj/item/sticker_roll" and the stickers are "/obj/item/stickable"
//These are separated because we do not want people sticking rolls onto people, as funny as that would be.
//Bag Quick Reference: "sticker_type" is a typepath for the sticker/object you want inside, "sticker_count" (default 10) is how many stickers you can get
//Stickable Quick Ref: icon/icon_state are for the in-hand and ground icons, "current_icon" is the icon_state that will be applied to a target.
//"target_icon" is the .dmi icon file selected to use, very rare that it will be needed but exists for possible alternate icon files.
//"possible_icon_states" is optional and is a list of possible states for "current_icon" that can be switched between by using in hand.

//Sticker Roll Box
/obj/item/storage/box/stickers
	name = "Box of Sticker Rolls"
	desc = "Full of stickers for all of your creative needs"

//In the event of there ever being traitor only, or antagonistic subtypes of stickers, it's your responsibility to change this before adding them!
/obj/item/storage/box/stickers/PopulateContents()
	for(var/i in 1 to 7)
		var/random_sticker_roll = pick(subtypesof(/obj/item/sticker_roll))
		new random_sticker_roll(src)


//Menacing Sticker
/obj/item/stickable/menacing
	name = "Menacing Sticker"
	desc = "You feel incredibly intimidated by this sticker."
	possible_icon_states = list("menacing","do")
	current_icon = "menacing"

//Menacing sticker roll
/obj/item/sticker_roll/menacing
	name = "Roll of Menacing Stickers"
	desc = "This is the most menacing thing you have ever seen."
	icon_state = "anime"
	sticker_type = "/obj/item/stickable/menacing"
	sticker_count = 5

//Alphabet Sticker
/obj/item/stickable/alphabet
	name = "Alphabet Sticker"
	desc = "Using bluespace technology, you can apply any letter of the alphabet to almost any surface."
	possible_icon_states = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
	current_icon = "A"

//Alphabet sticker roll
/obj/item/sticker_roll/alphabet
	name = "Roll of Alphabet Stickers"
	desc = "Full of transforming alphabet stickers to apply wherever you please."
	icon_state = "letters"
	sticker_type = "/obj/item/stickable/alphabet"

//Number Stickers
/obj/item/stickable/number
	name = "Number Sticker"
	desc = "Using bluespace technology, you can apply any number to almost any surface."
	possible_icon_states = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
	current_icon = "0"

//Number sticker roll
/obj/item/sticker_roll/number
	name = "Roll of Number Stickers"
	desc = "Full of transforming numeric stickers to apply to wherever you please."
	sticker_type = "/obj/item/stickable/number"

//Icon Stickers
/obj/item/stickable/icon_stickers
	name = "Icon Sticker"
	desc = "Using bluespace technology, you can apply a number of icons to almost any surface."
	possible_icon_states = list("Exclamation", "Question", "Ook", "Lightbulb", "Banana", "Sick", "Heart", "Sad", "Angy", "Happy", "Manic", "Bad Times", "Blank Line", "Blank Column")
	current_icon = "Exclamation"

//Icon sticker roll
/obj/item/sticker_roll/icon_stickers
	name = "Roll of Icon Stickers"
	desc = "Full of transforming icon stickers to apply to wherever you please."
	sticker_type = "/obj/item/stickable/icon_stickers"

//Googly Eyes
/obj/item/stickable/eyes
	name = "Googly Eyes"
	desc = "A set of funny eyes that make anything better."
	possible_icon_states = list("Eye", "Lizard Eye", "Left Anime", "Right Anime", "Angry Liz Left", "Angry Liz Right", "Angry Left", "Angry Right")
	current_icon = "Eye"

//Googly Eye Roll
/obj/item/sticker_roll/eyes
	name = "Roll of googly eyes"
	desc = "Full of googly eyes to stick on everything you want."
	icon_state = "googly"
	sticker_type = "/obj/item/stickable/eyes"

//Status Stickers
/obj/item/stickable/status
	name = "HUDtastic Pranking Sticker"
	desc = "A set of anti-gravity pranking stickers from HONKtronics, makes security laugh every time!"
	target_icon = 'icons/mob/hud.dmi'
	possible_icon_states = list("electrified","synd", "traitor", "brother","hudill4","hudwanted","heretic", "wizard", "apprentice", "hudcaptain", "hudcentcom", "hudhealth-85", "huddead", "hudclown")
	current_icon = "electrified"

//Status Sticker Roll
/obj/item/sticker_roll/status
	name = "Roll of HUDTastic Stickers"
	desc = "HONKtronics is not responsible for where you stick these fun stickers!"
	sticker_type = "/obj/item/stickable/status"
	sticker_count = 5
