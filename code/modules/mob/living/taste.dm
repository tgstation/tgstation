#define DEFAULT_TASTE_SENSITIVITY 15

/mob/living
	var/last_taste_time
	var/last_taste_text

/mob/living/proc/get_taste_sensitivity()
	return DEFAULT_TASTE_SENSITIVITY

/mob/living/carbon/get_taste_sensitivity()
	var/obj/item/organ/tongue/tongue = getorganslot("tongue")
	if(istype(tongue))
		. = tongue.taste_sensitivity
	else
		. = 0 // can't taste anything without a tongue

// non destructively tastes a reagent container
/mob/living/proc/taste(var/datum/reagents/from)
	if(last_taste_time + 50 < world.time)
		var/datum/reagents/temp = new(1)
		from.copy_to(temp, 1) // just copy 1u, it's all we need.

		var/taste_sensitivity = get_taste_sensitivity()
		var/text_output = temp.generate_taste_message(taste_sensitivity)
		if(text_output != last_taste_text || last_taste_time + 100 < world.time) //We dont want to spam the same message over and over again at the person. Give it a bit of a buffer.
			src << "<span class='notice'>You can taste [text_output].</span>"//no taste means there are too many tastes and not enough flavor.

			last_taste_time = world.time
			last_taste_text = text_output

#undef DEFAULT_TASTE_SENSITIVITY
