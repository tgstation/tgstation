/client/proc/ReportIssue()
    //Big todo

/world/proc/CreateGithubIssue(title, body)
    . = global.github_api_key && config.githubrepoid
    if(.)
        call(GITHUB_ISSUES_DLL, GITHUB_ISSUES_CREATE)("[global.github_api_key]", "[config.githubrepoid]", title, body)

/world/proc/AppendGithubIssue(id, appendage)
    . = global.github_api_key && config.githubrepoid
    if(.)
        call(GITHUB_ISSUES_DLL, GITHUB_ISSUES_APPEND)("[global.github_api_key]", "[config.githubrepoid]", "[id]", appendage)