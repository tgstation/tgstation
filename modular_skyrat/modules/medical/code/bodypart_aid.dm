#define SELF_AID_REMOVE_DELAY 5 SECONDS
#define OTHER_AID_REMOVE_DELAY 2 SECONDS

/datum/bodypart_aid
	var/name
	/// Keeping track of how damaged our aid is from external things, such as hits, it will break when it reaches 0
	var/integrity = 2
	/// To which bodypart we're attached to
	var/obj/item/bodypart/bodypart
	/// Which item do we get when we rip this off, while its in pristine condition
	var/stack_to_drop
	/// Suffix for our used overlay. The suffix is the bodypart zone, and "_digitigrade" for some legs. If this is null then it wont make an overlay. Gauzes are rendered before splints
	var/overlay_prefix
	/// Bodypart is [this_prefix] with get_description()
	var/desc_prefix

/datum/bodypart_aid/Topic(href, href_list)
	. = ..()
	if(href_list["remove"])
		if(!bodypart.owner)
			return
		if(!iscarbon(usr))
			return
		if(!in_range(usr, bodypart.owner))
			return
		var/mob/living/carbon/C = usr
		var/self = (C == bodypart.owner)
		C.visible_message("<span class='notice'>[C] begins removing [name] from [self ? "[bodypart.owner.p_their(TRUE)]" : "[bodypart.owner]'s" ] [bodypart.name]...</span>", "<span class='notice'>You begin to remove [name] from [self ? "your" : "[bodypart.owner]'s"] [bodypart.name]...</span>")
		if(!do_after(C, (self ? SELF_AID_REMOVE_DELAY : OTHER_AID_REMOVE_DELAY), target=bodypart.owner))
			return
		if(QDELETED(src))
			return
		C.visible_message("<span class='notice'>[C] removes [name] from [self ? "[bodypart.owner.p_their(TRUE)]" : "[bodypart.owner]'s" ] [bodypart.name].</span>", "<span class='notice'>You remove [name] from [self ? "your" : "[bodypart.owner]'s" ] [bodypart.name].</span>")
		var/obj/item/gotten = rip_off()
		if(gotten && !C.put_in_hands(gotten))
			gotten.forceMove(get_turf(C))

/datum/bodypart_aid/New(obj/item/bodypart/BP)
	//'bodypart == BP' is set in subtypes to ensure some proper signals and behaviours
	if(overlay_prefix && bodypart.owner)
		bodypart.owner.update_bandage_overlays()

/datum/bodypart_aid/Destroy()
	if(overlay_prefix && bodypart.owner)
		bodypart.owner.update_bandage_overlays()
	bodypart = null
	..()

/**
 * take_damage() called when the bandage gets damaged
 *
 * This proc will subtract integrity and delete the bandage with a to_chat message to whoever was bandaged
 *
 */

/datum/bodypart_aid/proc/take_damage()
	integrity--
	if(integrity <= 0)
		if(bodypart.owner)
			to_chat(bodypart.owner, "<span class='warning'>The [name] on your [bodypart.name] tears and falls off!</span>")
		qdel(src)

/**
 * rip_off() called when someone rips it off
 *
 * It will return the bandage if it's considered pristine
 *
 */

/datum/bodypart_aid/proc/rip_off()
	if(is_pristine())
		. = new stack_to_drop(null, 1)
	qdel(src)

/**
 * get_description() called by examine procs
 *
 * It will returns a description of the bandage
 *
 */

/datum/bodypart_aid/proc/get_description()
	return "[name]"

/**
 * is_pristine() called by rip_off()
 *
 * Used to determine whether the bandage can be re-used and won't qdel itself
 *
 */

/datum/bodypart_aid/proc/is_pristine()
	return (integrity == initial(integrity))

/datum/bodypart_aid/splint
	name = "splint"
	overlay_prefix = "splint"
	desc_prefix = "fastened"
	stack_to_drop = /obj/item/stack/medical/splint
	/// How effective are we in keeping the bodypart rigid
	var/splint_factor = 0.3
	/// Whether the splint prevents the limb from being disabled, with a ruptured tendon or a shattered bone
	var/helps_disabled = TRUE
	/// Total condition of our splint, the more we use it the more it gets looser
	var/sling_condition = 5

/datum/bodypart_aid/splint/get_description()
	var/desc
	switch(sling_condition)
		if(0 to 1.25)
			desc = "barely holding"
		if(1.25 to 2.75)
			desc = "loose"
		if(2.75 to 4)
			desc = "rigid"
		if(4 to INFINITY)
			desc = "tight"
	desc += " [name]"
	return desc

/datum/bodypart_aid/splint/Destroy()
	SEND_SIGNAL(bodypart, COMSIG_BODYPART_SPLINT_DESTROYED)
	bodypart.current_splint = null
	return ..()

/datum/bodypart_aid/splint/New(obj/item/bodypart/BP)
	bodypart = BP
	BP.current_splint = src
	SEND_SIGNAL(BP, COMSIG_BODYPART_SPLINTED, src)
	..()

/datum/bodypart_aid/splint/improvised
	name = "improvised splint"
	splint_factor = 0.6
	helps_disabled= FALSE
	stack_to_drop = /obj/item/stack/medical/splint/improvised
	overlay_prefix = "splint_improv"

/datum/bodypart_aid/splint/tribal
	name = "tribal splint"
	splint_factor = 0.5
	stack_to_drop = /obj/item/stack/medical/splint/tribal
	overlay_prefix = "splint_tribal"

/datum/bodypart_aid/gauze
	name = "gauze"
	stack_to_drop = /obj/item/stack/medical/gauze
	overlay_prefix = "gauze"
	desc_prefix = "bandaged"
	/// How much more can we absorb
	var/absorption_capacity = 5
	/// How fast do we absorb
	var/absorption_rate = 0.12
	/// How much does the gauze help with keeping infections clean
	var/sanitisation_factor = 0.4
	/// How much sanitisation we've got after we become fairly stained and worn
	var/sanitisation_factor_stained = 0.8
	/// Is it blood stained? For description
	var/blood_stained = FALSE
	/// Is it pus stained? For description
	var/pus_stained = FALSE

/datum/bodypart_aid/gauze/get_description()
	var/desc
	switch(absorption_capacity)
		if(0 to 1.25)
			desc = "nearly ruined"
		if(1.25 to 2.75)
			desc = "badly worn"
		if(2.75 to 4)
			desc = "slightly used"
		if(4 to INFINITY)
			desc = "clean"
	if(blood_stained)
		desc += ", bloodied"
	if(pus_stained)
		desc += ", pus stained"
	desc += " [name]"
	return desc

/datum/bodypart_aid/gauze/New(obj/item/bodypart/BP)
	bodypart = BP
	BP.current_gauze = src
	SEND_SIGNAL(BP, COMSIG_BODYPART_GAUZED, src)
	..()

/datum/bodypart_aid/gauze/Destroy()
	SEND_SIGNAL(bodypart, COMSIG_BODYPART_GAUZE_DESTROYED)
	bodypart.current_gauze = null
	return ..()

/datum/bodypart_aid/gauze/is_pristine()
	. = ..()
	if(.)
		return (absorption_capacity == initial(absorption_capacity))

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandage won't help our wounds.
 * When the bandage is left with a low amount of absorption, it'll notify user and act worse as a sanitiser for infections
 * Returns TRUE if the bandage absorbed anything, FALSE if it's fully stained.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 * * type - Is it blood or pus we're being stained with? GAUZE_STAIN_BLOOD, GAUZE_STAIN_PUS defines from wounds.dm
 */

/datum/bodypart_aid/gauze/proc/seep_gauze(amount, type)
	if(absorption_capacity > 0)
		. = TRUE
		absorption_capacity -= amount
	else
		return FALSE
	//If our remaining absorption capacity is low, make so blood and pus stains show
	if(absorption_capacity < 2)
		sanitisation_factor = sanitisation_factor_stained
		if(type == GAUZE_STAIN_BLOOD && !blood_stained)
			blood_stained = TRUE
			if(bodypart.owner)
				to_chat(bodypart.owner, "<span class='warning'>The [name] on your [bodypart.name] [pick(list("pools", "trickles", "seeps"))] with blood.</span>")
		else if(type == GAUZE_STAIN_PUS && !pus_stained)
			pus_stained = TRUE
			if(bodypart.owner)
				to_chat(bodypart.owner, "<span class='warning'>The [name] on your [bodypart.name] [pick(list("pools", "trickles", "seeps"))] with pus.</span>")

/datum/bodypart_aid/gauze/improvised
	name = "improvised gauze"
	stack_to_drop = /obj/item/stack/medical/gauze/improvised
	absorption_rate = 0.09
	absorption_capacity = 3
