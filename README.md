# lamo [![Build Status](https://magnum.travis-ci.com/EthanArbuckle/lamo.svg?token=nnVLttWpyazVDADNrvzW&branch=lamo_no_ms)](https://magnum.travis-ci.com/EthanArbuckle/lamo)

<p style="font-size:small">
<strong>Mírmir - Multitasking done right</strong><br>
<br>
From the makers of Stratos, Mírmir is a completely integrated multitasking suit for iPhone and iPad on iOS 8 & 9. Built from the ground up using objective-c runtime swizzling. Featuring window snapping and easy to use 4 button controls as well as Activator support. Start using your device more efficiently than ever. Watch videos while you work, talk to your friends while you game - the possibilities are endless.<br>
<br>

Proudly made by The Cortex Dev Team 2015<br>
<br>
Configuration icon added to the home screen.
<p>
<a href=“https://www.youtube.com/watch?v=HpIU9a0HR6U”>Reviewed by iTwe4kz on YouTube</a><br>
<a href=“http://www.idownloadblog.com/2015/06/30/mimir-multiple-apps-multitasking-ios-8-3/”>Reviewed by Jeff on iDownloadBlog</a>                
<p>

#running in simulator

The easiest way to test this is to run it in simulator. Builds/ will be populated with 2 files, Lamo.dylib and LamoClient.dylib.

Lamo.dylib needs to be injected into the SpringBoard binary. This contains the core functions of the tweak.
LamoClient.dylib needs to be injected into UIKit. Without this, app rotations and statusbar hiding will not work. 

These can be injected via cycript, or optool. 