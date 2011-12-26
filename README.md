Emacs Anything Rake
===================

Return of a list of all the rake tasks defined in the current
projects.

## Functions:

```
M-x anything-rake
```

## Installation:

In your emacs config:

```
(add-to-list 'load-path "~/.emacs.d/load/path/anything-rake.el")
(require 'anything-rake)
```

There is no need to setup load-path with add-to-list if you copy
`anything-rake.el` to load-path directories.

Finally put the `rake_tasks_cacher.sh` shell script somewhere in
your `$PATH`.

## Screencast

<iframe
src="http://player.vimeo.com/video/34218683?title=0&amp;byline=0&amp;portrait=0"
width="400" height="300" frameborder="0" webkitAllowFullScreen
mozallowfullscreen allowFullScreen></iframe><p><a
href="http://vimeo.com/34218683">Anything-rake.el</a> from <a
href="http://vimeo.com/user695842">jpablobr</a> on <a
href="http://vimeo.com">Vimeo</a>.</p>

## Requirements

You will need to install
[anything-mode](http://www.emacswiki.org/emacs/Anything). See
documentation for how to install.
