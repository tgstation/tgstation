/obj/item/skillchip/job

/obj/item/skillchip/job/Initialize()
	. = ..()
	skillchip_flags |= SKILLCHIP_JOB_TYPE
