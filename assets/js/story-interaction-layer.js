const kebabize = (w) => w.replace(/\s+/g, "-").toLowerCase();

const tplKeyword = (word) => `<span word="${word}" class="ba-keyword font-semibold cursor-pointer">${word}</span>`;

const onload = () => {
  const showEvents = ["mouseenter", "focus"];
  const hideEvents = ["mouseleave", "blur"];
  const tooltip = document.querySelector("#tooltip");

  // transform keywords
  document.querySelectorAll(".content > .excerpt").forEach((excerpt) => {
    keywords.forEach((word) => {
      const regex = new RegExp("\\b" + word + "\\b", "g");
      excerpt.innerHTML = excerpt.innerHTML.replace(regex, tplKeyword(word));
    });
  });

  // setup keyword tooltips
  document.querySelectorAll(".ba-keyword").forEach((keyword) => {
    const popperInstance = Popper.createPopper(keyword, tooltip, {
      modifiers: [
        {
          name: "offset",
          options: {
            offset: [0, 5],
          },
        },
      ],
    });

    function showTooltip() {
      tooltip.setAttribute("data-show", "");
      popperInstance.update();
    }

    function hideTooltip() {
      tooltip.removeAttribute("data-show");
    }

    showEvents.forEach((event) => keyword.addEventListener(event, showTooltip));
    hideEvents.forEach((event) => keyword.addEventListener(event, hideTooltip));
  });
};

document.addEventListener("DOMContentLoaded", onload);
