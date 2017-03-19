/datum/surgery/core_removal
	name = "core removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/extract_core)
	species = list(/mob/living/simple_animal/slime)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")

/datum/surgery/core_removal/can_start(mob/user, mob/living/target)
	if(target.stat == DEAD)
		return 1
	return 0

//extract brain
/datum/surgery_step/extract_core
	name = "extract core"
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 100)
	time = 16

/datum/surgery_step/extract_core/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[IDENTITY_SUBJECT(1)] begins to extract a core from [IDENTITY_SUBJECT(2)].", "<span class='notice'>You begin to extract a core from [IDENTITY_SUBJECT(2)]...</span>", subjects=list(user, target))

/datum/surgery_step/extract_core/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/slime/slime = target
	if(slime.cores > 0)
		slime.cores--
		user.visible_message("[IDENTITY_SUBJECT(1)] successfully extracts a core from [IDENTITY_SUBJECT(2)]!", "<span class='notice'>You successfully extract a core from [IDENTITY_SUBJECT(2)]. [slime.cores] core\s remaining.</span>", subjects=list(user, target))

		new slime.coretype(slime.loc)

		if(slime.cores <= 0)
			slime.icon_state = "[slime.colour] baby slime dead-nocore"
			return 1
		else
			return 0
	else
		to_chat(user, "<span class='warning'>There aren't any cores left in [IDENTITY_SUBJECT(1)]!</span>", list(target))
		return 1