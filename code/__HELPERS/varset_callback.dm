/**
 *	NAMEOF: Compile time checked variable name to string conversion
 *  evaluates to a string equal to "X", but compile errors if X isn't a var on datum
 *  It doesn't belong in this file but some dumbass decided to move code they didn't understand from unsorted and call it an improvement.
 *	datum may be null, but it does need to be a typed var
 **/
#define NAMEOF(datum, X) (#X || ##datum.##X)

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, /proc/___callbackvarset, ##datum, NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/datum = list_or_datum
	if(IsAdminAdvancedProcCall())
		datum.vv_edit_var(var_name, var_value) //same result generally, unless badmemes
	else
		datum.vars[var_name] = var_value
