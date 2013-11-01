/*
//CONTENTS//
Multiple location example surgery



//THE SURGERY//
it is very similar to a normal surgery.
Location = "anywhere" is the unique difference.

/datum/surgery/multiLocExample
	name = "Multiple Location Surgery Example"
	steps = list(/datum/surgery_step/multiLocExampleStep)
	species = list(/mob/living/carbon)
	location = "anywhere" //A Location "Anywhere" is handled in /code/modules/surgery/helpers attempt_initiate_surgery(), it is converted into a User.zone_sel.selecting.


//THE STEPS//
The block of "If's" is necessary, add or remove so you have just the areas you want, and set them to convert L(or your subsitute) to what you want it to be
EG: a zone on a mob (where user is targetting) to the limb thats actually there.

/datum/surgery_step/multiLocExampleStep/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
A user.zone_sel.selecting (Carried over from attempt_initate_surgery() (because you can't operate on two limbs at once)) is converted to the correct organ/limb
	if(user.zone_sel.selecting == "r_arm")
		L = target.getlimb(/obj/item/organ/limb/r_arm)
	if(user.zone_sel.selecting == "l_arm")
		L = target.getlimb(/obj/item/organ/limb/l_arm)
	if(user.zone_sel.selecting == "r_leg")
		L = target.getlimb(/obj/item/organ/limb/r_leg)
	if(user.zone_sel.selecting == "l_leg")
		L = target.getlimb(/obj/item/organ/limb/l_leg)
	else
		L = target.getlimb(/obj/item/organ/limb/chest) This is to solve issues in the future, Make sure you include something for this in the success even if it ends the operation right there.
	if(L) //if the converted user.zone_sel.selecting is in the mob, continue
		user.visible_message("<span class ='notice'>Generic Statement.</span>")
	else
		user.visible_message("<span class ='notice'>Generic Statement 2.</span>")


/datum/surgery_step/multiLocExampleStep/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
This is a standard Success child,
You can use whatever you substituted "L" for here for useful things, swapping limbs for other limbs, etc.
*/

//This file is commented out as to avoid:
// a snowflakey removal of it 100% of the time
// it's an example, it doesn't work perfectly due to just being the multiple locations section.
// It is also not set to compile, due to being Empty (according to the compiler)

//Enjoy making Multi-location operations! (if you understood my Rambling)
//If you didn't understand this, Ask for RobRichards in Coderbus