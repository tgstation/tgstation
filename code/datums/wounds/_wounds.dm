/*
	Wounds are specific medical complications that can arise and be applied to (currently) carbons, with a focus on humans. All of the code for and related to this is heavily WIP,
	and the documentation will be slanted towards explaining what each part/piece is leading up to, until such a time as I finish the core implementations. The original design doc
	can be found at https://hackmd.io/@Ryll/r1lb4SOwU

	Wounds are datums that operate like a mix of diseases, brain traumas, and components, and are applied to a /obj/item/bodypart (preferably attached to a carbon) when they take large spikes of damage
	or under other certain conditions (thrown hard against a wall, sustained exposure to plasma fire, etc). Wounds are categorized by the three following criteria:
		1. Severity: Either MODERATE, SEVERE, or CRITICAL. See the hackmd for more details
		2. Viable zones: What body parts the wound is applicable to. Generic wounds like broken bones and severe burns can apply to every zone, but you may want to add special wounds for certain limbs
			like a twisted ankle for legs only, or open air exposure of the organs for particularly gruesome chest wounds. Wounds should be able to function for every zone they are marked viable for.
		3. Damage type: Currently either BRUTE or BURN. Again, see the hackmd for a breakdown of my plans for each type.

	When a body part suffers enough damage to get a wound, the severity (determined by a roll or something, worse damage leading to worse wounds), affected limb, and damage type sustained are factored into
	deciding what specific wound will be applied. I'd like to have a few different types of wounds for at least some of the choices, but I'm just doing rough generals for now. Expect polishing
*/

/datum/wound
	//Fluff
	var/form = "injury"
	var/name = "ouchie"
	var/desc = ""
	var/treat_text = ""
	var/examine_desc = ""

	var/severity = WOUND_SEVERITY_MODERATE
	var/damtype = BRUTE

	//Other
	//var/list/viable_mobtypes = list(mob/living/carbon) //typepaths of viable mobs
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //which body parts we can affect
	var/mob/living/carbon/victim = null
	var/obj/item/bodypart/limb = null

	/// Interaction times (do_after's) and click cooldowns with the affected limb will have their duration multiplied by this (mostly busted limbs).
	var/interaction_efficiency_penalty = 1
	/// Incoming damage on this limb will be multiplied by this, to simulate tenderness and vulnerability (mostly burns).
	var/damage_mulitplier_penalty = 1

	///TODO: damage per interaction with the affected limb & ability to alternate movespeed slowdowns to simulate one leg limping

	var/process_dead = FALSE //if this ticks while the host is dead
	var/limp_slowdown = 0
	var/sound_effect

/datum/wound/Destroy()
	. = ..()
	remove_wound()
	qdel(src)

/// Apply whatever wound we've created to the specified limb
/datum/wound/proc/apply_wound(obj/item/bodypart/L)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones))
		return

	victim = L.owner
	limb = L
	LAZYADD(victim.all_wounds, src)
	LAZYADD(limb.wounds, src)
	limb.update_wound()

	if(sound_effect)
		playsound(L.owner, sound_effect, 60 + 20 * severity, TRUE)

/// Remove the wound from whatever it's afflicting
/datum/wound/proc/remove_wound()
	if(victim)
		LAZYREMOVE(victim.all_wounds, src)
		victim = null
	if(limb)
		limb.update_wound()
		LAZYREMOVE(limb.wounds, src)
		limb = null

// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons
/datum/wound/brute
	damtype = BRUTE
	sound_effect = 'sound/effects/crack1.ogg'

/datum/wound/brute/apply_wound(obj/item/bodypart/L)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones))
		return

	. = ..()

	if(L.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/mob/living/carbon/C = L.owner
		C.AddComponent(/datum/component/limp)

/datum/wound/brute/dislocation
	name = "Joint Dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation may suffice."
	examine_desc = "is awkwardly jammed out of place"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 4


/datum/wound/brute/hairline_fracture
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though splinting will prevent worsening situation."
	examine_desc = "appears bruised and grotesquely swollen"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 7

/datum/wound/brute/compound_fracture
	name = "Compound Fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "has a cracked bone sticking out of it"
	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 4
	limp_slowdown = 12
	sound_effect = 'sound/effects/crack2.ogg'


// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	damtype = BURN
	sound_effect = 'sound/effects/sizzle1.ogg'

// we don't even care about first degree burns
/datum/wound/burn/second_deg
	name = "Second Degree Burns"
	desc = "Patient is suffering considerable burns with mild skin penetration, creating a risk of infection and increased burning sensations."
	treat_text = "Recommended application of disinfectant and salve to affected limb, followed by bandaging."
	examine_desc = "is badly burned and breaking out in blisters"
	severity = WOUND_SEVERITY_MODERATE
	damage_mulitplier_penalty = 1.25

/datum/wound/burn/third_deg
	name = "Third Degree Burns"
	desc = "Patient is suffering extreme burns with full skin penetration, creating serious risk of infection and greatly reduced limb integrity."
	treat_text = "Recommended immediate disinfection and excision of ruined skin, followed by bandaging."
	examine_desc = "appears seriously charred, with aggressive red splotches"
	severity = WOUND_SEVERITY_SEVERE
	damage_mulitplier_penalty = 1.5

/datum/wound/burn/fourth_deg
	name = "Catastrophic Burns"
	desc = "Patient is suffering near complete loss of tissue and significantly charred muscle and bone, creating life-threatening risk of infection and negligible limb integrity."
	treat_text = "Immediate surgical debriding of ruined skin, followed by potent tissue regeneration formula and bandaging."
	examine_desc = "is a ruined mess of blanched bone, melted fat, and charred tissue"
	severity = WOUND_SEVERITY_CRITICAL
	damage_mulitplier_penalty = 2
	sound_effect = 'sound/effects/sizzle2.ogg'
