
let Hooks = {};
Hooks.DetectShift = {
  mounted() {
    this.el.addEventListener("mousedown", e => {
      let shiftPressed = e.shiftKey;
      this.el.setAttribute("phx-value-shift-pressed", shiftPressed);
    });
  }
};

export default Hooks;

