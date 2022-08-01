export const InitModal = {
  initEventHandlers() {
    (document.querySelectorAll('.js-modal-trigger') || []).forEach(($trigger) => {
      const modal = $trigger.dataset.target;
      const $target = document.getElementById(modal);
  
      $trigger.addEventListener('click', () => {
        this.openModal($target);
      });
    });

    (document.querySelectorAll('.modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button') || []).forEach(($close) => {
      const $target = $close.closest('.modal');
  
      $close.addEventListener('click', () => {
        this.closeModal($target);
      });
    });

    document.addEventListener('keydown', (event) => {
      const e = event || window.event;
  
      if (e.keyCode === 27) { // Escape key
        this.closeAllModals();
      }
    });
  },
  openModal($el) {
    if ($el.childElementCount > 0)
      $el.classList.add('is-active');
  },
  closeModal($el) {
    $el.classList.remove('is-active');
    this.pushEvent("close-modal");
  },
  closeAllModals() {
    (document.querySelectorAll('.modal') || []).forEach(($modal) => {
      this.closeModal($modal);
    });
  },
  mounted() {
    // U know, just in case
    this.closeAllModals = this.closeAllModals.bind(this);
    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.initEventHandlers = this.initEventHandlers.bind(this);

    this.initEventHandlers();
  }
}