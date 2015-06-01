# lamo [![Build Status](https://magnum.travis-ci.com/EthanArbuckle/lamo.svg?token=nnVLttWpyazVDADNrvzW&branch=lamo_no_ms)](https://magnum.travis-ci.com/EthanArbuckle/lamo)

super rad windowing tweak - cortex dev team

#running in simulator

The easiest way to test this is to run it in simulator. Builds/ will be populated with 2 files, Lamo.dylib and LamoClient.dylib.

Lamo.dylib needs to be injected into the SpringBoard binary. This contains the core functions of the tweak.
LamoClient.dylib needs to be injected into UIKit. Without this, app rotations and statusbar hiding will not work. 

These can be injected via cycript, or optool. 