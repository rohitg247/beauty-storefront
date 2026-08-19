/*
  brand.js — custom interaction layer.

  Loaded as a module, after Dawn's own scripts. Everything here is optional
  polish: if this file fails to parse, fails to load, or throws, the store
  still renders and still sells. Nothing here is responsible for revealing
  content — scroll reveals are handled by the theme's own animations.js.
*/

(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const finePointer = window.matchMedia('(pointer: fine)');
  const inThemeEditor = Boolean(window.Shopify && window.Shopify.designMode);

  /*
    Magnetic buttons. The element follows the cursor a few pixels while it is
    hovered, then springs back. CSS owns the transform via --mx/--my, so with
    JS absent the values stay at 0 and the element never moves.
  */
  function initMagnetic() {
    if (reduceMotion.matches || !finePointer.matches) return;

    const strength = 0.28;
    const maxOffset = 10;

    // Hero CTAs opt in by position rather than by markup, so the banner
    // section stays untouched. Anything else can opt in with data-magnetic.
    const targets = document.querySelectorAll('[data-magnetic], .banner__buttons .button');

    targets.forEach((el) => {
      if (el.dataset.magneticBound === 'true') return;
      el.dataset.magneticBound = 'true';
      el.setAttribute('data-magnetic', '');

      let frame = null;

      const move = (event) => {
        if (frame) cancelAnimationFrame(frame);
        frame = requestAnimationFrame(() => {
          const rect = el.getBoundingClientRect();
          const dx = event.clientX - (rect.left + rect.width / 2);
          const dy = event.clientY - (rect.top + rect.height / 2);
          const clamp = (n) => Math.max(-maxOffset, Math.min(maxOffset, n * strength));
          el.style.setProperty('--mx', `${clamp(dx)}px`);
          el.style.setProperty('--my', `${clamp(dy)}px`);
        });
      };

      const reset = () => {
        if (frame) cancelAnimationFrame(frame);
        el.dataset.magneticActive = 'false';
        el.style.setProperty('--mx', '0px');
        el.style.setProperty('--my', '0px');
      };

      el.addEventListener('pointerenter', () => {
        el.dataset.magneticActive = 'true';
      });
      el.addEventListener('pointermove', move);
      el.addEventListener('pointerleave', reset);
      el.addEventListener('blur', reset);
    });
  }

  /*
    WebGL hero.

    three.js is 670KB. It is only fetched when every one of these is true, so
    phones and reduced-motion visitors never download it and never pay for it.
    Everyone else who fails a gate keeps the CSS gradient in .hero-canvas-layer,
    which is also what shows while the module is in flight.
  */
  function initHeroScene() {
    const layer = document.querySelector('.hero-canvas-layer');
    if (!layer) return;

    if (
      inThemeEditor ||
      reduceMotion.matches ||
      !finePointer.matches ||
      window.innerWidth < 768 ||
      !window.WebGL2RenderingContext
    ) {
      return;
    }

    // Confirm a real context can be created, not just that the class exists.
    const probe = document.createElement('canvas').getContext('webgl2');
    if (!probe) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (!entries.some((entry) => entry.isIntersecting)) return;
        observer.disconnect();

        import(layer.dataset.sceneSrc)
          .then((module) => module.mountHeroScene(layer))
          .catch(() => {
            /* Gradient fallback is already on screen. Nothing to undo. */
          });
      },
      { rootMargin: '200px' }
    );

    observer.observe(layer);
  }

  function boot() {
    try {
      initMagnetic();
    } catch (error) {
      console.warn('[brand] magnetic hover skipped', error);
    }

    try {
      initHeroScene();
    } catch (error) {
      console.warn('[brand] hero scene skipped', error);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot, { once: true });
  } else {
    boot();
  }

  // Re-run magnetic binding when the merchant edits a section in the editor.
  document.addEventListener('shopify:section:load', () => {
    try {
      initMagnetic();
    } catch (error) {
      console.warn('[brand] magnetic rebind skipped', error);
    }
  });
})();
