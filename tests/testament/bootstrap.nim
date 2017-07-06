import os, strutils, base64

const
  bootstrap_min_js* = slurp("js" / "bootstrap.min.js")
  bootstrap_script_tag* = "<script>\L$1\L</script>" % [bootstrap_min_js]
  bootstrap_script_cdn_tag* = """<script src="https://ajax.aspnetcdn.com/ajax/bootstrap/3.3.7/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>"""

  bootstrap_min_css* = slurp("css" / "bootstrap.min.css")
  bootstrap_style_tag* = "<style>\L$1\L</style>" % [bootstrap_min_css]
  bootstrap_style_cdn_tag* = """<link rel="stylesheet" href="https://ajax.aspnetcdn.com/ajax/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />"""

  bootstrap_theme_min_css* = slurp("css" / "bootstrap-theme.min.css")
  bootstrap_theme_style_tag* = "<style>\L$1\L</style>" % [bootstrap_theme_min_css]
  bootstrap_theme_style_cdn_tag* = """<link rel="stylesheet" href="https://ajax.aspnetcdn.com/ajax/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous" />"""

  glyphicons_halflings_regular_eot_base64 = base64.encode(slurp("fonts" / "glyphicons-halflings-regular.eot"), newLine="")
  glyphicons_halflings_regular_woff2_base64 = base64.encode(slurp("fonts" / "glyphicons-halflings-regular.woff2"), newLine="")
  glyphicons_halflings_regular_woff_base64 = base64.encode(slurp("fonts" / "glyphicons-halflings-regular.woff"), newLine="")
  glyphicons_halflings_regular_ttf_base64 = base64.encode(slurp("fonts" / "glyphicons-halflings-regular.ttf"), newLine="")
  glyphicons_halflings_regular_svg_base64 = base64.encode(slurp("fonts" / "glyphicons-halflings-regular.svg"), newLine="")
  glyphicons_halflings_regular_css* = """@font-face {
    font-family: 'Glyphicons Halflings';
    src: url('data:application/vnd.ms-fontobject;base64,""" & glyphicons_halflings_regular_eot_base64 & """');
    src: 
        url('data:application/vnd.ms-fontobject;base64,""" & glyphicons_halflings_regular_eot_base64 & """?#iefix') format('embedded-opentype'), 
        url('data:application/font-woff2;base64,""" & glyphicons_halflings_regular_woff2_base64 & """') format('woff2'),
        url('data:application/x-font-woff;base64,""" & glyphicons_halflings_regular_woff_base64 & """') format('woff'),
        url('data:application/octet-stream;base64,""" & glyphicons_halflings_regular_ttf_base64 & """') format('truetype'),
        url('data:image/svg+xml;base64,""" & glyphicons_halflings_regular_svg_base64 & """#glyphicons_halflingsregular') format('svg');
}"""
  glyphicons_halflings_regular_style_tag* = "<style>\L$1\L</style>" % [glyphicons_halflings_regular_css]