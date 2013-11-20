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
	has_multi_loc = 1 //Needed to handle Multilocation

//THE STEPS//
The block of "If's" is necessary, add or remove so you have just the areas you want, and set them to convert L(or your subsitute) to what you want it to be
EG: a zone on a mob (where user is targetting) to the limb thats actually there.


/datum/surgery_step/multiLocExampleStep
	implements = list()
	time = 9001
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head", "etc")
	// allowed_organs is a list of organs this operation works with, it is defined in the earliest instance of the surgery_step (Eg, datum/surgery_step/multiLocExampleStep)
	// allowed_organs is handled in Handle_Multi_Loc() in surgery_step.dm


/datum/surgery_step/multiLocExampleStep/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ //new_organ is a variable in /datum/surgery_step, it is null by default, and is given a value in Handle_Multi_Loc()
	//Although Handle_Multi_Loc() is /datum/surgery_step/SURGERYNAME/Handle_Multi_Loc() you do not need to rewrite it in the surgery
	if(L)
		user.visible_message("<span class ='notice'>Generic Statement.</span>")
	else
		user.visible_message("<span class ='notice'>Generic Statement 2.</span>")


/datum/surgery_step/multiLocExampleStep/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
You can use whatever you substituted "L" for here for useful things, swapping limbs for other limbs, etc.
if the surgery is intended to be MultiLoc but should only be performable once per limb, add this
"surgery.invalid_locations += user.zone_sel.selecting"
Just after you have swapped limbs around, see limb augmentation for an example of this

*/

//This file is commented out as to avoid:
// a snowflakey removal of it 100% of the time
// it's an example, it doesn't work perfectly due to just being the multiple locations section.
// It is also not set to compile, due to being Empty (according to the compiler)

//Enjoy making Multi-location operations! (if you understood my Rambling)
//If you didn't understand this, Ask for RobRichards in Coderbus