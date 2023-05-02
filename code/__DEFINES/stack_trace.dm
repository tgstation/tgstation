/// gives us the stack trace from CRASH() without ending the current proc.
#define stack_trace(message) _stack_trace(message, __TG_FILE__, __LINE__)
