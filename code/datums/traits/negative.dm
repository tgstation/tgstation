//predominantly negative traits

/datum/trait/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>You start feeling depressed.</span>"
	lose_text = "<span class='notice'>You no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
	mood_trait = TRUE



/datum/trait/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom. passed down for generations. You have to keep it safe!"
	value = -1
	mood_trait = TRUE
	var/obj/item/heirloom
	var/where_text

/datum/trait/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/heirloom_type
	switch(trait_holder.mind.assigned_role)
		if("Clown")
			heirloom_type = /obj/item/bikehorn/golden
		if("Mime")
			heirloom_type = /obj/item/reagent_containers/food/snacks/baguette
		if("Lawyer")
			heirloom_type = /obj/item/gavelhammer
		if("Janitor")
			heirloom_type = /obj/item/mop
		if("Security Officer")
			heirloom_type = /obj/item/book/manual/wiki/security_space_law
		if("Scientist")
			heirloom_type = /obj/item/toy/plush/slimeplushie
		if("Assistant")
			heirloom_type = /obj/item/storage/toolbox/mechanical/old/heirloom
	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(trait_holder))
	var/list/slots = list(
		"in your backpack" = slot_in_backpack,
		"in your left pocket" = slot_l_store,
		"in your right pocket" = slot_r_store
	)
	var/where = H.equip_in_one_of_slots(heirloom, slots)
	if(!where)
		where = "at your feet"
		if(where == "in your backpack")
			H.back.SendSignal(COMSIG_TRY_STORAGE_SHOW, H)
	where_text = "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>"

/datum/trait/family_heirloom/post_add()
	to_chat(trait_holder, where_text)
	var/list/family_name = splittext(trait_holder.real_name, " ")
	heirloom.name = "\improper [family_name[family_name.len]] family [heirloom.name]"

/datum/trait/family_heirloom/on_process()
	if(heirloom in trait_holder.GetAllContents())
		trait_holder.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		trait_holder.SendSignal(COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		trait_holder.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		trait_holder.SendSignal(COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)



/datum/trait/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "You sleep like a rock! Whenever you're put to sleep, you sleep for a little bit longer."
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>You feel sleepy.</span>"
	lose_text = "<span class='notice'>You feel awake again.</span>"
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/datum/trait/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Better bring some mannitol!"
	value = -2
	gain_text = "<span class='danger'>You feel smooth.</span>"
	lose_text = "<span class='notice'>You feel wrinkled again.</span>"
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."

/datum/trait/brainproblems/on_process()
	trait_holder.adjustBrainLoss(0.2)



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



/datum/trait/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -1

/datum/trait/nyctophobia/on_process()
	var/mob/living/carbon/human/H = trait_holder
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(trait_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(trait_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(trait_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			trait_holder.toggle_move_intent()
		trait_holder.SendSignal(COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		trait_holder.SendSignal(COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")



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
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(trait_holder)
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(trait_holder)
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(trait_holder)
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
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
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in view(5, trait_holder))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = trait_holder
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/pastatomato(get_turf(H)) //now that's what I call spaghetti code
