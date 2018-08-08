# ****************************************************************************
#  Project:  LibCMaker_wxWidgets
#  Purpose:  A CMake build script for wxWidgets library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
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

## +++ Common part of the lib_cmaker_<lib_name> function +++
set(cmr_lib_NAME "wxWidgets")

# To find library's LibCMaker source dir.
set(lcm_${cmr_lib_NAME}_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root.")
endif()

include(${LIBCMAKER_SRC_DIR}/cmake/modules/lib_cmaker_init.cmake)

function(lib_cmaker_wxwidgets)

  # Make the required checks.
  # Add library's and common LibCMaker module paths to CMAKE_MODULE_PATH.
  # Unset lcm_CMAKE_ARGS.
  # Set vars:
  #   cmr_CMAKE_MIN_VER
  #   cmr_lib_cmaker_main_PATH
  #   cmr_printers_PATH
  #   lower_lib_NAME
  # Parce args and set vars:
  #   arg_VERSION
  #   arg_DOWNLOAD_DIR
  #   arg_UNPACKED_DIR
  #   arg_BUILD_DIR
  lib_cmaker_init(${ARGN})

  include(${cmr_lib_cmaker_main_PATH})
  include(${cmr_printers_PATH})

  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Library specific build arguments.
  #-----------------------------------------------------------------------

  # Use always builtin libs.
  cmr_wx_option(wxUSE_REGEX "enable support for wxRegEx class" builtin)
  cmr_wx_option(wxUSE_ZLIB "use zlib for LZW compression" builtin)
  #TODO: use LibCMaker_Expat for EXPAT.
  #cmr_wx_option(wxUSE_EXPAT "use expat for XML parsing" sys)
  cmr_wx_option(wxUSE_LIBJPEG "use libjpeg (JPEG file format)" builtin)
  cmr_wx_option(wxUSE_LIBPNG "use libpng (PNG image format)" builtin)
  if(NOT (UNIX AND NOT APPLE))
    # Builtin libtiff on unix is currently not supported (version 3.1.1).
    cmr_wx_option(wxUSE_LIBTIFF "use libtiff (TIFF file format)" builtin)
  endif()

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(cmr_LIB_VARS
    wxBUILD_SHARED
    wxBUILD_MONOLITHIC
    wxBUILD_TESTS
    wxBUILD_DEMOS
    wxBUILD_PRECOMP
    wxBUILD_INSTALL
    wxBUILD_COMPATIBILITY
    wxBUILD_CUSTOM_SETUP_HEADER_PATH
    wxBUILD_USE_STATIC_RUNTIME
    wxBUILD_MSVC_MULTIPROC
    wxBUILD_CXX_STANDARD

    wxUSE_STC

    wxUSE_REGEX
    wxUSE_ZLIB
    wxUSE_EXPAT
    wxUSE_LIBJPEG
    wxUSE_LIBPNG
    wxUSE_LIBTIFF
  )

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND lcm_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

  if(USE_FIND_PACKAGE_MODULE)
    set(WX_lib_BUILD_MODE "INSTALL")
  else()
    set(WX_lib_BUILD_MODE "BUILD")
  endif()

  cmr_lib_cmaker_main(
    NAME          ${cmr_lib_NAME}
    VERSION       ${arg_VERSION}
    LANGUAGES     CXX C
    COMPONENTS    ${arg_COMPONENTS}
    BASE_DIR      ${lcm_${cmr_lib_NAME}_SRC_DIR}
    DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
    UNPACKED_DIR  ${arg_UNPACKED_DIR}
    BUILD_DIR     ${arg_BUILD_DIR}
    CMAKE_ARGS    ${lcm_CMAKE_ARGS}
    ${WX_lib_BUILD_MODE}
  )

endfunction()
