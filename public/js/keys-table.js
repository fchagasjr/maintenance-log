let userKeyRows = document.querySelectorAll("[id^='user-key-']");

userKeyRows.forEach((userKeyRow) => {
  userKeyRow.addEventListener("click", function() {
    let revokeButton = document.getElementById(`revoke-${userKeyRow.id}`);
    if (revokeButton.style.display == "none") {
      revokeButton.style.display = "block";
    } else {
      revokeButton.style.display = "none";
    }
    console.log("Clicked");
  })
})
