/*
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */
/**
 ** Paper is now using markdown (like in github pull notes) for ALL rendering
 ** so we do loose a bit of functionality but we gain in easy of use of
 ** paper and getting rid of that crashing bug
 **/
/obj/item/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	inhand_icon_state = "paper"
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
	var/info

	/// The (text for the) stamps on the paper.
	var/stamps
	var/list/stamped

	/// This REALLY should be a componenet.  Basicly used during, april fools
	/// to honk at you
	var/rigged = 0
	var/spam_flag = 0
	///
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0

	var/ui_x = 600
	var/ui_y = 800
	/// When a piece of paper cannot be edited, this makes it mutable
	var/finalized = FALSE
	/// We MAY be edited, mabye we are just looking at it or something.
	var/readonly = FALSE
	/// Color of the pin that wrote on this paper
	var/pen_color = "black"

/**
 ** This proc copies this sheet of paper to a new
 ** sheet,  Makes it nice and easy for carbon and
 ** the copyer machine
 **/
/obj/item/paper/proc/copy()
	var/obj/item/paper/N = new(arglist(args))
	N.info = info
	N.pen_color = pen_color
	N.color = color
	N.finalized = TRUE
	N.update_icon_state()
	N.stamps = stamps
	N.stamped = stamped.Copy()
	copy_overlays(N, TRUE)
	return N

/**
 ** This proc sets the text of the paper and updates the
 ** icons.  You can modify the pen_color after if need
 ** be.
 **/
/obj/item/paper/proc/setText(text, read_only = TRUE)
	readonly = read_only
	info = text
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
	update_icon_state()


/obj/item/paper/update_icon_state()
	if(resistance_flags & ON_FIRE)
		icon_state = "paper_onfire"
		return
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/ui_base_html(html)
	/// This might change in a future PR
	var/datum/asset/spritesheet/assets = get_asset_datum(/datum/asset/spritesheet/simple/paper)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())


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
	readonly = TRUE		/// Assume we are just reading it
	if(rigged && (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)
			addtimer(CALLBACK(src, .proc/reset_spamflag), 20)
	. = ..()


/obj/item/paper/proc/clearpaper()
	finalized = FALSE
	info = null
	stamps = null
	LAZYCLEARLIST(stamped)
	cut_overlays()
	update_icon_state()


/obj/item/paper/can_interact(mob/user)
	if(!..())
		return FALSE
	if(resistance_flags & ON_FIRE)		/// Are we on fire?  Hard ot read if so
		return FALSE
	if(user.is_blind())					/// Even harder to read if your blind...braile? humm
		return FALSE
	return user.can_read(src)			// checks if the user can read.


/obj/item/paper/attackby(obj/item/P, mob/living/carbon/human/user, params)
	readonly = TRUE		/// Assume we are just reading it
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(finalized)
			to_chat(user, "<span class='warning'>This sheet of paper has already been written too!</span>")
			return
		readonly = FALSE	/// Nope we are going to write stuff
		/// should a crayon be in the same subtype as a pen?  How about a brush or charcoal?
		if(istype(P, /obj/item/pen))
			var/obj/item/pen/PEN = P
			pen_color = PEN.colour
		else
			var/obj/item/toy/crayon/PEN = P
			pen_color = PEN.crayon_color
		ui_interact(user)
		return
	else if(istype(P, /obj/item/stamp))

		if(!in_range(src, user))
			return

		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		if (isnull(stamps))
			stamps = sheet.css_tag()
		stamps += sheet.icon_tag(P.icon_state)
		var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[P.icon_state]")
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		LAZYADD(stamped, P.icon_state)
		add_overlay(stampoverlay)

		to_chat(user, "<span class='notice'>You stamp the paper with your rubber stamp.</span>")

		return /// Normaly you just stamp, you don't need to read the thing
	if(P.get_temperature())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	. = ..()

/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		add_overlay("paper_onfire_overlay")
		info = "[stars(info)]"


/obj/item/paper/extinguish()
	..()
	cut_overlay("paper_onfire_overlay")

/obj/item/paper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		assets.send(user)
		/// The x size is because we double the width for the editor
		ui = new(user, src, ui_key, "PaperSheet", name, 400, 600, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/paper/ui_close(mob/user)
	var/datum/tgui/ui = SStgui.try_update_ui(user, src, "main");
	if(ui)
		ui.close()

/obj/item/paper/proc/ui_update()
	var/datum/tgui/ui = SStgui.try_update_ui(usr, src, "main");
	if(ui)
		ui.update()

/obj/item/paper/ui_data(mob/user)
	var/list/data = list()
	data["text"] = info
	data["paper_state"] = icon_state	/// TODO: show the sheet will bloodied or crinkling
	data["pen_color"] = pen_color
	data["paper_color"] = color || "white"	// color might not be set
	data["edit_sheet"] = readonly || finalized ? FALSE : TRUE
	/// data["stamps_info"] = list(stamp_info)
	data["stamps"] = stamps
	return data


/obj/item/paper/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("save")
			var/in_paper = params["text"]
			if(length(in_paper) > 0 && length(in_paper) < 1000) // Sheet must have less than 1000 charaters
				info = in_paper
				finalized = TRUE		// once you have writen to a sheet you cannot write again
				to_chat(usr, "You have finished your paper masterpiece!");
				ui_update()
			else
				to_chat(usr, pick("Writing block strikes again!", "You forgot to write anthing!"))
				ui_close(usr)
			update_icon()
			. = TRUE



/*
 * Construction paper
 */

/obj/item/paper/construction

/obj/item/paper/construction/Initialize()
	. = ..()
	color = pick("FF0000", "#33cc33", "#ffb366", "#551A8B", "#ff80d5", "#4d94ff")

/*
 * Natural paper
 */

/obj/item/paper/natural/Initialize()
	. = ..()
	color = "#FFF5ED"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null

/obj/item/paper/crumpled/update_icon_state()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/muddy
	icon_state = "scrap_mud"
