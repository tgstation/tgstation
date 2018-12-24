/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/empty = FALSE

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/regular/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/firstaid/regular/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/ancient
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/ancient/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment= 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/fire
	name = "burn treatment kit"
	desc = "A specialized medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/storage/firstaid/fire/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins rubbing \the [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to start a fire!</span>")
	return FIRELOSS

/obj/item/storage/firstaid/fire/Initialize(mapload)
	. = ..()
	icon_state = pick("ointment","firefirstaid")

/obj/item/storage/firstaid/fire/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 3,
		/obj/item/reagent_containers/pill/oxandrolone = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/toxin
	name = "toxin treatment kit"
	desc = "Used to treat toxic blood content and radiation poisoning."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/storage/firstaid/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

/obj/item/storage/firstaid/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/storage/pill_bottle/charcoal = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation treatment kit"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/storage/firstaid/o2/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins hitting [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/storage/firstaid/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/salbutamol = 4,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A first aid kit for when you get toolboxed."
	icon_state = "brute"
	item_state = "firstaid-brute"

/obj/item/storage/firstaid/brute/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins beating [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/firstaid/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/styptic = 4,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/advanced
	name = "advanced first aid kit"
	desc = "An advanced kit to help deal with advanced wounds."
	icon_state = "radfirstaid"
	item_state = "firstaid-rad"
	custom_premium_price = 600

/obj/item/storage/firstaid/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 3,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/penacid = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/tactical
	name = "combat medical kit"
	desc = "I hope you've got insurance."
	icon_state = "bezerk"

/obj/item/storage/firstaid/tactical/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/tactical/PopulateContents()
	if(empty)
		return
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/reagent_containers/pill/patch/styptic(src)
	new /obj/item/reagent_containers/pill/patch/styptic(src)
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	new /obj/item/clothing/glasses/hud/health/night(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pill_bottle/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.click_gather = TRUE
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/pill, /obj/item/dice))

/obj/item/storage/pill_bottle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (TOXLOSS)

/obj/item/storage/pill_bottle/charcoal
	name = "bottle of charcoal pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/charcoal/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/epinephrine(src)

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mutadone(src)

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mannitol(src)

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/stimulant(src)

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/patch/styptic(src)

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a badly drawn thing with the shape of a mushroom."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label says 'gotta go fast'."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aranesp(src)

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psicodine(src)

/obj/item/storage/pill_bottle/happiness
	name = "happiness pill bottle"
	desc = "The label is long gone, in its place an 'H' written with a marker."

/obj/item/storage/pill_bottle/happiness/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happiness(src)

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid"
	desc = "Contains pills to expunge radioation and toxins"

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/penacid(src)
