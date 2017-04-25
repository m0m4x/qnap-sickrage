# QSickRage

SickRage server for QNAP NAS.

SickRage server is automatically pulled from git repository when the package is installed. The repository used is https://github.com/SickRage/SickRage/.

# Requisites

- Install Git and Python from Entware-ng with
  > opkg install git
  
  > opkg install python

or

- Install Git and Python (use the community Python version from http://apps.qnap.community/)
 
# Install

  
# Contribute

- First you need to install the QDK package to your QNAP NAS. You can download it here http://wiki.qnap.com/wiki/QPKG_Development_Guidelines.

- Then clone this repository to into your NAS (use SSH access).

- Go to the folder, make your changes.

- When you're done you can build the package by executing `qbuild`.

- The package is created under `build/` directory.

- Install it by the AppCenter or via the command line `bash build/QSickRage_*.qpkg`.

# Authors

- clinton-hall
- hadim

# License

GPLv3, see [LICENSE](LICENSE).
