// This file contains all boxes used by the Medical department, or otherwise associated with the task of mob interactions.

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syringes/variety
	name = "syringe variety box"

/obj/item/storage/box/syringes/variety/PopulateContents()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/piercing(src)
	new /obj/item/reagent_containers/syringe/bluespace(src)

/obj/item/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "epipen"

/obj/item/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "epipen"

/obj/item/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker( src )

/obj/item/storage/box/beakers/big
	name = "box of big beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/big/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker/large(src)

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker/bluespace(src)

/obj/item/storage/box/beakers/variety
	name = "beaker variety box"

/obj/item/storage/box/beakers/variety/PopulateContents()
	new /obj/item/reagent_containers/cup/beaker(src)
	new /obj/item/reagent_containers/cup/beaker/bluespace(src)
	new /obj/item/reagent_containers/cup/beaker/large(src)
	new /obj/item/reagent_containers/cup/beaker/meta(src)
	new /obj/item/reagent_containers/cup/beaker/noreact(src)
	new /obj/item/reagent_containers/cup/beaker/plastic(src)

/obj/item/storage/box/medigels
	name = "box of medical gels"
	desc = "A box full of medical gel applicators, with unscrewable caps and precision spray heads."
	illustration = "medgel"

/obj/item/storage/box/medigels/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/medigel( src )

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."
	illustration = "dna"

/obj/item/storage/box/injectors/PopulateContents()
	var/list/items_inside = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/plumbing/PopulateContents()
	var/list/items_inside = list(
		/obj/item/stock_parts/water_recycler = 2,
		/obj/item/stack/ducts/fifty = 1,
		/obj/item/stack/sheet/iron/ten = 1,
		)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/evilmeds
	name = "box of premium medicine"
	desc = "Contains a large number of beakers filled with premium medical supplies. Straight from Interdyne Pharmaceutics!"
	icon_state = "syndiebox"
	illustration = "beaker"

/obj/item/storage/box/evilmeds/PopulateContents()
	var/list/items_inside = list(
		/obj/item/reagent_containers/cup/beaker/meta/omnizine = 1,
		/obj/item/reagent_containers/cup/beaker/meta/sal_acid = 1,
		/obj/item/reagent_containers/cup/beaker/meta/oxandrolone = 1,
		/obj/item/reagent_containers/cup/beaker/meta/pen_acid = 1,
		/obj/item/reagent_containers/cup/beaker/meta/atropine = 1,
		/obj/item/reagent_containers/cup/beaker/meta/salbutamol = 1,
		/obj/item/reagent_containers/cup/beaker/meta/rezadone = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/box/bandages
	name = "box of bandages"
	desc = "A box of DeForest brand gel bandages designed to treat blunt-force trauma."
	icon_state = "brutebox"
	base_icon_state = "brutebox"
	inhand_icon_state = "brutebox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound = 'sound/items/handling/matchbox_pickup.ogg'
	illustration = null
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_CREW * 1.75
	storage_type = /datum/storage/box/bandages

/obj/item/storage/box/bandages/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/stack/medical/bandage(src)

/obj/item/storage/box/bandages/update_icon_state()
	. = ..()
	switch(length(contents))
		if(5)
			icon_state = "[base_icon_state]_f"
		if(3 to 4)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 2)
			icon_state = "[base_icon_state]_almostempty"
		if(0)
			icon_state = base_icon_state

// The actual box
/obj/item/storage/box/triage_cards
	name = "triage card box"
	desc = "A box containing triage cards, used for quickly assessing the severity of a patient's condition."
	custom_price = PAYCHECK_CREW

/obj/item/storage/box/triage_cards/PopulateContents()
	new /obj/item/paper_bin/triage/minor(src)
	new /obj/item/paper_bin/triage/major(src)
	new /obj/item/paper_bin/triage/critical(src)
	new /obj/item/paper_bin/triage/dead(src)
	new /obj/item/pen(src)

// The triage cards themselves
#define SEVERITY_MINIMAL "minimal"
#define SEVERITY_DELAYED "delayed"
#define SEVERITY_IMMEDIATE "immediate"
#define SEVERITY_DEAD "expectant / deceased"

/obj/item/paper/triage
	name = "triage card"
	desc = "A card used to determine the severity of a patient's condition at a glance."
	default_raw_text = "It's so over" // filler text
	var/severity = "none"

/obj/item/paper/triage/Initialize(mapload)
	name = "\"[severity]\" [name]"
	default_raw_text = {"
		<center>
			<h2>TAG - TRIAGE</h2>
		</center>
		<b>Name:</b><br>
		\[______________________________\]<br>
		<center>
			<h3>- [uppertext(severity)] -<h3>
			<h4>[severity_to_subtitle()]</h4>
		</center>
		<b>Injuries:</b><br>
		\[________________________________________\]<br>
		\[________________________________________\]<br>
		\[________________________________________\]<br>
		\[________________________________________\]<br>
		\[________________________________________\]<br>
	"}
	return ..()

/obj/item/paper/triage/proc/severity_to_subtitle()
	switch(severity)
		if(SEVERITY_DEAD)
			return "NO RESPIRATION"
		if(SEVERITY_IMMEDIATE)
			return "LIFE THREATENING"
		if(SEVERITY_DELAYED)
			return "SERIOUS INJURIES - NOT LIFE THREATENING"
		if(SEVERITY_MINIMAL)
			return "MINOR INJURIES - WALKING WOUNDED"
	return "UNKNOWN"

/obj/item/paper/triage/examine(mob/user)
	. = ..()
	switch(severity)
		if(SEVERITY_DEAD)
			. += span_notice("This card indicates that the patient is deceased or is not expected to survive.")
		if(SEVERITY_IMMEDIATE)
			. += span_notice("This card indicates that the patient is in a critical condition and requires immediate attention.")
		if(SEVERITY_DELAYED)
			. += span_notice("This card indicates that the patient is seriously injured, but not in immediate danger.")
		if(SEVERITY_MINIMAL)
			. += span_notice("This card indicates that the patient is only slightly injured.")

	. += span_smallnoticeital("There is a guide to triage on the back of the card, if you <i>look closer</i>.")

/obj/item/paper/triage/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>The back of [src] has a guide to performing triage:</i>")
	. += "&bull; \"Is the victim walking and can respond to simple orders?\" If so, mark as <b>minimal</b>."
	. += "&bull; \"Has the victim stopped breathing entirely (without even gasping for air)?\" If so, mark as <b>expectant / deceased</b>."
	. += "&bull; \"Is the victim bleeding, failing to follow simple commands, lacking a pulse, having difficulties breathing?\" If so, mark as <b>immediate</b>."
	. += "&bull; Otherwise, mark as <b>delayed</b>."

/obj/item/paper/triage/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	var/px = text2num(LAZYACCESS(modifiers, ICON_X))
	var/py = text2num(LAZYACCESS(modifiers, ICON_Y))

	if(isnull(px) || isnull(py))
		return NONE

	user.do_attack_animation(interacting_with, used_item = src)
	interacting_with.balloon_alert(user, "card attached")
	interacting_with.AddComponent(/datum/component/sticker, src, get_dir(interacting_with, src), px, py)
	return ITEM_INTERACT_SUCCESS

/obj/item/paper/triage/minor
	color = COLOR_ASSEMBLY_GREEN
	severity = SEVERITY_MINIMAL

/obj/item/paper/triage/major
	color = COLOR_ASSEMBLY_YELLOW
	severity = SEVERITY_DELAYED

/obj/item/paper/triage/critical
	color = COLOR_ASSEMBLY_RED
	severity = SEVERITY_IMMEDIATE

/obj/item/paper/triage/dead
	color = COLOR_ASSEMBLY_BLACK
	severity = SEVERITY_DEAD

// Paper bin to store a lot of triage cards. Goes away when empty.
/obj/item/paper_bin/triage
	name = "triage card stack"
	desc = "A stack of triage cards for quickly assessing the severity of a patient's condition."
	icon_state = ""
	bin_overlay_string = ""
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "paper"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	total_paper = 20

/obj/item/paper_bin/triage/fire_act(exposed_temperature, exposed_volume)
	total_paper -= round(exposed_volume / 25, 1)
	if(total_paper <= 0)
		qdel(src)
	else
		update_appearance()

/obj/item/paper_bin/triage/dump_contents(atom/droppoint, collapse = FALSE)
	. = ..()
	if(total_paper <= 0)
		qdel(src)

/obj/item/paper_bin/triage/remove_paper(amount)
	. = ..()
	if(total_paper <= 0)
		qdel(src)

/obj/item/paper_bin/triage/Exited(atom/movable/gone, direction)
	. = ..()
	if(total_paper <= 0 && !QDELING(src))
		qdel(src)

/obj/item/paper_bin/triage/minor
	papertype = /obj/item/paper/triage/minor

/obj/item/paper_bin/triage/major
	papertype = /obj/item/paper/triage/major

/obj/item/paper_bin/triage/critical
	papertype = /obj/item/paper/triage/critical

/obj/item/paper_bin/triage/dead
	papertype = /obj/item/paper/triage/dead

#undef SEVERITY_MINIMAL
#undef SEVERITY_DELAYED
#undef SEVERITY_IMMEDIATE
#undef SEVERITY_DEAD
