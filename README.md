Dart GL
=======

Dart doesn't come with its own implementation of OpenGL matrix stack being OpenGL 2+ compliant, so each time you have to rewrite everything from scratch. This is especially annoying when you want to focus on creating fast prototypes or simple applications (or just love the pre OpenGL 2.0 immediate mode! ;) ).

Dart GL is a small template library I wrote for just that reason. It comes with a convenient camera system, few OpenGL matrices and some standard functions used in "classic" OpenGL applications (<code>glTranslatef()</code>, <code>glRotatef()</code> etc.). This greatly reduces development time in its early stages.

Also:
- WebAudio sound playback
- basic types for renderable objects and textures (use it for testing, more complex apps will likely require different structures)
- font rendering
- texture atlas support
