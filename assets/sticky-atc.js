/*
  sticky-atc.js

  The sticky bar is a mirror, not a second product form. It forwards clicks to
  the real add-to-cart button and copies that button's label and disabled state,
  plus the price block's markup, whenever the theme re-renders them on a variant
  change. Nothing here talks to the Cart API.

  If this script fails, the bar simply never becomes visible — CSS keeps it
  translated off-screen and `visibility: hidden` until data-visible="true".
*/

if (!customElements.get('sticky-atc')) {
  customElements.define(
    'sticky-atc',
    class StickyAtc extends HTMLElement {
      connectedCallback() {
        this.submitTarget = document.getElementById(this.dataset.submitTarget);
        this.priceSource = document.getElementById(this.dataset.priceSource);
        this.button = this.querySelector('[data-sticky-submit]');
        this.label = this.querySelector('[data-sticky-label]');
        this.price = this.querySelector('[data-sticky-price]');

        if (!this.submitTarget || !this.button) return;

        this.button.addEventListener('click', this.forwardClick);
        this.syncButton();
        this.watchForRerenders();
        this.watchVisibility();
      }

      disconnectedCallback() {
        this.visibilityObserver?.disconnect();
        this.buttonObserver?.disconnect();
        this.priceObserver?.disconnect();
        this.button?.removeEventListener('click', this.forwardClick);
      }

      forwardClick = () => {
        this.submitTarget.click();
      };

      /* Show the bar only once the real button has scrolled out of view. */
      watchVisibility() {
        this.visibilityObserver = new IntersectionObserver(
          ([entry]) => {
            const shouldShow = !entry.isIntersecting && entry.boundingClientRect.top < 0;
            this.dataset.visible = String(shouldShow);
            // Keep it out of the tab order while it is off-screen.
            this.button.tabIndex = shouldShow ? 0 : -1;
          },
          { threshold: 0 }
        );

        this.visibilityObserver.observe(this.submitTarget);
      }

      /*
        Dawn replaces the button and price nodes wholesale when the variant
        changes, so observe the parents rather than the nodes themselves.
      */
      watchForRerenders() {
        this.buttonObserver = new MutationObserver(() => this.syncButton());
        this.buttonObserver.observe(this.submitTarget.parentElement || this.submitTarget, {
          subtree: true,
          childList: true,
          attributes: true,
          attributeFilter: ['disabled'],
        });

        if (this.priceSource && this.price) {
          this.priceObserver = new MutationObserver(() => this.syncPrice());
          this.priceObserver.observe(this.priceSource, { subtree: true, childList: true });
          this.syncPrice();
        }
      }

      syncButton() {
        const live = document.getElementById(this.dataset.submitTarget);
        if (!live) return;
        this.submitTarget = live;

        this.button.disabled = live.disabled;

        const liveLabel = live.querySelector('span');
        if (liveLabel && this.label) {
          this.label.textContent = liveLabel.textContent.trim();
        }
      }

      syncPrice() {
        this.price.innerHTML = this.priceSource.innerHTML;
      }
    }
  );
}
