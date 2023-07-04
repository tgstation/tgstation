/obj/item/organ/internal/brain/clockwork
	name = "enigmatic gearbox"
	desc ="An engineer would call this inconcievable wonder of gears and metal a 'black box'"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-clock"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/robust //Set to true if the robustbits causes brain replacement. Because holy fuck is the CLANG CLANG CLANG CLANG annoying

/obj/item/organ/internal/brain/clockwork/emp_act(severity)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)

/obj/item/organ/internal/brain/clockwork/on_life()
	. = ..()
	if(prob(5) && !robust)
		SEND_SOUND(owner, sound('sound/ambience/ambiruin3.ogg', volume = 25))
