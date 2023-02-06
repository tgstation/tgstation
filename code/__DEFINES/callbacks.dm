#define GLOBAL_PROC "some_magic_bullshit"
/// A shorthand for the callback datum, [documented here](datum/callback.html)
#define CALLBACK new /datum/callback
#define INVOKE_ASYNC(TRG, PR, ARG...) if ((TRG) == GLOBAL_PROC) { spawn (-1) call(PR)(##ARG); } else { spawn(-1) call(TRG, PR)(##ARG); }
/// like CALLBACK but specifically for verb callbacks
#define VERB_CALLBACK new /datum/callback/verb_callback
