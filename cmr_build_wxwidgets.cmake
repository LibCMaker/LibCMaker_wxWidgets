# ****************************************************************************
#  Project:  LibCMaker_wxWidgets
#  Purpose:  A CMake build script for wxWidgets library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
#
#    This file is part of the LibCMaker_wxWidgets project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(WX_lib_NAME        "wxWidgets")
#set(WX_lib_VERSION     "3.1.1")
set(WX_lib_VERSION     "3.1.2.20190118")
# Note that for MinGW users the order of libs is important!
set(WX_lib_COMPONENTS  core base)
set(WX_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${WX_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

#set(WX_USE_FIND_PACKAGE_MODULE OFF)
set(WX_USE_FIND_PACKAGE_MODULE ON)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

include(${WX_lib_DIR}/cmake/cmr_wx_option.cmake)

# Global build options.
#cmr_wx_option(wxBUILD_SHARED "Build wx libraries as shared libs"
#  ${BUILD_SHARED_LIBS}
#)
cmr_wx_option(wxBUILD_MONOLITHIC "Build wxWidgets as single library" OFF)
cmr_wx_option(wxBUILD_SAMPLES "Build only important samples (SOME) or ALL" OFF
  STRINGS SOME ALL OFF
)
cmr_wx_option(wxBUILD_TESTS "Build console tests (CONSOLE_ONLY) or ALL" OFF
  STRINGS CONSOLE_ONLY ALL OFF
)
cmr_wx_option(wxBUILD_DEMOS "Build demos" OFF)
cmr_wx_option(wxBUILD_PRECOMP "Use precompiled headers" ON)
cmr_wx_option(wxBUILD_INSTALL "Create install/uninstall target for wxWidgets"
  ${WX_USE_FIND_PACKAGE_MODULE}
)
cmr_wx_option(wxBUILD_COMPATIBILITY
  "Enable compatibility with earlier wxWidgets versions"
  3.1
  STRINGS 2.8 3.0 3.1
)

#set(wxBUILD_CUSTOM_SETUP_HEADER_PATH "" CACHE PATH
#  "Include path containing custom wx/setup.h"
#)
#wx_option(wxBUILD_DEBUG_LEVEL "Debug Level" Default STRINGS Default 0 1 2)

if(MSVC)
  # LibCMaker set /MD or /MT flags by cmr_USE_MSVC_STATIC_RUNTIME.
  #cmr_wx_option(wxBUILD_USE_STATIC_RUNTIME
  #  "Link using the static runtime library"
  #  OFF
  #)
  cmr_wx_option(wxBUILD_MSVC_MULTIPROC
    "Enable multi-processor compilation for MSVC"
    ${cmr_BUILD_MULTIPROC}
  )
else()
  # It set in WX by CMAKE_CXX_STANDARD
  #cmr_wx_option(wxBUILD_CXX_STANDARD
  #  "C++ standard used to build wxWidgets targets"
  #  ${CXX_STANDARD_DEFAULT}
  #  STRINGS COMPILER_DEFAULT 98 11 14 17
  #)
endif()

# TODO: cmr_wx_option(wxUSE_*)

# Exclude STC for version 3.1.1. TODO: check it for newer version.
cmr_wx_option(wxUSE_STC "use wxStyledTextCtrl library" OFF)


# Vars to find_project() only.
# Vars from 'FindwxWidgets.cmake'.

# TODO: needed?
# WIN32 config part.
#set(WX_CFG_DEBUG_SFX "")
#if(CMAKE_CFG_INTDIR STREQUAL "." AND CMAKE_BUILD_TYPE STREQUAL "Debug"
#    OR CMAKE_CFG_INTDIR STREQUAL "Debug")
#  set(WX_CFG_DEBUG_SFX "d")
#endif()
#set(wxWidgets_CONFIGURATION "mswu${WX_CFG_DEBUG_SFX}")

# TODO: needed?
# UNIX config part.
#set(wxWidgets_USE_STATIC ON)
#set(wxWidgets_USE_UNICODE ON)


#-----------------------------------------------------------------------
# FindwxWidgets.cmake options
#
set(wxWidgets_ROOT_DIR "${cmr_INSTALL_DIR}")


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${WX_lib_NAME}
  VERSION         ${WX_lib_VERSION}
  COMPONENTS      ${WX_lib_COMPONENTS}
  LIB_DIR         ${WX_lib_DIR}
  REQUIRED
  NOT_USE_VERSION_IN_FIND_PACKAGE
  CUSTOM_LOGIC_FILE ${WX_lib_DIR}/cmake/cmr_find_package_wxwidgets_custom.cmake
)

# wxWidgets_USE_FILE set in cmr_find_package_icu_host_tools_custom.cmake.
# WX_lib_EXPORT_FILE set in cmr_find_package_icu_host_tools_custom.cmake.

if(WX_USE_FIND_PACKAGE_MODULE)
#  include(${wxWidgets_USE_FILE})
else()
  include(${WX_lib_EXPORT_FILE})
endif()
