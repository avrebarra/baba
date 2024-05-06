<script>
  document.addEventListener("DOMContentLoaded", (event) => {
    var keywords = {{ page.keywords | jsonify }};
    document.querySelectorAll(".content > .excerpt").forEach((excerpt) => {
      keywords.forEach((word) => {
        const regex = new RegExp("\\b" + word + "\\b", "g");
        const wordkebab = word.replace(/\s+/g, '-').toLowerCase()

        excerpt.innerHTML = excerpt.innerHTML.replace(regex, `<span class="keyword keyword-${wordkebab} font-semibold">${word}</span>`);
      });
    });

    // new ReadingTime(270, "", "minutes read", "words", "Less than a minute read");
  });
</script>
