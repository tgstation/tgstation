
/*
SHIT'S MAGIC, By Remie Richards

HOW TO USE:

PROP:
	var/somevar = someval
	IS NOW
	PROP(somevar, someval)

	The auto generated variables are:
	prop_somevar
	prop_getters_somevar
	prop_setters_somevar

	However you should only access "somevar" (without the quotes), using the correct macros
	Using these macros will convert somevar into prop_somevar in the background naturally
	Intended to make this whole thing feel nicer to use

PROPN:
	Same as above except the getter/setter lists start null
	This lets you avoid byond's hidden, costly Init() procs

LAZYINIT_PROPLISTS:
	Initialises all non-null getter/setter lists to an empty list
	Useful only if you *NEED* all getter/setter lists to exist and you used PROPN()

GET:
	var/variable = someobj.somevar
	IS NOW
	var/variable = GET(someobj, somevar)

SET:
	someobj.somevar = someval
	IS NOW
	SET(someobj, somevar, someval)

[SET/GET]_MODIFY:
	Same as their above equivalents, except they have slightly higher costs due to allowing for the returned/set value to be modified
	GET_MODIFY is more costly (only one proc call more) than SET_MODIFY due to needing to call a proc for ease-of-use

	*The non-MODIFY versions can be considered read/write traps, as opposed to getters/setters

ADD_[SETTER/GETTER]:
	Wrappers around LAZYADD() that add a setter/getter callback datum to the appropriate list

REMOVE_[SETTER/GETTER]:
	Wrappers around LAZYREMOVE() that remove a setter/getter callback datum from the appropriate list

*/


//Define a propery + associated set/get lists
#define PROP(propname, propval) 				\
	var/prop_##propname = ##propval;			\
	var/list/prop_getters_##propname = list();	\
	var/list/prop_setters_##propname = list();


//See above, but null lists, so you don't have to suffer at the hands of byond's hidden init() procs
#define PROPN(propname, propval) 				\
	var/prop_##propname = ##propval;			\
	var/list/prop_getters_##propname;			\
	var/list/prop_setters_##propname;


//Initialises all property set/get lists that are null to list()
#define LAZYINIT_PROPLISTS(propobject)													\
	var/list/VARS_##propobject = ##propobject.vars;										\
	for(var/variable in VARS_##propobject) 												\
	{																					\
		if(findtext(variable, "prop_getters") || findtext(variable, "prop_setters"))	\
		{																				\
			if(##propobject.vars[variable] == null)										\
			{																			\
				##propobject.vars[variable] = list();									\
			}																			\
		}																				\
	}																					\


//Gets a property, and calls all /datum/callbacks inside the prop_getters_PROPNAME list
#define GET(propobject, propname)	##propobject.prop_##propname;	\
	var/list/GETTERS_##propname = ##propobject.prop_getters_##propname; \
	for(var/##propname_cb in GETTERS_##propname) 						\
	{																	\
		var/datum/callback/CB_##propname = ##propname_cb;				\
		CB_##propname.Invoke(##propobject.prop_##propname)				\
	};


//Same as the above, except the final set value can be modified by each of the getters
//Cascading, this means if A modifies it then B recieves the modified value from A!
//NULL IS NOT A VALID GETTER RETURN VALUE
#define GET_MODIFY(propobject, propname)	get_modified_property_value(##propobject, #propname)

//must be proc to ensure var/somevar = GET_MODIFY(...)
/proc/get_modified_property_value(datum/propobj, propnamestring)
	. = propobj.vars["prop_[propnamestring]"]
	var/list/getters = propobj.vars["prop_getters_[propnamestring]"]
	for(var/cb in getters)
		var/datum/callback/CB = cb
		var/override = CB.Invoke(.)
		if(override != null)
			. = override


//Sets a property, and calls all /datum/callbacks inside the prop_setters_PROPNAME list
#define SET(propobject, propname, propval)  							\
	##propobject.prop_##propname = ##propval; 							\
	var/list/SETTERS_##propname = ##propobject.prop_setters_##propname; \
	for(var/##propname_cb in SETTERS_##propname) 						\
	{																	\
		var/datum/callback/CB_##propname = ##propname_cb;				\
		CB_##propname.Invoke(##propval)									\
	};


//Same as the above, except the final set value can be modified by each of the setters
//Cascading, this means if A modifies it then B recieves the modified value from A!
//NULL IS NOT A VALID SETTER RETURN VALUE
#define SET_MODIFY(propobject, propname, propval)  								\
	var/newval_##propname = ##propval;											\
	var/list/SETTERS_##propname = ##propobject.prop_setters_##propname; 		\
	for(var/##propname_cb in SETTERS_##propname) 								\
	{																			\
		var/datum/callback/CB_##propname = ##propname_cb;						\
		var/override_##propname = CB_##propname.Invoke(newval_##propname);		\
		if(override_##propname != null)											\
		{																		\
			newval_##propname = override_##propname								\
		}																		\
	};																			\
	##propobject.prop_##propname = newval_##propname; 							\


//Just to make this feel more legit
#define ADD_GETTER(propobject, propname, getter_callback)	\
	LAZYADD(##propobject.prop_getters_##propname, ##getter_callback)

#define ADD_SETTER(propobject, propname, setter_callback)	\
	LAZYADD(##propobject.prop_setters_##propname, ##setter_callback)

//These two require you to have held a reference to the getter/setter callback
//(or obtain one from the lists, which is naughty don't do that)
#define REMOVE_GETTER(propobject, propname, getter_callback)	\
	LAZYREMOVE(##propobject.prop_getters_##propname, ##getter_callback)

#define REMOVE_SETTER(propobject, propname, setter_callback)	\
	LAZYREMOVE(##propobject.prop_setters_##propname, ##setter_callback)
