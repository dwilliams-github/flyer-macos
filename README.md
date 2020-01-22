#  README

Source code for the Flyer game.

## Architecture

Implementation relies heavily on SpriteKit for rendering, animation, and sound. Physics is implemented
in the code and does not rely on any SpriteKit functionality. SpriteKit is extended to fold space over 
on the screen (objects that leave on the left appear immediate on the right). Modest use is made
of SpriteKit game scenes.

Views are created in an Xcode storyboard. This might be a little unusual for a MacOS application, but I was
just curious how this is done and wanted to try it.

## Assets

Art files are organized in the Art directory. These were created for this game using [Sketch](https://www.sketch.com/).

Sounds files are stored in the Sound directory. They are taken from [freesound.org](https://freesound.org/)
and are all under the creative commons license.

## History

This is a recreation of the "flyer" game I wrote many years ago. See: [github](https://github.com/dwilliams-github/flyer|GitHub)

Ironically, the code for the old version, which ran under classic MacOS, is organized in only five 
(relatively large) source files,
even though it has roughly the same game play. The number of source files in the current version is the
price of modularity.

The somewhat playful intro screen artwork is a reproduction of the art I used in this earlier version.