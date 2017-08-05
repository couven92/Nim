import strutils, os, largestringsplit

const
  jquery_2_2_0_min_js_large = slurp("js" / "jquery-2.2.0.min.js")
  jquery_script_tag_large = "<script>\L$1\L</script>" % [jquery_2_2_0_min_js_large]

  jquery_2_2_0_min_js* = largeStringSplit(jquery_2_2_0_min_js_large)
  jquery_script_tag* = largeStringSplit(jquery_script_tag_large)
  jquery_sctipt_cdn_tag* = """<script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-2.2.0.min.js" integrity="sha384-K+ctZQ+LL8q6tP7I94W+qzQsfRV2a+AfHIi9k8z8l9ggpc8X+Ytst4yBo/hH+8Fk" crossorigin="anonymous"></script>"""
