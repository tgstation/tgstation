//AI lawset
/datum/ai_laws/ratvar
	name = "Servant of the Justiciar"
	zeroth = ("Purge all untruths and honor Ratvar.")
	inherent = list()

//Clockwork wall: Causes nearby caches to generate components
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "clockwork_wall"

/turf/closed/wall/clockwork/New()
	..()
	SSobj.processing += src
	clockwork_construction_value += 5

/turf/closed/wall/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value -= 5
	..()

/turf/closed/wall/clockwork/process()
	for(var/obj/structure/clockwork/cache/C in range(3, src))
		if(prob(5))
			C.stored_components[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++

/turf/closed/wall/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.isOn())
			user << "<span class='warning'>Your [WT.name]'s flame has no effect on [src]!</span>"
		return 0
	..()

//Clockwork floor: Slowly heals conventional damage on nearby servants`````
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "clockwork_floor"

/turf/open/floor/clockwork/New()
	..()
	SSobj.processing += src
	clockwork_construction_value++

/turf/open/floor/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value--
	..()

/turf/open/floor/clockwork/process()
	for(var/mob/living/L in range(3, src))
		if(L.stat == DEAD)
			continue
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)

/turf/open/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user << "<span class='warning'>[src]'s tiles are too tightly pressed to pry up!</span>"
		return 0
	..()

//Function Call verb: Calls forth a Ratvarian spear.
/mob/living/carbon/human/proc/function_call()
	set name = "Function Call"
	set desc = "Calls forth your Ratvarian spear."
	set category = "Clockwork"

	if(usr.l_hand && usr.r_hand)
		usr << "<span class='warning'>You need an empty to hand to call forth your spear!</span>"
		return 0
	usr.visible_message("<span class='warning'>A strange spear materializes in [usr]'s hands!</span>", "<span class='brass'>You call forth your spear!</span>")
	var/obj/item/clockwork/ratvarian_spear/R = new(get_turf(usr))
	usr.put_in_hands(R)
	usr.verbs -= /mob/living/carbon/human/proc/function_call
	return 1

/*

The Ratvarian Language

	In the lore of the Servants of Ratvar, the Ratvarian tongue is a timeless language and full of power. It sounds like gibberish, much like Nar-Sie's language, but is in fact derived from
aforementioned language, and may induce miracles when spoken in the correct way with an amplifying tool (similar to runes used by the Nar-Sian cult).

	While the canon states that the language of Ratvar and his servants is incomprehensible to the unenlightened as it is a derivative of the most ancient known language, in reality it is
actually very simple. To translate a plain English sentence to Ratvar's tongue, simply move all of the letters thirteen places ahead, starting from "a" if the end of the alphabet is reached.
This cipher is known as "rot13" for "rotate 13 places" and there are many sites online that allow instant translation between English and rot13 - one of the benefits is that moving the translated
sentence thirteen places ahead changes it right back to plain English.

	There are, however, a few parts of the Ratvarian tongue that aren't typical and are implemented for fluff reasons. Some words may have apostrophes, hyphens, and spaces, making the plain
English translation apparent but disjoined (for instance, "Oru`byq zl-cbjre!" translates directly to "Beh'old my-power!") although this can be ignored without impacting overall quality. When
translating from Ratvar's tongue to plain English, simply remove the disjointments and use the finished sentence. This would make "Oru`byq zl-cbjre!" into "Behold my power!" after removing the
abnormal spacing, hyphens, and grave accents.

List of nuances:

- Any time the word "of" occurs, it is linked to the previous word by a hyphen. If it is the first word, nothing is done. (i.e. "V nz-bs Ratvar." directly translates to "I am-of Ratvar.")
- Although "Ratvar" translates to "Engine" in English, the word "Ratvar" is used regardless of language as it is a proper noun.
 - The same rule applies to Ratvar's four generals: Nezbere (Armorer), Sevtug (Fright), Nzcrentr (Amperage), and Inath-Neq (Vangu-Ard), although these words can be used in proper context if one is
   not referring to the four generals and simply using the words themselves.

*/
