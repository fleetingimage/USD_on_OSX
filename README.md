# USD_on_OSX
Script to download, patch and build USD on M1 Macs. Tested on macOS Monterey 12.3.1
with USD "release" branch 22.05a

Based on the work by:
https://simo.virokannas.fi/2022/04/compiling-pixars-usd-natively-on-apple-m1/

## Background
USD is currently designed with PySide2, which is supported to python 3.7.
On macOS, default python is 3.8. Simo Virokannas has provided some patches
to mend the differences between PySide2 and PySide6. It is likely that Pixar will soon
advance their code and this work will no longer be necessary.

## Build
* Install Xcode and make sure it works. (Run xcode-select to confirm.)
* Install CMake from cmake.org (Presumes installed as /Applications/CMake.app)

* Download the script or clone this repo.
* Modify the DIST and WORK environment variables in the script if necessary.

* Run the script to:
  * Create destination and work directories. Requires sudo password for writing to `/opt/USD` by default.
  * Create and activate a python virtual environment for working with USD.
  * Install PyOpenGL, PySide6 and numpy into the venv
  * Clone USD.git from https://github.com/PixarAnimationStudios/USD.git
  * Grab and apply patches from Simo Virokannas
  * Apply a third patch per Simo instructions.
  * Build USD (downloads Boost, TBB, OpenSubdiv)
  * Create an "activate" script.

## Usage
    % source /opt/USD/activate
    % curl -O https://graphics.pixar.com/usd/files/Kitchen_set.zip
    % unzip Kitchen_set.zip
    % usdview Kitchen_set/Kitchen_set.usd
