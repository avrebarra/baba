const kebabize = (w) => w.replace(/\s+/g, "-").toLowerCase();
const wait = async (fx) => (fx() ? new Promise((r) => setTimeout(() => wait(fx).then(r), 100)) : Promise.resolve());

const tplKeyword = (word) => `<span word="${word}" class="ba-keyword font-semibold cursor-pointer">${word}</span>`;

const onload = async () => {
  const showEvents = ["mouseenter", "focus"];
  const hideEvents = ["mouseleave", "blur"];
  const tooltip = document.querySelector("#tooltip");

  // wait for dictionary loading
  const dictionary = await useDictionary();

  // transform keywords
  document.querySelectorAll(".content > .excerpt").forEach((excerpt) => {
    keywords.forEach((word) => {
      const regex = new RegExp("\\b" + word + "\\b", "g");
      excerpt.innerHTML = excerpt.innerHTML.replace(regex, tplKeyword(word));
    });
  });

  // setup keyword tooltips
  document.querySelectorAll(".ba-keyword").forEach((keywordEl) => {
    const popperInstance = Popper.createPopper(keywordEl, tooltip, {
      modifiers: [
        {
          name: "offset",
          options: {
            offset: [0, 5],
          },
        },
      ],
    });

    function showTooltip(el) {
      const word = el.getAttribute("word");
      tooltip.querySelector("#content").innerHTML = dictionary[word] || "No Translation Found";
      tooltip.setAttribute("data-show", "");
      popperInstance.update();
    }

    function hideTooltip() {
      tooltip.removeAttribute("data-show");
    }

    showEvents.forEach((e) => {
      keywordEl.addEventListener(e, () => showTooltip(keywordEl));
    });
    hideEvents.forEach((e) => {
      keywordEl.addEventListener(e, hideTooltip);
    });
  });
};

document.addEventListener("DOMContentLoaded", onload);
