if (!customElements.get('newsletter-popup')) {
  customElements.define(
    'newsletter-popup',
    class NewsletterPopup extends ModalDialog {
      constructor() {
        super();
        this.storageKey = 'vsling-newsletter-popup-dismissed';
        this.delayMs = Number(this.dataset.delay || 8) * 1000;
        this.showOnce = this.dataset.showOnce !== 'false';
        this.formPanel = this.querySelector('[data-popup-form]');
        this.successPanel = this.querySelector('[data-popup-success]');
      }

      connectedCallback() {
        super.connectedCallback();
        this.checkFormSuccess();
        this.scheduleOpen();
      }

      show() {
        this.setAttribute('open', '');
      }

      hide() {
        this.removeAttribute('open');
        if (this.showOnce) {
          window.localStorage.setItem(this.storageKey, 'true');
        }
      }

      scheduleOpen() {
        if (this.hasAttribute('open')) {
          return;
        }

        if (this.showOnce && window.localStorage.getItem(this.storageKey) === 'true') {
          return;
        }

        window.setTimeout(() => {
          if (this.showOnce && window.localStorage.getItem(this.storageKey) === 'true') {
            return;
          }
          this.show();
        }, this.delayMs);
      }

      checkFormSuccess() {
        const params = new URLSearchParams(window.location.search);
        const hash = window.location.hash;
        const customerPosted = params.get('customer_posted') === 'true' || hash.includes('contact_posted');

        if (!customerPosted) {
          return;
        }

        this.showSuccess();
        this.show();
        window.localStorage.setItem(this.storageKey, 'true');
      }

      showSuccess() {
        if (this.formPanel) {
          this.formPanel.hidden = true;
        }
        if (this.successPanel) {
          this.successPanel.hidden = false;
        }
      }
    }
  );
}
