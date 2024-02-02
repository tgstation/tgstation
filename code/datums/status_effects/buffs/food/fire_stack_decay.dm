#define FOOD_FIRESTACK_DECAY_COEFF 1.54
/**
 * A food trait that makes fire stacks decay faster. rates are as following:
 * quality 1: 3x faster (0.15 stacks per second)
 * quality 2: 5x faster (0.25 stacks per second)
 * quality 3: 8x faster (0.40 stacks per second)
 * quality 4: 12x faster (0.60 stacks per second)
 * quality 5: 16x faster (0.80 stacks per second)
 *
 * Keep in mind fire stacks normally decay very slowly, so this is still quite passive.
 */
/datum/status_effect/food/fire_stack_decay
	alert_type = /atom/movable/screen/alert/status_effect/food/fire_stack_decay

/datum/status_effect/food/fire_stack_decay/on_apply()
	owner.fire_stack_decay_rate *= round((strength + 1) ** FOOD_FIRESTACK_DECAY_COEFF, 1)
	return ..()

/datum/status_effect/food/fire_stack_decay/be_replaced()
	owner.fire_stack_decay_rate /= round((strength + 1) ** FOOD_FIRESTACK_DECAY_COEFF, 1)
	return ..()

/datum/status_effect/food/fire_stack_decay/on_remove()
	owner.fire_stack_decay_rate /= round((strength + 1) ** FOOD_FIRESTACK_DECAY_COEFF, 1)
	return ..()

/atom/movable/screen/alert/status_effect/food/fire_stack_decay
	name = "Briny meal"
	desc = "This meal feels like the cool, refreshing seaside on a nice day..."


#undef FOOD_FIRESTACK_DECAY_COEFF
