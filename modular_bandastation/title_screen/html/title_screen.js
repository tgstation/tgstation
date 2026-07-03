function call_byond(href, value) {
  window.location = `byond://?src=${globalThis.playerRef};${href}=${value}`;
}

// MARK: State/Info updates
function toggleGoodBadClass(element, condition) {
  element.classList.add(condition ? 'good' : 'bad');
  element.classList.remove(!condition ? 'good' : 'bad');
}

const ready_int = 0;
const readyElement = document.querySelector('.lobby-toggle_ready');
function toggleReady(setReady) {
  toggleGoodBadClass(readyElement, setReady === '1'); // YES. Byond sends true/false like a "1"/"0"
}

const noticeElement = document.getElementById('container_notice');
function updateNotice(notice) {
  const emptyNotice = notice === undefined;
  noticeElement.classList.toggle('hidden', emptyNotice);
  noticeElement.innerHTML = emptyNotice ? '' : notice;
}

const character_name_slot = document.getElementById('character_name');
function updateCharacterName(name) {
  character_name_slot.setAttribute('data-name', name);
}

const info_placement = document.getElementById('round_info');
function updateInfo(info) {
  info_placement.innerHTML = info;
}

const adminButtons = document.getElementById('lobby_admin');
function toggleAdmin(visible) {
  adminButtons.classList.toggle('hidden', visible !== 'true');
}

// MARK: Image processing
let imgSrc;
const imgElement = document.getElementById('screen_image');
const imgBlurElement = document.getElementById('screen_blur');

function updateImage(image) {
  imgSrc = image;
  imgElement.src = imgSrc;
  imgBlurElement.src = imgSrc;

  const videoFrame = document.getElementById('screen_video');
  if (videoFrame) {
    videoFrame.src = '';
    videoFrame.classList.add('hidden');
    if (typeof isVideoEnabled !== 'undefined') {
      isVideoEnabled = false;
    }
  }

  imgElement.classList.remove('hidden');
  imgBlurElement.classList.remove('hidden');
}

let attempts = 0;
const maxAttempts = 10;
function fixImage() {
  const testImg = new Image();
  testImg.src = imgSrc;
  if (testImg.naturalWidth !== 0 || testImg.naturalHeight !== 0) {
    attempts = 0;
    updateImage(imgSrc);
    return;
  }

  if (attempts === maxAttempts) {
    attempts = 0;
    return;
  }

  attempts++;
  setTimeout(fixImage, 1000);
}

// MARK: Traits
function traitSignup(assign, id) {
  if (!id) {
    return;
  }

  const traitID = `lobby-trait-${Number(id)}`;
  const trait_link = document.getElementById(traitID);
  toggleGoodBadClass(trait_link, assign === 'true');
}

let traitsCount = 0;
const traitsContainer = document.getElementById('lobby_traits');
function createTraitButton(name, desc) {
  if (!traitsContainer) {
    return;
  }

  traitsCount++;
  if (traitsCount === 1) {
    const hr = document.createElement('hr');
    traitsContainer.appendChild(hr);
  }

  const button = document.createElement('a');
  button.id = `lobby-trait-${traitsCount}`;
  button.className = 'lobby_element checkbox bad';
  button.href = `byond://?src=${globalThis.playerRef};trait_signup=${name};id=${traitsCount}`;

  const buttonText = document.createElement('span');
  buttonText.className = 'lobby-text';
  buttonText.innerHTML = name;

  const buttonTooltipWrapper = document.createElement('div');
  buttonTooltipWrapper.className = 'lobby-tooltip';
  buttonTooltipWrapper.setAttribute('data-position', 'right');

  const buttonTooltip = document.createElement('span');
  buttonTooltip.className = 'lobby-tooltip-content';
  buttonTooltip.innerHTML = desc;

  buttonTooltipWrapper.appendChild(buttonTooltip);
  button.appendChild(buttonText);
  button.appendChild(buttonTooltipWrapper);
  traitsContainer.appendChild(button);
  traitsContainer.classList.remove('hidden');
}

// MARK: Loading
const loadingName = document.getElementById('character_name');
function updateLoadingName(name) {
  loadingName.setAttribute('data-loading', name);
}

const logoElement = document.getElementById('logo');
function updateLoadedCount(count) {
  logoElement.setAttribute('data-loaded', `${Math.round(count)}%`);
  document.documentElement.style.setProperty(
    '--loading-percentage',
    `${count}%`,
  );
}

function finishLoading() {
  document.documentElement.style = '';
  document.documentElement.className = '';
}

// MARK: Authentication
const authBrowser = document.getElementById('external_auth');
const authCheckbox = document.getElementById('hide_auth');
const authButton = document.getElementById('open_auth');
function toggleAuthModal() {
  const checked = authCheckbox.checked;
  authCheckbox.checked = !checked;

  if (!checked) {
    call_byond('discord_oauth_close', true);
    setTimeout(() => {
      authButton.style.display = '';
      authBrowser.className = '';
    }, 200);
  }
}

function updateAuthBrowser() {
  authBrowser.className = 'open';
  authButton.style.display = 'none';
  setTimeout(() => updateExternalWindowPos(), 1000);
}

function updateExternalWindowPos() {
  if (!authBrowser) {
    return;
  }

  const titleBarHeight = 43; // I hate Byond sometimes
  const pixelRatio = window.devicePixelRatio ?? 1;
  const rect = authBrowser.getBoundingClientRect();
  const placeholderSize = {
    pos: [rect.left * pixelRatio, rect.top + titleBarHeight * pixelRatio],
    size: [
      (rect.right - rect.left) * pixelRatio,
      (rect.bottom - rect.top) * pixelRatio,
    ],
  };

  BYOND.winset('authwindow', {
    pos: `${placeholderSize.pos[0]},${placeholderSize.pos[1]}`,
    size: `${placeholderSize.size[0]},${placeholderSize.size[1]}`,
  });
}

window.addEventListener('resize', updateExternalWindowPos);

/* Return focus to Byond after click */
function reFocus() {
  call_byond('focus', true);
}

document.addEventListener('keyup', reFocus);
document.addEventListener('mouseup', reFocus);

let isVideoEnabled = false;

function toggleVideo(videoId, platform) {
  const img = document.getElementById('screen_image');
  const blur = document.getElementById('screen_blur');
  const videoFrame = document.getElementById('screen_video');

  if (!videoFrame) return;

  if (videoId) {
    isVideoEnabled = true;

    img.classList.add('hidden');
    blur.classList.add('hidden');

    let url = '';

    if (platform === 'youtube') {
      url = `https://www.youtube.com/embed/${videoId}?autoplay=1&controls=1&loop=1&playlist=${videoId}&showinfo=0&modestbranding=1`;
    } else if (platform === 'rutube') {
      url = `https://rutube.ru/play/embed/${videoId}?autoStart=true&mute=0&autoplay=1`;
    }

    videoFrame.src = url;
    videoFrame.classList.remove('hidden');
  } else {
    isVideoEnabled = false;
    videoFrame.src = '';
    videoFrame.classList.add('hidden');

    img.classList.remove('hidden');
    blur.classList.remove('hidden');
  }
}

function toggleYoutubeVideo(videoId) {
  toggleVideo(videoId, 'youtube');
}

function toggleRutubeVideo(videoId) {
  toggleVideo(videoId, 'rutube');
}

/* Tell Byond that the title screen is ready */
call_byond('titleReady', true);
