<!-- vars loader -->
<script>
  var Babba = {}

  Babba.baseURL = "{{ '/' | relative_url | default: '' }}"
  Babba.storyURL = "{{ page.url | default: '' }}"
  Babba.storyID = Babba.storyURL.replace('.html','').substring(1)
  Babba.storyAssetsURL = Babba.storyURL.replace('.html', '.json')

</script>
