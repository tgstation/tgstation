/proc/cmp_mob_playtime_asc(mob/a, mob/b)
	return cmp_numeric_asc(a?.client?.get_exp_living(TRUE), b?.client?.get_exp_living(TRUE))

/proc/cmp_mob_playtime_dsc(mob/a, mob/b)
	return cmp_numeric_dsc(a?.client?.get_exp_living(TRUE), b?.client?.get_exp_living(TRUE))
