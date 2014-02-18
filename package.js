Package.describe({
  summary: "Upload csv email list."
});

Package.on_use(function (api) {
  api.use(["coffeescript", "iron-router", "underscore", 'standard-app-packages'], ["client", "server"]);
  api.add_files(["inviteListEvent.litcoffee", "inviteList.html", "csvToArray.litcoffee", "inviteList.litcoffee"], "client");
  api.add_files("emailCSV.litcoffee",["client", "server"]);

  api.export("inviteListEvent", 'client');
});
