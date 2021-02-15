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
  var surname = "";
  if(names.length > 0) {
    name = randomName();
    surname = randomName();
  } else {
    name = randomId(5);
    surname = randomId(10);
  }

  let form = new FormData();
  form.append("type", "public");
  form.append("name", name + " " + surname);
  form.append("workphone", "" + makeNumber(10));
  form.append("extension", "" + makeNumber(4));
  form.append("company", random_company());
  form.append("title", "Developer");
  form.append("notes", "Made from Daniele Tentoni js script.");
  debugger;
  // form.append("extension", "" + name);

  let authToken = $("#authTokenInput").val();
  if(!authToken) {
  	alert("Insert auth token");
  	return;
  }

  $.ajax({
    data: form,
    cache: false,
    contentType: false,
    headers: {
      "Authorization": authToken
    },
    method: "POST",
    mimeType: "multipart/form-data",
    processData: false,
    timeout: 0,
    url: "https://nethctiapp.nethserver.net/webrest/phonebook/create",
    success: function (response) {
      let next = counter - 1;
      console.log("Success call for " + name + " " + surname);
      console.log("Process request " + next);
      if(next > 0)
        fetch(next);
      else
        console.log("Finish");
    }
  });
}

function randomName() {
  return capitalize(names[Math.floor(Math.random() * names.length)]);
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
  return capitalize(result);
}

// Generate a random number.
function makeNumber(length) {
  let characters = '0123456789';
  let charactersLength = characters.length;
  var result = '';
  for (var i = 0; i < length; i++ ) {
    // This is a randomId.
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

function random_company() {
	let companies = ["Wedo", "Nethesis", "MyCompany"];
	return companies[Math.floor(Math.random() * companies.length)];
}

// Capitalize first char of a string.
const capitalize = (s) => {
  if (typeof s !== 'string') return ''
  return s.charAt(0).toUpperCase() + s.slice(1)
}