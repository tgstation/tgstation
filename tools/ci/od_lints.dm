//1000-1999
#pragma FileAlreadyIncluded disabled
#pragma MissingIncludedFile disabled
#pragma MisplacedDirective error
#pragma UndefineMissingDirective error
#pragma DefinedMissingParen error
#pragma ErrorDirective error
#pragma WarningDirective error
#pragma MiscapitalizedDirective error

//2000-2999
#pragma SoftReservedKeyword error
#pragma DuplicateVariable error
#pragma DuplicateProcDefinition error
#pragma TooManyArguments error
#pragma PointlessParentCall error
#pragma PointlessBuiltinCall error
#pragma SuspiciousMatrixCall error
#pragma MalformedRange error
#pragma InvalidRange error
#pragma InvalidSetStatement error
#pragma InvalidOverride error
#pragma DanglingVarType error
#pragma MissingInterpolatedExpression error
#pragma AmbiguousResourcePath error
#pragma SuspiciousSwitchCase error

//3000-3999
#pragma EmptyBlock notice // Set to error when it supports {} blocks
#pragma EmptyProc disabled // NOTE: If you enable this in OD's default pragma config file, it will emit for OD's DMStandard. Put it in your codebase's pragma config file.
#pragma UnsafeClientAccess disabled // NOTE: Only checks for unsafe accesses like "client.foobar" and doesn't consider if the client was already null-checked earlier in the proc
#pragma AssignmentInConditional warning
