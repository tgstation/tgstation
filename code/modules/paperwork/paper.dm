/**
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */
#define MAX_PAPER_LENGTH 5000
#define MAX_PAPER_STAMPS 30		// Too low?
#define MAX_PAPER_STAMPS_OVERLAYS 4
#define MODE_READING 0
#define MODE_WRITING 1
#define MODE_STAMPING 2

/**
 * This is a custom ui state.  All it really does is keep track of pen
 * being used and if they are editing it or not.  This way we can keep
 * the data with the ui rather than on the paper
 */
/datum/ui_state/default/paper_state
	/// What edit mode we are in and who is
	/// writing on it right now
	var/edit_mode = MODE_READING
	/// Setup for writing to a sheet
	var/pen_color = "black"
	var/pen_font = ""
	var/is_crayon = FALSE
	/// Setup for stamping a sheet
	// Why not the stamp obj?  I have no idea
	// what happens to states out of scope so
	// don't want to put instances in this
	var/stamp_icon_state = ""
	var/stamp_name = ""
	var/stamp_class = ""

/datum/ui_state/default/paper_state/proc/copy_from(datum/ui_state/default/paper_state/from)
	switch(from.edit_mode)
		if(MODE_READING)
			edit_mode = MODE_READING
		if(MODE_WRITING)
			edit_mode = MODE_WRITING
			pen_color = from.pen_color
			pen_font = from.pen_font
			is_crayon = from.is_crayon
		if(MODE_STAMPING)
			edit_mode = MODE_STAMPING
			stamp_icon_state = from.stamp_icon_state
			stamp_class = from.stamp_class
			stamp_name = from.stamp_name

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
	var/list/stamps			/// Positioning for the stamp in tgui
	var/list/stamped		/// Overlay info

	/// This REALLY should be a componenet.  Basicly used during, april fools
	/// to honk at you
	var/rigged = 0
	var/spam_flag = 0

	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0

	// Ok, so WHY are we caching the ui's?
	// Since we are not using autoupdate we
	// need some way to update the ui's of
	// other people looking at it and if
	// its been updated.  Yes yes, lame
	// but canot be helped.  However by
	// doing it this way, we can see
	// live updates and have multipule
	// people look at it
	var/list/viewing_ui = list()

	/// When the sheet can be "filled out"
	/// This is an associated list
	var/list/form_fields = list()
	var/field_counter = 1

/obj/item/paper/Destroy()
	close_all_ui()
	stamps = null
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
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	update_icon()

/obj/item/paper/update_icon_state()
	if(info && show_written_words)
		icon_state = "[initial(icon_state)]_words"

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, "<span class='warning'>You cut yourself on the paper! Ahhhh! Ahhhhh!</span>")
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)

/obj/item/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/// ONLY USED FOR APRIL FOOLS
/obj/item/paper/proc/reset_spamflag()
	spam_flag = FALSE

/obj/item/paper/attack_self(mob/user)
	if(rigged && (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)
			addtimer(CALLBACK(src, .proc/reset_spamflag), 20)
	. = ..()

/obj/item/paper/proc/clearpaper()
	info = ""
	stamps = null
	LAZYCLEARLIST(stamped)
	cut_overlays()
	update_icon_state()

/obj/item/paper/examine_more(mob/user)
	ui_interact(user)
	return list("<span class='notice'><i>You try to read [src]...</i></span>")

/obj/item/paper/can_interact(mob/user)
	if(!..())
		return FALSE
	// Are we on fire?  Hard ot read if so
	if(resistance_flags & ON_FIRE)
		return FALSE
	// Even harder to read if your blind...braile? humm
	if(user.is_blind())
		return FALSE
	// checks if the user can read.
	return user.can_read(src)

/**
 * This creates the ui, since we are using a custom state but not much else
 * just makes it easyer to make it.
 */
/obj/item/paper/proc/create_ui(mob/user, datum/ui_state/default/paper_state/state)
	ui_interact(user, state = state)

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
		close_all_ui()
		return

	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(length(info) >= MAX_PAPER_LENGTH) // Sheet must have less than 1000 charaters
			to_chat(user, "<span class='warning'>This sheet of paper is full!</span>")
			return

		var/datum/ui_state/default/paper_state/state = new
		state.edit_mode = MODE_WRITING
		// should a crayon be in the same subtype as a pen?  How about a brush or charcoal?
		// TODO:  Convert all writing stuff to one type, /obj/item/art_tool maybe?
		state.is_crayon = istype(P, /obj/item/toy/crayon);
		if(state.is_crayon)
			var/obj/item/toy/crayon/PEN = P
			state.pen_font = CRAYON_FONT
			state.pen_color = PEN.paint_color
		else
			var/obj/item/pen/PEN = P
			state.pen_font = PEN.font
			state.pen_color = PEN.colour

		create_ui(user, state)
		return
	else if(istype(P, /obj/item/stamp))

		var/datum/ui_state/default/paper_state/state = new
		state.edit_mode = MODE_STAMPING	// we are read only becausse the sheet is full
		state.stamp_icon_state = P.icon_state

		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		state.stamp_class = sheet.icon_class_name(P.icon_state)

		to_chat(user, "<span class='notice'>You ready your stamp over the paper! </span>")

		create_ui(user, state)
		return /// Normaly you just stamp, you don't need to read the thing
	else
		// cut paper?  the sky is the limit!
		var/datum/ui_state/default/paper_state/state = new
		state.edit_mode = MODE_READING
		create_ui(user, state)	// The other ui will be created with just read mode outside of this

	return ..()


/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(.)
		info = "[stars(info)]"

/obj/item/paper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/paper),
	)

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui,
		datum/ui_state/default/paper_state/state)
	// Update the state
	ui = ui || SStgui.get_open_ui(user, src)
	if(ui && state)
		var/datum/ui_state/default/paper_state/current_state = ui.state
		current_state.copy_from(state)
	// Update the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet", name)
		state = new
		ui.set_state(state)
		ui.set_autoupdate(FALSE)
		viewing_ui[user] = ui
		ui.open()

/obj/item/paper/ui_close(mob/user)
	/// close the editing window and change the mode
	viewing_ui[user] = null
	. = ..()

// Again, we have to do this as autoupdate is off
/obj/item/paper/proc/update_all_ui()
	for(var/datum/tgui/ui in viewing_ui)
		ui.process(force = TRUE)

// Again, we have to do this as autoupdate is off
/obj/item/paper/proc/close_all_ui()
	for(var/datum/tgui/ui in viewing_ui)
		ui.close()
	viewing_ui = list()

/obj/item/paper/ui_data(mob/user)
	var/list/data = list()

	var/datum/tgui/ui = viewing_ui[user]
	var/datum/ui_state/default/paper_state/state = ui.state

	// Should all this go in static data and just do a forced update?
	data["text"] = info
	data["max_length"] = MAX_PAPER_LENGTH
	data["paper_state"] = icon_state	/// TODO: show the sheet will bloodied or crinkling?
	data["paper_color"] = !color || color == "white" ? "#FFFFFF" : color	// color might not be set
	data["stamps"] = stamps

	data["edit_mode"] = state.edit_mode
	data["edit_usr"] = "[ui.user]";

	// pen info for editing
	data["is_crayon"] = state.is_crayon
	data["pen_font"] = state.pen_font
	data["pen_color"] = state.pen_color
	// stamping info for..stamping
	data["stamp_class"] = state.stamp_class

	data["field_counter"] = field_counter
	data["form_fields"] = form_fields

	return data

/obj/item/paper/ui_act(action, params, datum/tgui/ui, datum/ui_state/default/paper_state/state)
	if(..())
		return
	switch(action)
		if("stamp")
			var/stamp_x = text2num(params["x"])
			var/stamp_y = text2num(params["y"])
			var/stamp_r = text2num(params["r"])	// rotation in degrees

			if (isnull(stamps))
				stamps = new/list()
			if(stamps.len < MAX_PAPER_STAMPS)
				// I hate byond when dealing with freaking lists
				stamps += list(list(state.stamp_class, stamp_x,  stamp_y,stamp_r))	/// WHHHHY

				/// This does the overlay stuff
				if (isnull(stamped))
					stamped = new/list()
				if(stamped.len < MAX_PAPER_STAMPS_OVERLAYS)
					var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[state.stamp_icon_state]")
					stampoverlay.pixel_x = rand(-2, 2)
					stampoverlay.pixel_y = rand(-3, 2)
					add_overlay(stampoverlay)
					LAZYADD(stamped, state.stamp_icon_state)

				ui.user.visible_message("<span class='notice'>[ui.user] stamps [src] with [state.stamp_name]!</span>", "<span class='notice'>You stamp [src] with [state.stamp_name]!</span>")
			else
				to_chat(usr, pick("You try to stamp but you miss!", "There is no where else you can stamp!"))

			update_all_ui()
			. = TRUE

		if("save")
			var/in_paper = params["text"]
			var/paper_len = length(in_paper)
			var/list/fields = params["form_fields"]
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

			for(var/key in fields)
				form_fields[key] = fields[key];


			update_all_ui()
			update_icon()

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

/obj/item/paper/crumpled/update_icon_state()
	return

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
