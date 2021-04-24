/**
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */
#define MAX_PAPER_LENGTH 5000
#define MAX_PAPER_STAMPS 30 // Too low?
#define MAX_PAPER_STAMPS_OVERLAYS 4
#define MODE_READING 0
#define MODE_WRITING 1
#define MODE_STAMPING 2

/**
 * Paper is now using markdown (like in github pull notes) for ALL rendering
 * so we do loose a bit of functionality but we gain in easy of use of
 * paper and getting rid of that crashing bug
 */
/obj/item/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	inhand_icon_state = "paper"
	worn_icon_state = "paper"
	custom_fire_overlay = "paper_onfire_overlay"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	grind_results = list(/datum/reagent/cellulose = 3)
	color = "white"
	/// What's actually written on the paper.
	var/info = ""
	var/show_written_words = TRUE

	/// The (text for the) stamps on the paper.
	var/list/stamps /// Positioning for the stamp in tgui
	var/list/stamped /// Overlay info

	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0

	/// When the sheet can be "filled out"
	/// This is an associated list
	var/list/form_fields = list()
	var/field_counter = 1

/obj/item/paper/Destroy()
	stamps = null
	stamped = null
	form_fields = null
	stamped = null
	. = ..()

/**
 * This proc copies this sheet of paper to a new
 * sheet,  Makes it nice and easy for carbon and
 * the copyer machine
 */
/obj/item/paper/proc/copy()
	var/obj/item/paper/N = new(arglist(args))
	N.info = info
	N.color = color
	N.update_icon_state()
	N.stamps = stamps
	N.stamped = stamped.Copy()
	N.form_fields = form_fields.Copy()
	N.field_counter = field_counter
	copy_overlays(N, TRUE)
	return N

/**
 * This proc sets the text of the paper and updates the
 * icons.  You can modify the pen_color after if need
 * be.
 */
/obj/item/paper/proc/setText(text)
	info = text
	form_fields = null
	field_counter = 0
	update_icon_state()

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison,contact_poison_volume)
			contact_poison = null
	. = ..()

/obj/item/paper/Initialize()
	. = ..()
	pixel_x = base_pixel_x + rand(-9, 9)
	pixel_y = base_pixel_y + rand(-8, 8)
	update_appearance()

/obj/item/paper/update_icon_state()
	if(info && show_written_words)
		icon_state = "[initial(icon_state)]_words"
	return ..()

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(!usr.can_read(src) || usr.incapacitated(TRUE, TRUE) || (isobserver(usr) && !isAdminGhostAI(usr)))
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>")
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if(((loc == usr || istype(loc, /obj/item/clipboard)) && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/obj/item/paper/proc/clearpaper()
	info = ""
	stamps = null
	LAZYCLEARLIST(stamped)
	cut_overlays()
	update_icon_state()

/obj/item/paper/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		. += "<span class='warning'>You're too far away to read it!</span>"
		return
	if(user.can_read(src))
		ui_interact(user)
		return
	. += "<span class='warning'>You cannot read it!</span>"

/obj/item/paper/ui_status(mob/user,/datum/ui_state/state)
		// Are we on fire?  Hard ot read if so
	if(resistance_flags & ON_FIRE)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	if(user.incapacitated(TRUE, TRUE) || (isobserver(user) && !isAdminGhostAI(user)))
		return UI_UPDATE
	// Even harder to read if your blind...braile? humm
	// .. or if you cannot read
	if(!user.can_read(src))
		return UI_CLOSE
	if(in_contents_of(/obj/machinery/door/airlock) || in_contents_of(/obj/item/clipboard))
		return UI_INTERACTIVE
	return ..()



/obj/item/paper/can_interact(mob/user)
	if(in_contents_of(/obj/machinery/door/airlock))
		return TRUE
	return ..()


/obj/item/proc/burn_paper_product_attackby_check(obj/item/I, mob/living/user, bypass_clumsy)
	var/ignition_message = I.ignition_effect(src, user)
	if(!ignition_message)
		return
	. = TRUE
	if(!bypass_clumsy && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10) && Adjacent(user))
		user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
							"<span class='userdanger'>You miss [src] and accidentally light yourself on fire!</span>")
		if(user.is_holding(I)) //checking if they're holding it in case TK is involved
			user.dropItemToGround(I)
		user.adjust_fire_stacks(1)
		user.IgniteMob()
		return

	if(user.is_holding(src)) //no TK shit here.
		user.dropItemToGround(src)
	user.visible_message(ignition_message)
	add_fingerprint(user)
	fire_act(I.get_temperature())

/obj/item/paper/attackby(obj/item/P, mob/living/user, params)
	if(burn_paper_product_attackby_check(P, user))
		SStgui.close_uis(src)
		return

	// Enable picking paper up by clicking on it with the clipboard or folder
	if(istype(P, /obj/item/clipboard) || istype(P, /obj/item/folder))
		P.attackby(src, user)
		return
	else if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(length(info) >= MAX_PAPER_LENGTH) // Sheet must have less than 1000 charaters
			to_chat(user, "<span class='warning'>This sheet of paper is full!</span>")
			return
		ui_interact(user)
		return
	else if(istype(P, /obj/item/stamp))
		to_chat(user, "<span class='notice'>You ready your stamp over the paper! </span>")
		ui_interact(user)
		return /// Normaly you just stamp, you don't need to read the thing
	else
		// cut paper?  the sky is the limit!
		ui_interact(user) // The other ui will be created with just read mode outside of this

	return ..()


/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(.)
		info = "[stars(info)]"

/obj/item/paper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/paper),
	)

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	// Update the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet", name)
		ui.open()


/obj/item/paper/ui_static_data(mob/user)
	. = list()
	.["text"] = info
	.["max_length"] = MAX_PAPER_LENGTH
	.["paper_color"] = !color || color == "white" ? "#FFFFFF" : color // color might not be set
	.["paper_state"] = icon_state /// TODO: show the sheet will bloodied or crinkling?
	.["stamps"] = stamps



/obj/item/paper/ui_data(mob/user)
	var/list/data = list()
	data["edit_usr"] = "[user]"

	var/obj/holding = user.get_active_held_item()
	// Use a clipboard's pen, if applicable
	if(istype(loc, /obj/item/clipboard))
		var/obj/item/clipboard/clipboard = loc
		if(clipboard.pen)
			holding = clipboard.pen
	if(istype(holding, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/PEN = holding
		data["pen_font"] = CRAYON_FONT
		data["pen_color"] = PEN.paint_color
		data["edit_mode"] = MODE_WRITING
		data["is_crayon"] = TRUE
		data["stamp_class"] = "FAKE"
		data["stamp_icon_state"] = "FAKE"
	else if(istype(holding, /obj/item/pen))
		var/obj/item/pen/PEN = holding
		data["pen_font"] = PEN.font
		data["pen_color"] = PEN.colour
		data["edit_mode"] = MODE_WRITING
		data["is_crayon"] = FALSE
		data["stamp_class"] = "FAKE"
		data["stamp_icon_state"] = "FAKE"
	else if(istype(holding, /obj/item/stamp))
		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		data["stamp_icon_state"] = holding.icon_state
		data["stamp_class"] = sheet.icon_class_name(holding.icon_state)
		data["edit_mode"] = MODE_STAMPING
		data["pen_font"] = "FAKE"
		data["pen_color"] = "FAKE"
		data["is_crayon"] = FALSE
	else
		data["edit_mode"] = MODE_READING
		data["pen_font"] = "FAKE"
		data["pen_color"] = "FAKE"
		data["is_crayon"] = FALSE
		data["stamp_icon_state"] = "FAKE"
		data["stamp_class"] = "FAKE"
	data["field_counter"] = field_counter
	data["form_fields"] = form_fields

	return data

/obj/item/paper/ui_act(action, params,datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("stamp")
			var/stamp_x = text2num(params["x"])
			var/stamp_y = text2num(params["y"])
			var/stamp_r = text2num(params["r"]) // rotation in degrees
			var/stamp_icon_state = params["stamp_icon_state"]
			var/stamp_class = params["stamp_class"]
			if (isnull(stamps))
				stamps = list()
			if(stamps.len < MAX_PAPER_STAMPS)
				// I hate byond when dealing with freaking lists
				stamps[++stamps.len] = list(stamp_class, stamp_x, stamp_y, stamp_r) /// WHHHHY

				/// This does the overlay stuff
				if (isnull(stamped))
					stamped = list()
				if(stamped.len < MAX_PAPER_STAMPS_OVERLAYS)
					var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[stamp_icon_state]")
					stampoverlay.pixel_x = rand(-2, 2)
					stampoverlay.pixel_y = rand(-3, 2)
					add_overlay(stampoverlay)
					LAZYADD(stamped, stamp_icon_state)

				update_static_data(usr,ui)
				var/obj/O = ui.user.get_active_held_item()
				ui.user.visible_message("<span class='notice'>[ui.user] stamps [src] with \the [O.name]!</span>", "<span class='notice'>You stamp [src] with \the [O.name]!</span>")
			else
				to_chat(usr, pick("You try to stamp but you miss!", "There is no where else you can stamp!"))
			. = TRUE

		if("save")
			var/in_paper = params["text"]
			var/paper_len = length(in_paper)
			field_counter = params["field_counter"] ? text2num(params["field_counter"]) : field_counter

			if(paper_len > MAX_PAPER_LENGTH)
				// Side note, the only way we should get here is if
				// the javascript was modified, somehow, outside of
				// byond.  but right now we are logging it as
				// the generated html might get beyond this limit
				log_paper("[key_name(ui.user)] writing to paper [name], and overwrote it by [paper_len-MAX_PAPER_LENGTH]")
			if(paper_len == 0)
				to_chat(ui.user, pick("Writing block strikes again!", "You forgot to write anthing!"))
			else
				log_paper("[key_name(ui.user)] writing to paper [name]")
				if(info != in_paper)
					to_chat(ui.user, "You have added to your paper masterpiece!");
					info = in_paper
					update_static_data(usr,ui)


			update_appearance()
			. = TRUE

/**
 * Construction paper
 */
/obj/item/paper/construction

/obj/item/paper/construction/Initialize()
	. = ..()
	color = pick("FF0000", "#33cc33", "#ffb366", "#551A8B", "#ff80d5", "#4d94ff")

/**
 * Natural paper
 */
/obj/item/paper/natural/Initialize()
	. = ..()
	color = "#FFF5ED"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null
	show_written_words = FALSE

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/muddy
	icon_state = "scrap_mud"

#undef MAX_PAPER_LENGTH
#undef MAX_PAPER_STAMPS
#undef MAX_PAPER_STAMPS_OVERLAYS
#undef MODE_READING
#undef MODE_WRITING
#undef MODE_STAMPING
