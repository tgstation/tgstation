/proc/cmp_numeric_dsc(a,b)
	return b - a

/proc/cmp_numeric_asc(a,b)
	return a - b

/proc/cmp_text_asc(a,b)
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	return sorttext(a,b)

/proc/cmp_embed_text_asc(a,b)
	if(isdatum(a))
		a = REF(a)
	if(isdatum(b))
		b = REF(b)
	return sorttext("[b]", "[a]")

/proc/cmp_embed_text_dsc(a,b)
	if(isdatum(a))
		a = REF(a)
	if(isdatum(b))
		b = REF(b)
	return sorttext("[a]", "[b]")

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

/proc/cmp_records_asc(datum/record/a, datum/record/b)
	return sorttext(b.name, a.name)

/proc/cmp_records_dsc(datum/record/a, datum/record/b)
	return sorttext(a.name, b.name)

// Datum cmp with vars is always slower than a specialist cmp proc, use your judgement.
/proc/cmp_datum_numeric_asc(datum/a, datum/b, variable)
	return cmp_numeric_asc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_numeric_dsc(datum/a, datum/b, variable)
	return cmp_numeric_dsc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_text_asc(datum/a, datum/b, variable)
	return sorttext(b.vars[variable], a.vars[variable])

/proc/cmp_datum_text_dsc(datum/a, datum/b, variable)
	return sorttext(a.vars[variable], b.vars[variable])

/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)

/proc/cmp_playtime_asc(client/a, client/b)
	return cmp_numeric_asc(a.get_exp_living(TRUE), b.get_exp_living(TRUE))

/proc/cmp_playtime_dsc(client/a, client/b)
	return cmp_numeric_asc(a.get_exp_living(TRUE), b.get_exp_living(TRUE))

/proc/cmp_subsystem_init(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return initial(b.init_order) - initial(a.init_order) //uses initial() so it can be used on types

/proc/cmp_subsystem_display(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return sorttext(b.name, a.name)

/proc/cmp_subsystem_priority(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return a.priority - b.priority

/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/proc/cmp_timer(datum/timedevent/a, datum/timedevent/b)
	return a.timeToRun - b.timeToRun

/proc/cmp_ruincost_priority(datum/map_template/ruin/A, datum/map_template/ruin/B)
	return initial(A.cost) - initial(B.cost)

/proc/cmp_qdel_item_time(datum/qdel_item/A, datum/qdel_item/B)
	. = B.hard_delete_time - A.hard_delete_time
	if (!.)
		. = B.destroy_time - A.destroy_time
	if (!.)
		. = B.failures - A.failures
	if (!.)
		. = B.qdels - A.qdels

/proc/cmp_generic_stat_item_time(list/A, list/B)
	. = B[STAT_ENTRY_TIME] - A[STAT_ENTRY_TIME]
	if (!.)
		. = B[STAT_ENTRY_COUNT] - A[STAT_ENTRY_COUNT]

/proc/cmp_profile_avg_time_dsc(list/A, list/B)
	return (B[PROFILE_ITEM_TIME]/(B[PROFILE_ITEM_COUNT] || 1)) - (A[PROFILE_ITEM_TIME]/(A[PROFILE_ITEM_COUNT] || 1))

/proc/cmp_profile_time_dsc(list/A, list/B)
	return B[PROFILE_ITEM_TIME] - A[PROFILE_ITEM_TIME]

/proc/cmp_profile_count_dsc(list/A, list/B)
	return B[PROFILE_ITEM_COUNT] - A[PROFILE_ITEM_COUNT]

/proc/cmp_atom_layer_asc(atom/A,atom/B)
	if(A.plane != B.plane)
		return A.plane - B.plane
	else
		return A.layer - B.layer

/proc/cmp_advdisease_resistance_asc(datum/disease/advance/A, datum/disease/advance/B)
	return A.totalResistance() - B.totalResistance()

/proc/cmp_quirk_asc(datum/quirk/A, datum/quirk/B)
	var/a_sign = SIGN(initial(A.value) * -1)
	var/b_sign = SIGN(initial(B.value) * -1)

	// Neutral traits go last.
	if(a_sign == 0)
		a_sign = 2
	if(b_sign == 0)
		b_sign = 2

	var/a_name = initial(A.name)
	var/b_name = initial(B.name)

	if(a_sign != b_sign)
		return a_sign - b_sign
	else
		return sorttext(b_name, a_name)

/proc/cmp_job_display_asc(datum/job/A, datum/job/B)
	return A.display_order - B.display_order

/proc/cmp_department_display_asc(datum/job_department/A, datum/job_department/B)
	return A.display_order - B.display_order

/proc/cmp_reagents_asc(datum/reagent/a, datum/reagent/b)
	return sorttext(initial(b.name),initial(a.name))

/proc/cmp_typepaths_asc(A, B)
	return sorttext("[B]","[A]")

/proc/cmp_pdaname_asc(datum/computer_file/program/messenger/A, datum/computer_file/program/messenger/B)
	return sorttext(B?.computer?.saved_identification, A?.computer?.saved_identification)

/proc/cmp_pdajob_asc(datum/computer_file/program/messenger/A, datum/computer_file/program/messenger/B)
	return sorttext(B?.computer?.saved_job, A?.computer?.saved_job)

/proc/cmp_num_string_asc(A, B)
	return text2num(A) - text2num(B)

/proc/cmp_mob_realname_dsc(mob/A,mob/B)
	return sorttext(A.real_name,B.real_name)

/// Orders bodyparts by their body_part value, ascending.
/proc/cmp_bodypart_by_body_part_asc(obj/item/bodypart/limb_one, obj/item/bodypart/limb_two)
	return limb_one.body_part - limb_two.body_part

/// Orders by integrated circuit weight
/proc/cmp_port_order_asc(datum/port/compare1, datum/port/compare2)
	return compare1.order - compare2.order

/// Orders by uplink category weight
/proc/cmp_uplink_category_desc(datum/uplink_category/compare1, datum/uplink_category/compare2)
	return initial(compare2.weight) - initial(compare1.weight)

/**
 * Sorts crafting recipe requirements before the crafting recipe is inserted into GLOB.crafting_recipes
 *
 * Prioritises [/datum/reagent] to ensure reagent requirements are always processed first when crafting.
 * This prevents any reagent_containers from being consumed before the reagents they contain, which can
 * lead to runtimes and item duplication when it happens.
 */
/proc/cmp_crafting_req_priority(A, B)
	var/lhs
	var/rhs

	lhs = ispath(A, /datum/reagent) ? 0 : 1
	rhs = ispath(B, /datum/reagent) ? 0 : 1

	return lhs - rhs

/// Orders heretic knowledge by priority
/proc/cmp_heretic_knowledge(datum/heretic_knowledge/knowledge_a, datum/heretic_knowledge/knowledge_b)
	return initial(knowledge_b.priority) - initial(knowledge_a.priority)

/// Passed a list of assoc lists, sorts them by the list's "name" keys.
/proc/cmp_assoc_list_name(list/A, list/B)
	return sorttext(B["name"], A["name"])

/// Used by /datum/achievement_data/load_all_achievements() to determine in which order awards have to be loaded.
/proc/cmp_award_priority(type_a, type_b)
	var/datum/award/award_a = SSachievements.awards[type_a]
	var/datum/award/award_b = SSachievements.awards[type_b]
	return award_b?.load_priority - award_a?.load_priority
