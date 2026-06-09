class SiteFaqAccordion {
  constructor(container) {
    this.container = container;
    this.details = Array.from(container.querySelectorAll('details.site-faq__item'));
    this.bindEvents();
  }

  bindEvents() {
    this.details.forEach((detail) => {
      detail.addEventListener('toggle', () => {
        if (!detail.open) {
          return;
        }

        this.details.forEach((other) => {
          if (other !== detail && other.open) {
            other.open = false;
          }
        });
      });
    });
  }
}

document.querySelectorAll('[data-site-faq]').forEach((container) => {
  new SiteFaqAccordion(container);
});
