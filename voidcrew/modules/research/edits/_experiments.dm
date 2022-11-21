#define RESEARCH_POINTS_PER_EXPERIMENT 2000

/datum/experiment/finish_experiment(datum/component/experiment_handler/experiment_handler)
	. = ..()
	experiment_handler.linked_web.add_point_list(list(
		TECHWEB_POINT_TYPE_GENERIC = RESEARCH_POINTS_PER_EXPERIMENT),
	)

#undef RESEARCH_POINTS_PER_EXPERIMENT
