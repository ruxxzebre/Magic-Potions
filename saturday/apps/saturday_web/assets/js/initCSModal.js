export const InitCSModal = {
  mounted() {
    const self = this;
    (
      document.querySelectorAll(
        ".modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button"
      ) || []
    ).forEach(($close) => {
      $close.addEventListener("click", () => {
        self.pushEvent("close-cs-modal");
      });
    });
  },
};
