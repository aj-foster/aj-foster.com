const systemDarkModeSetting = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
const storedDarkModeSetting = window.localStorage.getItem('prefers-color-scheme');
const darkModeToggle = document.getElementById('darkmode');

if (storedDarkModeSetting === 'dark') {
  document.body.classList.add('prefers-dark-mode');
  darkModeToggle.checked = true;
} else if (storedDarkModeSetting === 'light') {
  document.body.classList.add('prefers-light-mode');
  darkModeToggle.checked = false;
} else if (systemDarkModeSetting) {
  darkModeToggle.checked = true;
}

darkModeToggle.addEventListener('change', function (event) {
  if (darkModeToggle.checked) {
    document.body.classList.remove('prefers-light-mode');
    document.body.classList.add('prefers-dark-mode');
    window.localStorage.setItem('prefers-color-scheme', 'dark');
  } else {
    document.body.classList.remove('prefers-dark-mode');
    document.body.classList.add('prefers-light-mode');
    window.localStorage.setItem('prefers-color-scheme', 'light');
  }
});

if (window.matchMedia) {
  window
    .matchMedia('(prefers-color-scheme: dark)')
    .addEventListener('change', function () {
      if (window.localStorage.getItem('prefers-color-scheme') == null) {
        darkModeToggle.checked = window.matchMedia('(prefers-color-scheme: dark)').matches;
      }
    });
}