/*
  header-hover.js — opens the header submenus on hover, on desktop only.

  The theme inherits Dawn's header, where each submenu is a native
  <details>/<summary> toggled by click (see assets/details-disclosure.js). That
  file is inherited Sense code and the theme rules forbid rewriting it, so this
  layers on top instead of touching it.

  WHAT THIS DELIBERATELY DOES NOT DO

  It does not replace the click behaviour. The native <details> toggle keeps
  working, so touch devices, hybrid touchscreen laptops, keyboard users and
  screen readers all behave exactly as they did before this file existed. Hover
  is added for people who have a mouse; nothing is taken away from anyone else.

  If this file fails to load or throws, the nav still opens on click. That is
  the whole safety story.

  THE TWO DELAYS ARE THE WHOLE TRICK

  Opening instantly means the panel flashes open as the cursor crosses the bar
  on its way somewhere else. Closing instantly means the panel snaps shut in the
  few pixels of dead space between the label and the panel below it. Both are
  the difference between a nav that feels considered and one that feels broken,
  and neither shows up in a screenshot.
*/

(function () {
  'use strict';

  var OPEN_DELAY = 120;
  var CLOSE_DELAY = 220;
  var DESKTOP_MIN = 990;

  function init() {
    /* The theme editor gets the plain click behaviour. Hover-driven panels
       fight the editor's own scroll-into-view and section highlighting, and a
       merchant cannot inspect a panel that closes when they move the mouse. */
    if (window.Shopify && window.Shopify.designMode) return;

    /* A mouse, not a finger. `(hover: hover) and (pointer: fine)` is what
       excludes touch and hybrid devices where hover is emulated by a tap —
       there, hovering to open would eat the first tap. */
    var canHover = window.matchMedia('(hover: hover) and (pointer: fine)');
    if (!canHover.matches) return;

    var menus = Array.prototype.slice.call(document.querySelectorAll('header-menu'));
    if (!menus.length) return;

    var openTimer = null;
    var closeTimer = null;

    function isDesktop() {
      return window.innerWidth >= DESKTOP_MIN && canHover.matches;
    }

    function detailsOf(menu) {
      return menu.querySelector('details');
    }

    function closeAll(except) {
      menus.forEach(function (menu) {
        if (menu === except) return;
        var details = detailsOf(menu);
        if (!details || !details.open) return;
        details.removeAttribute('open');
        var summary = details.querySelector('summary');
        if (summary) summary.setAttribute('aria-expanded', 'false');
      });
    }

    function open(menu) {
      var details = detailsOf(menu);
      if (!details || details.open) return;
      closeAll(menu);
      details.setAttribute('open', '');
      var summary = details.querySelector('summary');
      if (summary) summary.setAttribute('aria-expanded', 'true');
    }

    function close(menu) {
      var details = detailsOf(menu);
      if (!details || !details.open) return;

      /* Never yank a panel closed while the keyboard is inside it. Someone
         tabbing through the submenu will move the mouse off it, and closing
         then would drop their focus onto a hidden element. */
      if (details.contains(document.activeElement)) return;

      details.removeAttribute('open');
      var summary = details.querySelector('summary');
      if (summary) summary.setAttribute('aria-expanded', 'false');
    }

    menus.forEach(function (menu) {
      if (!detailsOf(menu)) return;

      menu.addEventListener('mouseenter', function () {
        if (!isDesktop()) return;
        window.clearTimeout(closeTimer);
        window.clearTimeout(openTimer);
        openTimer = window.setTimeout(function () {
          open(menu);
        }, OPEN_DELAY);
      });

      menu.addEventListener('mouseleave', function () {
        if (!isDesktop()) return;
        window.clearTimeout(openTimer);
        window.clearTimeout(closeTimer);
        closeTimer = window.setTimeout(function () {
          close(menu);
        }, CLOSE_DELAY);
      });

      /* A click on the label should still work. Cancel any pending hover timer
         so the two mechanisms cannot fight over the same panel. */
      menu.addEventListener('click', function () {
        window.clearTimeout(openTimer);
        window.clearTimeout(closeTimer);
      });
    });

    /* Escape closes whatever is open, which is what the keyboard expects and
       what Dawn does not provide for the hover case. */
    document.addEventListener('keydown', function (event) {
      if (event.key !== 'Escape') return;
      window.clearTimeout(openTimer);
      window.clearTimeout(closeTimer);
      closeAll(null);
    });
  }

  try {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function () {
        try {
          init();
        } catch (e) {
          if (window.console && console.warn) console.warn('[header-hover] disabled:', e);
        }
      });
    } else {
      init();
    }
  } catch (e) {
    if (window.console && console.warn) console.warn('[header-hover] disabled:', e);
  }
})();
