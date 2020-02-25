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
Qualities below NORMAL_QUALITY result in worse items , less force , less integrity etc.database
Qualittes above NORMAL_QUALITY result in better items with more force
Items that reach quality of MASTERWORK_QUALITY have a tiny chance of instead becoming ARTIFACT_QUALITY which adds fantasy component of 10 quality(very powerful)
*/
///This Component handles adding quality to items.
/datum/component/quality
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///List containing values used in adding force to items
	var/list/quality_levels = list(UNUSABLE_QUALITY,SHODDY_QUALITY,POOR_QUALITY,NORMAL_QUALITY,GOOD_QUALITY,FINE_QUALITY,SUPERIOR_QUALITY,EXCEPTIONAL_QUALITY,ARTISAN_QUALITY,MASTERWORK_QUALITY,ARTIFACT_QUALITY )

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
	var/quality_val

	quality_val = _quality_val

	if(!_quality_val)
		// This returns normal distributuion
		quality_val = pick(2;0 ,4;1 ,6;2 ,4;3 ,2;4)


	if(!_creator || !_skill) //no runtimes
		return
	creator = _creator

	var/quality_skill_modifier = creator.mind.get_skill_modifier(_skill, SKILL_QUALITY_MODIFIER)
	creator_name = creator.name

	var/obj/item/parent_item = parent
	old_name = parent_item.name
	//we set the has_quality to true so no more quality components can be added
	parent_item.has_quality = TRUE

	generate_quality(quality_val,quality_skill_modifier)
	apply_quality()

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/OnExamine)

/datum/component/quality/proc/OnExamine(datum/source, mob/user)
	var/obj/item/parent_item = parent
	to_chat(user, "<span class='notice'>It is a [parent_item.name] created by [creator_name]</span>")

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
	parent_item.modify_max_integrity(parent_item*quality)

	if(istype(parent_item,/obj/item/twohanded))
		var/obj/item/twohanded/twohanded_item = parent_item
		twohanded_item.force_unwielded *= quality // we dont know if it posses that var but it is still essential
		twohanded_item.force_wielded *= quality

	var/armor_qual = (quality - 1)*20
	parent_item.armor?.modifyAllRatings(armor_qual) // modifies all armor ratings

	if(quality_level == 10)
		parent_item.AddComponent(/datum/component/fantasy,10)
	parent_item.name = handle_name(parent_item.name)

///Returns the item to the state it was before the modification
/datum/component/quality/proc/unmodify()
	var/obj/item/parent_item = parent
	parent_item.name = old_name
	parent_item.force /= quality
	parent_item.throwforce  /= quality
	parent_item.modify_max_integrity(parent_item/quality)

	var/armor_qual = (quality - 1)*20
	parent_item.armor = parent_item.armor?.modifyAllRatings(-armor_qual)

	if(istype(parent_item,/obj/item/twohanded))
		var/obj/item/twohanded/twohanded_item = parent_item
		twohanded_item.force_unwielded /= quality // we dont know if it posses that var but it is still essential
		twohanded_item.force_wielded /= quality

	parent_item.has_quality = FALSE

/datum/component/quality/Destroy()
	unmodify()
	return ..()

/datum/component/quality/proc/handle_name(var/oldname)
	switch(quality_level)
		if(0)
			return "Unusable [oldname]"
		if(1)
			return "Shoddy [oldname]"
		if(2)
			return "Poor [oldname]"
		if(3)
			return "Normal [oldname]"
		if(4)
			return "Well-done [oldname]"
		if(5)
			return "Finely-crafted [oldname]"
		if(6)
			return "Superior [oldname]"
		if(7)
			return "Exceptional [oldname]"
		if(8)
			return "Artisan [oldname]"
		if(9)
			return "Masterwork [oldname]"
		if(10)
			return "Legendary [oldname]"
