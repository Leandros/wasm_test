let obj = "../out.wasm";

let buf = "";

fetch(obj).then(response =>
	response.arrayBuffer()
).then(bytes =>
	WebAssembly.instantiate(bytes, {
		env: {
			putc: function(c) {
				c = String.fromCharCode(c);
				if (c === "\n") {
					console.log(buf);
					buf = "";
				} else {
				  buf += c;
				}
			}
		}
	})
).then(results => {
  instance = results.instance;
  document.getElementById("container").innerText = instance.exports.main();
});

