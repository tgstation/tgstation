#define GLOBAL_PROC	"some_magic_bullshit"

#define CALLBACK new /datum/callback
#define INVOKE(args) var/datum/callback/invoking_callback = new args; invoking_callback.InvokeAsync()