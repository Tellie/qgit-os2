===================================================================================================
**** If you like the programs i'm porting and you want to donate to me, see the following URL: ****
**** http://www.bitwiseworks.com/shop/index.php?id_product=38&controller=product& id_lang=1    ****
****             Or send directly to me using PayPal: tellie@elbertpol.nl                      ****
****                All the money you send will go to the QT5 project                          ****
===================================================================================================

qgit v2.13 for OS/2 - Qt 6.8.3 build

 CONTENTS OF THIS FILE
 =====================

1. INTRODUCTION

2. REQUIREMENTS

3. INSTALLATION

4. LICENSE, COPYRIGHT, DISCLAIMER

5. CONTACT

6. CREDITS

7. SUPPORT AND DONATIONS

8. HISTORY

9. RESTRICTIONS


1. INTRODUCTION
===============

Welcome to qgit v2.13 port for OS/2, eComStation and ArcaOS.
This build is compiled with GCC 15.2.0 against Qt 6.8.3.

With qgit you will be able to browse revisions history, view patch content
and changed files, graphically following different development branches.


2. REQUIREMENTS
===============

  git
  ---
  qgit is a front end for git, so git must be installed and in the PATH:
   1. yum install git

  RPM Installation (preferred):
  ============================
  klibc and LIBCx
  ---------------
   1. yum install libc
   2. yum install libcx
   3. yum install pthread

  GCC runtime
  -----------
   1. yum install libgcc1
   2. yum install libstdc++6 libstdc++
   3. yum install libsupc++6 libsupc++
   4. yum install libgcc-fwd

  Libraries used by Qt 6
  ----------------------
   1. yum install zlib expat fontconfig
   2. yum install libicu
   3. yum install pcre2
   4. yum install libzstd

  Qt 6.8.3 (not available as RPM)
  -------------------------------
  This version needs the Qt 6.8.3 DLLs of TeLLie's Qt 6.8.3 build:
     QT6CORE.DLL   QT6GUI.DLL   QT6WIDGE.DLL   QT6CORE5.DLL (Core5Compat)
     plugins\platforms  (the OS/2 platform plugin)
  and the libraries it depends on:
     FREETYP6.DLL  PNG1616.DLL  INTL8.DLL
  They must be in a directory in your LIBPATH (or BEGINLIBPATH).

  If you don't have Qt 6.8.3, use the Qt5 version of qgit instead.


3. INSTALLATION
===============

  qgit
  ----
  1. Unzip the package to a directory of your choice, e.g. x:\apps\qgit
  2. Create a WPS object for bin\qgit.exe (optional).
  3. Start qgit in (or open) a git repository.

  External tools (optional)
  -------------------------
  The default external diff viewer (kompare) and editor (emacs) do not
  exist on OS/2; change them in Edit -> Settings. Syntax highlighting
  uses source-highlight if it is installed; without it qgit just shows
  plain text.


4. LICENSE, COPYRIGHT, DISCLAIMER
=================================

(C) 2007-2025 https://github.com/tibirna/qgit

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


5. CONTACT
==========

if you find a bug, then add a ticket to the trac at http://svn.netlabs.org/qtapps

Only bug reports with a reproducable bug are accepted. :-)



6. CREDITS
==========

The port was done by: Elbert Pol aka TeLLie

Thanks go to:

  * Dmitry A. Kuminov
  * Silvan Scherrer

They either helped me when I had some nasty questions or did some testing for me.


7. SUPPORT AND DONATIONS
========================

qgit is based on volunteer work. If you would like to support further
development, you can do so in one of the following ways:


  * Donate to the Qt5 project

  * While working on Qt 5 for OS/2, we are glad to know that our work is being partly sponsored by the grateful OS/2 community.
    Given the scale of this project and all other OS/2 projects that we work on, and also the fact that the OS/2 world has limited financial resources nowadays, every penny counts.
    We need to pay our full-time and part-time developers for their hard work. So any contribution is highly appreciated!
    To do so, please visit our online shop where you can buy development units of a preferred value.
    https://www.bitwiseworks.com/shop/index.php

  * Contribute to the project: Besides actual development, this also includes maintaining the documentation and the project web site as well as help for users.

8. HISTORY
==========
Compiled now with Qt v6.8.3 (GCC 15.2.0)

Changelog:

2.13 (Qt 6.8.3 build)
OS/2: linked with LIBCx (-lcx); fixes a crash at startup while Qt scans
  the platform plugins ("uncommitted memory allocated by LIBCX0")
Readme renamed to README-QT6.txt, requirements for Qt 6.8.3 added

Update to upstream qgit (tibirna/qgit 751cb10, sept 2026): rename branch,
  confirmation for drag and drop, fix for the first commit
OS/2: scripts are run via sh, files and patches are written without CRLF
OS/2: fix for repositories when qgit is started from a subdirectory
OS/2: build script build-os2.sh (Qt5 or Qt 6.8.3, e.g. "sh build-os2.sh qt6")
Update to the new upstream version 2.12

Stay tuned.