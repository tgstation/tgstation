/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteful brown colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	icon_state = "cargosoft"
	inhand_icon_state = "greyscale_softcap" //todo wip
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING
	/// For setting icon archetype
	var/soft_type = "cargo"
	/// If there is a suffix to append
	var/soft_suffix = "soft"

	dog_fashion = /datum/dog_fashion/head/cargo_tech
	/// Whether this is on backwards... Woah, cool
	var/flipped = FALSE

/obj/item/clothing/head/soft/dropped()
	icon_state = "[soft_type][soft_suffix]"
	flipped = FALSE
	..()

/obj/item/clothing/head/soft/verb/flipcap()
	set category = "Object"
	set name = "Flip cap"

	flip(usr)


/obj/item/clothing/head/soft/click_alt(mob/user)
	flip(user)
	return CLICK_ACTION_SUCCESS


/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(!user.incapacitated)
		flipped = !flipped
		if(flipped)
			icon_state = "[soft_type][soft_suffix]_flipped"
			to_chat(user, span_notice("You flip the hat backwards."))
		else
			icon_state = "[soft_type][soft_suffix]"
			to_chat(user, span_notice("You flip the hat back in normal position."))
		update_icon()
		usr.update_worn_head() //so our mob-overlays update

/obj/item/clothing/head/soft/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click the cap to flip it [flipped ? "forwards" : "backwards"].")

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	soft_type = "red"
	dog_fashion = null

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	soft_type = "blue"
	dog_fashion = null

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	soft_type = "green"
	dog_fashion = null

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	soft_type = "yellow"
	dog_fashion = null

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	soft_type = "grey"
	dog_fashion = null

/* A grey baseball cap that grants TRAIT_JOLLY when it's on your head.
 * Used for testing that gaining and losing the JOLLY trait behaves properly.
 * Also a perfectly valid weird admin reward.
 */
/obj/item/clothing/head/soft/grey/jolly
	name = "jolly grey cap"
	desc = "It's a baseball hat in a sublime grey colour. Why, wearing this alone would boost a person's spirits!"
	clothing_traits = list(TRAIT_JOLLY)

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	soft_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	soft_type = "mime"
	dog_fashion = null

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	soft_type = "purple"
	dog_fashion = null

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "blacksoft"
	soft_type = "black"
	dog_fashion = null

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	inhand_icon_state = "rainbow_softcap"
	soft_type = "rainbow"
	dog_fashion = null

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's a robust baseball hat in tasteful red colour."
	icon_state = "secsoft"
	soft_type = "sec"
	armor_type = /datum/armor/cosmetic_sec
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/soft/veteran
	name = "veteran cap"
	desc = "It's a robust baseball hat in tasteful black colour with a golden connotation to \"REMEMBER\"."
	icon_state = "veteransoft"
	soft_type = "veteran"
	armor_type = /datum/armor/cosmetic_sec
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/soft/paramedic
	name = "paramedic cap"
	desc = "It's a baseball hat with a dark turquoise color and a reflective cross on the top."
	icon_state = "paramedicsoft"
	soft_type = "paramedic"
	dog_fashion = null

/obj/item/clothing/head/soft/fishing_hat
	name = "legendary fishing hat"
	desc = "An ancient relic of a bygone era of bountiful catches and endless rivers. Printed on the front is a poem:<i>\n\
		Women Fear Me\n\
		Fish Fear Me\n\
		Men Turn Their Eyes Away From Me\n\
		As I Walk No Beast Dares Make A Sound In My Presence\n\
		I Am Alone On This Barren Earth.</i>"
	icon_state = "fishing_hat"
	soft_type = "fishing_hat"
	inhand_icon_state = "fishing_hat"
	soft_suffix = null
	worn_y_offset = 5
	clothing_flags = SNUG_FIT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE
	dog_fashion = null
	clothing_traits = list(TRAIT_SCARY_FISHERMAN) //Fish, carps, lobstrosities and frogs fear me.

/obj/item/clothing/head/soft/fishing_hat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("crustacean_replacement.json", "crustacean")) //you asked for this.
	AddElement(/datum/element/skill_reward, /datum/skill/fishing)
	AddComponent(/datum/component/adjust_fishing_difficulty, -5)

#define PROPHAT_MOOD "prophat"

/obj/item/clothing/head/soft/propeller_hat
	name = "propeller hat"
	desc = "A colorful hat with a spinning propeller sat on top."
	icon_state = "propeller_hat"
	soft_type = "propeller_hat"
	inhand_icon_state = "rainbow_softcap"
	worn_y_offset = 1
	soft_suffix = null
	actions_types = list(/datum/action/item_action/toggle)
	var/enabled_waddle = TRUE
	var/active = FALSE

/obj/item/clothing/head/soft/propeller_hat/update_icon_state()
	. = ..()
	worn_icon_state = "[soft_type][flipped ? "_flipped" : null][active ? "_on" : null]"

/obj/item/clothing/head/soft/propeller_hat/attack_self(mob/user)
	active = !active
	balloon_alert(user, (active ? "started propeller" : "stopped propeller"))
	update_icon()
	user.update_worn_head()
	add_fingerprint(user)

/obj/item/clothing/head/soft/propeller_hat/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HEAD)
		user.add_mood_event(PROPHAT_MOOD, /datum/mood_event/prophat)

/obj/item/clothing/head/soft/propeller_hat/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event(PROPHAT_MOOD)
	active = FALSE
	update_icon()

#undef PROPHAT_MOOD
