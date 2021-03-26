var names = [];
var companies = [];
let titles = ["Software Developer", "System Administrator", "DevOps Engineer", "CEO", "CIO", "CTO", "KT", "Consulente alle Vendite", "Consulente Aziendale", "Responsabile Risorse Umane"];
let characters = '0123456789';

$(document).ready(function () {
  // Fetch document at upload.
  $("#make-call-button").on("click", function(e) {
    e.preventDefault();
    start_fetch();
  });
  $("#inputfile").on("change", function() {
    read_names(this.files[0]);
  });
  $("#companiesfile").on("change", function() {
    read_companies(this.files[0]);
  });
  $("#make-call-spinner").hide();
});

const read_names = (f) => {
	let fr = new FileReader();
    fr.onload = function() {
      $('#output').text(fr.result);
      names = ("" + fr.result).split("\n");
      console.log("Names: " + names.length);
    }
    fr.readAsText(f);
}

const read_companies = (f) => {
	let fr = new FileReader();
    fr.onload = function() {
      $('#output').text(fr.result);
      companies = ("" + fr.result).split("\n");
      console.log("Companies: " + companies.length);
    }
    fr.readAsText(f);
}

function start_fetch() {
	let n = $("#callNumber").val();
  $("#make-call-spinner").show();
  $("#results").text("");
	if(n > 0) fetch(n, n);
	else fetch(1, 1);
}

function fetch(tot, counter) {
  var name = "";
  var surname = "";
  if(names.length > 0) {
    name = randomName();
    surname = randomName();
  } else {
    name = randomId(5);
    surname = randomId(10);
  }
  let company = random_company();
  let title = random_title();

  let form = new FormData();
  form.append("type", "public");
  form.append("name", name + " " + surname);
  form.append("workphone", "" + makeNumber(10));
  form.append("extension", "" + makeNumber(4));
  form.append("company", company);
  form.append("title", title);
  form.append("notes", "Made from Daniele Tentoni js script.");
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
    	let text = $('#results').text();
    	$("#results").text(text + name + " " + surname + " " + company + " " + title + "\n");
    	console.log("Process request " + next);
      let perc = (tot - next) / tot * 100;
      $("#call-progress").css('width', perc + '%').attr('aria-valuenow', perc);
    	if(next > 0) {
    		fetch(tot, next);
    	} else {
        $("#make-call-spinner").hide();
    	}
    }
  });
}

function randomName() {
  return capitalize(names[Math.floor(Math.random() * names.length)]);
}

// Generate a random string.
function randomId(length) {
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
  var result = '';
  for (var i = 0; i < length; i++ ) {
    // This is a randomId.
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

function random_company() {
	return companies[Math.floor(Math.random() * companies.length)];
}

function random_title() {
	return titles[Math.floor(Math.random() * titles.length)];
}

// Capitalize first char of a string.
const capitalize = (s) => {
  if (typeof s !== 'string') return ''
  return s.charAt(0).toUpperCase() + s.slice(1)
}