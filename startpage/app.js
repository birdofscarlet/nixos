"use strict";

// --- pure helpers (also exercised by tests under node) -------------------

// Merge link groups by title, so links.local.js can add to a public group.
function mergeGroups(base, extra) {
  const out = [];
  const index = new Map();
  for (const g of [...base, ...extra]) {
    const key = g.title.toLowerCase();
    if (!index.has(key)) {
      const copy = { title: g.title, links: [] };
      index.set(key, copy);
      out.push(copy);
    }
    index.get(key).links.push(...g.links);
  }
  return out;
}

// Every word in the query must appear in group title, link name or url.
function matches(group, link, query) {
  const hay = (group.title + " " + link.name + " " + link.url).toLowerCase();
  return query.toLowerCase().split(/\s+/).filter(Boolean).every((w) => hay.includes(w));
}

// Turn free text into a URL: explicit url, bare domain, or a web search.
function resolveQuery(text, searchUrl) {
  const s = text.trim();
  if (s.startsWith("?")) return searchUrl + encodeURIComponent(s.slice(1).trim());
  if (/^https?:\/\//i.test(s)) return s;
  if (/^[\w-]+(\.[\w-]+)+(\/\S*)?$/.test(s)) return "https://" + s;
  return searchUrl + encodeURIComponent(s);
}

// --- page ----------------------------------------------------------------

function init() {
  const searchUrl = window.SEARCH_URL || "https://duckduckgo.com/?q=";
  const groups = mergeGroups(window.LINKS || [], window.LINKS_LOCAL || []);
  const grid = document.getElementById("grid");
  const input = document.getElementById("q");

  const cards = [];
  for (const g of groups) {
    const fs = document.createElement("fieldset");
    const legend = document.createElement("legend");
    legend.textContent = "[ " + g.title + " ]";
    fs.appendChild(legend);

    const items = [];
    for (const l of g.links) {
      if (!/^(https?|file):/i.test(l.url)) continue; // never render javascript: etc.
      const a = document.createElement("a");
      a.href = l.url;
      a.textContent = l.name;
      a.title = l.url;
      fs.appendChild(a);
      items.push({ group: g, link: l, a });
    }
    grid.appendChild(fs);
    cards.push({ fs, items });
  }

  let visible = [];
  let sel = 0;
  let navigated = false; // true once the arrow keys have been used

  function paint() {
    for (const c of cards) for (const it of c.items) it.a.classList.remove("sel");
    if ((input.value.trim() || navigated) && visible[sel]) visible[sel].a.classList.add("sel");
  }

  function render() {
    const q = input.value.trim();
    visible = [];
    for (const c of cards) {
      let any = false;
      for (const it of c.items) {
        const show = !q || q.startsWith("?") || matches(it.group, it.link, q);
        it.a.hidden = !show;
        if (show) { visible.push(it); any = true; }
      }
      c.fs.classList.toggle("empty", !any);
    }
    sel = Math.min(sel, Math.max(visible.length - 1, 0));
    paint();
  }

  input.addEventListener("input", () => { sel = 0; navigated = false; render(); });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      input.value = ""; sel = 0; navigated = false; render(); input.focus();
      return;
    }
    if (e.key === "ArrowDown" || e.key === "ArrowUp") {
      e.preventDefault();
      if (!visible.length) return;
      navigated = true;
      sel = (sel + (e.key === "ArrowDown" ? 1 : -1) + visible.length) % visible.length;
      paint();
      visible[sel].a.scrollIntoView({ block: "nearest" });
      return;
    }
    if (e.key === "Enter") {
      const q = input.value.trim();
      let url = null;
      if (!q.startsWith("?") && visible[sel] && (q || navigated)) url = visible[sel].link.url;
      else if (q) url = resolveQuery(q, searchUrl);
      if (!url) return;
      e.preventDefault();
      if (e.ctrlKey || e.metaKey || e.shiftKey) window.open(url, "_blank", "noopener");
      else location.href = url;
      return;
    }
    // typing anywhere goes to the prompt
    if (document.activeElement !== input && e.key.length === 1 &&
        !e.ctrlKey && !e.metaKey && !e.altKey) input.focus();
  });

  const clock = document.getElementById("clock");
  const date = document.getElementById("date");
  function tick() {
    const d = new Date();
    clock.textContent = d.toLocaleTimeString("en-GB");
    date.textContent = d.toLocaleDateString("en-CA") + " " +
      d.toLocaleDateString("en-US", { weekday: "short" }).toLowerCase();
  }
  tick();
  setInterval(tick, 1000);

  render();
  input.focus();
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = { mergeGroups, matches, resolveQuery };
} else {
  init();
}
