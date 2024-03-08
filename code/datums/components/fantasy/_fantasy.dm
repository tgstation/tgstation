/datum/component/fantasy
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/quality

	var/canFail
	var/announce

	var/originalName
	var/list/affixes
	var/list/appliedComponents

	var/static/list/affixListing

///affixes expects an initialized list
/datum/component/fantasy/Initialize(quality, list/affixes = list(), canFail=FALSE, announce=FALSE)
	if(!isitem(parent) || HAS_TRAIT(parent, TRAIT_INNATELY_FANTASTICAL_ITEM))
		return COMPONENT_INCOMPATIBLE

	src.quality = quality
	if(isnull(src.quality))
		src.quality = random_quality()
	src.canFail = canFail
	src.announce = announce

	src.affixes = affixes
	appliedComponents = list()
	if(affixes && affixes.len)
		set_affixes()
	else
		random_affixes()

/datum/component/fantasy/Destroy()
	unmodify()
	affixes = null
	return ..()

/datum/component/fantasy/RegisterWithParent()
	var/obj/item/master = parent
	originalName = master.name
	modify()
	RegisterSignal(parent, COMSIG_STACK_CAN_MERGE, PROC_REF(try_merge_stack))

/datum/component/fantasy/proc/try_merge_stack(obj/item/stack/to_merge, in_hand)
	SIGNAL_HANDLER
	return CANCEL_STACK_MERGE

/datum/component/fantasy/UnregisterFromParent()
	unmodify()

/datum/component/fantasy/InheritComponent(datum/component/fantasy/newComp, original, quality, list/affixes, canFail, announce)
	unmodify()
	if(newComp)
		src.quality += newComp.quality
		src.canFail = newComp.canFail
		src.announce = newComp.announce
	else
		src.quality += quality
		src.canFail = canFail || src.canFail
		src.announce = announce || src.announce
	modify()

/datum/component/fantasy/proc/random_quality()
	var/quality = pick(1;15, 2;14, 2;13, 2;12, 3;11, 3;10, 3;9, 4;8, 4;7, 4;6, 5;5, 5;4, 5;3, 6;2, 6;1, 6;0)
	if(prob(50))
		quality = -quality
	return quality

///proc on creation for random affixes
/datum/component/fantasy/proc/random_affixes(force)
	var/alignment
	if(quality >= 0)
		alignment |= AFFIX_GOOD
	if(quality <= 0)
		alignment |= AFFIX_EVIL

	if(!affixListing)
		affixListing = list()
		for(var/T in subtypesof(/datum/fantasy_affix))
			var/datum/fantasy_affix/affix = new T
			affixListing[affix] = affix.weight

	if(length(affixes))
		if(!force)
			return
		affixes = list()

	var/usedSlots = NONE
	for(var/i in 1 to max(1, abs(quality))) // We want at least 1 affix applied
		var/datum/fantasy_affix/affix = pick_weight(affixListing)
		if(affix.placement & usedSlots)
			continue
		if(!(affix.alignment & alignment))
			continue
		if(!affix.validate(parent))
			continue
		affixes += affix
		usedSlots |= affix.placement

///proc on creation for specific affixes given to the fantasy component
/datum/component/fantasy/proc/set_affixes(force)
	var/usedSlots = NONE
	for(var/datum/fantasy_affix/affix in affixes) // We want at least 1 affix applied
		if((affix.placement & usedSlots) || (!affix.validate(parent)))
			affixes.Remove(affix) //bad affix (can't be added to this item)
			continue
		usedSlots |= affix.placement

/datum/component/fantasy/proc/modify()
	var/obj/item/master = parent
	master.apply_fantasy_bonuses(quality)

	var/newName = originalName
	for(var/i in affixes)
		var/datum/fantasy_affix/affix = i
		newName = affix.apply(src, newName)

	if(quality != 0)
		newName = "[newName] [quality > 0 ? "+" : ""][quality]"

	if(canFail && prob((quality - 9)*10))
		var/turf/place = get_turf(parent)
		place.visible_message(span_danger("[parent] [span_blue("violently glows blue")] for a while, then evaporates."))
		master.burn()
		return

	master.name = newName
	if(announce)
		announce()

/datum/component/fantasy/proc/unmodify()
	var/obj/item/master = parent

	for(var/i in affixes)
		var/datum/fantasy_affix/affix = i
		affix.remove(src)
	QDEL_LIST(appliedComponents)
	master.remove_fantasy_bonuses(quality)

	master.name = originalName

/datum/component/fantasy/proc/announce()
	var/turf/location = get_turf(parent)
	var/span
	var/effect_description
	if(quality >= 0)
		span = "<span class='notice'>"
		effect_description = "<span class='heavy_brass'>shimmering golden glow</span>"
	else
		span = "<span class='danger'>"
		effect_description = span_bold("mottled black glow")

	location.visible_message("[span]The [originalName] is covered by a [effect_description] and then transforms into [parent]!</span>")
