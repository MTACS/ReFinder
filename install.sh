#!/bin/bash

cp -r build/ReFinder.app /Applications/
cp build/ReFinder.dylib /private/var/ammonia/core/tweaks
cp build/ReFinder.dylib.whitelist /private/var/ammonia/core/tweaks

killall Finder