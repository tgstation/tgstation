


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=10">
        <title>-tg-station/code/game/gamemodes/nuclear/nuclearbomb.dm at e31f8b6afed73cc66b74eb6ce02a6a7299939c45 · Ikarrus/-tg-station</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="https://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <meta property="og:image" content="https://github.global.ssl.fastly.net/images/modules/logos_page/Octocat.png">
    <meta name="hostname" content="github-fe129-cp1-prd.iad.github.net">
    <meta name="ruby" content="ruby 1.9.3p194-tcs-github-tcmalloc (e1c0c3f392) [x86_64-linux]">
    <link rel="assets" href="https://github.global.ssl.fastly.net/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035/">
    <link rel="xhr-socket" href="/_sockets" />
    


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="4AB0BDF5:2EF1:2265E:52A64A37" name="octolytics-dimension-request_id" /><meta content="2319040" name="octolytics-actor-id" /><meta content="Adrinus" name="octolytics-actor-login" /><meta content="729a9fc46569a3809fbb924c774c8921e8b1ef2ae30f57d4b53615c506f4a8f2" name="octolytics-actor-hash" />
    

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="0Itmz8Z9w4A+R99bu3z3TVOSkOGJkL9jdLtvtsNmoOA=" name="csrf-token" />

    <link href="https://github.global.ssl.fastly.net/assets/github-1cddff501e45a3bd3dd9bd109289016b0a6f5078.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://github.global.ssl.fastly.net/assets/github2-66df24787a23849c944bfddcdd8cd59077af5dd1.css" media="all" rel="stylesheet" type="text/css" />
    

    

      <script src="https://github.global.ssl.fastly.net/assets/frameworks-5970f5a0a3dcc441d5f7ff74326ffd59bbe9388e.js" type="text/javascript"></script>
      <script src="https://github.global.ssl.fastly.net/assets/github-8ce88caabed1ff1adea938157241afc74c47eb91.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="dba60f32ae5c652b9101caacea4e86ac">

        <link data-pjax-transient rel='permalink' href='/Ikarrus/-tg-station/blob/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm'>
  <meta property="og:title" content="-tg-station"/>
  <meta property="og:type" content="githubog:gitrepository"/>
  <meta property="og:url" content="https://github.com/Ikarrus/-tg-station"/>
  <meta property="og:image" content="https://github.global.ssl.fastly.net/images/gravatars/gravatar-user-420.png"/>
  <meta property="og:site_name" content="GitHub"/>
  <meta property="og:description" content="-tg-station - /tg/&#39;s SS13 branch"/>

  <meta name="description" content="-tg-station - /tg/&#39;s SS13 branch" />

  <meta content="3828067" name="octolytics-dimension-user_id" /><meta content="Ikarrus" name="octolytics-dimension-user_login" /><meta content="13575928" name="octolytics-dimension-repository_id" /><meta content="Ikarrus/-tg-station" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="true" name="octolytics-dimension-repository_is_fork" /><meta content="3234987" name="octolytics-dimension-repository_parent_id" /><meta content="tgstation/-tg-station" name="octolytics-dimension-repository_parent_nwo" /><meta content="3234987" name="octolytics-dimension-repository_network_root_id" /><meta content="tgstation/-tg-station" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45.atom" rel="alternate" title="Recent Commits to -tg-station:e31f8b6afed73cc66b74eb6ce02a6a7299939c45" type="application/atom+xml" />

  </head>


  <body class="logged_in  env-production windows vis-public fork page-blob">
    <div class="wrapper">
      
      
      
      


      <div class="header header-logged-in true">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/">
  <span class="mega-octicon octicon-mark-github"></span>
</a>

    
    <a href="/notifications" class="notification-indicator tooltipped downwards" data-gotokey="n" title="You have unread notifications">
        <span class="mail-status unread"></span>
</a>

      <div class="command-bar js-command-bar  in-repository">
          <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    data-username="Adrinus"
      data-repo="Ikarrus/-tg-station"
      data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45"
      data-sha="46128ecb93b9cec25682faee8f11e67aa9495dfb"
  >

    <input type="hidden" name="nwo" value="Ikarrus/-tg-station" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="octicon help tooltipped downwards" title="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
        <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
            <li><a href="https://gist.github.com">Gist</a></li>
            <li><a href="/blog">Blog</a></li>
          <li><a href="https://help.github.com">Help</a></li>
        </ul>
      </div>

    


  <ul id="user-links">
    <li>
      <a href="/Adrinus" class="name">
        <img height="20" src="https://1.gravatar.com/avatar/25ca93bb1cec212636d33da6c3d62f5b?d=https%3A%2F%2Fidenticons.github.com%2Fbb574fcc5c51891fa708cea3d9aea648.png&amp;r=x&amp;s=140" width="20" /> Adrinus
      </a>
    </li>

      <li>
        <a href="/new" id="new_repo" class="tooltipped downwards" title="Create a new repo" aria-label="Create a new repo">
          <span class="octicon octicon-repo-create"></span>
        </a>
      </li>

      <li>
        <a href="/settings/profile" id="account_settings"
          class="tooltipped downwards"
          aria-label="Account settings "
          title="Account settings ">
          <span class="octicon octicon-tools"></span>
        </a>
      </li>
      <li>
        <a class="tooltipped downwards" href="/logout" data-method="post" id="logout" title="Sign out" aria-label="Sign out">
          <span class="octicon octicon-log-out"></span>
        </a>
      </li>

  </ul>

<div class="js-new-dropdown-contents hidden">
  

<ul class="dropdown-menu">
  <li>
    <a href="/new"><span class="octicon octicon-repo-create"></span> New repository</a>
  </li>
  <li>
    <a href="/organizations/new"><span class="octicon octicon-organization"></span> New organization</a>
  </li>



</ul>

</div>


    
  </div>
</div>

      

      




          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">

    <li class="subscription">
      <form accept-charset="UTF-8" action="/notifications/subscribe" class="js-social-container" data-autosubmit="true" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="0Itmz8Z9w4A+R99bu3z3TVOSkOGJkL9jdLtvtsNmoOA=" /></div>  <input id="repository_id" name="repository_id" type="hidden" value="13575928" />

    <div class="select-menu js-menu-container js-select-menu">
      <a class="social-count js-social-count" href="/Ikarrus/-tg-station/watchers">
        1
      </a>
      <span class="minibutton select-menu-button with-count js-menu-target" role="button" tabindex="0">
        <span class="js-select-button">
          <span class="octicon octicon-eye-watch"></span>
          Watch
        </span>
      </span>

      <div class="select-menu-modal-holder">
        <div class="select-menu-modal subscription-menu-modal js-menu-content">
          <div class="select-menu-header">
            <span class="select-menu-title">Notification status</span>
            <span class="octicon octicon-remove-close js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-list js-navigation-container" role="menu">

            <div class="select-menu-item js-navigation-item selected" role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input checked="checked" id="do_included" name="do" type="radio" value="included" />
                <h4>Not watching</h4>
                <span class="description">You only receive notifications for conversations in which you participate or are @mentioned.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-eye-watch"></span>
                  Watch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input id="do_subscribed" name="do" type="radio" value="subscribed" />
                <h4>Watching</h4>
                <span class="description">You receive notifications for all conversations in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-eye-unwatch"></span>
                  Unwatch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <div class="select-menu-item-text">
                <input id="do_ignore" name="do" type="radio" value="ignore" />
                <h4>Ignoring</h4>
                <span class="description">You do not receive any notifications for conversations in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="octicon octicon-mute"></span>
                  Stop ignoring
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

</form>
    </li>

  <li>
  

  <div class="js-toggler-container js-social-container starring-container ">
    <a href="/Ikarrus/-tg-station/unstar"
      class="minibutton with-count js-toggler-target star-button starred upwards"
      title="Unstar this repository" data-remote="true" data-method="post" rel="nofollow">
      <span class="octicon octicon-star-delete"></span><span class="text">Unstar</span>
    </a>

    <a href="/Ikarrus/-tg-station/star"
      class="minibutton with-count js-toggler-target star-button unstarred upwards"
      title="Star this repository" data-remote="true" data-method="post" rel="nofollow">
      <span class="octicon octicon-star"></span><span class="text">Star</span>
    </a>

      <a class="social-count js-social-count" href="/Ikarrus/-tg-station/stargazers">
        0
      </a>
  </div>

  </li>


        <li>
          <a href="/Ikarrus/-tg-station/fork" class="minibutton with-count js-toggler-target fork-button lighter upwards" title="Fork this repo" rel="nofollow" data-method="post">
            <span class="octicon octicon-git-branch-create"></span><span class="text">Fork</span>
          </a>
          <a href="/Ikarrus/-tg-station/network" class="social-count">328</a>
        </li>


</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo-forked"></span>
          <span class="author">
            <a href="/Ikarrus" class="url fn" itemprop="url" rel="author"><span itemprop="title">Ikarrus</span></a>
          </span>
          <span class="repohead-name-divider">/</span>
          <strong><a href="/Ikarrus/-tg-station" class="js-current-repository js-repo-home-link">-tg-station</a></strong>

          <span class="page-context-loader">
            <img alt="Octocat-spinner-32" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

            <span class="fork-flag">
              <span class="text">forked from <a href="/tgstation/-tg-station">tgstation/-tg-station</a></span>
            </span>
        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">

      <div class="repository-with-sidebar repo-container  ">

        <div class="repository-sidebar">
            

<div class="sunken-menu vertical-right repo-nav js-repo-nav js-repository-container-pjax js-octicon-loaders">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped leftwards" title="Code">
        <a href="/Ikarrus/-tg-station" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-gotokey="c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /Ikarrus/-tg-station">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


      <li class="tooltipped leftwards" title="Pull Requests">
        <a href="/Ikarrus/-tg-station/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-gotokey="p" data-selected-links="repo_pulls /Ikarrus/-tg-station/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>0</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


        <li class="tooltipped leftwards" title="Wiki">
          <a href="/Ikarrus/-tg-station/wiki" aria-label="Wiki" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_wiki /Ikarrus/-tg-station/wiki">
            <span class="octicon octicon-book"></span> <span class="full-word">Wiki</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>
    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped leftwards" title="Pulse">
        <a href="/Ikarrus/-tg-station/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /Ikarrus/-tg-station/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Graphs">
        <a href="/Ikarrus/-tg-station/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /Ikarrus/-tg-station/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Network">
        <a href="/Ikarrus/-tg-station/network" aria-label="Network" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-selected-links="repo_network /Ikarrus/-tg-station/network">
          <span class="octicon octicon-git-branch"></span> <span class="full-word">Network</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

            <div class="only-with-full-nav">
              

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/Ikarrus/-tg-station.git" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/Ikarrus/-tg-station.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="ssh"
  data-url="/users/set_protocol?protocol_selector=ssh&amp;protocol_type=clone">
  <h3><strong>SSH</strong> clone URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="git@github.com:Ikarrus/-tg-station.git" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="git@github.com:Ikarrus/-tg-station.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>
  <div class="clone-url-box">
    <input type="text" class="clone js-url-field"
           value="https://github.com/Ikarrus/-tg-station" readonly="readonly">

    <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/Ikarrus/-tg-station" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
      <a href="#" class="js-clone-selector" data-protocol="ssh">SSH</a>,
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <span class="octicon help tooltipped upwards" title="Get help on which URL is right for you.">
    <a href="https://help.github.com/articles/which-remote-url-should-i-use">
    <span class="octicon octicon-question"></span>
    </a>
  </span>
</p>


  <a href="http://windows.github.com" class="minibutton sidebar-button">
    <span class="octicon octicon-device-desktop"></span>
    Clone in Desktop
  </a>

              <a href="/Ikarrus/-tg-station/archive/e31f8b6afed73cc66b74eb6ce02a6a7299939c45.zip"
                 class="minibutton sidebar-button"
                 title="Download this repository as a zip file"
                 rel="nofollow">
                <span class="octicon octicon-cloud-download"></span>
                Download ZIP
              </a>
            </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:9b0b2d22a544e9c159c687b0612e5893 -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<a href="/Ikarrus/-tg-station/find/e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-pjax data-hotkey="t" class="js-show-file-finder" style="display:none">Show File Finder</a>

<div class="file-navigation">
  

<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target" data-hotkey="w"
    data-master-branch="master"
    data-ref=""
    role="button" aria-label="Switch branches or tags" tabindex="0">
    <span class="octicon octicon-git-branch"></span>
    <i>tree:</i>
    <span class="js-select-button">e31f8b6afe</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax>

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-remove-close js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/500/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="500"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="500">500</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/Access/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="Access"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="Access">Access</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/adminnotice/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="adminnotice"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="adminnotice">adminnotice</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/emergency/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="emergency"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="emergency">emergency</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/freq/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="freq"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="freq">freq</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/fucklasers/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="fucklasers"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="fucklasers">fucklasers</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/hairburn/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="hairburn"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="hairburn">hairburn</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/jammin/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="jammin"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="jammin">jammin</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/master/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/miscmapfix/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="miscmapfix"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="miscmapfix">miscmapfix</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/nuke/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="nuke"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="nuke">nuke</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/nuke_ready/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="nuke_ready"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="nuke_ready">nuke_ready</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/portaflash/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="portaflash"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="portaflash">portaflash</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/portaoverlay/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="portaoverlay"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="portaoverlay">portaoverlay</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/telecompower/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="telecompower"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="telecompower">telecompower</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Ikarrus/-tg-station/blob/voteresults/code/game/gamemodes/nuclear/nuclearbomb.dm"
                 data-name="voteresults"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target"
                 title="voteresults">voteresults</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Ikarrus/-tg-station/tree/e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-direction="back" data-pjax="true" itemscope="url" rel="nofollow"><span itemprop="title">-tg-station</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Ikarrus/-tg-station/tree/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code" data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-direction="back" data-pjax="true" itemscope="url" rel="nofollow"><span itemprop="title">code</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Ikarrus/-tg-station/tree/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game" data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-direction="back" data-pjax="true" itemscope="url" rel="nofollow"><span itemprop="title">game</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Ikarrus/-tg-station/tree/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes" data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-direction="back" data-pjax="true" itemscope="url" rel="nofollow"><span itemprop="title">gamemodes</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Ikarrus/-tg-station/tree/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear" data-branch="e31f8b6afed73cc66b74eb6ce02a6a7299939c45" data-direction="back" data-pjax="true" itemscope="url" rel="nofollow"><span itemprop="title">nuclear</span></a></span><span class="separator"> / </span><strong class="final-path">nuclearbomb.dm</strong> <span class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="code/game/gamemodes/nuclear/nuclearbomb.dm" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>



  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://1.gravatar.com/avatar/5c293028a8a9ed9066737284d0009d95?d=https%3A%2F%2Fidenticons.github.com%2Fb8cfff7877a3695d4b30db1aa6b36994.png&amp;r=x&amp;s=140" width="24" />
    <span class="author"><a href="/Ikarrus" rel="author">Ikarrus</a></span>
    <time class="js-relative-date" datetime="2013-12-08T09:33:53-08:00" title="2013-12-08 09:33:53">December 08, 2013</time>
    <div class="commit-title">
        <a href="/Ikarrus/-tg-station/commit/e31f8b6afed73cc66b74eb6ce02a6a7299939c45" class="message" data-pjax="true" title="Added feedback when anchoring fails">Added feedback when anchoring fails</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>5</strong> contributors</a></p>
          <a class="avatar tooltipped downwards" title="Giacom" href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm?author=Giacom"><img height="20" src="https://2.gravatar.com/avatar/5f3d22e88974d56da3f3705de7f96542?d=https%3A%2F%2Fidenticons.github.com%2Fdb9285a4cd5594ce7035b91f9747cff8.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="Ikarrus" href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm?author=Ikarrus"><img height="20" src="https://1.gravatar.com/avatar/5c293028a8a9ed9066737284d0009d95?d=https%3A%2F%2Fidenticons.github.com%2Fb8cfff7877a3695d4b30db1aa6b36994.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="errorage" href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm?author=errorage"><img height="20" src="https://1.gravatar.com/avatar/a844db42a1c8392017e6695201f43356?d=https%3A%2F%2Fidenticons.github.com%2Ff5eb56aa8ae6404d209a5af400f82130.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="Aranclanos" href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm?author=Aranclanos"><img height="20" src="https://0.gravatar.com/avatar/d7832db0b1655aca490c6b545ae8294a?d=https%3A%2F%2Fidenticons.github.com%2F5afbc5940313bc2b2fe8c92a0452de2a.png&amp;r=x&amp;s=140" width="20" /></a>
    <a class="avatar tooltipped downwards" title="Cheridan" href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm?author=Cheridan"><img height="20" src="https://1.gravatar.com/avatar/95bad0ce4a8b422a88b5450daa0eb0d4?d=https%3A%2F%2Fidenticons.github.com%2F3bc3239922299f4e7030568eea6296a8.png&amp;r=x&amp;s=140" width="20" /></a>


    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img height="24" src="https://2.gravatar.com/avatar/5f3d22e88974d56da3f3705de7f96542?d=https%3A%2F%2Fidenticons.github.com%2Fdb9285a4cd5594ce7035b91f9747cff8.png&amp;r=x&amp;s=140" width="24" />
            <a href="/Giacom">Giacom</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://1.gravatar.com/avatar/5c293028a8a9ed9066737284d0009d95?d=https%3A%2F%2Fidenticons.github.com%2Fb8cfff7877a3695d4b30db1aa6b36994.png&amp;r=x&amp;s=140" width="24" />
            <a href="/Ikarrus">Ikarrus</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://1.gravatar.com/avatar/a844db42a1c8392017e6695201f43356?d=https%3A%2F%2Fidenticons.github.com%2Ff5eb56aa8ae6404d209a5af400f82130.png&amp;r=x&amp;s=140" width="24" />
            <a href="/errorage">errorage</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://0.gravatar.com/avatar/d7832db0b1655aca490c6b545ae8294a?d=https%3A%2F%2Fidenticons.github.com%2F5afbc5940313bc2b2fe8c92a0452de2a.png&amp;r=x&amp;s=140" width="24" />
            <a href="/Aranclanos">Aranclanos</a>
          </li>
          <li class="facebox-user-list-item">
            <img height="24" src="https://1.gravatar.com/avatar/95bad0ce4a8b422a88b5450daa0eb0d4?d=https%3A%2F%2Fidenticons.github.com%2F3bc3239922299f4e7030568eea6296a8.png&amp;r=x&amp;s=140" width="24" />
            <a href="/Cheridan">Cheridan</a>
          </li>
      </ul>
    </div>
  </div>

<div id="files" class="bubble">
  <div class="file">
    <div class="meta">
      <div class="info">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">file</span>
          <span>214 lines (193 sloc)</span>
        <span>8.411 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled tooltipped leftwards" href="#"
                 title="You must be on a branch to make or propose changes to this file">Edit</a>
          <a href="/Ikarrus/-tg-station/raw/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm" class="button minibutton " id="raw-url">Raw</a>
            <a href="/Ikarrus/-tg-station/blame/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm" class="button minibutton ">Blame</a>
          <a href="/Ikarrus/-tg-station/commits/e31f8b6afed73cc66b74eb6ce02a6a7299939c45/code/game/gamemodes/nuclear/nuclearbomb.dm" class="button minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
          <a class="minibutton danger disabled empty-icon tooltipped leftwards" href="#"
             title="You must be signed in and on a branch to make or propose changes">
          Delete
        </a>
      </div><!-- /.actions -->

    </div>
        <div class="blob-wrapper data type-dm js-blob-data">
        <table class="file-code file-diff">
          <tr class="file-code-line">
            <td class="blob-line-nums">
              <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>
<span id="L80" rel="#L80">80</span>
<span id="L81" rel="#L81">81</span>
<span id="L82" rel="#L82">82</span>
<span id="L83" rel="#L83">83</span>
<span id="L84" rel="#L84">84</span>
<span id="L85" rel="#L85">85</span>
<span id="L86" rel="#L86">86</span>
<span id="L87" rel="#L87">87</span>
<span id="L88" rel="#L88">88</span>
<span id="L89" rel="#L89">89</span>
<span id="L90" rel="#L90">90</span>
<span id="L91" rel="#L91">91</span>
<span id="L92" rel="#L92">92</span>
<span id="L93" rel="#L93">93</span>
<span id="L94" rel="#L94">94</span>
<span id="L95" rel="#L95">95</span>
<span id="L96" rel="#L96">96</span>
<span id="L97" rel="#L97">97</span>
<span id="L98" rel="#L98">98</span>
<span id="L99" rel="#L99">99</span>
<span id="L100" rel="#L100">100</span>
<span id="L101" rel="#L101">101</span>
<span id="L102" rel="#L102">102</span>
<span id="L103" rel="#L103">103</span>
<span id="L104" rel="#L104">104</span>
<span id="L105" rel="#L105">105</span>
<span id="L106" rel="#L106">106</span>
<span id="L107" rel="#L107">107</span>
<span id="L108" rel="#L108">108</span>
<span id="L109" rel="#L109">109</span>
<span id="L110" rel="#L110">110</span>
<span id="L111" rel="#L111">111</span>
<span id="L112" rel="#L112">112</span>
<span id="L113" rel="#L113">113</span>
<span id="L114" rel="#L114">114</span>
<span id="L115" rel="#L115">115</span>
<span id="L116" rel="#L116">116</span>
<span id="L117" rel="#L117">117</span>
<span id="L118" rel="#L118">118</span>
<span id="L119" rel="#L119">119</span>
<span id="L120" rel="#L120">120</span>
<span id="L121" rel="#L121">121</span>
<span id="L122" rel="#L122">122</span>
<span id="L123" rel="#L123">123</span>
<span id="L124" rel="#L124">124</span>
<span id="L125" rel="#L125">125</span>
<span id="L126" rel="#L126">126</span>
<span id="L127" rel="#L127">127</span>
<span id="L128" rel="#L128">128</span>
<span id="L129" rel="#L129">129</span>
<span id="L130" rel="#L130">130</span>
<span id="L131" rel="#L131">131</span>
<span id="L132" rel="#L132">132</span>
<span id="L133" rel="#L133">133</span>
<span id="L134" rel="#L134">134</span>
<span id="L135" rel="#L135">135</span>
<span id="L136" rel="#L136">136</span>
<span id="L137" rel="#L137">137</span>
<span id="L138" rel="#L138">138</span>
<span id="L139" rel="#L139">139</span>
<span id="L140" rel="#L140">140</span>
<span id="L141" rel="#L141">141</span>
<span id="L142" rel="#L142">142</span>
<span id="L143" rel="#L143">143</span>
<span id="L144" rel="#L144">144</span>
<span id="L145" rel="#L145">145</span>
<span id="L146" rel="#L146">146</span>
<span id="L147" rel="#L147">147</span>
<span id="L148" rel="#L148">148</span>
<span id="L149" rel="#L149">149</span>
<span id="L150" rel="#L150">150</span>
<span id="L151" rel="#L151">151</span>
<span id="L152" rel="#L152">152</span>
<span id="L153" rel="#L153">153</span>
<span id="L154" rel="#L154">154</span>
<span id="L155" rel="#L155">155</span>
<span id="L156" rel="#L156">156</span>
<span id="L157" rel="#L157">157</span>
<span id="L158" rel="#L158">158</span>
<span id="L159" rel="#L159">159</span>
<span id="L160" rel="#L160">160</span>
<span id="L161" rel="#L161">161</span>
<span id="L162" rel="#L162">162</span>
<span id="L163" rel="#L163">163</span>
<span id="L164" rel="#L164">164</span>
<span id="L165" rel="#L165">165</span>
<span id="L166" rel="#L166">166</span>
<span id="L167" rel="#L167">167</span>
<span id="L168" rel="#L168">168</span>
<span id="L169" rel="#L169">169</span>
<span id="L170" rel="#L170">170</span>
<span id="L171" rel="#L171">171</span>
<span id="L172" rel="#L172">172</span>
<span id="L173" rel="#L173">173</span>
<span id="L174" rel="#L174">174</span>
<span id="L175" rel="#L175">175</span>
<span id="L176" rel="#L176">176</span>
<span id="L177" rel="#L177">177</span>
<span id="L178" rel="#L178">178</span>
<span id="L179" rel="#L179">179</span>
<span id="L180" rel="#L180">180</span>
<span id="L181" rel="#L181">181</span>
<span id="L182" rel="#L182">182</span>
<span id="L183" rel="#L183">183</span>
<span id="L184" rel="#L184">184</span>
<span id="L185" rel="#L185">185</span>
<span id="L186" rel="#L186">186</span>
<span id="L187" rel="#L187">187</span>
<span id="L188" rel="#L188">188</span>
<span id="L189" rel="#L189">189</span>
<span id="L190" rel="#L190">190</span>
<span id="L191" rel="#L191">191</span>
<span id="L192" rel="#L192">192</span>
<span id="L193" rel="#L193">193</span>
<span id="L194" rel="#L194">194</span>
<span id="L195" rel="#L195">195</span>
<span id="L196" rel="#L196">196</span>
<span id="L197" rel="#L197">197</span>
<span id="L198" rel="#L198">198</span>
<span id="L199" rel="#L199">199</span>
<span id="L200" rel="#L200">200</span>
<span id="L201" rel="#L201">201</span>
<span id="L202" rel="#L202">202</span>
<span id="L203" rel="#L203">203</span>
<span id="L204" rel="#L204">204</span>
<span id="L205" rel="#L205">205</span>
<span id="L206" rel="#L206">206</span>
<span id="L207" rel="#L207">207</span>
<span id="L208" rel="#L208">208</span>
<span id="L209" rel="#L209">209</span>
<span id="L210" rel="#L210">210</span>
<span id="L211" rel="#L211">211</span>
<span id="L212" rel="#L212">212</span>
<span id="L213" rel="#L213">213</span>

            </td>
            <td class="blob-line-code">
                    <div class="code-body highlight"><pre><div class='line' id='LC1'><span class="n">var</span><span class="o">/</span><span class="n">bomb_set</span></div><div class='line' id='LC2'><br/></div><div class='line' id='LC3'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span></div><div class='line' id='LC4'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">name</span> <span class="o">=</span> <span class="s">&quot;\improper Nuclear Fission Explosive&quot;</span></div><div class='line' id='LC5'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">desc</span> <span class="o">=</span> <span class="s">&quot;Uh oh. RUN!!!!&quot;</span></div><div class='line' id='LC6'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">icon</span> <span class="o">=</span> <span class="err">&#39;</span><span class="n">icons</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">stationobjs</span><span class="p">.</span><span class="n">dmi</span><span class="err">&#39;</span></div><div class='line' id='LC7'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">icon_state</span> <span class="o">=</span> <span class="s">&quot;nuclearbomb0&quot;</span></div><div class='line' id='LC8'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">density</span> <span class="o">=</span> <span class="mi">1</span></div><div class='line' id='LC9'><br/></div><div class='line' id='LC10'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">timeleft</span> <span class="o">=</span> <span class="mf">60.0</span></div><div class='line' id='LC11'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">timing</span> <span class="o">=</span> <span class="mf">0.0</span></div><div class='line' id='LC12'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">r_code</span> <span class="o">=</span> <span class="s">&quot;ADMIN&quot;</span></div><div class='line' id='LC13'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">code</span> <span class="o">=</span> <span class="s">&quot;&quot;</span></div><div class='line' id='LC14'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">yes_code</span> <span class="o">=</span> <span class="mf">0.0</span></div><div class='line' id='LC15'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">safety</span> <span class="o">=</span> <span class="mf">1.0</span></div><div class='line' id='LC16'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">disk</span><span class="o">/</span><span class="n">nuclear</span><span class="o">/</span><span class="n">auth</span> <span class="o">=</span> <span class="n">null</span></div><div class='line' id='LC17'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">flags</span> <span class="o">=</span> <span class="n">FPRINT</span></div><div class='line' id='LC18'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">use_power</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC19'><br/></div><div class='line' id='LC20'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">New</span><span class="p">()</span></div><div class='line' id='LC21'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">..()</span></div><div class='line' id='LC22'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">r_code</span> <span class="o">=</span> <span class="s">&quot;[rand(10000, 99999.0)]&quot;</span><span class="c1">//Creates a random code upon object spawn.</span></div><div class='line' id='LC23'><br/></div><div class='line' id='LC24'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">process</span><span class="p">()</span></div><div class='line' id='LC25'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span><span class="p">)</span></div><div class='line' id='LC26'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">bomb_set</span> <span class="o">=</span> <span class="mi">1</span> <span class="c1">//So long as there is one nuke timing, it means one nuke is armed.</span></div><div class='line' id='LC27'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="o">--</span></div><div class='line' id='LC28'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timeleft</span> <span class="o">&lt;=</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC29'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">explode</span><span class="p">()</span></div><div class='line' id='LC30'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC31'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">playsound</span><span class="p">(</span><span class="n">loc</span><span class="p">,</span> <span class="err">&#39;</span><span class="n">sound</span><span class="o">/</span><span class="n">items</span><span class="o">/</span><span class="n">timer</span><span class="p">.</span><span class="n">ogg</span><span class="err">&#39;</span><span class="p">,</span> <span class="mi">5</span><span class="p">,</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC32'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">for</span><span class="p">(</span><span class="n">var</span><span class="o">/</span><span class="n">mob</span><span class="o">/</span><span class="n">M</span> <span class="n">in</span> <span class="n">viewers</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="n">src</span><span class="p">))</span></div><div class='line' id='LC33'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">((</span><span class="n">M</span><span class="p">.</span><span class="n">client</span> <span class="o">&amp;&amp;</span> <span class="n">M</span><span class="p">.</span><span class="n">machine</span> <span class="o">==</span> <span class="n">src</span><span class="p">))</span></div><div class='line' id='LC34'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">attack_hand</span><span class="p">(</span><span class="n">M</span><span class="p">)</span></div><div class='line' id='LC35'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC36'><br/></div><div class='line' id='LC37'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">attackby</span><span class="p">(</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">I</span> <span class="n">as</span> <span class="n">obj</span><span class="p">,</span> <span class="n">mob</span><span class="o">/</span><span class="n">user</span> <span class="n">as</span> <span class="n">mob</span><span class="p">)</span></div><div class='line' id='LC38'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">istype</span><span class="p">(</span><span class="n">I</span><span class="p">,</span> <span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">disk</span><span class="o">/</span><span class="n">nuclear</span><span class="p">))</span></div><div class='line' id='LC39'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">usr</span><span class="p">.</span><span class="n">drop_item</span><span class="p">()</span></div><div class='line' id='LC40'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">I</span><span class="p">.</span><span class="n">loc</span> <span class="o">=</span> <span class="n">src</span></div><div class='line' id='LC41'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">auth</span> <span class="o">=</span> <span class="n">I</span></div><div class='line' id='LC42'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">add_fingerprint</span><span class="p">(</span><span class="n">user</span><span class="p">)</span></div><div class='line' id='LC43'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC44'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">..()</span></div><div class='line' id='LC45'><br/></div><div class='line' id='LC46'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">attack_paw</span><span class="p">(</span><span class="n">mob</span><span class="o">/</span><span class="n">user</span> <span class="n">as</span> <span class="n">mob</span><span class="p">)</span></div><div class='line' id='LC47'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span> <span class="n">src</span><span class="p">.</span><span class="n">attack_hand</span><span class="p">(</span><span class="n">user</span><span class="p">)</span></div><div class='line' id='LC48'><br/></div><div class='line' id='LC49'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">attack_hand</span><span class="p">(</span><span class="n">mob</span><span class="o">/</span><span class="n">user</span> <span class="n">as</span> <span class="n">mob</span><span class="p">)</span></div><div class='line' id='LC50'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">user</span><span class="p">.</span><span class="n">set_machine</span><span class="p">(</span><span class="n">src</span><span class="p">)</span></div><div class='line' id='LC51'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">dat</span> <span class="o">=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;&lt;TT&gt;</span><span class="se">\n</span><span class="s">Auth. Disk: &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];auth=1&#39;&gt;[]&lt;/A&gt;&lt;HR&gt;&quot;</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">auth</span> <span class="o">?</span> <span class="s">&quot;++++++++++&quot;</span> <span class="o">:</span> <span class="s">&quot;----------&quot;</span><span class="p">))</span></div><div class='line' id='LC52'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">auth</span><span class="p">)</span></div><div class='line' id='LC53'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">yes_code</span><span class="p">)</span></div><div class='line' id='LC54'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">dat</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;</span><span class="se">\n</span><span class="s">&lt;B&gt;Status&lt;/B&gt;: []-[]&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;B&gt;Timer&lt;/B&gt;: []&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Timer: [] &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];timer=1&#39;&gt;Toggle&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">Time: &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];time=-10&#39;&gt;-&lt;/A&gt; &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];time=-1&#39;&gt;-&lt;/A&gt; [] &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];time=1&#39;&gt;+&lt;/A&gt; &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];time=10&#39;&gt;+&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Safety: [] &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];safety=1&#39;&gt;Toggle&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">Anchor: [] &lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];anchor=1&#39;&gt;Toggle&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&quot;</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">?</span> <span class="s">&quot;Func/Set&quot;</span> <span class="o">:</span> <span class="s">&quot;Functional&quot;</span><span class="p">),</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;Safe&quot;</span> <span class="o">:</span> <span class="s">&quot;Engaged&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="o">?</span> <span class="s">&quot;Engaged&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">)</span></div><div class='line' id='LC55'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC56'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">dat</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;</span><span class="se">\n</span><span class="s">&lt;B&gt;Status&lt;/B&gt;: Auth. S2-[]&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;B&gt;Timer&lt;/B&gt;: []&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Timer: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Time: - - [] + +&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">[] Safety: Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Anchor: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">&quot;</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;Safe&quot;</span> <span class="o">:</span> <span class="s">&quot;Engaged&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="o">?</span> <span class="s">&quot;Engaged&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">))</span></div><div class='line' id='LC57'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC58'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span><span class="p">)</span></div><div class='line' id='LC59'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">dat</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;</span><span class="se">\n</span><span class="s">&lt;B&gt;Status&lt;/B&gt;: Set-[]&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;B&gt;Timer&lt;/B&gt;: []&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Timer: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Time: - - [] + +&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Safety: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Anchor: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">&quot;</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;Safe&quot;</span> <span class="o">:</span> <span class="s">&quot;Engaged&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="o">?</span> <span class="s">&quot;Engaged&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">))</span></div><div class='line' id='LC60'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC61'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">dat</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;</span><span class="se">\n</span><span class="s">&lt;B&gt;Status&lt;/B&gt;: Auth. S1-[]&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;B&gt;Timer&lt;/B&gt;: []&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Timer: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Time: - - [] + +&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;BR&gt;</span><span class="se">\n</span><span class="s">Safety: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">Anchor: [] Toggle&lt;BR&gt;</span><span class="se">\n</span><span class="s">&quot;</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;Safe&quot;</span> <span class="o">:</span> <span class="s">&quot;Engaged&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">,</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">?</span> <span class="s">&quot;On&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">),</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="o">?</span> <span class="s">&quot;Engaged&quot;</span> <span class="o">:</span> <span class="s">&quot;Off&quot;</span><span class="p">))</span></div><div class='line' id='LC62'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">message</span> <span class="o">=</span> <span class="s">&quot;AUTH&quot;</span></div><div class='line' id='LC63'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">auth</span><span class="p">)</span></div><div class='line' id='LC64'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">message</span> <span class="o">=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;[]&quot;</span><span class="p">,</span> <span class="n">src</span><span class="p">.</span><span class="n">code</span><span class="p">)</span></div><div class='line' id='LC65'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">yes_code</span><span class="p">)</span></div><div class='line' id='LC66'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">message</span> <span class="o">=</span> <span class="s">&quot;*****&quot;</span></div><div class='line' id='LC67'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">dat</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;&lt;HR&gt;</span><span class="se">\n</span><span class="s">&gt;[]&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=1&#39;&gt;1&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=2&#39;&gt;2&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=3&#39;&gt;3&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=4&#39;&gt;4&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=5&#39;&gt;5&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=6&#39;&gt;6&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=7&#39;&gt;7&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=8&#39;&gt;8&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=9&#39;&gt;9&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=R&#39;&gt;R&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=0&#39;&gt;0&lt;/A&gt;&lt;A href=&#39;?src=</span><span class="se">\r</span><span class="s">ef[];type=E&#39;&gt;E&lt;/A&gt;&lt;BR&gt;</span><span class="se">\n</span><span class="s">&lt;/TT&gt;&quot;</span><span class="p">,</span> <span class="n">message</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">,</span> <span class="n">src</span><span class="p">)</span></div><div class='line' id='LC68'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">datum</span><span class="o">/</span><span class="n">browser</span><span class="o">/</span><span class="n">popup</span> <span class="o">=</span> <span class="k">new</span><span class="p">(</span><span class="n">user</span><span class="p">,</span> <span class="s">&quot;nuclearbomb&quot;</span><span class="p">,</span> <span class="n">name</span><span class="p">,</span> <span class="mi">300</span><span class="p">,</span> <span class="mi">400</span><span class="p">)</span></div><div class='line' id='LC69'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">popup</span><span class="p">.</span><span class="n">set_content</span><span class="p">(</span><span class="n">dat</span><span class="p">)</span></div><div class='line' id='LC70'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">popup</span><span class="p">.</span><span class="n">open</span><span class="p">()</span></div><div class='line' id='LC71'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC72'><br/></div><div class='line' id='LC73'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">Topic</span><span class="p">(</span><span class="n">href</span><span class="p">,</span> <span class="n">href_list</span><span class="p">)</span></div><div class='line' id='LC74'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(..())</span></div><div class='line' id='LC75'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC76'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">usr</span><span class="p">.</span><span class="n">set_machine</span><span class="p">(</span><span class="n">src</span><span class="p">)</span></div><div class='line' id='LC77'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;auth&quot;</span><span class="p">])</span></div><div class='line' id='LC78'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">auth</span><span class="p">)</span></div><div class='line' id='LC79'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">auth</span><span class="p">.</span><span class="n">loc</span> <span class="o">=</span> <span class="n">src</span><span class="p">.</span><span class="n">loc</span></div><div class='line' id='LC80'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">yes_code</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC81'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">auth</span> <span class="o">=</span> <span class="n">null</span></div><div class='line' id='LC82'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC83'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">I</span> <span class="o">=</span> <span class="n">usr</span><span class="p">.</span><span class="n">get_active_hand</span><span class="p">()</span></div><div class='line' id='LC84'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">istype</span><span class="p">(</span><span class="n">I</span><span class="p">,</span> <span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">disk</span><span class="o">/</span><span class="n">nuclear</span><span class="p">))</span></div><div class='line' id='LC85'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">usr</span><span class="p">.</span><span class="n">drop_item</span><span class="p">()</span></div><div class='line' id='LC86'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">I</span><span class="p">.</span><span class="n">loc</span> <span class="o">=</span> <span class="n">src</span></div><div class='line' id='LC87'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">auth</span> <span class="o">=</span> <span class="n">I</span></div><div class='line' id='LC88'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">auth</span><span class="p">)</span></div><div class='line' id='LC89'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;type&quot;</span><span class="p">])</span></div><div class='line' id='LC90'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;type&quot;</span><span class="p">]</span> <span class="o">==</span> <span class="s">&quot;E&quot;</span><span class="p">)</span></div><div class='line' id='LC91'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">==</span> <span class="n">src</span><span class="p">.</span><span class="n">r_code</span><span class="p">)</span></div><div class='line' id='LC92'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">yes_code</span> <span class="o">=</span> <span class="mi">1</span></div><div class='line' id='LC93'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">=</span> <span class="n">null</span></div><div class='line' id='LC94'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC95'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">=</span> <span class="s">&quot;ERROR&quot;</span></div><div class='line' id='LC96'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC97'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;type&quot;</span><span class="p">]</span> <span class="o">==</span> <span class="s">&quot;R&quot;</span><span class="p">)</span></div><div class='line' id='LC98'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">yes_code</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC99'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">=</span> <span class="n">null</span></div><div class='line' id='LC100'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC101'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">+=</span> <span class="n">text</span><span class="p">(</span><span class="s">&quot;[]&quot;</span><span class="p">,</span> <span class="n">href_list</span><span class="p">[</span><span class="s">&quot;type&quot;</span><span class="p">])</span></div><div class='line' id='LC102'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">length</span><span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">code</span><span class="p">)</span> <span class="o">&gt;</span> <span class="mi">5</span><span class="p">)</span></div><div class='line' id='LC103'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">code</span> <span class="o">=</span> <span class="s">&quot;ERROR&quot;</span></div><div class='line' id='LC104'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">yes_code</span><span class="p">)</span></div><div class='line' id='LC105'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;time&quot;</span><span class="p">])</span></div><div class='line' id='LC106'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">time</span> <span class="o">=</span> <span class="n">text2num</span><span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;time&quot;</span><span class="p">])</span></div><div class='line' id='LC107'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timeleft</span> <span class="o">+=</span> <span class="n">time</span></div><div class='line' id='LC108'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timeleft</span> <span class="o">=</span> <span class="n">min</span><span class="p">(</span><span class="n">max</span><span class="p">(</span><span class="n">round</span><span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timeleft</span><span class="p">),</span> <span class="mi">60</span><span class="p">),</span> <span class="mi">600</span><span class="p">)</span></div><div class='line' id='LC109'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;timer&quot;</span><span class="p">])</span></div><div class='line' id='LC110'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">==</span> <span class="o">-</span><span class="mf">1.0</span><span class="p">)</span></div><div class='line' id='LC111'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC112'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span><span class="p">)</span></div><div class='line' id='LC113'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">usr</span> <span class="o">&lt;&lt;</span> <span class="s">&quot;</span><span class="se">\r</span><span class="s">ed The safety is still on.&quot;</span></div><div class='line' id='LC114'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC115'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">=</span> <span class="o">!</span><span class="p">(</span> <span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="p">)</span></div><div class='line' id='LC116'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span><span class="p">)</span></div><div class='line' id='LC117'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">icon_state</span> <span class="o">=</span> <span class="s">&quot;nuclearbomb2&quot;</span></div><div class='line' id='LC118'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="o">!</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span><span class="p">)</span></div><div class='line' id='LC119'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">bomb_set</span> <span class="o">=</span> <span class="mi">1</span><span class="c1">//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N</span></div><div class='line' id='LC120'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC121'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">bomb_set</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC122'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC123'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">icon_state</span> <span class="o">=</span> <span class="s">&quot;nuclearbomb1&quot;</span></div><div class='line' id='LC124'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">bomb_set</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC125'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;safety&quot;</span><span class="p">])</span></div><div class='line' id='LC126'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">=</span> <span class="o">!</span><span class="p">(</span> <span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="p">)</span></div><div class='line' id='LC127'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">icon_state</span> <span class="o">=</span> <span class="s">&quot;nuclearbomb1&quot;</span></div><div class='line' id='LC128'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">safety</span><span class="p">)</span></div><div class='line' id='LC129'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC130'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">bomb_set</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC131'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">href_list</span><span class="p">[</span><span class="s">&quot;anchor&quot;</span><span class="p">])</span></div><div class='line' id='LC132'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="o">!</span><span class="n">isinspace</span><span class="p">())</span></div><div class='line' id='LC133'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="o">=</span> <span class="o">!</span><span class="p">(</span> <span class="n">src</span><span class="p">.</span><span class="n">anchored</span> <span class="p">)</span></div><div class='line' id='LC134'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC135'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">usr</span> <span class="o">&lt;&lt;</span> <span class="s">&quot;&lt;span class=&#39;warning&#39;&gt;There is nothing to anchor to!&lt;/span&gt;&quot;</span></div><div class='line' id='LC136'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">add_fingerprint</span><span class="p">(</span><span class="n">usr</span><span class="p">)</span></div><div class='line' id='LC137'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">for</span><span class="p">(</span><span class="n">var</span><span class="o">/</span><span class="n">mob</span><span class="o">/</span><span class="n">M</span> <span class="n">in</span> <span class="n">viewers</span><span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="n">src</span><span class="p">))</span></div><div class='line' id='LC138'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">((</span><span class="n">M</span><span class="p">.</span><span class="n">client</span> <span class="o">&amp;&amp;</span> <span class="n">M</span><span class="p">.</span><span class="n">machine</span> <span class="o">==</span> <span class="n">src</span><span class="p">))</span></div><div class='line' id='LC139'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">attack_hand</span><span class="p">(</span><span class="n">M</span><span class="p">)</span></div><div class='line' id='LC140'><br/></div><div class='line' id='LC141'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">ex_act</span><span class="p">(</span><span class="n">severity</span><span class="p">)</span></div><div class='line' id='LC142'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC143'><br/></div><div class='line' id='LC144'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">blob_act</span><span class="p">()</span></div><div class='line' id='LC145'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">==</span> <span class="o">-</span><span class="mf">1.0</span><span class="p">)</span></div><div class='line' id='LC146'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC147'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC148'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span> <span class="p">..()</span></div><div class='line' id='LC149'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC150'><br/></div><div class='line' id='LC151'><br/></div><div class='line' id='LC152'><span class="cp">#define NUKERANGE 80</span></div><div class='line' id='LC153'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">nuclearbomb</span><span class="o">/</span><span class="n">proc</span><span class="o">/</span><span class="n">explode</span><span class="p">()</span></div><div class='line' id='LC154'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">src</span><span class="p">.</span><span class="n">safety</span><span class="p">)</span></div><div class='line' id='LC155'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC156'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC157'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">timing</span> <span class="o">=</span> <span class="o">-</span><span class="mf">1.0</span></div><div class='line' id='LC158'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">yes_code</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC159'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">safety</span> <span class="o">=</span> <span class="mi">1</span></div><div class='line' id='LC160'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">src</span><span class="p">.</span><span class="n">icon_state</span> <span class="o">=</span> <span class="s">&quot;nuclearbomb3&quot;</span></div><div class='line' id='LC161'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">for</span><span class="p">(</span><span class="n">var</span><span class="o">/</span><span class="n">mob</span><span class="o">/</span><span class="n">M</span> <span class="n">in</span> <span class="n">player_list</span><span class="p">)</span></div><div class='line' id='LC162'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">M</span> <span class="o">&lt;&lt;</span> <span class="err">&#39;</span><span class="n">sound</span><span class="o">/</span><span class="n">machines</span><span class="o">/</span><span class="n">Alarm</span><span class="p">.</span><span class="n">ogg</span><span class="err">&#39;</span></div><div class='line' id='LC163'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span> <span class="p">(</span><span class="n">ticker</span> <span class="o">&amp;&amp;</span> <span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">)</span></div><div class='line' id='LC164'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">explosion_in_progress</span> <span class="o">=</span> <span class="mi">1</span></div><div class='line' id='LC165'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">sleep</span><span class="p">(</span><span class="mi">100</span><span class="p">)</span></div><div class='line' id='LC166'><br/></div><div class='line' id='LC167'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">enter_allowed</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC168'><br/></div><div class='line' id='LC169'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">off_station</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC170'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">turf</span><span class="o">/</span><span class="n">bomb_location</span> <span class="o">=</span> <span class="n">get_turf</span><span class="p">(</span><span class="n">src</span><span class="p">)</span></div><div class='line' id='LC171'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span> <span class="n">bomb_location</span> <span class="o">&amp;&amp;</span> <span class="p">(</span><span class="n">bomb_location</span><span class="p">.</span><span class="n">z</span> <span class="o">==</span> <span class="mi">1</span><span class="p">)</span> <span class="p">)</span></div><div class='line' id='LC172'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span> <span class="p">(</span><span class="n">bomb_location</span><span class="p">.</span><span class="n">x</span> <span class="o">&lt;</span> <span class="p">(</span><span class="mi">128</span><span class="o">-</span><span class="n">NUKERANGE</span><span class="p">))</span> <span class="o">||</span> <span class="p">(</span><span class="n">bomb_location</span><span class="p">.</span><span class="n">x</span> <span class="o">&gt;</span> <span class="p">(</span><span class="mi">128</span><span class="o">+</span><span class="n">NUKERANGE</span><span class="p">))</span> <span class="o">||</span> <span class="p">(</span><span class="n">bomb_location</span><span class="p">.</span><span class="n">y</span> <span class="o">&lt;</span> <span class="p">(</span><span class="mi">128</span><span class="o">-</span><span class="n">NUKERANGE</span><span class="p">))</span> <span class="o">||</span> <span class="p">(</span><span class="n">bomb_location</span><span class="p">.</span><span class="n">y</span> <span class="o">&gt;</span> <span class="p">(</span><span class="mi">128</span><span class="o">+</span><span class="n">NUKERANGE</span><span class="p">))</span> <span class="p">)</span></div><div class='line' id='LC173'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">off_station</span> <span class="o">=</span> <span class="mi">1</span></div><div class='line' id='LC174'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC175'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">off_station</span> <span class="o">=</span> <span class="mi">2</span></div><div class='line' id='LC176'><br/></div><div class='line' id='LC177'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">ticker</span><span class="p">)</span></div><div class='line' id='LC178'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">ticker</span><span class="p">.</span><span class="n">mode</span> <span class="o">&amp;&amp;</span> <span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">name</span> <span class="o">==</span> <span class="s">&quot;nuclear emergency&quot;</span><span class="p">)</span></div><div class='line' id='LC179'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">computer</span><span class="o">/</span><span class="n">syndicate_station</span><span class="o">/</span><span class="n">syndie_location</span> <span class="o">=</span> <span class="n">locate</span><span class="p">(</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">machinery</span><span class="o">/</span><span class="n">computer</span><span class="o">/</span><span class="n">syndicate_station</span><span class="p">)</span></div><div class='line' id='LC180'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">syndie_location</span><span class="p">)</span></div><div class='line' id='LC181'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="o">:</span><span class="n">syndies_didnt_escape</span> <span class="o">=</span> <span class="p">(</span><span class="n">syndie_location</span><span class="p">.</span><span class="n">z</span> <span class="o">&gt;</span> <span class="mi">1</span> <span class="o">?</span> <span class="mi">0</span> <span class="o">:</span> <span class="mi">1</span><span class="p">)</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="c1">//muskets will make me change this, but it will do for now</span></div><div class='line' id='LC182'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="o">:</span><span class="n">nuke_off_station</span> <span class="o">=</span> <span class="n">off_station</span></div><div class='line' id='LC183'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">station_explosion_cinematic</span><span class="p">(</span><span class="n">off_station</span><span class="p">,</span><span class="n">null</span><span class="p">)</span></div><div class='line' id='LC184'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">)</span></div><div class='line' id='LC185'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">explosion_in_progress</span> <span class="o">=</span> <span class="mi">0</span></div><div class='line' id='LC186'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">name</span> <span class="o">==</span> <span class="s">&quot;nuclear emergency&quot;</span><span class="p">)</span></div><div class='line' id='LC187'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="o">:</span><span class="n">nukes_left</span> <span class="o">--</span></div><div class='line' id='LC188'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC189'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">world</span> <span class="o">&lt;&lt;</span> <span class="s">&quot;&lt;B&gt;The station was destoyed by the nuclear blast!&lt;/B&gt;&quot;</span></div><div class='line' id='LC190'><br/></div><div class='line' id='LC191'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">station_was_nuked</span> <span class="o">=</span> <span class="p">(</span><span class="n">off_station</span><span class="o">&lt;</span><span class="mi">2</span><span class="p">)</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="c1">//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.</span></div><div class='line' id='LC192'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="c1">//kinda shit but I couldn&#39;t  get permission to do what I wanted to do.</span></div><div class='line' id='LC193'><br/></div><div class='line' id='LC194'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="o">!</span><span class="n">ticker</span><span class="p">.</span><span class="n">mode</span><span class="p">.</span><span class="n">check_finished</span><span class="p">())</span><span class="c1">//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is</span></div><div class='line' id='LC195'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">world</span> <span class="o">&lt;&lt;</span> <span class="s">&quot;&lt;B&gt;Resetting in 30 seconds!&lt;/B&gt;&quot;</span></div><div class='line' id='LC196'><br/></div><div class='line' id='LC197'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">feedback_set_details</span><span class="p">(</span><span class="s">&quot;end_error&quot;</span><span class="p">,</span><span class="s">&quot;nuke - unhandled ending&quot;</span><span class="p">)</span></div><div class='line' id='LC198'><br/></div><div class='line' id='LC199'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">blackbox</span><span class="p">)</span></div><div class='line' id='LC200'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">blackbox</span><span class="p">.</span><span class="n">save_all_data_to_sql</span><span class="p">()</span></div><div class='line' id='LC201'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">sleep</span><span class="p">(</span><span class="mi">300</span><span class="p">)</span></div><div class='line' id='LC202'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">log_game</span><span class="p">(</span><span class="s">&quot;Rebooting due to nuclear detonation&quot;</span><span class="p">)</span></div><div class='line' id='LC203'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">kick_clients_in_lobby</span><span class="p">(</span><span class="s">&quot;</span><span class="se">\r</span><span class="s">ed The round came to an end with you in the lobby.&quot;</span><span class="p">,</span> <span class="mi">1</span><span class="p">)</span> <span class="c1">//second parameter ensures only afk clients are kicked</span></div><div class='line' id='LC204'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">world</span><span class="p">.</span><span class="n">Reboot</span><span class="p">()</span></div><div class='line' id='LC205'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC206'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">return</span></div><div class='line' id='LC207'><br/></div><div class='line' id='LC208'><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">disk</span><span class="o">/</span><span class="n">nuclear</span><span class="o">/</span><span class="n">Del</span><span class="p">()</span></div><div class='line' id='LC209'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if</span><span class="p">(</span><span class="n">blobstart</span><span class="p">.</span><span class="n">len</span> <span class="o">&gt;</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC210'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">var</span><span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">D</span> <span class="o">=</span> <span class="k">new</span> <span class="o">/</span><span class="n">obj</span><span class="o">/</span><span class="n">item</span><span class="o">/</span><span class="n">weapon</span><span class="o">/</span><span class="n">disk</span><span class="o">/</span><span class="n">nuclear</span><span class="p">(</span><span class="n">pick</span><span class="p">(</span><span class="n">blobstart</span><span class="p">))</span></div><div class='line' id='LC211'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">message_admins</span><span class="p">(</span><span class="s">&quot;[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).&quot;</span><span class="p">)</span></div><div class='line' id='LC212'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="n">log_game</span><span class="p">(</span><span class="s">&quot;[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).&quot;</span><span class="p">)</span></div><div class='line' id='LC213'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="p">..()</span></div></pre></div>
            </td>
          </tr>
        </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2013 <span title="0.05292s from github-fe129-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/Ikarrus/-tg-station/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-remove-close close ajax-error-dismiss"></a>
      Something went wrong with that request. Please try again.
    </div>

  </body>
</html>

