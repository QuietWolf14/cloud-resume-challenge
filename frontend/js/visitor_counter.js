// define the callAPI function that takes a first name and last name as parameters
var callAPI = (firstName,lastName)=>{
  // instantiate a headers object
  //var myHeaders = new Headers();
  
  // add content type header to object
  //myHeaders.append("Content-Type", "application/json");
  
  // using the built-in JSON utility package, turn object to string and store in a variable
  var raw = JSON.stringify({"firstName":firstName,"lastName":lastName});
  
  // create a JSON object with parameters for API call and store in a variable
  var requestOptions = {
      method: 'GET',
      //headers: myHeaders,
      mode: "cors",
      redirect: 'follow'
  };
  
  // make API call with parameters and use promises to get response
  fetch("https://k1mjxiesd7.execute-api.us-east-1.amazonaws.com/dev/visitor-count", requestOptions)
  //.then(response => response.text())
  .then(response => {
    return response.json();
  })
  .then(result => {
    visitor_count = result.visitor_count;
    document.getElementById('count-el').innerText = visitor_count
  })
  .catch(error => {
    console.log('error', error);
  });

}
// origin is http://127.0.0.1:5500