/// gives us the stack trace from CRASH() without ending the current proc.
/// Do not call directly, use the [stack_trace] macro instead.
/proc/_stack_trace(message, file, line)
	CRASH("[message] ([file]:[line])")
