#define EXHALE 0
#define INHALE 1


/datum/component/immersion
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/obj/item/organ/eyes/E
	var/obj/item/organ/eyes/L
	var/mob/living/carbon/C
	var/last_blink
	var/last_breath
	var/blink_every = 24 SECONDS
	var/breathe_every = 14 SECONDS
	var/next_breath_type = INHALE
	var/warned_blink = FALSE
	var/warned_breath = FALSE

/datum/component/immersion/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	C = parent
	E = C.getorganslot(ORGAN_SLOT_EYES)
	L = C.getorganslot(ORGAN_SLOT_LUNGS)

	START_PROCESSING(SSprocessing, src)
	to_chat(C, "<span class='notice'>You suddenly realize you're breathing and blinking manually.</span>")

/datum/component/immersion/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	to_chat(C, "<span class='notice'>You revert back to automatic breathing and blinking.</span>")
	return ..()

/datum/component/immersion/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_EMOTE, .proc/check_emote)

/datum/component/immersion/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_EMOTE)

/datum/component/immersion/process()
	if(E && world.time > (last_blink + (blink_every)))
		if(!warned_blink)
			to_chat(C, "<span class='userdanger'>You need to blink!</span>")

		warned_blink = TRUE
		E.damage++

		if(prob(4))
			C.visible_message("<b>[C]'s</b> eyes water!", \
			"<span class='notice'>Your eyes water painfully!</span>")

	if(L && world.time > (last_breath + (breathe_every)))
		if(!warned_breath)
			to_chat(C, "<span class='userdanger'>You need to [next_breath_type ? "inhale" : "exhale"]!</span>")

		warned_breath = TRUE
		C.losebreath += 0.8
		L.damage += 0.4

	return

/datum/component/immersion/proc/check_emote(mob/living/carbon/user, list/emote_args)
	var/datum/emote/emote = emote_args[EMOTE_DATUM]

	if(emote.key == "blink")
		warned_blink = FALSE
		last_blink = world.time

	if(emote.key == "inhale" && next_breath_type == INHALE)
		warned_breath = FALSE
		last_breath = world.time
		next_breath_type = !next_breath_type
		C.losebreath -= 1.4 // give them a bit of a refund since losebreath takes so long to wear off

	if(emote.key == "exhale" && next_breath_type == EXHALE)
		warned_breath = FALSE
		last_breath = world.time
		next_breath_type = !next_breath_type
		C.losebreath -= 1.4


#undef INHALE
#undef EXHALE