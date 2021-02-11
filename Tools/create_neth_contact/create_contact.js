var names = [];
$(document).ready(function () {
  // Fetch document at upload.
  $("#inputfile").on("change", function() {
    let fr = new FileReader();
    fr.onload = function() {
      $('#output').text(fr.result);
      names = ("" + fr.result).split("\n");
      console.log(names.length);
    }
    fr.readAsText(this.files[0]);
  });
});

function start_fetch() {
  let n = $("#callNumber").val();
  if(n > 0) fetch(n);
  else fetch(1);
}

function fetch(counter) {
  var name = "";
  if(names.length > 0) {
    name = randomName();
  } else {
    name = randomId(5);
  }
  name = capitalize(name);

  let form = new FormData();
  form.append("type", "public");
  form.append("name", "" + name);
  form.append("workphone", "" + makeNumber());
  form.append("company", "Wedo");
  form.append("title", "Developer");
  form.append("notes", "Made from Daniele Tentoni js script.");
  // form.append("extension", "" + name);

  $.ajax({
    data: form,
    cache: false,
    contentType: false,
    headers: {
      "Authorization": "andrea:73aeb0e22afb5d9393d477e28d67ef54a24d3e54"
    },
    method: "POST",
    mimeType: "multipart/form-data",
    processData: false,
    timeout: 0,
    url: "https://nethctiapp.nethserver.net/webrest/phonebook/create",
    success: function (response) {
      let next = counter - 1;
      console.log("Success call for " + name);
      console.log("Process request " + next);
      if(next > 0)
        fetch(next);
      else
        console.log("Finish");
    }
  });
}

function randomName() {
  return names[Math.floor(Math.random() * names.length)];
}

// Generate a random string.
function makeId(length) {
  let characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let charactersLength = characters.length;
  var result = '';
  for (var i = 0; i < length; i++ ) {
    // This is a randomId.
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

// Generate a random number.
function makeNumber() {
  let characters = '0123456789';
  let charactersLength = characters.length;
  var result = '';
  for (var i = 0; i < 10; i++ ) {
    // This is a randomId.
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

// Capitalize first char of a string.
const capitalize = (s) => {
  if (typeof s !== 'string') return ''
  return s.charAt(0).toUpperCase() + s.slice(1)
}