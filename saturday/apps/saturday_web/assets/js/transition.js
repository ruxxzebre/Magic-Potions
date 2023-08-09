export const transition = {
  mounted() {
    this.startTransition();
  },
  waitFor(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  },
  async startTransition() {
    // this.el.classList.remove("fade-in", "scale-100");
    // this.el.classList.add("fade-in", "scale-95");
    await this.waitFor(10);
  },
};
