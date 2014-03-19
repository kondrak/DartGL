Dart GL
=======

Dart doesn't come with its own implementation of OpenGL matrix stack and any comfortable functions to use it, so each time you have to rewrite everything from scratch. This is especially annoying when you want to focus on creating fast prototypes or simple applications.

Dart GL is a small template library I wrote for just that reason. It comes with a convenient camera system, OpenGL matrix stack and some standard functions used in classic OpenGL applications (<code>glTranslatef()</code>, <code>glRotatef()</code> etc.).

Also:
- WebAudio sound playback
- basic types for renderable objects and textures (use it for testing, more complex apps will likely require different structures)
- font rendering
- texture atlas support
