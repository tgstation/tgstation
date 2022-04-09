///Tosses an error into the exception list with a manual error name. Use ONLY when a stack_trace call is pointless.
#define THROW_ERROR(message) INVOKE_ASYNC(_test_error(message, __FILE__, __LINE__))

///gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null

/proc/_test_error(error_text, file, line) //DO NOT CALL DIRECTLY. Use THROW_ERROR().
	set waitfor = FALSE

	var/exception/tossed_error = new /exception("MANUAL ERROR: [error_text]", file, line)
	world.Error(tossed_error)
