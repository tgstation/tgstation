//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime
	is_valid_mutantrace(mob/living/carbon/slime/target)
		return istype(target, /mob/living/carbon/slime/)

	can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
		return target.stat == 2



//////CUT FLESH//////
/datum/surgery_step/slime/cut_flesh/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_flesh/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && istype(target) && target.core_removal_stage == 0

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", \
	"You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts through [target]'s flesh with \the [tool].</span>",	\
	"<span class='notice'>You cut through [target]'s flesh with \the [tool], revealing its silky innards.</span>")
	target.core_removal_stage = 1

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s flesh with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing [target]'s flesh with \the [tool]!</span>")



//////CUT INNARDS///////
/datum/surgery_step/slime/cut_innards/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/slime/cut_innards
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_innards/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && istype(target) && target.core_removal_stage == 1

/datum/surgery_step/slime/cut_innards/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
	"You start cutting [target]'s silky innards apart with \the [tool].")

/datum/surgery_step/slime/cut_innards/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts [target]'s innards apart with \the [tool], exposing the cores.</span>",	\
	"<span class='notice'>You cut [target]'s innards apart with \the [tool], exposing the cores.</span>")
	target.core_removal_stage = 2

/datum/surgery_step/slime/cut_innards/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing [target]'s innards with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing [target]'s innards with \the [tool]!</span>")



///////SAW CORE///////
/datum/surgery_step/slime/saw_core
	allowed_tools = list(
		/obj/item/weapon/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/slime/saw_core/can_use(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	return ..() && (istype(target) && target.core_removal_stage == 2 && target.cores > 0) //This is being passed a human as target, unsure why.

/datum/surgery_step/slime/saw_core/begin_step(mob/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
	"You start cutting out one of [target]'s cores with \the [tool].")

/datum/surgery_step/slime/saw_core/end_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	target.cores--
	user.visible_message("<span class='notice'>[user] cuts out one of [target]'s cores with \the [tool].</span>",,	\
	"<span class='notice'>You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.</span>")

	if(target.cores >= 0)
		new target.coretype(target.loc)
	if(target.cores <= 0)
		target.icon_state = "[target.colour] baby slime dead-nocore"

/datum/surgery_step/slime/saw_core/fail_step(mob/living/user, mob/living/carbon/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, causing \him to miss the core!</span>", \
	"<span class='warning'>Your hand slips, causing you to miss the core!</span>")
