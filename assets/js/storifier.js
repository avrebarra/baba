const kebabize = (w) => w.replace(/\s+/g, "-").toLowerCase();
const wait = async (fx) => (fx() ? new Promise((r) => setTimeout(() => wait(fx).then(r), 100)) : Promise.resolve());

const tplParagraph = (text) => `<p>${text}</p>`;
const tplKeyword = (word) => `<span word="${word}" class="ba-keyword font-semibold cursor-pointer">${word}</span>`;
const tplKeywordTranslations = (words) => words.map((word) => `<div class="text-center">${word}</div>`).join("");

const onload = async () => {
  const showEvents = ["mouseenter", "focus"];
  const hideEvents = ["mouseleave", "blur"];
  const tooltip = document.querySelector("#tooltip");

  // wait for dictionary loading
  const dictionary = await useDictionary();
  const storyOrig = await useStory(STORY_URL);
  const story = { ...storyOrig.translations["en-pt"], keywords: Object.keys(storyOrig.translations["en-pt"].keywords) };
  console.log(story);

  // load story content
  const titleEl = document.querySelector("#story-title > .data");
  titleEl.innerHTML = story.title;

  const contentEl = document.querySelector("#story-content > .data");
  contentEl.innerHTML = story.paragraphs.map((text) => tplParagraph(text)).join("\n");

  // transform keywords
  document.querySelectorAll("#story-content > .data").forEach((excerpt) => {
    story.keywords.forEach((word) => {
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
      tooltip.querySelector("#content").innerHTML = tplKeywordTranslations(dictionary[word]) || "No Translation Found";
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
