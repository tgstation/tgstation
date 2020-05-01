/**
 * Pick From Weighted Lists
 * The first value of a list is the weight, which is equal to the number of entries into the pick.
 * Additional entries are either "end_point"s which are endpoints for spawn selection OR they are unique named lists with their own weight element.
 * This supports nested, weighted lists, an example can be found in arcade.dm with "arcade_prize_pool"
 *
 * The proc adds the list weights together and rolls a number with the combined weight as the cap.
 * It then goes through the list deducting the weight values of each entry in sequence until it hits 0 or less.
 * Once the value hits 0 the loop breaks and the list selected provides it's "element_list" as a result.
 *
 * Arguments
 * list to pick from ~ this is the list it will be reading and moving through
 *
 */

/proc/pick_from_weighted_lists(list/list_to_pick_from)
	var/choice_pool = list_to_pick_from
	while(!choice_pool["end_point"])
		var/weight = 0
		for(var/element in (choice_pool - "weight")) //We first check how much is the total weight.
			weight += choice_pool[element]["weight"]
		if(!weight) //To prevent infinite loops.
			CRASH("pick_from_weighted_lists() ran with a list lacking both element_list and weight indexes.")
		var/random_roll = rand(1, weight) //Then we run the random roll.
		for(var/element in (choice_pool - "weight")) //Let's scan where do we hit.
			random_roll -= choice_pool[element]["weight"]
			if(random_roll <= 0) //Jackpot!
				choice_pool = choice_pool[element]
				break
	return choice_pool["end_point"]
