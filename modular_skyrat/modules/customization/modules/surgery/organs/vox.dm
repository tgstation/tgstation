/obj/item/organ/lungs/vox
	name = "vox lungs"
	desc = "They're filled with dust... wow."
	icon_state = "lungs-c"
	safe_oxygen_min = 0	//Dont need oxygen
	safe_oxygen_max = 2 //But it is quite toxic to them
	safe_nitro_min = 10 // Atleast 10 nitrogen
	oxy_damage_type = TOX
	oxy_breath_dam_min = 6
	oxy_breath_dam_max = 20

	cold_level_1_threshold = 0 // Vox should be able to breathe in cold gas without issues?
	cold_level_2_threshold = 0
	cold_level_3_threshold = 0
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/brain/vox
	name = "vox brain"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/brain/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(owner.stat == DEAD)
		return
	switch(severity)
		if(1)
			to_chat(owner, "<span class='boldwarning'>You feel [pick("like your brain is being fried", "a sharp pain in your head")]!</span>")
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 150)
			owner.jitteriness += 30
			owner.stuttering += 30
			owner.add_confusion(10)
		if(2)
			to_chat(owner, "<span class='warning'>You feel [pick("disoriented", "confused", "dizzy")].</span>")
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 150)
			owner.jitteriness += 10
			owner.stuttering += 10
			owner.add_confusion(3)
