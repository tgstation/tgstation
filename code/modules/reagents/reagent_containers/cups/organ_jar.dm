// The organ jar - a 120u beaker that can hold a single organ
/obj/item/reagent_containers/cup/beaker/organ_jar
	name = "organ jar"
	desc = "A large shatter-resistant jar, unwieldy for the sake of chemistry, but big enough to put an organ inside of."
	icon_state = "organ_jar"
	fill_icon_state = "organ_jar"
	// The plastic makes it more shatter-proof!
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT*1.25, /datum/material/plastic=SHEET_MATERIAL_AMOUNT * 1.5)
	volume = 120
	// Difficult to transfer from in small amounts (to discourage using it for things besides organs)
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(20, 40, 60, 120)
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)
	w_class = WEIGHT_CLASS_SMALL // Organs are small by default, so the jar should be at least small as well
	/// The organ that is currently inside the jar
	var/obj/item/organ/held_organ = null
	/// Whether the jar is filled to capacity with formaldehyde, preserving any organ inside
	var/full_of_formaldehyde = FALSE

/obj/item/reagent_containers/cup/beaker/organ_jar/examine(mob/user)
	. = ..()
	. += span_info("Any organ inside the jar will be preserved if it is entirely filled with formaldehyde.")
	if(held_organ && held_organ.GetComponent(/datum/component/ghostrole_on_revive))
		. += span_smallnoticeital("The brain is twitching...") // Guaranteed to be a brain if it has that component

/obj/item/reagent_containers/cup/beaker/organ_jar/Destroy(force)
	. = ..()
	QDEL_NULL(held_organ)

// Alt click lets you take the organ out, if it's present
/obj/item/reagent_containers/cup/beaker/organ_jar/click_alt(mob/user)
	if(held_organ)
		balloon_alert(user, "removed [held_organ]")
		user.put_in_hands(held_organ)
		held_organ.organ_flags &= ~ORGAN_FROZEN
		held_organ = null
		name = initial(name)
		desc = initial(desc)
		update_appearance()
		return CLICK_ACTION_SUCCESS
	return  ..()

// Clicking on the jar with an organ lets you put the organ inside, if there isn't one already
// Otherwise it should act like a normal bottle
/obj/item/reagent_containers/cup/beaker/organ_jar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/organ))
		return
	if(held_organ)
		balloon_alert(user, "the jar already contains [held_organ]")
		return  ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "inserted [tool]")
	held_organ = tool
	name = "[tool.name] in a jar"
	desc = "A jar with \the [tool] inside it."
	check_organ_freeze()
	update_appearance()
	return ITEM_INTERACT_SUCCESS

// Organ icon size goes from 32 to this
#define JAR_INNER_ICON_SIZE 24

/obj/item/reagent_containers/cup/beaker/organ_jar/update_overlays()
	. = ..()
	// Draw the organ icon inside the jar, if present
	if(!isnull(held_organ))
		var/image/organ_img = image(held_organ, src, layer = FLOAT_LAYER)
		var/list/icon_dimensions = get_icon_dimensions(held_organ.icon)
		organ_img.transform = organ_img.transform.Scale( // Make it smaller so it fits
			JAR_INNER_ICON_SIZE / icon_dimensions["width"],
			JAR_INNER_ICON_SIZE / icon_dimensions["height"],
		)
		organ_img.pixel_z -= 3
		organ_img.plane = FLOAT_PLANE
		organ_img.blend_mode = BLEND_INSET_OVERLAY
		. += organ_img

#undef JAR_INNER_ICON_SIZE

/obj/item/reagent_containers/cup/beaker/organ_jar/on_reagent_change(datum/reagents/holder, ...)
	. = ..()
	full_of_formaldehyde = !!holder.has_reagent(/datum/reagent/toxin/formaldehyde, amount = holder.maximum_volume)
	check_organ_freeze()

// Proc that stops the held organ from rotting if the jar is full of formaldehyde
/obj/item/reagent_containers/cup/beaker/organ_jar/proc/check_organ_freeze()
	if(isnull(held_organ))
		return
	if(full_of_formaldehyde)
		held_organ.organ_flags |= ORGAN_FROZEN
	else
		held_organ.organ_flags &= ~ORGAN_FROZEN

// Defines for note flavor types
// One of these is picked whenever a brain in a jar is created
// A note with a "stuck in mail" flavor will appear upon examining more
#define NOTE_STUCK_IN_MAIL 0
// A note with a "gift from a fellow morbid researcher" flavor will appear upon examining more
#define NOTE_MORBID_GIFT 1
// A note with a "discarded brain from the recovered crew" flavor will appear upon examining more
#define NOTE_DISCARDED_LOST_CREW 2

/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar
	// Which note to show when someone examins more
	var/note_type = NOTE_STUCK_IN_MAIL

/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar/examine(mob/user)
	. = ..()
	. += span_notice("<i>You can see a note attached to the bottom..</i>")

/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar/examine_more(mob/user)
	. = ..()
	// Flavor for why the brain is scarred
	switch(note_type)
		if(NOTE_STUCK_IN_MAIL)
			. += span_notice("According to the note, this jar must've been stuck in the mail for at least 50 years...")
		if(NOTE_MORBID_GIFT)
			. += span_notice("It reads...")
			. += span_notice("Greetings, XXX. I stumbled upon a hermit in my travels, \
			whose quirks immediately piqued my interest. I'm sure his brain will be as useful to your research \
			as it has been to mine. Signed, YYY.")
		if(NOTE_DISCARDED_LOST_CREW)
			. += span_notice("It reads...")
			. += span_notice("Hey, XXX. Management wanted me to discard this poor schmuck's brain, \
			claiming it's 'too damaged to viably recover', so I figured I might as well throw you a bone. \
			I know you like these sorts of things. Signed, ZZZ.")


/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar/Initialize(mapload)
	. = ..()
	note_type = rand(0, 2) // Attach a random note to it
	var/obj/item/organ/brain/scarred_brain = new() // Make a new brain
	// Make it revivable, scar it if revival is successful
	scarred_brain.AddComponent( \
		/datum/component/ghostrole_on_revive,\
		refuse_revival_if_failed = TRUE, \
		on_successful_revive = CALLBACK(src, PROC_REF(handle_revival), scarred_brain) \
		)
	held_organ = scarred_brain // Put the brain inside the jar
	reagents.add_reagent(/datum/reagent/toxin/formaldehyde, reagents.maximum_volume) // Fill the jar with formaldehyde
	name = "brain in a jar" // Set a custom name&description
	desc = "A brain in a jar. You can see it twitching..."
	update_appearance()

// All this does is add a random special brain trauma + add recovered crew antag datum for logging
/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar/proc/handle_revival(obj/item/organ/brain/brain_to_scar)
	brain_to_scar.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_ABSOLUTE, natural_gain = TRUE)
	var/mob/living/carbon/human/owner = brain_to_scar.owner
	owner.mind.add_antag_datum(/datum/antagonist/recovered_crew) // for tracking mostly (c)

#undef NOTE_STUCK_IN_MAIL
#undef NOTE_MORBID_GIFT
#undef NOTE_DISCARDED_LOST_CREW
