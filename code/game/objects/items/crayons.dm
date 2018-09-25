#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

#define PAINT_NORMAL	1
#define PAINT_LARGE_HORIZONTAL	2
#define PAINT_LARGE_HORIZONTAL_ICON	'icons/effects/96x32.dmi'

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"

	var/icon_capped
	var/icon_uncapped
	var/use_overlays = FALSE

	item_color = "red"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "coloured")
	grind_results = list()
	var/paint_color = "#FF0000" //RGB

	var/drawtype
	var/text_buffer = ""

	var/list/graffiti = list("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","body","cyka","arrow","star","poseur tag","prolizard","antilizard")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/list/numerals = list("0","1","2","3","4","5","6","7","8","9")
	var/list/oriented = list("arrow","body") // These turn to face the same way as the drawer
	var/list/runes = list("rune1","rune2","rune3","rune4","rune5","rune6")
	var/list/randoms = list(RANDOM_ANY, RANDOM_RUNE, RANDOM_ORIENTED,
		RANDOM_NUMBER, RANDOM_GRAFFITI, RANDOM_LETTER)
	var/list/graffiti_large_h = list("yiffhell", "secborg", "paint")

	var/list/all_drawables

	var/paint_mode = PAINT_NORMAL

	var/charges = 30 //-1 or less for unlimited uses
	var/charges_left
	var/volume_multiplier = 1 // Increases reagent effect

	var/actually_paints = TRUE

	var/instant = FALSE
	var/self_contained = TRUE // If it deletes itself when it is empty

	var/list/validSurfaces = list(/turf/open/floor)

	var/edible = TRUE // That doesn't mean eating it is a good idea

	var/list/reagent_contents = list("nutriment" = 1)
	// If the user can toggle the colour, a la vanilla spraycan
	var/can_change_colour = FALSE

	var/has_cap = FALSE
	var/is_capped = FALSE

	var/pre_noise = FALSE
	var/post_noise = FALSE


/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming [src] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/Initialize()
	. = ..()
	// Makes crayons identifiable in things like grinders
	if(name == "crayon")
		name = "[item_color] crayon"

	all_drawables = graffiti + letters + numerals + oriented + runes + graffiti_large_h
	drawtype = pick(all_drawables)

	refill()

/obj/item/toy/crayon/proc/refill()
	if(charges == -1)
		charges_left = 100
	else
		charges_left = charges

	if(!reagents)
		create_reagents(charges_left * volume_multiplier)
	reagents.clear_reagents()

	var/total_weight = 0
	for(var/key in reagent_contents)
		total_weight += reagent_contents[key]

	var/units_per_weight = reagents.maximum_volume / total_weight
	for(var/reagent in reagent_contents)
		var/weight = reagent_contents[reagent]
		var/amount = weight * units_per_weight
		reagents.add_reagent(reagent, amount)

/obj/item/toy/crayon/proc/use_charges(mob/user, amount = 1, requires_full = TRUE)
	// Returns number of charges actually used
	if(charges == -1)
		. = amount
		refill()
	else
		if(check_empty(user, amount, requires_full))
			return 0
		else
			. = min(charges_left, amount)
			charges_left -= .

/obj/item/toy/crayon/proc/check_empty(mob/user, amount = 1, requires_full = TRUE)
	// When eating a crayon, check_empty() can be called twice producing
	// two messages unless we check for being deleted first
	if(QDELETED(src))
		return TRUE

	. = FALSE
	// -1 is unlimited charges
	if(charges == -1)
		. = FALSE
	else if(!charges_left)
		to_chat(user, "<span class='warning'>There is no more of [src] left!</span>")
		if(self_contained)
			qdel(src)
		. = TRUE
	else if(charges_left < amount && requires_full)
		to_chat(user, "<span class='warning'>There is not enough of [src] left!</span>")
		. = TRUE

/obj/item/toy/crayon/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	// tgui is a plague upon this codebase

	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crayon", name, 600, 600,
			master_ui, state)
		ui.open()

/obj/item/toy/crayon/spraycan/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(has_cap)
			is_capped = !is_capped
			to_chat(user, "<span class='notice'>The cap on [src] is now [is_capped ? "on" : "off"].</span>")
			update_icon()

/obj/item/toy/crayon/ui_data()
	var/list/data = list()
	data["drawables"] = list()
	var/list/D = data["drawables"]

	var/list/g_items = list()
	D += list(list("name" = "Graffiti", "items" = g_items))
	for(var/g in graffiti)
		g_items += list(list("item" = g))

	var/list/glh_items = list()
	D += list(list("name" = "Graffiti Large Horizontal", "items" = glh_items))
	for(var/glh in graffiti_large_h)
		glh_items += list(list("item" = glh))

	var/list/L_items = list()
	D += list(list("name" = "Letters", "items" = L_items))
	for(var/L in letters)
		L_items += list(list("item" = L))

	var/list/N_items = list()
	D += list(list(name = "Numerals", "items" = N_items))
	for(var/N in numerals)
		N_items += list(list("item" = N))

	var/list/O_items = list()
	D += list(list(name = "Oriented", "items" = O_items))
	for(var/O in oriented)
		O_items += list(list("item" = O))

	var/list/R_items = list()
	D += list(list(name = "Runes", "items" = R_items))
	for(var/R in runes)
		R_items += list(list("item" = R))

	var/list/rand_items = list()
	D += list(list(name = "Random", "items" = rand_items))
	for(var/i in randoms)
		rand_items += list(list("item" = i))

	data["selected_stencil"] = drawtype
	data["text_buffer"] = text_buffer

	data["has_cap"] = has_cap
	data["is_capped"] = is_capped
	data["can_change_colour"] = can_change_colour
	data["current_colour"] = paint_color

	return data

/obj/item/toy/crayon/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("toggle_cap")
			if(has_cap)
				is_capped = !is_capped
				. = TRUE
		if("select_stencil")
			var/stencil = params["item"]
			if(stencil in all_drawables + randoms)
				drawtype = stencil
				. = TRUE
			if(stencil in graffiti_large_h)
				paint_mode = PAINT_LARGE_HORIZONTAL
				text_buffer = ""
			else
				paint_mode = PAINT_NORMAL
		if("select_colour")
			if(can_change_colour)
				paint_color = input(usr,"","Choose Color",paint_color) as color|null
				. = TRUE
		if("enter_text")
			var/txt = stripped_input(usr,"Choose what to write.",
				"Scribbles",default = text_buffer)
			text_buffer = crayon_text_strip(txt)
			. = TRUE
			paint_mode = PAINT_NORMAL
			drawtype = "a"
	update_icon()

/obj/item/toy/crayon/proc/crayon_text_strip(text)
	var/list/base = string2charlist(lowertext(text))
	var/list/out = list()
	for(var/a in base)
		if(a in (letters|numerals))
			out += a
	return jointext(out,"")

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !check_allowed_items(target))
		return

	var/cost = 1
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		cost = 5
	if(istype(target, /obj/item/canvas))
		cost = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.has_trait(TRAIT_TAGGER))
			cost *= 0.5
	var/charges_used = use_charges(user, cost)
	if(!charges_used)
		return
	. = charges_used

	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc

	if(!is_type_in_list(target,validSurfaces))
		return

	var/drawing = drawtype
	switch(drawtype)
		if(RANDOM_LETTER)
			drawing = pick(letters)
		if(RANDOM_GRAFFITI)
			drawing = pick(graffiti)
		if(RANDOM_RUNE)
			drawing = pick(runes)
		if(RANDOM_ORIENTED)
			drawing = pick(oriented)
		if(RANDOM_NUMBER)
			drawing = pick(numerals)
		if(RANDOM_ANY)
			drawing = pick(all_drawables)

	var/temp = "rune"
	if(drawing in letters)
		temp = "letter"
	else if(drawing in graffiti)
		temp = "graffiti"
	else if(drawing in numerals)
		temp = "number"


	var/graf_rot
	if(drawing in oriented)
		switch(user.dir)
			if(EAST)
				graf_rot = 90
			if(SOUTH)
				graf_rot = 180
			if(WEST)
				graf_rot = 270
			else
				graf_rot = 0

	var/list/click_params = params2list(params)
	var/clickx
	var/clicky

	if(click_params && click_params["icon-x"] && click_params["icon-y"])
		clickx = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		clicky = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)

	if(!instant)
		to_chat(user, "<span class='notice'>You start drawing a [temp] on the	[target.name]...</span>")

	if(pre_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/takes_time = !instant

	var/wait_time = 50
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		wait_time *= 3

	if(takes_time)
		if(!do_after(user, 50, target = target))
			return

	if(length(text_buffer))
		drawing = copytext(text_buffer,1,2)


	var/list/turf/affected_turfs = list()

	if(actually_paints)
		switch(paint_mode)
			if(PAINT_NORMAL)
				var/obj/effect/decal/cleanable/crayon/C = new(target, paint_color, drawing, temp, graf_rot)
				C.add_hiddenprint(user)
				C.pixel_x = clickx
				C.pixel_y = clicky
				affected_turfs += target
			if(PAINT_LARGE_HORIZONTAL)
				var/turf/left = locate(target.x-1,target.y,target.z)
				var/turf/right = locate(target.x+1,target.y,target.z)
				if(is_type_in_list(left, validSurfaces) && is_type_in_list(right, validSurfaces))
					var/obj/effect/decal/cleanable/crayon/C = new(left, paint_color, drawing, temp, graf_rot, PAINT_LARGE_HORIZONTAL_ICON)
					C.add_hiddenprint(user)
					affected_turfs += left
					affected_turfs += right
					affected_turfs += target
				else
					to_chat(user, "<span class='warning'>There isn't enough space to paint!</span>")
					return

	if(!instant)
		to_chat(user, "<span class='notice'>You finish drawing \the [temp].</span>")
	else
		to_chat(user, "<span class='notice'>You spray a [temp] on \the [target.name]</span>")

	if(length(text_buffer))
		text_buffer = copytext(text_buffer,2)

	if(post_noise)
		audible_message("<span class='notice'>You hear spraying.</span>")
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)

	var/fraction = min(1, . / reagents.maximum_volume)
	if(affected_turfs.len)
		fraction /= affected_turfs.len
	for(var/t in affected_turfs)
		reagents.reaction(t, TOUCH, fraction * volume_multiplier)
		reagents.trans_to(t, ., volume_multiplier)
	check_empty(user)

/obj/item/toy/crayon/attack(mob/M, mob/user)
	if(edible && (M == user))
		to_chat(user, "You take a bite of the [src.name]. Delicious!")
		var/eaten = use_charges(user, 5, FALSE)
		if(check_empty(user)) //Prevents divsion by zero
			return
		var/fraction = min(eaten / reagents.total_volume, 1)
		reagents.reaction(M, INGEST, fraction * volume_multiplier)
		reagents.trans_to(M, eaten, volume_multiplier)
		// check_empty() is called during afterattack
	else
		..()

/obj/item/toy/crayon/red
	icon_state = "crayonred"
	paint_color = "#DA0000"
	item_color = "red"
	reagent_contents = list("nutriment" = 1, "redcrayonpowder" = 1)

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	paint_color = "#FF9300"
	item_color = "orange"
	reagent_contents = list("nutriment" = 1, "orangecrayonpowder" = 1)

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	paint_color = "#FFF200"
	item_color = "yellow"
	reagent_contents = list("nutriment" = 1, "yellowcrayonpowder" = 1)

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	paint_color = "#A8E61D"
	item_color = "green"
	reagent_contents = list("nutriment" = 1, "greencrayonpowder" = 1)

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	paint_color = "#00B7EF"
	item_color = "blue"
	reagent_contents = list("nutriment" = 1, "bluecrayonpowder" = 1)

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	paint_color = "#DA00FF"
	item_color = "purple"
	reagent_contents = list("nutriment" = 1, "purplecrayonpowder" = 1)

/obj/item/toy/crayon/black
	icon_state = "crayonblack"
	paint_color = "#1C1C1C" //Not completely black because total black looks bad. So Mostly Black.
	item_color = "black"
	reagent_contents = list("nutriment" = 1, "blackcrayonpowder" = 1)

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	paint_color = "#FFFFFF"
	item_color = "white"
	reagent_contents = list("nutriment" = 1, "whitecrayonpowder" = 1)

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	paint_color = "#FFFFFF"
	item_color = "mime"
	reagent_contents = list("nutriment" = 1, "invisiblecrayonpowder" = 1)
	charges = -1

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	paint_color = "#FFF000"
	item_color = "rainbow"
	reagent_contents = list("nutriment" = 1, "colorful_reagent" = 1)
	drawtype = RANDOM_ANY // just the default starter.

	charges = -1

/obj/item/toy/crayon/rainbow/afterattack(atom/target, mob/user, proximity)
	paint_color = rgb(rand(0,255), rand(0,255), rand(0,255))
	. = ..()

/*
 * Crayon Box
 */

/obj/item/storage/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/crayons/Initialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 7
	STR.can_hold = typecacheof(list(/obj/item/toy/crayon))

/obj/item/storage/crayons/PopulateContents()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_icon()

/obj/item/storage/crayons/update_icon()
	cut_overlays()
	for(var/obj/item/toy/crayon/crayon in contents)
		add_overlay(mutable_appearance('icons/obj/crayons.dmi', crayon.item_color))

/obj/item/storage/crayons/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		switch(C.item_color)
			if("mime")
				to_chat(usr, "This crayon is too sad to be contained in this box.")
				return
			if("rainbow")
				to_chat(usr, "This crayon is too powerful to be contained in this box.")
				return
		if(istype(W, /obj/item/toy/crayon/spraycan))
			to_chat(user, "Spraycans are not crayons.")
			return
	return ..()

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "spray can"
	icon_state = "spraycan"

	icon_capped = "spraycan_cap"
	icon_uncapped = "spraycan"
	use_overlays = TRUE
	paint_color = null

	item_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	desc = "A metallic container containing tasty paint."

	instant = TRUE
	edible = FALSE
	has_cap = TRUE
	is_capped = TRUE
	self_contained = FALSE // Don't disappear when they're empty
	can_change_colour = TRUE

	validSurfaces = list(/turf/open/floor, /turf/closed/wall)
	reagent_contents = list("welding_fuel" = 1, "ethanol" = 1)

	pre_noise = TRUE
	post_noise = FALSE

/obj/item/toy/crayon/spraycan/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(is_capped || !actually_paints)
		user.visible_message("<span class='suicide'>[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, but nothing happens!</span>")
		user.say("MEDIOCRE!!", forced="spraycan suicide")
		return SHAME
	else
		user.visible_message("<span class='suicide'>[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, spraying paint across [user.p_their()] teeth!</span>")
		user.say("WITNESS ME!!", forced="spraycan suicide")
		if(pre_noise || post_noise)
			playsound(loc, 'sound/effects/spray.ogg', 5, 1, 5)
		if(can_change_colour)
			paint_color = "#C0C0C0"
		update_icon()
		if(actually_paints)
			H.lip_style = "spray_face"
			H.lip_color = paint_color
			H.update_body()
		var/used = use_charges(user, 10, FALSE)
		var/fraction = min(1, used / reagents.maximum_volume)
		reagents.reaction(user, VAPOR, fraction * volume_multiplier)
		reagents.trans_to(user, used, volume_multiplier)

		return (OXYLOSS)

/obj/item/toy/crayon/spraycan/New()
	..()
	// If default crayon red colour, pick a more fun spraycan colour
	if(!paint_color)
		paint_color = pick("#DA0000","#FF9300","#FFF200","#A8E61D","#00B7EF",
		"#DA00FF")
	refill()
	update_icon()


/obj/item/toy/crayon/spraycan/examine(mob/user)
	. = ..()
	if(charges_left)
		to_chat(user, "It has [charges_left] use\s left.")
	else
		to_chat(user, "It is empty.")
	to_chat(user, "<span class='notice'>Alt-click [src] to [ is_capped ? "take the cap off" : "put the cap on"].</span>")

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return

	if(check_empty(user))
		return

	if(iscarbon(target))
		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 25, 1, 5)

		var/mob/living/carbon/C = target
		user.visible_message("<span class='danger'>[user] sprays [src] into the face of [target]!</span>")
		to_chat(target, "<span class='userdanger'>[user] sprays [src] into your face!</span>")

		if(C.client)
			C.blur_eyes(3)
			C.blind_eyes(1)
		if(C.get_eye_protection() <= 0) // no eye protection? ARGH IT BURNS.
			C.confused = max(C.confused, 3)
			C.Knockdown(60)
		if(ishuman(C) && actually_paints)
			var/mob/living/carbon/human/H = C
			H.lip_style = "spray_face"
			H.lip_color = paint_color
			H.update_body()

		// Caution, spray cans contain inflammable substances
		. = use_charges(user, 10, FALSE)
		var/fraction = min(1, . / reagents.maximum_volume)
		reagents.reaction(C, VAPOR, fraction * volume_multiplier)

		return

	if(istype(target, /obj/structure/window))
		if(actually_paints)
			target.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
			if(color_hex2num(paint_color) < 255)
				target.set_opacity(255)
			else
				target.set_opacity(initial(target.opacity))
		. = use_charges(user, 2)
		var/fraction = min(1, . / reagents.maximum_volume)
		reagents.reaction(target, TOUCH, fraction * volume_multiplier)
		reagents.trans_to(target, ., volume_multiplier)

		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		return

	. = ..()

/obj/item/toy/crayon/spraycan/update_icon()
	icon_state = is_capped ? icon_capped : icon_uncapped
	if(use_overlays)
		cut_overlays()
		var/mutable_appearance/spray_overlay = mutable_appearance('icons/obj/crayons.dmi', "[is_capped ? "spraycan_cap_colors" : "spraycan_colors"]")
		spray_overlay.color = paint_color
		add_overlay(spray_overlay)

/obj/item/toy/crayon/spraycan/borg
	name = "cyborg spraycan"
	desc = "A metallic container containing shiny synthesised paint."
	charges = -1

/obj/item/toy/crayon/spraycan/borg/afterattack(atom/target,mob/user,proximity)
	var/diff = ..()
	if(!iscyborg(user))
		to_chat(user, "<span class='notice'>How did you get this?</span>")
		qdel(src)
		return FALSE

	var/mob/living/silicon/robot/borgy = user

	if(!diff)
		return
	// 25 is our cost per unit of paint, making it cost 25 energy per
	// normal tag, 50 per window, and 250 per attack
	var/cost = diff * 25
	// Cyborgs shouldn't be able to use modules without a cell. But if they do
	// it's free.
	if(borgy.cell)
		borgy.cell.use(cost)

/obj/item/toy/crayon/spraycan/hellcan
	name = "hellcan"
	desc = "This spraycan doesn't seem to be filled with paint..."
	icon_state = "deathcan2_cap"
	icon_capped = "deathcan2_cap"
	icon_uncapped = "deathcan2"
	use_overlays = FALSE

	volume_multiplier = 25
	charges = 100
	reagent_contents = list("clf3" = 1)
	actually_paints = FALSE
	paint_color = "#000000"

/obj/item/toy/crayon/spraycan/lubecan
	name = "slippery spraycan"
	desc = "You can barely keep hold of this thing."
	icon_state = "clowncan2_cap"
	icon_capped = "clowncan2_cap"
	icon_uncapped = "clowncan2"
	use_overlays = FALSE

	reagent_contents = list("lube" = 1, "banana" = 1)
	volume_multiplier = 5
	validSurfaces = list(/turf/open/floor)

/obj/item/toy/crayon/spraycan/mimecan
	name = "silent spraycan"
	desc = "Art is best seen, not heard."
	icon_state = "mimecan_cap"
	icon_capped = "mimecan_cap"
	icon_uncapped = "mimecan"
	use_overlays = FALSE

	can_change_colour = FALSE
	paint_color = "#FFFFFF" //RGB

	pre_noise = FALSE
	post_noise = FALSE
	reagent_contents = list("nothing" = 1, "mutetoxin" = 1)

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_NUMBER
#undef RANDOM_ORIENTED
#undef RANDOM_RUNE
#undef RANDOM_ANY
