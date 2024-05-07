<script src="https://unpkg.com/@popperjs/core@2"></script>

<style>
  #arrow, #arrow::before {
    position: absolute;
    width: 8px;
    height: 8px;
    background: inherit;
  }

  #arrow {
    visibility: hidden;
  }

  #arrow::before {
    visibility: visible;
    content: '';
    transform: rotate(45deg);
  }

  #tooltip {
    background: #333;
    color: white;
    font-weight: bold;
    padding: 4px 8px;
    font-size: 13px;
    border-radius: 4px;
    display: none;
  }

  #tooltip[data-show] {
    display: block;
  }

  #tooltip[data-popper-placement^='top'] > #arrow {
    bottom: -4px;
  }

  #tooltip[data-popper-placement^='bottom'] > #arrow {
    top: -4px;
  }

  #tooltip[data-popper-placement^='left'] > #arrow {
    right: -4px;
  }

  #tooltip[data-popper-placement^='right'] > #arrow {
    left: -4px;
  }
</style>

<div id="tooltip" role="tooltip">
  <div id="content">Word Translation</div>
  <div id="arrow" data-popper-arrow></div>
</div>

<!-- vars loader -->
<script>
  var keywords = {{ page.keywords | jsonify }}.map((e)=>e.toLowerCase());
</script>

<script src="{{ '/assets/js/story-interaction-layer.js' | relative_url}}"></script>
