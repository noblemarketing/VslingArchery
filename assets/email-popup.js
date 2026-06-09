class EmailPopup extends HTMLElement {
  constructor() {
    super();
    this.storageKey = 'vsling-email-popup-dismissed';
    this.delayMs = Number(this.dataset.delay || 8) * 1000;
    this.showOnce = this.dataset.showOnce !== 'false';
    this.form = this.querySelector('#EmailPopupForm');
    this.formPanel = this.querySelector('[data-email-popup-form]');
    this.successPanel = this.querySelector('[data-email-popup-success]');
    this.bindEvents();
    this.scheduleOpen();
    this.checkFormSuccess();
  }

  bindEvents() {
    this.querySelectorAll('[data-email-popup-close]').forEach((el) => {
      el.addEventListener('click', () => this.close(true));
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && this.classList.contains('is-open')) {
        this.close(true);
      }
    });
  }

  scheduleOpen() {
    if (this.showOnce && window.localStorage.getItem(this.storageKey) === 'true') {
      return;
    }

    window.setTimeout(() => {
      if (this.showOnce && window.localStorage.getItem(this.storageKey) === 'true') {
        return;
      }
      this.open();
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
    this.open(false);
    window.localStorage.setItem(this.storageKey, 'true');
  }

  open(persistDismissal = false) {
    this.hidden = false;
    this.classList.add('is-open');
    document.body.style.overflow = 'hidden';

    if (persistDismissal && this.showOnce) {
      window.localStorage.setItem(this.storageKey, 'true');
    }
  }

  close(persistDismissal = true) {
    this.classList.remove('is-open');
    this.hidden = true;
    document.body.style.overflow = '';

    if (persistDismissal && this.showOnce) {
      window.localStorage.setItem(this.storageKey, 'true');
    }
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

if (!customElements.get('email-popup')) {
  customElements.define('email-popup', EmailPopup);
}
