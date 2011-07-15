# Instalatron

RedHat Anaconda Testing Framework using Oracle's VirtualBox

# Requirements

Rubygems

VirtualBox >= 4.0.8

ImageMagick >=  6.6.4

# Install

Make you you have installed VirtualBox and ImageMagick before installing.

Install instalatron gem:

`sudo gem install instalatron`

 
# Examples

Creating a new recording

`instalatron-record --iso-file my-abiquo-iso.iso`

This will create a new VM in VirtualBox and will start the recording session

Creating a new instalatron script

`instalatron-play -s ciab --iso-file ~/Downloads/abiquo-linux-ee-1.8-preview-2011-07-07-1456.iso --nic-config nic1:eth0:bridged --vm-memory 1024`

This will create a VM with 1024 MB of RAM and use the script found in 'ciab' directory to create a Cloud in a Box install.

