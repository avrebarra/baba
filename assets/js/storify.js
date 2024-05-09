const kebabize = (w) => w.replace(/\s+/g, "-").toLowerCase();
const wait = async (fx) => (fx() ? new Promise((r) => setTimeout(() => wait(fx).then(r), 100)) : Promise.resolve());

const tplParagraph = (text) => `<p>${text}</p>`;
const tplKeyword = (word) => `<span word="${word}">${word}</span>`;
const tplKeywordMain = (word) => `<span word="${word}" class="ba-keyword font-semibold cursor-pointer">${word}</span>`;
const tplKeywordTranslations = (words) => words.map((word) => `<div class="text-center">${word}</div>`).join("");

let selectedWord = null;

const onload = async () => {
  const showEvents = ["mouseenter", "focus"];
  const hideEvents = ["mouseleave", "blur"];
  const tooltipEl = document.querySelector("#tooltip");

  // wait for data loadings
  const { get: getLang } = await useLanguageSwitcher();
  const lang = await getLang();
  const [from, to] = lang.split("-");

  const storyAssets = await useStoryAssets(Babba.storyID);
  const story = storyAssets.translations[lang];
  const hasTranslation = story ? true : false;

  // load story content
  const titleEl = document.querySelector("#story-title > .data");
  titleEl.innerHTML = hasTranslation ? story.title : storyAssets.title + "*";

  const warningNoTranslationEl = document.querySelector("#warning-no-translation");
  hasTranslation ? warningNoTranslationEl.classList.add("hidden") : null;

  const contentEl = document.querySelector("#story-content > .data");
  contentEl.innerHTML = (hasTranslation && to != "en" ? story.paragraphs : storyAssets.paragraphs).map((text) => tplParagraph(text)).join("\n");

  const moralEl = document.querySelector("#story-moral > .data");
  moralEl.innerHTML = from != "en" && hasTranslation ? story.moral : storyAssets.moral;

  // transform keywords
  if (Object.keys(story.keywords).length > 0) {
    document.querySelectorAll("#story-content > .data").forEach((excerpt) => {
      Object.keys(story.keywords)
        .sort((a, b) => a.length - b.length)
        .forEach((word) => {
          const regex = new RegExp("\\b" + word + "\\b", "ig");
          excerpt.innerHTML = excerpt.innerHTML.replace(regex, tplKeywordMain(word));
        });
    });
  }

  // setup keyword tooltips
  const attachTranslationPopupEl = (el) => {
    const popperInstance = Popper.createPopper(el, tooltipEl, { modifiers: [{ name: "offset", options: { offset: [0, 5] } }] });

    function show(el) {
      const word = el.getAttribute("word");
      tooltipEl.querySelector("#content").innerHTML = story.keywords[word] ? tplKeywordTranslations(story.keywords[word]) : "No Translation Found";
      tooltipEl.setAttribute("data-show", "");
      popperInstance.update();
    }

    function hide() {
      tooltipEl.removeAttribute("data-show");
    }

    showEvents.forEach((e) => el.addEventListener(e, () => show(el)));
    hideEvents.forEach((e) => el.addEventListener(e, hide));
  };

  document.querySelectorAll(".ba-keyword").forEach((el) => attachTranslationPopupEl(el));

  // add word click listener
  let curSelected = null;
  const onWordSelect = (word, selection) => {
    curSelected = new DOMParser().parseFromString(tplKeyword(word), "text/html").body.firstChild;
    selection.surroundContents(curSelected);
    attachTranslationPopupEl(curSelected);
    hideEvents.forEach((e) =>
      curSelected.addEventListener(
        e,
        () => {
          curSelected.replaceWith(curSelected.innerHTML);
        },
        { once: true }
      )
    );
  };
  const content = document.querySelector("#story-content .data");
  content.addEventListener("click", function (event) {
    var word = "";
    var selection = "";
    if (window.getSelection && (sel = window.getSelection()).modify) {
      var sel = window.getSelection();
      if (sel.isCollapsed) {
        sel.modify("move", "forward", "character");
        sel.modify("move", "backward", "word");
        sel.modify("extend", "forward", "word");
        word = sel.toString();
        selection = sel.getRangeAt(0);
        sel.modify("move", "forward", "character"); // clear selection
      } else {
        word = sel.toString();
      }
    }
    word && selection && onWordSelect(word, selection);
  });
};

document.addEventListener("DOMContentLoaded", onload);
