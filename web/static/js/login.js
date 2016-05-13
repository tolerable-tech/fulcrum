$("form#login").on("ajax:success", function(){
  window.location = "/" // redirect wherever you want to after login
}).on("ajax:error", function(){
  $(".alert-danger").html("Unable to login.");
});
