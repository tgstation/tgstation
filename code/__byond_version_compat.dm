// This file contains defines allowing targeting byond versions newer than the supported

#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif


// So we want to have compile time guarantees these procs exist, unfortunately 515 killed the .proc/procname syntax so we have to use nameof()
#if DM_VERSION < 515
#define PROC_REF(X) (.proc/##X)
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
#define PROC_REF_STATIC(X) (.proc/##X)
#define GLOBAL_PROC_REF(X) (/proc/##X)
#else
#define PROC_REF(X) (nameof(.proc/##X))
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
#define PROC_REF_STATIC(X) (nameof(.proc/##X))
#define GLOBAL_PROC_REF(X) (nameof(.proc/##X))
#endif
