#define UNUSABLE_QUALITY 0.7
#define SHODDY_QUALITY 0.8
#define POOR_QUALITY 0.9
#define NORMAL_QUALITY 1
#define GOOD_QUALITY 1.05
#define FINE_QUALITY 1.1
#define SUPERIOR_QUALITY 1.2
#define EXCEPTIONAL_QUALITY 1.3
#define ARTISAN_QUALITY 1.35
#define MASTERWORK_QUALITY 1.4
#define ARTIFACT_QUALITY 1.4

/*
This code handles quality. Whats quality? Quality is an overall state of an item.
Qualities below NORMAL_QUALITY result in worse items , less force , less integrity , you get the point.
Qualittes above NORMAL_QUALITY result in better items with more force
Items that reach quality of MASTERWORK_QUALITY have a tiny chance of instead becoming ARTIFACT_QUALITY which adds fantasy component of 10 quality(very powerful)
*/
///This Component handles adding quality to items.
/datum/component/quality
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///List containing values used in adding force to items
	var/static/list/quality_levels = list(UNUSABLE_QUALITY,SHODDY_QUALITY,POOR_QUALITY,NORMAL_QUALITY,GOOD_QUALITY,FINE_QUALITY,SUPERIOR_QUALITY,EXCEPTIONAL_QUALITY,ARTISAN_QUALITY,MASTERWORK_QUALITY,ARTIFACT_QUALITY )

	var/quality_level
	var/quality


	var/mob/living/carbon/human/creator

	var/old_name

	//we keep this one in case the creator is somehow deleted
	var/creator_name

///_Creator - mob that is the owner of the item, _skill - skill that the quality should be based off of,_quality_list - custom distribution optional, defaults to normal distribution
/datum/component/quality/Initialize(mob/living/carbon/human/_creator,datum/skill/_skill,_quality_val)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/OnExamine)
	RegisterSignal(parent, COMSIG_ITEM_QUALITY_STATE, .proc/check_state)

	var/quality_val

	quality_val = _quality_val

	if(!_quality_val)
		// This returns normal distributuion
		quality_val = pick(2;0 ,4;1 ,6;2 ,8;3 ,6;4 ,4;5 ,2;6)


	creator = _creator

	var/quality_skill_modifier = creator.mind.get_skill_modifier(_skill, SKILL_QUALITY_MODIFIER)
	creator_name = creator.name

	var/obj/item/parent_item = parent
	old_name = parent_item.name

	generate_quality(quality_val,quality_skill_modifier)
	apply_quality()



/datum/component/quality/proc/OnExamine(datum/source, mob/user)
	to_chat(user, "<span class='notice'>The item was created by [creator_name].</span>")

///Generates quality based off passed distribution/ normal distribution and skill. Returns the result
/datum/component/quality/proc/generate_quality(quality_val,quality_skill_modifier)
	quality_level = clamp(quality_val + quality_skill_modifier ,0,9) +1 // +1 because lists start with 1

	if(quality_level == 10 && prob(0.01)) //Artifact roll
		quality_level = 11

	quality = quality_levels[quality_level]

	return quality_level

///Applies quality to the item2
/datum/component/quality/proc/apply_quality()
	var/obj/item/parent_item = parent
	parent_item.force *= quality
	parent_item.throwforce *= quality
	parent_item.modify_max_integrity(parent_item.max_integrity*quality)
	var/armor_qual = (quality - 1)*20
	parent_item.armor?.modifyAllRatings(armor_qual) // modifies all armor ratings

	if(quality_level == 10)
		parent_item.AddComponent(/datum/component/fantasy,10)
	parent_item.name = handle_name()

///Returns the item to the state it was before the modification
/datum/component/quality/proc/unmodify()
	var/obj/item/parent_item = parent

	parent_item.name = old_name

	parent_item.force /= quality
	parent_item.throwforce  /= quality
	parent_item.modify_max_integrity(parent_item/quality)

	var/armor_qual = (quality - 1)*20
	parent_item.armor = parent_item.armor?.modifyAllRatings(-armor_qual)
/datum/component/quality/proc/check_state()
	return TRUE

/datum/component/quality/Destroy()
	//unmodify()
	return ..()

/datum/component/quality/proc/handle_name()
	switch(quality_level)
		if(0)
			return "Unusable [old_name]"
		if(1)
			return "Shoddy [old_name]"
		if(2)
			return "Poor [old_name]"
		if(3)
			return "Normal [old_name]"
		if(4)
			return "Well-done [old_name]"
		if(5)
			return "Finely-crafted [old_name]"
		if(6)
			return "Superior [old_name]"
		if(7)
			return "Exceptional [old_name]"
		if(8)
			return "Artisan [old_name]"
		if(9)
			return "Masterwork [old_name]"
		if(10)
			return "Legendary [old_name]"
