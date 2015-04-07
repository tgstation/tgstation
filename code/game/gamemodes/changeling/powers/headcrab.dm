/obj/effect/proc_holder/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifce our current body in a moment of need, stunning and damaging everyone nearby. If a dead body is nearby we infect it to raise again."
	chemical_cost = 20
	dna_cost = 1
	req_human = 1

/obj/effect/proc_holder/changeling/headcrab/sting_action(var/mob/user)
	explosion(get_turf(user),0,0,2,0,silent=1)
	var/turf = get_turf(user)
	spawn(5) // So it's not killed in explosion
		var/mob/living/simple_animal/hostile/headcrab/crab = new(turf)
		crab.origin = user.mind
	user.gib()
	feedback_add_details("changeling_powers","LR")
	return 1