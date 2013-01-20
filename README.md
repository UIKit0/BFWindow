BFWindow
========

NSWindow subclass that allows you to apply Core Animation effects.

## How does it work?

When you want to animate the whole NSWindow, you call `prepareForAnimationWithInsets:`. This method will hide the receiver and create a proxy window which will contain receiver's **screenshot** wrapped into `CALayer` that will be returned back to you. You can do whatever you want with that layer. When you finished, just call `completeAnimationAndOrderFront:` to remove proxy window from screen.

Please refer to the headers for additional documentation.

## Licence

BSD