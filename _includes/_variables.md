<script>
  const Babba = {
    baseURL: "{{ '/' | relative_url | default: '' }}",
    storyURL: "{{ page.url | default: '' }}",
    storyID: Babba.storyURL.replace('.html','').substring(1),
    storyAssetsURL: Babba.storyURL.replace('.html', '.json')
  }
</script>
