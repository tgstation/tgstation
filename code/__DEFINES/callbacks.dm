#define GLOBAL_PROC "some_magic_bullshit"
/// A shorthand for the callback datum, [documented here](datum/callback.html)
#define CALLBACK new /datum/callback
#define INVOKE_ASYNC(proc_owner, proc_path, proc_arguments...) \
	if ((proc_owner) == GLOBAL_PROC){ \
		spawn (-1); \
			call(proc_path)(##proc_arguments); \
	} \
	else { \
		spawn(-1); \
			call(proc_owner, proc_path)(##proc_arguments); \
	} \

/// like CALLBACK but specifically for verb callbacks
#define VERB_CALLBACK new /datum/callback/verb_callback
