# Instalatron

RedHat Anaconda Testing Framework using Oracle's VirtualBox

# Requirements

Ruby 1.8 (doesn't work with ruby 1.9 currently)

Rubygems

VirtualBox >= 4.0.8

ImageMagick >=  6.6.4

# Install

Make you you have installed VirtualBox (4.0.8 or greater) and ImageMagick (6.6.4) before installing.

Install instalatron gem:

`sudo gem install instalatron`

# Features

* Automatic creation of VMs to run the testing sessions
* Semi-automatic recording of the testing session (instalatron-record).
  See http://www.youtube.com/watch?v=TpdXdRqNpB4
* Replay recorded sessions with instalatron-play.
  See http://www.youtube.com/watch?v=TDL0nBFO5vM
* variable interpolation with ERB syntax
* Recorded sessions are simple text files (YAML) and images that can be edited and manipulated with standard tools 

 
# Examples

Creating a new recording

`instalatron-record --iso-file my-abiquo-iso.iso --vm-memory 768`

This will create a new VM in VirtualBox with 768 MB of RAM and will start the recording session

Running a recorded script

`instalatron-play -s path-to-previous-recording-dir --iso-file ~/Downloads/abiquo-linux-ee-1.8-preview-2011-07-07-1456.iso --nic-config nic1:eth0:bridged --vm-memory 1024`

This will create a VM with 1024 MB of RAM and use the script found in 'path-to-previous-recording-dir directory to create a Cloud in a Box install.

There's some technical info available in the wiki:

https://github.com/abiquo/instalatron/wiki

