//predominantly negative traits



/datum/trait/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep, you sleep for a little bit longer."
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>You feel sleepy.</span>"
	lose_text = "<span class='notice'>You feel awake again.</span>"
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."



/datum/trait/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	value = -1
	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/trait/nearsighted/add()
	trait_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/trait/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, slot_glasses)
	H.regenerate_icons() //this is to remove the inhand icon, which persists even if it's not in their hands



/datum/trait/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/trait/nonviolent/on_process()
	if(trait_holder.mind && LAZYLEN(trait_holder.mind.antag_datums))
		to_chat(trait_holder, "<span class='boldannounce'>Your antagonistic nature has caused you to renounce your pacifism.</span>")
		qdel(src)



/datum/trait/poor_aim
	name = "Poor Aim"
	desc = "You're terrible with guns and can't line up a straight shot to save your life. Dual-wielding is right out."
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."



/datum/trait/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."



/datum/trait/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	value = -1
	var/slot_string = "limb"

/datum/trait/prosthetic_limb/on_spawn()
	var/limb_slot = pick("l_arm", "r_arm", "l_leg", "r_leg")
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if("l_arm")
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(trait_holder)
			slot_string = "left arm"
		if("r_arm")
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(trait_holder)
			slot_string = "right arm"
		if("l_leg")
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(trait_holder)
			slot_string = "left leg"
		if("r_leg")
			prosthetic = new/obj/item/bodypart/r_leg/robot/surplus(trait_holder)
			slot_string = "right leg"
	prosthetic.replace_limb(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/trait/prosthetic_limb/post_add()
	to_chat(trait_holder, "<span class='boldannounce'>Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment.</span>")



/datum/trait/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. <b>This is not a license to grief.</b>"
	value = -2
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>You feel in tune with the world again.</span>"
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."

/datum/trait/insanity/on_process()
	if(trait_holder.reagents.has_reagent("mindbreaker"))
		trait_holder.hallucination = 0
		return
	if(prob(2)) //we'll all be mad soon enough
		madness()

/datum/trait/insanity/proc/madness(mad_fools)
	set waitfor = FALSE
	if(!mad_fools)
		mad_fools = prob(20)
	if(mad_fools)
		var/hallucination_type = pick(subtypesof(/datum/hallucination/rds))
		new hallucination_type (trait_holder, FALSE)
	else
		trait_holder.hallucination += rand(10, 50)

/datum/trait/insanity/post_add() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(!trait_holder.mind || trait_holder.mind.special_role)
		return
	to_chat(trait_holder, "<span class='big bold info'>Please note that your dissociation syndrome does NOT give you the right to attack people or otherwise cause any interference to \
	the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")



/datum/trait/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	value = -1
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	var/dumb_thing = TRUE

/datum/trait/social_anxiety/on_process()
	var/mob/living/carbon/human/H = trait_holder
	if(prob(5))
		H.stuttering = max(3, H.stuttering)
	else if(prob(1) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='danger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life

/datum/trait/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>You start feeling depressed.</span>"
	lose_text = "<span class='notice'>You no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
