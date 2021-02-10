var name = "";
var phone = "";
var i = 2010;

function fetch() {
  name = phone = "" + i + "";
  var form = new FormData();
  form.append("type", "public");
  form.append("name", name);
  form.append("workphone", phone);
  form.append("company", "Wedo");
  form.append("extension", phone);

  var settings = {
    "url": "https://nethctiapp.nethserver.net/webrest/phonebook/create",
    "method": "POST",
    "timeout": 0,
    "headers": {
      "Authorization": "andrea:8cd505076921b2445a046650c922d9f8a20757f6"
    },
    "processData": false,
    "mimeType": "multipart/form-data",
    "contentType": false,
    "data": form
  };

  $.ajax(settings).done(function (response) {
    console.log(response);
  });
}
