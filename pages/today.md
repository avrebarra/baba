---
layout: default
permalink: /today/
---

<title>Baba - {{ site.contents.last.title }}</title>

<div class="separator mt-10"></div>
<div class="content flex flex-col">
  <div class="font-semibold text-gray-500">Today's Story:</div>
  <div class="separator mt-2"></div>
  <div class="title max-w-md text-4xl font-black leading-normal">{{ site.contents.last.title }}</div>
  <div class="excerpt text-lg leading-loose flex flex-col gap-y-5 mt-3 text-gray-700">{{ site.contents.last.content }}</div>
  <div class="separator mt-4"></div>
</div>

<div class="button-reels flex flex-row gap-4 mt-3">
  <a
    href="{{'/storybank' | relative_url}}"
    id="bt-read"
    class="bg-lime-600 px-4 py-2 text-white hover:bg-lime-700 focus:bg-lime-700 focus:outline-none focus:shadow-outline"
    >See Other Stories</a>
</div>

<div class="separator mt-20"></div>