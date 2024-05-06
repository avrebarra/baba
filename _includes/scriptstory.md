<script>
  document.addEventListener("DOMContentLoaded", (event) => {
    var keywords = {{ page.keywords | jsonify }};
    document.querySelectorAll(".content > .excerpt").forEach((excerpt) => {
      keywords.forEach((word) => {
        const regex = new RegExp(word, "g");
        excerpt.innerHTML = excerpt.innerHTML.replace(regex, `<span class="keyword font-semibold">${word}</span>`);
      });
    });

    // new ReadingTime(270, "", "minutes read", "words", "Less than a minute read");
  });
</script>
