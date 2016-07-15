#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Bash script for installing pre-requisite packages for solidity on a
# variety of Linux and other UNIX-derived platforms.
#
# This is an "infrastucture-as-code" alternative to the manual build
# instructions pages which we previously maintained at:
# http://solidity.readthedocs.io/en/latest/installing-solidity.html
#
# The aim of this script is to simplify things down to the following basic
# flow for all supported operating systems:
#
# - git clone --recursive
# - ./install_deps.sh
# - cmake && make
#
# At the time of writing we are assuming that 'lsb_release' is present for all
# Linux distros, which is not a valid assumption.  We will need a variety of
# approaches to actually get this working across all the distros which people
# are using.
#
# See http://unix.stackexchange.com/questions/92199/how-can-i-reliably-get-the-operating-systems-name
# for some more background on this common problem.
#
# TODO - There is no support here yet for cross-builds in any form, only
# native builds.  Expanding the functionality here to cover the mobile,
# wearable and SBC platforms covered by doublethink and EthEmbedded would
# also bring in support for Android, iOS, watchOS, tvOS, Tizen, Sailfish,
# Maemo, MeeGo and Yocto.
#
# The documentation for solidity is hosted at:
#
# http://solidity.readthedocs.io/en/latest/
#
# (c) 2016 solidity contributors.
#------------------------------------------------------------------------------

# Check for 'uname' and abort if it is not available.
uname -v > /dev/null 2>&1 || { echo >&2 "ERROR - solidity requires 'uname' to identify the platform."; exit 1; }

case $(uname -s) in

#------------------------------------------------------------------------------
# macOS
#------------------------------------------------------------------------------

    Darwin)
        case $(sw_vers -productVersion | awk -F . '{print $1"."$2}') in
            10.10)
                echo "Installing solidity dependencies on OS X 10.10 Yosemite."
                ;;
            10.11)
                echo "Installing solidity dependencies on OS X 10.11 El Capitan."
                ;;
            10.12)
                echo "Installing solidity dependencies on macOS 10.12 Sierra."
                echo ""
                echo "NOTE - You are in unknown territory with this preview OS."
                echo "Even Homebrew doesn't have official support yet, and there are"
                echo "known issues (see https://github.com/ethereum/webthree-umbrella/issues/614)."
                echo "If you would like to partner with us to work through these issues, that"
                echo "would be fantastic.  Please just comment on that issue.  Thanks!"
                ;;
            *)
                echo "Unsupported macOS version."
                echo "We only support Yosemite and El Capitan, with work-in-progress on Sierra."
                exit 1
                ;;
        esac

        # Check for Homebrew install and abort if it is not installed.
        brew -v > /dev/null 2>&1 || { echo >&2 "ERROR - solidity requires a Homebrew install.  See http://brew.sh."; exit 1; }

        brew update
        brew upgrade
        
        brew install boost
        brew install cmake
        brew install jsoncpp

        # We should really 'brew install' our eth client here, but at the time of writing
        # the bottle is known broken, so we will just cheat and use a hardcoded ZIP for
        # the time being, which is good enough.   The cause of the breaks will go away
        # when we commit the repository reorg changes anyway.
        #
        # Bonus fun - the dylib paths aren't fixed up in the zip, so we need to globally
        # install the extra packages used by the eth runtime too.
        curl -O https://builds.ethereum.org/cpp-binaries-data/release-1.2.9/cpp-ethereum-osx-elcapitan.zip
        unzip cpp-ethereum-osx-elcapitan.zip
        brew install \
            cryptopp \
            gmp \
            leveldb \
            libjson-rpc-cpp \
            libmicrohttpd \
            miniupnpc

        ;;

#------------------------------------------------------------------------------
# FreeBSD
#------------------------------------------------------------------------------

    FreeBSD)
        echo "Installing solidity dependencies on FreeBSD."
        echo "ERROR - 'install_deps.sh' doesn't have FreeBSD support yet."
        echo "Please let us know if you see this error message, and we can work out what is missing."
        echo "Drop us a message at https://gitter.im/ethereum/solidity."
        exit 1
        ;;

#------------------------------------------------------------------------------
# Linux
#------------------------------------------------------------------------------
        
    Linux)
        case $(lsb_release -is) in

#------------------------------------------------------------------------------
# Arch Linux
#------------------------------------------------------------------------------
        
            Arch)
                #Arch
                echo "Installing solidity dependencies on Arch Linux."

                # All our dependencies can be found in the Arch Linux official repositories.
                # See https://wiki.archlinux.org/index.php/Official_repositories
                sudo pacman -Sy \
                    base-devel \
                    boost \ 
                    cmake \
                    git \
                ;;

#------------------------------------------------------------------------------
# Alpine Linux
#------------------------------------------------------------------------------

            Alpine)
                #Alpine
                echo "Installing solidity dependencies on Alpine Linux."
                echo "ERROR - 'install_deps.sh' doesn't have Alpine Linux support yet."
                echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
                echo "If you would like to get 'install_deps.sh' working for Alpine Linux, that would be fantastic."
                echo "Drop us a message at https://gitter.im/ethereum/solidity."
                echo "See also https://github.com/ethereum/webthree-umbrella/issues/495 where we are working through Alpine support."
                exit 1
                ;;

#------------------------------------------------------------------------------
# Debian
#------------------------------------------------------------------------------

            Debian)
                #Debian
                case $(lsb_release -cs) in
                    wheezy)
                        #wheezy
                        echo "Installing solidity dependencies on Debian Wheezy (7.x)."
                        echo "ERROR - 'install_deps.sh' doesn't have Debian Wheezy support yet."
                        echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
                        echo "If you would like to get 'install_deps.sh' working for Debian Wheezy, that would be fantastic."
                        echo "Drop us a message at https://gitter.im/ethereum/solidity."
                        echo "See also https://github.com/ethereum/webthree-umbrella/issues/495 where we are working through Alpine support."
                        exit 1
                        ;;
                    jessie)
                        #jessie
                        echo "Installing solidity dependencies on Debian Jesse (8.x)."
                        ;;
                    stretch)
                        #stretch
                        echo "Installing solidity dependencies on Debian Stretch (9.x)."
                        echo "ERROR - 'install_deps.sh' doesn't have Debian Stretch support yet."
                        echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
                        echo "If you would like to get 'install_deps.sh' working for Debian Stretch, that would be fantastic."
                        echo "Drop us a message at https://gitter.im/ethereum/solidity."
                        exit 1
                        ;;
                    *)
                        #other Debian
                        echo "Installing solidity dependencies on unknown Debian version."
                        echo "ERROR - Debian Jessie is the only Debian version which solidity has been tested on."
                        echo "If you are using a different release and would like to get 'install_deps.sh'"
                        echo "working for that release that would be fantastic."
                        echo "Drop us a message at https://gitter.im/ethereum/solidity."
                        exit 1
                        ;;
                esac

                # Install "normal packages"
                sudo apt-get -y update
                sudo apt-get -y install \
                    build-essential \
                    cmake \
                    g++ \
                    gcc \
                    git \
                    libboost-all-dev \
                    libjsoncpp-dev \
                    unzip

                ;;

#------------------------------------------------------------------------------
# Fedora
#------------------------------------------------------------------------------

            Fedora)
                #Fedora
                echo "Installing solidity dependencies on Fedora."

                # Install "normal packages"
                # See https://fedoraproject.org/wiki/Package_management_system.
                dnf install \
                    autoconf \ 
                    automake \
                    boost-devel \
                    cmake \
                    gcc \
                    gcc-c++ \
                    git \
                    libtool

                ;;

#------------------------------------------------------------------------------
# OpenSUSE
#------------------------------------------------------------------------------

            "openSUSE project")
                #openSUSE
                echo "Installing solidity dependencies on openSUSE."
                echo "ERROR - 'install_deps.sh' doesn't have openSUSE support yet."
                echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
                echo "If you would like to get 'install_deps.sh' working for openSUSE, that would be fantastic."
                echo "See https://github.com/ethereum/webthree-umbrella/issues/552."
                exit 1
                ;;

#------------------------------------------------------------------------------
# Ubuntu
#
# TODO - I wonder whether all of the Ubuntu-variants need some special
# treatment?
#
# TODO - We should also test this code on Ubuntu Server, Ubuntu Snappy Core
# and Ubuntu Phone.
#
# TODO - Our Ubuntu build is only working for amd64 and i386 processors.
# It would be good to add armel, armhf and arm64.
# See https://github.com/ethereum/webthree-umbrella/issues/228.
#------------------------------------------------------------------------------

            Ubuntu)
                #Ubuntu
                case $(lsb_release -cs) in
                    trusty)
                        #trusty
                        echo "Installing solidity dependencies on Ubuntu Trusty Tahr (14.04)."
                        ;;
                    utopic)
                        #utopic
                        echo "Installing solidity dependencies on Ubuntu Utopic Unicorn (14.10)."
                        ;;
                    vivid)
                        #vivid
                        echo "Installing solidity dependencies on Ubuntu Vivid Vervet (15.04)."
                        ;;
                    wily)
                        #wily
                        echo "Installing solidity dependencies on Ubuntu Wily Werewolf (15.10)."
                        ;;
                    xenial)
                        #xenial
                        echo "Installing solidity dependencies on Ubuntu Xenial Xerus (16.04)."
                        ;;
                    yakkety)
                        #yakkety
                        echo "Installing solidity dependencies on Ubuntu Yakkety Yak (16.10)."
                        echo ""
                        echo "NOTE - You are in unknown territory with this preview OS."
                        echo "We will need to update the Ethereum PPAs, work through build and runtime breaks, etc."
                        echo "See https://github.com/ethereum/webthree-umbrella/issues/624."
                        echo "If you would like to partner with us to work through these, that"
                        echo "would be fantastic.  Please just comment on that issue.  Thanks!"
                        ;;
                    *)
                        #other Ubuntu
                        echo "ERROR - Unknown or unsupported Ubuntu version."
                        echo "We only support Trusty, Utopic, Vivid, Wily and Xenial, with work-in-progress on Yakkety."
                        exit 1
                        ;;
                esac

                sudo apt-get -y update
                sudo apt-get -y install \
                    build-essential \
                    cmake \
                    git \
                    libboost-all-dev \
                    libjsoncpp-dev

                # Install 'eth', for use in the Solidity Tests-over-IPC.
                sudo add-apt-repository -y ppa:ethereum/ethereum
                sudo apt-get -y update
                sudo apt-get -y install cpp-ethereum

                # And install the English language package and reconfigure the locales.
                # We really shouldn't need to do this, and should instead force our locales to "C"
                # within our application runtimes, because this issue shows up on multiple Linux distros,
                # and each will need fixing in the install steps, where we should really just fix it once
                # in the code.
                #
                # See https://github.com/ethereum/webthree-umbrella/issues/169
                sudo apt-get -y install language-pack-en-base
                sudo dpkg-reconfigure locales

                ;;
            *)

#------------------------------------------------------------------------------
# Other (unknown) Linux
# Major and medium distros which we are missing would include Mint, CentOS,
# RHEL, Raspbian, Cygwin, OpenWrt, gNewSense, Trisquel and SteamOS.
#------------------------------------------------------------------------------

                #other Linux
                echo "ERROR - Unsupported or unidentified Linux distro."
                echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
                echo "If you would like to get your distro working, that would be fantastic."
                echo "Drop us a message at https://gitter.im/ethereum/solidity."
                exit 1
                ;;
        esac
        ;;

#------------------------------------------------------------------------------
# Other platform (not Linux, FreeBSD or macOS).
# Not sure what might end up here?
# Maybe OpenBSD, NetBSD, AIX, Solaris, HP-UX?
#------------------------------------------------------------------------------

    *)
        #other
        echo "ERROR - Unsupported or unidentified operating system."
        echo "See http://solidity.readthedocs.io/en/latest/installing-solidity.html for manual instructions."
        echo "If you would like to get your operating system working, that would be fantastic."
        echo "Drop us a message at https://gitter.im/ethereum/solidity."
        ;;
esac
