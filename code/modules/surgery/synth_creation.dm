/datum/surgery/synth_creation
//Synth surgery. Use a positronic brain to turn a fully augged, debrained corpse into a funcitonal synth!
	name = "synth creation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/create_synth)
	species = list(/mob/living/carbon/human)
	possible_locs = list("head")
	requires_organic_bodypart = 0 //We in fact, require the EXACT OPPOSITE.

/datum/surgery/synth_creation/can_start(mob/user, mob/living/carbon/human/target)
	// Requires a brainless corpse, obviously not already a synth.
	if(target.getorgan(/obj/item/organ/internal/brain) || target.stat != DEAD || target.dna.species.id == "synth")
		return 0
	var/organ_count = 0
	for(var/obj/item/organ/limb/robot/RR in target.organs) //Humans have six limbs. If all six are augged, it is ready for being a synth!
		organ_count++
	if(organ_count < 6) //Not fully augged!
		return 0

	return 1

/datum/surgery_step/create_synth
	name = "create synth using positronic brain"
	implements = list(/obj/item/device/mmi/posibrain = 100)
	time = 64


/datum/surgery_step/create_synth/preop(mob/user, mob/living/carbon/human/target, target_zone, var/obj/item/device/mmi/posibrain/PB, datum/surgery/surgery)
	if(!PB.brainmob || !PB.brainmob.client) //No player, no synth!
		user << "<span class='warning'>[PB] must be operational before it can be installed.</span>"
		return -1
	if(target.getBruteLoss() || target.getFireLoss()) //Physical damage to the mechanical components of the body would complicate the operation.
		user << "<span class='warning'>[target] appears to be damaged, and requires repair.</span>"
		return -1

	user.visible_message("[user] begins inserting [PB] into [target].", "<span class='notice'>You begin the delicate task of reconfiguring and installing the synth's brain...</span>")

/datum/surgery_step/create_synth/success(mob/user, mob/living/carbon/human/target, target_zone, var/obj/item/device/mmi/posibrain/PB, datum/surgery/surgery)

	if(target.key) //Well, a brainless corpse should not have a player in it anyway...
		target.ghostize()

	if(PB.brainmob.mind)
		PB.brainmob.mind.transfer_to(target)
		qdel(PB)
	else
		return 0


	var/obj/item/organ/internal/brain/synthetic/newbrain = new /obj/item/organ/internal/brain/synthetic(target)
	newbrain.Insert(target) //Carbons die without a brain!
	target.revive()
	target.emote("gasp")
	var/datum/species/prev_species = target.dna.species
	target.set_species(/datum/species/synth)
	var/datum/species/synth/synthspecies = target.dna.species
	synthspecies.assume_disguise(prev_species, target)
	return 1