#define UNUSABLE_QUALITY 0.7
#define SHODDY_QUALITY 0.8
#define POOR_QUALITY 0.9
#define NORMAL_QUALITY 1
#define GOOD_QUALITY 1.05
#define FINE_QUALITY 1.1
#define SUPERIOR_QUALITY 1.2
#define EXCEPTIONAL_QUALITY 1.3
#define MASTERFUL_QUALITY 1.4
#define ARTIFACT_QUALITY 1.45

datum/component/quality
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/quality_level

	var/announce

	var/originalName
	var/list/affixes
	var/list/appliedComponents

	var/static/list/affixListing
	var/list/quality_list = list("0" = 1, "1" = 2 , "2" = 2 , "3" = 1)
	//Skill of our choosing, it can be whatever we want
	//Mind - Mind of the creator
	//Modifier - flat bonus towards quality

/datum/component/quality/Initialize(datum/skill,datum/mind,modifier)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	generate_quality(skill,mind,modifier)
	apply_quality()

/datum/component/quality/generate_quality(datum/skill,datum/mind,modifier)
	quality_level = clamp(pickweight(quality_list) + mind.known_skills[skill] + modifier,0,9)
	return quality_level

/datum/component/quality/apply_quality()
	var/quality = quality_level2quality_val(quality_level)
	parent.force *= quality
	parent.throwforce *= quality
	parent.max_integrity += quality
	var/armor_qual = (quality - 1)*20
	parent.armor.modifyRating(armor_qual,armor_qual,armor_qual,armor_qual,armor_qual,armor_qual,armor_qual,armor_qual,armor_qual,armor_qual) // modifies all armor ratings

/datum/component/quality/quality_level2quality_val(quality_level)
	switch(quality_level)
		if(0)
			return UNUSABLE_QUALITY
		if(1)
			return SHODDY_QUALITY
		if(2)
			return POOR_QUALITY
		if(3)
			return NORMAL_QUALITY
		if(4)
			return GOOD_QUALITY
		if(5)
			return FINE_QUALITY
		if(6)
			return SUPERIOR_QUALITY
		if(7)
			return EXCEPTIONAL_QUALITY
		if(8)
			return MASTERFUL_QUALITY
		if(9)
			return ARTIFACT_QUALITY

/datum/component/quality/quality_val2quality_level(quality_val)
	switch(quality_val)
		if(UNUSABLE_QUALITY)
			return 0
		if(SHODDY_QUALITY)
			return 1
		if(POOR_QUALITY)
			return 2
		if(NORMAL_QUALITY)
			return 3
		if(GOOD_QUALITY)
			return 4
		if(FINE_QUALITY)
			return 5
		if(SUPERIOR_QUALITY)
			return 6
		if(EXCEPTIONAL_QUALITY)
			return 7
		if(MASTERFUL_QUALITY)
			return 8
		if(ARTIFACT_QUALITY)
			return 9

