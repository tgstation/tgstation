/// Job related skillchip category
#define SKILLCHIP_CATEGORY_JOB "job"

/obj/item/skillchip/job
	skillchip_flags = SKILLCHIP_RESTRICTED_CATEGORIES
	chip_category = SKILLCHIP_CATEGORY_JOB
	incompatibility_list = list(SKILLCHIP_CATEGORY_JOB)
	abstract_parent_type = /obj/item/skillchip/job
	slot_use = 2

#undef SKILLCHIP_CATEGORY_JOB
