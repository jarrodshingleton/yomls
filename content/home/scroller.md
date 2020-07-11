+++
# Slider widget.
widget = "slider"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 2  # Order that this section will appear.

# Slide interval.
# Use `false` to disable animation or enter a time in ms, e.g. `5000` (5s).
interval = 4000

# Slide height (optional).
# E.g. `500px` for 500 pixels or `calc(100vh - 70px)` for full screen.
height = ""

# Slides.
# Duplicate an `[[item]]` block to add more slides.
[[item]]
  title = "Check out Jarrod's Blog post on Linear Regression!"
  content = "Linear Regression is Fun! :smile:"
  align = "center"  # Choose `center`, `left`, or `right`.

  # Overlay a color or image (optional).
  #   Deactivate an option by commenting out the line, prefixing it with `#`.
  overlay_color = "#666"  # An HTML color value.
  overlay_img = "boards.jpg"  # Image path relative to your `static/img/` folder.
  overlay_filter = 0.5  # Darken the image. Value in range 0-1.

  # Call to action button (optional).
  #   Activate the button by specifying a URL and button label below.
  #   Deactivate by commenting out parameters, prefixing lines with `#`.
  cta_label = "Let's see this magic."
  cta_url = "/post/linear_regression/"
  cta_icon_pack = "fas"
  cta_icon = "graduation-cap"

[[item]]
  title = "A Very Great Awesome ML Tutorial"
  content = "Follow this [**link**](/tutorials/newtutorial/) :smile:"
  align = "left"

  overlay_color = "#555"  # An HTML color value.
  overlay_img = "blackboard.jpg"  # Image path relative to your `static/img/` folder.
  overlay_filter = 0.5  # Darken the image. Value in range 0-1.

[[item]]
  title = "Be sure to take a gander at Jarrod's Corner!"
  content = "Lots of great photos of Jarrod's most recent [work](/jcorner/). :dragon:"
  align = "right"

  overlay_color = "#333"  # An HTML color value.
  overlay_img = "lake.jpg"  # Image path relative to your `static/img/` folder.
  overlay_filter = 0.5  # Darken the image. Value in range 0-1.
  
[[item]]
  title = "Thanks for visiting."
  content = "We are just at the beginning of our quest. Please join us as we battle data sets with our Elfen forged ML algorithms! ![Picture](/static/img/mace_01_t.png)"
  align = "center"
  
  overlay_color = "#4168E1"
  overlay_img = ""
  overlay_filter = 0.5
  
+++
