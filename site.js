const THEMES = {
  black: ['near black and muted', '#161717', '#c8c5bf', '#c2a46a', '#8f9a6d', '#ba6962', '#a08299'],
  blue: ['cool dark slate', '#1b1f27', '#cdd3de', '#81a1c1', '#9bb48a', '#c47a7a', '#b48ead'],
  grey: ['the onyx look, cream text and a gold accent', '#282828', '#ccc3b8', '#c8a46b', '#8aa66a', '#c26a6a', '#a8879a'],
  gruvbox: ['gruvbox dark, hard', '#1d2021', '#ebdbb2', '#83a598', '#b8bb26', '#fb4934', '#b16286'],
  white: ['soft warm off white', '#e8e6e1', '#3a3633', '#3f6b8a', '#5f6a2c', '#a8423a', '#8a4f72']
};
const KEYS = ['bg', 'bg1', 'line', 'fg', 'fg1', 'fg2', 'accent', 'green', 'red', 'blue', 'magenta', 'cyan'];
const root = document.documentElement;

function savedTheme() {
  let name = 'black';
  try { name = localStorage.getItem('dots-theme') || 'black'; } catch (e) {}
  return THEMES[name] ? name : 'black';
}

root.dataset.theme = savedTheme();

function $(sel) { return document.querySelector(sel); }

function cssVar(k) { return getComputedStyle(root).getPropertyValue('--' + k).trim(); }

function toast(title, body) {
  const t = $('#toast');
  if (!t) return;
  $('#toast-title').textContent = title;
  $('#toast-body').textContent = body;
  t.classList.add('on');
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => t.classList.remove('on'), 2200);
}

function notes() {
  const box = document.createElement('div');
  box.className = 'notes';
  document.body.appendChild(box);
  const toast = $('#toast');
  if (toast) box.appendChild(toast);
  return box;
}

function installHint(box) {
  const target = $('#install');
  const block = $('#install-cmd');
  const btn = $('#install-cmd .copy');
  const cmd = btn ? btn.dataset.copy : 'git clone https://github.com/saeeedhany/dots && ./dots/install.sh';
  const still = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  const h = document.createElement('a');
  h.className = 'hint';
  h.href = target ? '#install' : (location.pathname.includes('/blog/') ? '../' : '') + 'index.html#install';
  h.setAttribute('role', 'status');
  h.innerHTML = '<b class="t"></b><span class="body"></span><span class="go"></span>' +
    '<button class="m" aria-label="minimize">_</button>';
  box.appendChild(h);
  const t = h.querySelector('.t'), body = h.querySelector('.body'), go = h.querySelector('.go');
  let here = false, typing;

  const stored = v => { try { v ? localStorage.setItem('dots-install', 'min') : localStorage.removeItem('dots-install'); } catch (e) {} };
  let min = false;
  try { min = localStorage.getItem('dots-install') === 'min'; } catch (e) {}

  const type = () => {
    clearInterval(typing);
    body.innerHTML = '<span class="term"><span class="p">❯</span> <span class="typed"></span><i class="cursor"></i></span>';
    const out = body.querySelector('.typed');
    if (still) { out.textContent = cmd; return; }
    let i = 0;
    typing = setInterval(() => {
      out.textContent = cmd.slice(0, ++i);
      if (i >= cmd.length) clearInterval(typing);
    }, 28);
  };

  const paint = () => {
    h.classList.toggle('min', min);
    h.classList.toggle('here', here);
    h.querySelector('.m').hidden = min;
    if (min) {
      clearInterval(typing);
      t.textContent = '';
      body.textContent = '';
      go.textContent = here ? '❯ here it is' : '❯ install';
      h.setAttribute('aria-label', 'open the install notice');
      return;
    }
    h.removeAttribute('aria-label');
    if (here) {
      t.textContent = 'you found it';
      type();
      go.textContent = '❯ copy it, give it a try';
    } else {
      clearInterval(typing);
      t.textContent = 'dots';
      body.textContent = 'this whole setup installs on a fresh arch machine with one command';
      go.textContent = '❯ show me how';
    }
  };

  h.addEventListener('click', e => {
    if (e.target.closest('.m')) {
      e.preventDefault();
      min = true; stored(true); paint();
    } else if (min) {
      e.preventDefault();
      min = false; stored(false); paint();
    } else if (here) {
      e.preventDefault();
      copy(cmd, 'copied');
      go.textContent = '❯ now paste it in a terminal on arch';
    }
  });

  if (target) {
    new IntersectionObserver(entries => {
      const now = entries.some(e => e.isIntersecting);
      if (now === here) return;
      here = now;
      if (block) {
        block.classList.toggle('lit', here);
      }
      paint();
    }, { rootMargin: '0px 0px -40% 0px' }).observe(target);
  }
  paint();
  setTimeout(() => h.classList.add('on'), 1200);
}

function copy(text, title) {
  const done = () => toast(title, text);
  if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, done);
  else done();
}

function paintPalette(name) {
  const pal = $('#palette');
  if (pal) {
    pal.innerHTML = '';
    KEYS.forEach(k => {
      const hex = cssVar(k);
      const b = document.createElement('button');
      b.className = 'sw';
      b.innerHTML = '<i style="background:' + hex + '"></i><span><b>' + k + '</b>' + hex + '</span>';
      b.addEventListener('click', () => copy(hex, 'color'));
      pal.appendChild(b);
    });
  }
  document.querySelectorAll('.pal-name').forEach(e => e.textContent = name);
  document.querySelectorAll('.notif-hex').forEach(e => e.textContent = cssVar('accent'));
  document.querySelectorAll('[data-hex]').forEach(e => e.textContent = cssVar(e.dataset.hex));
}

function paintThemes(name) {
  const list = $('#themelist');
  if (!list) return;
  list.innerHTML = '';
  let screen = '';
  Object.keys(THEMES).forEach(n => {
    const [desc, ...cols] = THEMES[n];
    const b = document.createElement('button');
    b.className = 'th' + (n === name ? ' cur' : '');
    b.innerHTML = '<span class="mark">' + (n === name ? '*' : '') + '</span><span>' + n + '</span>' +
      '<span class="strip">' + cols.map(c => '<i style="background:' + c + '"></i>').join('') + '</span>' +
      '<span class="desc">' + desc + '</span>';
    b.addEventListener('click', () => applyTheme(n, true));
    list.appendChild(b);
    screen += (n === name ? '<span class="u">*</span> ' : '  ') + n + '\n';
  });
  document.querySelectorAll('.screen-themes').forEach(e => e.innerHTML = screen.trimEnd());
}

function paintPicker(name) {
  const pick = $('#picker');
  if (!pick) return;
  pick.innerHTML = '<span>theme</span>';
  Object.keys(THEMES).forEach(n => {
    const b = document.createElement('button');
    b.textContent = n;
    if (n === name) b.className = 'cur';
    b.addEventListener('click', () => applyTheme(n, true));
    pick.appendChild(b);
  });
}

function applyTheme(name, announce) {
  root.dataset.theme = name;
  try { localStorage.setItem('dots-theme', name); } catch (e) {}
  const cmd = $('#theme-cmd');
  if (cmd) cmd.textContent = announce ? 'theme ' + name : 'theme';
  paintThemes(name);
  paintPicker(name);
  paintPalette(name);
  if (announce) toast('theme', name + ' applied');
}

function tick() {
  const d = new Date();
  const day = d.toLocaleDateString('en-GB', { weekday: 'short' });
  const date = String(d.getDate()).padStart(2, '0') + ' ' + d.toLocaleDateString('en-GB', { month: 'short' });
  const h = d.getHours() % 12 || 12;
  const m = String(d.getMinutes()).padStart(2, '0');
  const s = day + ' ' + date + ' ' + String(h).padStart(2, '0') + ':' + m + ' ' + (d.getHours() < 12 ? 'AM' : 'PM');
  document.querySelectorAll('#clock, .sclock').forEach(e => e.textContent = s);
}

document.addEventListener('DOMContentLoaded', () => {
  applyTheme(savedTheme(), false);
  installHint(notes());
  tick();
  setInterval(tick, 1000);
  window.addEventListener('storage', e => {
    if (e.key === 'dots-theme' && THEMES[e.newValue]) applyTheme(e.newValue, false);
  });

  const tags = [...document.querySelectorAll('.tag[href^="#"]')];
  const sections = tags.map(t => document.querySelector(t.getAttribute('href')));
  const select = i => tags.forEach((t, j) => t.classList.toggle('sel', i === j));
  if (tags.length) {
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => { if (e.isIntersecting) select(sections.indexOf(e.target)); });
    }, { rootMargin: '-45% 0px -50% 0px' });
    sections.forEach(s => s && obs.observe(s));
  }

  document.addEventListener('keydown', e => {
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    const i = '123456789'.indexOf(e.key);
    if (i >= 0 && sections[i]) sections[i].scrollIntoView();
    const bar = $('.bar');
    if (e.key === 'b' && bar) bar.style.visibility = bar.style.visibility === 'hidden' ? '' : 'hidden';
  });

  document.querySelectorAll('.copy').forEach(b =>
    b.addEventListener('click', () => copy(b.dataset.copy, 'copied')));
  document.querySelectorAll('[data-copy-var]').forEach(b =>
    b.addEventListener('click', () => copy(cssVar(b.dataset.copyVar), b.dataset.copyVar)));
});
