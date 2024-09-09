/// The return type which is a specially handled list which can contain both an error and the expected result.
/// This define is so you can at a glance know if something is just returning a normal list or a Result list
#define RESULT /list

#define IS_ERROR 1
#define IS_OK 2

#define RESULT_OK(VALUE) list(VALUE, IS_OK)
#define RESULT_ERR(ERROR) list(ERROR, IS_ERROR)

// these are public so coders can use these elsewhere
#define RESULT_IS_OK(RET) (RET[2] == IS_OK)
#define RESULT_IS_ERR(RET) (RET[2] == IS_ERROR)

// fuck you dont make this public
#define RESULT_UNWRAP_UNSAFE(RET) (RET[1])

#define RESULT_ERR_HANDLE_NOOP 0
#define RESULT_ERR_HANDLE_RETURN 1

/// Handles the unwrapping of a result wrapper with REQUIRED error handling.
/// The error handler proc will be called with the string error message.
/// The error handler can return RESULT_ERR_HANDLE_RETURN to cause a return on current scope.
#define RESULT_UNWRAP(RET, OUT, ERR_HANDLER) \
	if(RESULT_IS_OK(RET)) { \
		##OUT = RESULT_UNWRAP_UNSAFE(##RET); \
	} else { \
		if(##ERR_HANDLER(RET[1]) == RESULT_ERR_HANDLE_RETURN) { \
			return; \
		}; \
	};
