/*
  skin-quiz.js — turns the server-rendered quiz into a stepped experience.

  Contract with sections/skin-quiz.liquid and section-skin-quiz.css:

  - Without this file the page is already useful: every question and every
    result panel is visible and it reads as "routines by concern". The CSS keys
    all hiding off `quiz-form:defined`, so nothing collapses until this script
    has actually registered the element. No flash, nothing stuck invisible.
  - If setup throws, `data-quiz-failed` goes on the element and the stylesheet
    restores that same base layout. A broken script degrades to a working page.
  - No scoring data lives in here. Each input carries data-concerns and
    data-weight, so the markup is the single source of truth.

  Everything is wrapped so a throw cannot escape into Dawn's scripts.
*/

(function () {
  'use strict';

  var STORE_KEY = 'embrae:quiz:result';
  var STORE_DAYS = 30;

  /* localStorage is not guaranteed: private windows, blocked site data, and
     thumbnail/preview contexts can all throw on access rather than return
     null. Every read and write is therefore best-effort and the quiz works
     identically when it fails. */
  function readStored() {
    try {
      var raw = window.localStorage.getItem(STORE_KEY);
      if (!raw) return null;
      var parsed = JSON.parse(raw);
      if (!parsed || !parsed.concern || !parsed.at) return null;
      var ageDays = (Date.now() - parsed.at) / 86400000;
      return ageDays > STORE_DAYS ? null : parsed.concern;
    } catch (e) {
      return null;
    }
  }

  function writeStored(concern) {
    try {
      window.localStorage.setItem(STORE_KEY, JSON.stringify({ concern: concern, at: Date.now() }));
    } catch (e) {
      /* Not being able to remember the result is not a failure worth surfacing. */
    }
  }

  function clearStored() {
    try {
      window.localStorage.removeItem(STORE_KEY);
    } catch (e) {}
  }

  function param(name) {
    try {
      return new URLSearchParams(window.location.search).get(name);
    } catch (e) {
      return null;
    }
  }

  class QuizForm extends HTMLElement {
    connectedCallback() {
      try {
        this.setup();
      } catch (e) {
        /* Put the page back the way it renders without JS. */
        this.setAttribute('data-quiz-failed', '');
        if (window.console && console.warn) console.warn('[skin-quiz] disabled:', e);
      }
    }

    setup() {
      this.steps = Array.prototype.slice.call(this.querySelectorAll('[data-quiz-step]'));
      this.results = Array.prototype.slice.call(this.querySelectorAll('[data-quiz-result]'));
      this.progressEl = this.querySelector('[data-quiz-progress]');
      this.navEl = this.querySelector('[data-quiz-nav]');
      this.backBtn = this.querySelector('[data-quiz-back]');
      this.nextBtn = this.querySelector('[data-quiz-next]');
      this.tagsInput = this.querySelector('[data-quiz-tags]');

      if (!this.steps.length) throw new Error('no questions');

      this.nextLabel = this.nextBtn ? this.nextBtn.textContent.trim() : 'Next';
      this.finishLabel = this.getAttribute('data-finish-label') || this.nextLabel;
      this.index = 0;

      if (this.backBtn) this.backBtn.addEventListener('click', this.back.bind(this));
      if (this.nextBtn) this.nextBtn.addEventListener('click', this.next.bind(this));

      Array.prototype.forEach.call(this.querySelectorAll('[data-quiz-retake]'), function (btn) {
        btn.addEventListener('click', this.retake.bind(this));
      }, this);

      /* Clear the "answer this first" message as soon as they answer. */
      this.addEventListener('change', function (event) {
        if (!event.target.classList.contains('quiz__input')) return;
        var step = event.target.closest('[data-quiz-step]');
        if (!step) return;
        var err = step.querySelector('[data-quiz-error]');
        if (err) err.hidden = true;
      });

      /* A result is only restored when the visitor asked for one — a #quiz-result
         link or a ?concern= link. Landing on the plain quiz URL from "Take Skin
         Quiz" must always start at question one, or that nav item is broken. */
      var deepLink = param('concern');
      var wantsResult = deepLink || window.location.hash === '#quiz-result';
      var restore = deepLink || (wantsResult ? readStored() : null);

      if (restore && this.hasResult(restore)) {
        this.showResult(restore, { focus: false, push: false });
      } else {
        this.showStep(0);
      }
    }

    hasResult(handle) {
      return this.results.some(function (el) {
        return el.getAttribute('data-quiz-result') === handle;
      });
    }

    showStep(i) {
      this.index = i;
      this.removeAttribute('data-quiz-complete');

      this.steps.forEach(function (step, n) {
        step.classList.toggle('is-active', n === i);
      });

      this.results.forEach(function (el) {
        el.classList.remove('is-active');
      });

      if (this.backBtn) this.backBtn.hidden = i === 0;
      if (this.nextBtn) {
        this.nextBtn.textContent = i === this.steps.length - 1 ? this.finishLabel : this.nextLabel;
      }

      if (this.progressEl) {
        var label = this.steps[i].getAttribute('data-step-label') || '';
        this.progressEl.textContent =
          'Step ' + (i + 1) + ' of ' + this.steps.length + (label ? ' — ' + label : '');
      }
    }

    focusStep() {
      var legend = this.steps[this.index].querySelector('.quiz__question');
      if (legend && typeof legend.focus === 'function') legend.focus();
    }

    answered(step) {
      return !!step.querySelector('.quiz__input:checked');
    }

    next() {
      var step = this.steps[this.index];

      if (!this.answered(step)) {
        var err = step.querySelector('[data-quiz-error]');
        if (err) err.hidden = false;
        this.focusStep();
        return;
      }

      if (this.index < this.steps.length - 1) {
        this.showStep(this.index + 1);
        this.focusStep();
        return;
      }

      var winner = this.score();
      if (winner) this.showResult(winner, { focus: true, push: true });
    }

    back() {
      if (this.index === 0) return;
      this.showStep(this.index - 1);
      this.focusStep();
    }

    /* Each checked answer adds its weight to every concern it names. Highest
       total wins; a tie resolves to whichever concern was reached first, which
       is the earlier question — the more important one, since the questions are
       ordered by the merchant. */
    score() {
      var tally = {};
      var order = [];

      Array.prototype.forEach.call(this.querySelectorAll('.quiz__input:checked'), function (input) {
        var raw = (input.getAttribute('data-concerns') || '').trim();
        if (!raw) return;
        var weight = parseInt(input.getAttribute('data-weight'), 10);
        if (isNaN(weight)) weight = 1;

        raw.split(',').forEach(function (handle) {
          var key = handle.trim();
          if (!key) return;
          if (!(key in tally)) {
            tally[key] = 0;
            order.push(key);
          }
          tally[key] += weight;
        });
      });

      var best = null;
      var bestScore = -1;
      order.forEach(function (key) {
        if (tally[key] > bestScore) {
          bestScore = tally[key];
          best = key;
        }
      });

      /* Every scoring answer pointed at a concern with no result panel. Rather
         than show nothing, fall back to the first panel on the page. */
      if (best && !this.hasResult(best)) {
        best = this.results.length ? this.results[0].getAttribute('data-quiz-result') : null;
      }

      return best;
    }

    showResult(handle, opts) {
      opts = opts || {};

      this.setAttribute('data-quiz-complete', '');
      this.steps.forEach(function (step) {
        step.classList.remove('is-active');
      });

      var active = null;
      this.results.forEach(function (el) {
        var match = el.getAttribute('data-quiz-result') === handle;
        el.classList.toggle('is-active', match);
        if (match) active = el;
      });

      if (this.progressEl) this.progressEl.textContent = '';

      /* Tagging the subscriber with the concern they matched. The theme's own
         newsletter form already posts contact[tags], so this rides an existing
         supported field rather than inventing one. */
      if (this.tagsInput) this.tagsInput.value = 'newsletter,quiz-' + handle;

      writeStored(handle);

      /* Make the result linkable and shareable without adding a history entry
         the back button would have to walk through. */
      try {
        var url = new URL(window.location.href);
        url.searchParams.set('concern', handle);
        url.hash = 'quiz-result';
        window.history.replaceState({}, '', url.toString());
      } catch (e) {}

      if (opts.focus && active) {
        var heading = active.querySelector('.quiz__result-title');
        if (heading && typeof heading.focus === 'function') heading.focus();
      }
    }

    retake() {
      clearStored();

      Array.prototype.forEach.call(this.querySelectorAll('.quiz__input:checked'), function (input) {
        input.checked = false;
      });

      if (this.tagsInput) this.tagsInput.value = 'newsletter';

      try {
        var url = new URL(window.location.href);
        url.searchParams.delete('concern');
        url.hash = '';
        window.history.replaceState({}, '', url.toString());
      } catch (e) {}

      this.showStep(0);
      this.focusStep();
    }
  }

  try {
    /* In the theme editor every question and every result stays visible, so a
       merchant can see and style all of it without playing through the quiz. */
    if (window.Shopify && window.Shopify.designMode) return;

    if (!window.customElements || window.customElements.get('quiz-form')) return;
    window.customElements.define('quiz-form', QuizForm);
  } catch (e) {
    if (window.console && console.warn) console.warn('[skin-quiz] not registered:', e);
  }
})();
