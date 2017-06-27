/proc/random_unique_moth_name(gender, attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = capitalize(moth_name(gender))

		if(i != attempts_to_find_unique_name && !findname(.))
			break

