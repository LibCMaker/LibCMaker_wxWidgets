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

# Part of "LibCMaker/cmake/cmr_find_package.cmake".

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
  set(find_LIB_VARS
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

  foreach(d ${find_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND find_CMAKE_ARGS
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
    LibCMaker_DIR ${find_LibCMaker_DIR}
    NAME          ${find_NAME}
    VERSION       ${find_VERSION}
    COMPONENTS    ${find_COMPONENTS}
    LANGUAGES     CXX C
    BASE_DIR      ${find_LIB_DIR}
    DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
    UNPACKED_DIR  ${cmr_UNPACKED_DIR}
    BUILD_DIR     ${lib_BUILD_DIR}
    CMAKE_ARGS    ${find_CMAKE_ARGS}
    ${WX_lib_BUILD_MODE}
  )
