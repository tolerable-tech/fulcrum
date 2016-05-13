import {Socket} from "deps/phoenix/web/static/js/phoenix"
import "deps/phoenix_html/web/static/js/phoenix_html"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.channel("topic:subtopic", {})
// chan.join().receive("ok", chan => {
//   console.log("Success!")
// })

let App = {
	bindToLoginForm: function() {
//TODO figure out how to use this
		  console.log("hurr");
			$("form#login").on("ajax:success", function(){
				console.log("success!");
				window.location = "/" // redirect wherever you want to after login
			}).on("ajax:error", function(){
				console.log("what!");
				$(".alert-danger").html("Unable to login.");
			}).on("ajax:complete", function() {
				console.log("wtf bro");
			});
  }
}

window.App = App;

export default App
