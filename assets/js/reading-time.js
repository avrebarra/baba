"use strict";

(function (window) {
  var wordsPerSecond, totalWords, totalReadingTimeSeconds, readingTimeDuration, readingTimeSeconds;

  function ReadingTime(numberWordsPerMinute, readigTimeLabel, minutesLabel, wordsLabel, lessThanAMinuteLabel) {
    const wordsPerMinute = numberWordsPerMinute;
    const paragraphs = document.querySelectorAll("article.detail-wrapper p");
    var count = 0;

    paragraphs.forEach(function (paragraph) {
      count += paragraph.innerHTML.split(" ").length;
    });

    document.querySelector(".reading-time__label").innerHTML = readigTimeLabel;
    totalWords = count;
    wordsPerSecond = wordsPerMinute / 60;
    totalReadingTimeSeconds = totalWords / wordsPerSecond;
    readingTimeDuration = Math.floor(totalReadingTimeSeconds / 60);
    readingTimeSeconds = Math.round(totalReadingTimeSeconds - readingTimeDuration * 60);

    if (readingTimeDuration > 0) {
      if (readingTimeSeconds > 30) {
        readingTimeDuration++;
      }
      document.querySelector(".reading-time__duration").innerHTML = readingTimeDuration + " " + minutesLabel;
    } else {
      document.querySelector(".reading-time__duration").innerHTML = lessThanAMinuteLabel;
    }
  }

  window.ReadingTime = ReadingTime;
})(window);
