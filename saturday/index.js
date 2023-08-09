class Classy {
  constructor(x) {
    this.x = x;
  }

  getX() {
    return this.x;
  }
}

const a = new Classy("a");
const b = new Classy("b");

console.log(a.getX === b.getX);
