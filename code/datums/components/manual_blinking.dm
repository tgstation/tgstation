/datum/component/manual_blinking
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/obj/item/organ/eyes/E
	var/warned = FALSE
	var/last_blink
	var/check_every = 10 SECONDS
	var/list/valid_emotes = list(/datum/emote/living/carbon/blink, /datum/emote/living/carbon/blink_r)

/datum/component/manual_blinking/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/carbon/C = parent
	E = C.getorganslot(ORGAN_SLOT_EYES)

	if(E)
		START_PROCESSING(SSprocessing, src)
		to_chat(C, "<span class='notice'>You suddenly realize you're blinking manually.</span>")

/datum/component/manual_blinking/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	to_chat(parent, "<span class='notice'>You revert back to automatic blinking.</span>")
	return ..()

/datum/component/manual_blinking/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_EMOTE, .proc/check_emote)
	RegisterSignal(parent, COMSIG_CARBON_GAIN_ORGAN, .proc/check_added_organ)
	RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, .proc/check_removed_organ)

/datum/component/manual_blinking/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_EMOTE)
	UnregisterSignal(parent, COMSIG_CARBON_GAIN_ORGAN)
	UnregisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN)

/datum/component/manual_blinking/process()
	var/mob/living/carbon/C = parent

	if(E && world.time > (last_blink + check_every))
		if(!warned)
			to_chat(C, "<span class='userdanger'>You need to blink!</span>")

		warned = TRUE
		E.applyOrganDamage(1)

		if(prob(4))
			C.visible_message("<b>[C]'s</b> eyes water!", \
			"<span class='notice'>Your eyes water painfully!</span>")

/datum/component/manual_blinking/proc/check_added_organ(mob/who_cares, obj/item/organ/O)
	testing(O)
	var/obj/item/organ/eyes/new_eyes = O

	if(istype(new_eyes,/obj/item/organ/eyes))
		E = new_eyes
		START_PROCESSING(SSprocessing, src)

/datum/component/manual_blinking/proc/check_removed_organ(mob/who_cares, obj/item/organ/O)
	testing(O)
	var/obj/item/organ/eyes/bye_beyes = O // oh come on, that's pretty good

	if(istype(bye_beyes, /obj/item/organ/eyes))
		E = null
		STOP_PROCESSING(SSprocessing, src)

/datum/component/manual_blinking/proc/check_emote(mob/living/carbon/user, list/emote_args)
	var/datum/emote/emote = emote_args[EMOTE_DATUM]

	if(emote.type in valid_emotes)
		testing("blinked")
		warned = FALSE
		last_blink = world.time
