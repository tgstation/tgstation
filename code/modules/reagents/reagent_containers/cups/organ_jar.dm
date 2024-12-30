// The organ jar - a 150u bottle that can hold a single organ
/obj/item/reagent_containers/cup/organ_jar
	name = "organ jar"
	desc = "A jar large enough to put an organ inside it."
	possible_transfer_amounts = list(10, 20, 30, 50, 150)
	// It's pretty big
	volume = 150
	icon_state = "organ_jar"
	fill_icon_state = "organ_jar"
	inhand_icon_state = "atoxinbottle"
	worn_icon_state = "bottle"
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

	var/obj/item/organ/held_organ = null
	var/full_of_formaldehyde = FALSE

/obj/item/reagent_containers/cup/organ_jar/examine(mob/user)
	. = ..()
	. += span_info("Any organ inside the jar will be preserved if it is filled with formaldehyde.")
	if(!isnull(held_organ) && held_organ.GetComponent(/datum/component/ghostrole_on_revive))
		. += span_smallnoticeital("The brain is twitching..") // Guaranteed to be a brain if it has that component

/obj/item/reagent_containers/cup/organ_jar/Initialize(mapload)
	. = ..()
	update_appearance()

// Alt click lets you take the organ out, if it's present
/obj/item/reagent_containers/cup/organ_jar/click_alt(mob/user)
	if(!isnull(held_organ))
		balloon_alert(user, "removed [held_organ]")
		user.put_in_hands(held_organ)
		held_organ.organ_flags &= ~ORGAN_FROZEN
		held_organ = null
		name = "organ jar"
		desc = "A jar large enough to put an organ inside it."
		update_appearance()
		return CLICK_ACTION_SUCCESS
	else
		. = ..()

// Clicking on the jar with an organ lets you put the organ inside, if there isn't one already
// Otherwise it should act like a normal bottle
/obj/item/reagent_containers/cup/organ_jar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/organ))
		if(isnull(held_organ))
			if(!user.transferItemToLoc(tool, src))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "inserted [tool]")
			held_organ = tool
			name = "[tool.name] in a jar"
			desc = "A jar with [tool.name] inside it."
			check_organ_freeze()
			update_appearance()
		else
			balloon_alert(user, "the jar already contains [held_organ]")

// Organ icon size goes from 32 to this
#define JAR_INNER_ICON_SIZE 24

/obj/item/reagent_containers/cup/organ_jar/update_overlays()
	. = ..()
	// Draw the organ icon inside the jar, if present
	if(!isnull(held_organ))
		var/image/organ_img = image(held_organ, src)
		var/list/icon_dimensions = get_icon_dimensions(held_organ.icon)
		organ_img.transform = organ_img.transform.Scale( // Make it smaller so it fits
			JAR_INNER_ICON_SIZE / icon_dimensions["width"],
			JAR_INNER_ICON_SIZE / icon_dimensions["height"],
		)
		organ_img.pixel_y -= 3
		organ_img.layer = FLOAT_LAYER
		organ_img.plane = FLOAT_PLANE
		organ_img.blend_mode = BLEND_INSET_OVERLAY
		. += organ_img

#undef JAR_INNER_ICON_SIZE

/obj/item/reagent_containers/cup/organ_jar/on_reagent_change(datum/reagents/holder, ...)
	. = ..()
	full_of_formaldehyde = holder.has_reagent(/datum/reagent/toxin/formaldehyde, amount=holder.maximum_volume)
	check_organ_freeze()

// Proc that stops the held organ from rotting if the jar is full of formaldehyde
/obj/item/reagent_containers/cup/organ_jar/proc/check_organ_freeze()
	if(isnull(held_organ)) return;
	if(full_of_formaldehyde)
		held_organ.organ_flags |= ORGAN_FROZEN
	else
		held_organ.organ_flags &= ~ORGAN_FROZEN

// Defines for note flavor types
// One of these is picked whenever a brain in a jar is created
#define NOTE_STUCK_IN_MAIL 0
#define NOTE_MORBID_GIFT 1
#define NOTE_DISCARDED_LOST_CREW 2

/obj/item/reagent_containers/cup/organ_jar/brain_in_a_jar
	name = "brain in a jar"
	desc = "A brain in a jar. You can see it twitching.."
	var/note_type = NOTE_STUCK_IN_MAIL

/obj/item/reagent_containers/cup/organ_jar/brain_in_a_jar/examine(mob/user)
	. = ..()
	. += span_notice("<i>You can see a note attached to the bottom..</i>")


/obj/item/reagent_containers/cup/organ_jar/brain_in_a_jar/examine_more(mob/user)
	. = ..()
	// Flavor for why the brain is scarred
	switch(note_type)
		if(NOTE_STUCK_IN_MAIL)
			. += span_notice("According to the note, this jar must've been stuck in the mail for at least 50 years..")
		if(NOTE_MORBID_GIFT)
			. += span_notice("It reads..")
			. += span_notice("Greetings, XXX. I stumbled upon a hermit in my travels, \
			whose quirks immediately piqued my interest. I'm sure his brain will be as useful to your research \
			as it has been to mine. Signed, YYY.")
		if(NOTE_DISCARDED_LOST_CREW)
			. += span_notice("It reads..")
			. += span_notice("Hey, XXX. Management wanted me to discard this poor schmuck's brain, \
			claiming it's 'too damaged to viably recover', so I figured I might as well throw you a bone. \
			I know you like these sorts of things. Signed, ZZZ.")



/obj/item/reagent_containers/cup/organ_jar/brain_in_a_jar/Initialize(mapload)
	. = ..()
	note_type = rand(0, 2) // Attach a random note to it
	var/obj/item/organ/brain/scarred_brain = new() // Make a new brain
	// Make it revivable, scar it if revival is successful
	scarred_brain.AddComponent( \
		/datum/component/ghostrole_on_revive,\
		refuse_revival_if_failed = TRUE, \
		on_successful_revive = CALLBACK(src, PROC_REF(scar_upon_revival), scarred_brain) \
		)
	held_organ = scarred_brain // Put the brain inside the jar
	reagents.add_reagent(/datum/reagent/toxin/formaldehyde, reagents.maximum_volume) // Fill the jar with formaldehyde
	update_appearance()

// All this does is add a random special brain trauma
/obj/item/reagent_containers/cup/organ_jar/brain_in_a_jar/proc/scar_upon_revival(obj/item/organ/brain/brain_to_scar)
	brain_to_scar.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_ABSOLUTE, natural_gain = TRUE)


#undef NOTE_STUCK_IN_MAIL
#undef NOTE_MORBID_GIFT
#undef NOTE_DISCARDED_LOST_CREW
