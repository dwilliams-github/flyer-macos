#  README

Source code for the Flyer game.

## Architecture

Implementation relies heavily on SpriteKit for rendering, animation, and sound. Physics is implemented
in the code and does not rely on any SpriteKit functionality. SpriteKit is extended to fold space over 
on the screen (objects that leave on the left appear immediate on the right). Modest use is made
of SpriteKit game scenes.

Views are created in an Xcode storyboard. This might be a little unusual for a MacOS application, but I was
just curious how this is done and wanted to try it.

## History

This is a recreation of the "flyer" game I wrote many years ago. See:
  [[https://github.com/dwilliams-github/flyer|GitHub]]

Ironically, that old version, which ran under classic MacOS, was much simplier with only five source files,
even though it has basically the same game play.
