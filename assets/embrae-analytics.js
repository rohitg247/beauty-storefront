/*
  embrae-analytics.js — EMBRAE-specific funnel instrumentation.

  WHY THIS FILE EXISTS
  --------------------
  Shopify's own Web Pixels already emit the standard commerce events:
  page_viewed, product_viewed, product_added_to_cart, checkout_started and so
  on. Re-emitting those here would double-count them.

  What Shopify cannot know about is the funnel that is specific to this store:
  the skin quiz, the RESET/DEFEND/ADAPT/PROTECT routine, bundle consideration,
  and the sticky add-to-cart. Those are the events that answer the questions
  actually worth asking - does the quiz convert better than browsing, does the
  routine module move people to a bundle - and none of them was instrumented.

  HOW IT REACHES ANALYTICS
  ------------------------
  Everything goes through Shopify.analytics.publish(), which is the sanctioned
  route from theme code into Web Pixels. Any pixel the merchant connects - GA4
  via the Google channel, Meta CAPI via the Meta channel, or a custom pixel -
  subscribes to these by name.

  Pixels are NOT hardcoded into theme.liquid on purpose. A hardcoded gtag or
  fbq bypasses Shopify's Customer Privacy API, so it fires regardless of
  consent, which is a compliance problem and not a small one.

  SAFETY
  ------
  Additive and entirely optional. Every entry point is wrapped, and a failure
  here cannot reach Dawn's scripts - if Shopify.analytics is absent, or a
  selector changes, this file goes quiet and the store is unaffected. It sends
  no personal data: no email, no name, no address, no free-text answer.
*/

(function () {
  'use strict';

  // ---------------------------------------------------------------- helpers

  function emit(name, payload) {
    try {
      if (window.Shopify && window.Shopify.analytics && typeof window.Shopify.analytics.publish === 'function') {
        window.Shopify.analytics.publish(name, payload || {});
      }
    } catch (e) {
      /* Analytics must never break a page. */
    }
  }

  // Fires once per event name per page view. Guards against a scroll observer
  // or a repeated open/close inflating a count that is meant to mean "saw it".
  var seen = Object.create(null);
  function emitOnce(key, name, payload) {
    if (seen[key]) return;
    seen[key] = true;
    emit(name, payload);
  }

  function safe(fn) {
    return function () {
      try {
        return fn.apply(this, arguments);
      } catch (e) {
        /* swallow */
      }
    };
  }

  // ------------------------------------------------------------- skin quiz

  var quizStarted = false;

  var initQuiz = safe(function () {
    var quiz = document.querySelector('quiz-form');
    if (!quiz) return;

    emitOnce('quiz_view', 'embrae_quiz_view', {});

    // Delegated rather than bound to each control: the quiz re-renders its
    // steps, so anything bound directly would be lost after the first advance.
    quiz.addEventListener(
      'change',
      safe(function (event) {
        if (!event.target || event.target.type !== 'radio') return;

        if (!quizStarted) {
          quizStarted = true;
          emit('embrae_quiz_start', {});
        }

        emit('embrae_quiz_answer', {
          question: event.target.name || null,
          // The VALUE only, never a free-text field. Quiz answers are skin
          // information and the useful signal is which option, not who.
          answer: event.target.value || null,
        });
      })
    );

    // The result block is rendered server-side for every outcome and revealed
    // on completion, so its appearance - not a click - is what marks the end
    // of the quiz.
    var result = quiz.querySelector('[id*="quiz-result"], .quiz__result');
    if (result && typeof MutationObserver === 'function') {
      var observer = new MutationObserver(
        safe(function () {
          if (result.offsetParent === null) return;
          emitOnce('quiz_complete', 'embrae_quiz_complete', {
            recommended: result.querySelectorAll('[data-product-handle], .card-wrapper').length,
          });
        })
      );
      observer.observe(quiz, { attributes: true, childList: true, subtree: true });
    }
  });

  // ------------------------------------------------- routine, bundles, ATC

  var initCommerce = safe(function () {
    // Sticky ATC is a distinct decision point from the in-page button: it means
    // someone scrolled past the buy area and came back to it.
    document.addEventListener(
      'click',
      safe(function (event) {
        var t = event.target;
        if (!t || !t.closest) return;

        if (t.closest('.sticky-atc')) {
          emit('embrae_sticky_atc_click', { path: window.location.pathname });
        }

        var step = t.closest('.routine-arch__item');
        if (step) {
          var action = step.querySelector('.routine-arch__action');
          emit('embrae_routine_step_click', {
            step: action ? action.textContent.trim() : null,
          });
        }

        var daypart = t.closest('.routine-daypart__panel');
        if (daypart && t.closest('.button')) {
          var heading = daypart.querySelector('.routine-daypart__heading');
          emit('embrae_routine_daypart_click', {
            daypart: heading ? heading.textContent.trim() : null,
          });
        }
      }),
      // Passive: this only reads, never preventDefault, so it must not sit on
      // the critical path of a tap.
      { passive: true }
    );

    // FAQ expansion is the cheapest read on purchase anxiety available - which
    // question, on which page, before buying.
    document.addEventListener(
      'toggle',
      safe(function (event) {
        var d = event.target;
        if (!d || d.tagName !== 'DETAILS' || !d.open) return;
        var summary = d.querySelector('summary');
        if (!summary) return;
        emit('embrae_faq_expand', {
          question: summary.textContent.trim().slice(0, 120),
          path: window.location.pathname,
        });
      }),
      true // toggle does not bubble
    );
  });

  // ------------------------------------------------------ viewport signals

  var initViewport = safe(function () {
    if (typeof IntersectionObserver !== 'function') return;

    var targets = [
      ['.routine-arch__list', 'embrae_routine_view', 'routine'],
      ['.product__attributes', 'embrae_pdp_attributes_view', 'pdp_attributes'],
    ];

    targets.forEach(function (entry) {
      var el = document.querySelector(entry[0]);
      if (!el) return;
      var io = new IntersectionObserver(
        safe(function (entries) {
          entries.forEach(function (e) {
            if (!e.isIntersecting) return;
            emitOnce(entry[2], entry[1], { path: window.location.pathname });
            io.disconnect();
          });
        }),
        { threshold: 0.4 }
      );
      io.observe(el);
    });
  });

  // ------------------------------------------------------------------ boot

  var boot = safe(function () {
    // The theme editor re-renders sections constantly; counting those would
    // make the numbers meaningless.
    if (window.Shopify && window.Shopify.designMode) return;
    initQuiz();
    initCommerce();
    initViewport();
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot, { once: true });
  } else {
    boot();
  }
})();
