/client/proc/ReportIssue()
    //Big todo

/world/proc/CreateGithubIssue(title, body)
    if(!RunningService())
        return "Cannot create issue, server tools not detected!"

    var/rid = config.githubrepoid
    if(!rid)
        return "Cannot create issue, no github repo ID configured!"
    var/result = ServiceTransaction(SERVICE_REQUEST_GITHUB_CREATE_ISSUE, list (
        SERVICE_TRANSACTION_PARAM_GHI_REPOID = rid,
        SERVICE_TRANSACTION_PARAM_GHI_TITLE = title,
        SERVICE_TRANSACTION_PARAM_GHI_BODY = body
    ))

    if(!result)
        return "Operation timed out!";
    
    //list
    return "Issue Created: [result[SERVICE_TRANSACTION_PARAM_GHI_URL]]"

/world/proc/PostToGithubIssue(id, body)
    if(!RunningService())
        return "Cannot create issue, server tools not detected!"

    var/rid = config.githubrepoid
    if(!rid)
        return "Cannot post to issue, no github repo ID configured!"
    var/result = ServiceTransaction(SERVICE_REQUEST_GITHUB_CREATE_COMMENT, list (
        SERVICE_TRANSACTION_PARAM_GHI_REPOID = rid,
        SERVICE_TRANSACTION_PARAM_GHI_ID = id,
        SERVICE_TRANSACTION_PARAM_GHI_BODY = body
    ))

    if(!result)
        return "Operation timed out!"
    
    //list
    return "Commented on issue #[id]: [result[SERVICE_TRANSACTION_PARAM_GHI_URL]]"