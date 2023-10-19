
window.addEventListener("load", function() {
  let userKeyRows = document.querySelectorAll("[id^='userKey']");

  userKeyRows.forEach((userKeyRow) => {
    userKeyRow.addEventListener("click", function() {
      let revokeButton = document.getElementById(`revoke-${userKeyRow.id}`);
      if (revokeButton.style.display == "inline-block") {
        revokeButton.style.display = "none";
      } else {
        revokeButton.style.display = "inline-block";
      }
    })
  })

})


