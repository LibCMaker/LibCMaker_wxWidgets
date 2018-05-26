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

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(LibCMaker_wxWidgets_Compile_Test CXX)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

set(LIBCMAKER_WX_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_wxWidgets")
# To use our FindwxWidgets.cmake and UsewxWidgets.cmake.
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_WX_SRC_DIR}/cmake")


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars for LibCMaker_wxWidgets.
#-----------------------------------------------------------------------

# Standard CMake vars.
# We must set this variable explicitly for the static lib building.
set(BUILD_SHARED_LIBS OFF)

#set(SKIP_INSTALL_HEADERS ON)
#set(SKIP_INSTALL_LIBRARIES ON)
#set(SKIP_INSTALL_ALL ON)

# Set useful vars for lib_cmaker_wxwidgets().
set(cmr_PRINT_DEBUG ON)

set(lib_VERSION "3.1.1")
set(WX_lib_COMPONENTS core base)
set(USE_FIND_PACKAGE_MODULE OFF)

set(DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(BUILD_DIR "${PROJECT_BINARY_DIR}/build_wxwidgets")

# Library specific vars and options.

include(${LIBCMAKER_WX_SRC_DIR}/cmake/modules/cmr_wx_option.cmake)

# Global build options
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
  ${USE_FIND_PACKAGE_MODULE}
)
cmr_wx_option(wxBUILD_COMPATIBILITY "Enable compatibilty with earlier wxWidgets versions"
  3.1
  STRINGS 2.8 3.0 3.1
)

#set(wxBUILD_CUSTOM_SETUP_HEADER_PATH "" CACHE PATH
#  "Include path containing custom wx/setup.h"
#)

if(MSVC)
  cmr_wx_option(wxBUILD_USE_STATIC_RUNTIME "Link using the static runtime library"
    OFF
  )
  cmr_wx_option(wxBUILD_MSVC_MULTIPROC "Enable multi-processor compilation for MSVC"
    ON
  )
else()
  # It set in WX by CMAKE_CXX_STANDARD
  #cmr_wx_option(wxBUILD_CXX_STANDARD "C++ standard used to build wxWidgets targets"
  #  ${CXX_STANDARD_DEFAULT}
  #  STRINGS COMPILER_DEFAULT 98 11 14
  #)
endif()

# TODO: cmr_wx_option(wxUSE_*)

# Exclude STC for version 3.1.1. TODO: check it for newer version.
cmr_wx_option(wxUSE_STC "use wxStyledTextCtrl library" OFF)


#-----------------------------------------------------------------------
# Configure for find_package.
#-----------------------------------------------------------------------

if(USE_FIND_PACKAGE_MODULE)
  # Set CMake's search path for find_package(), find_program(), find_library(),
  # find_file(), and find_path() commands.
  list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")
  
  if(ANDROID)
    list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
  endif()
endif()


#-----------------------------------------------------------------------
# Build the wxWidgets and include it.
#-----------------------------------------------------------------------

# Build the library at a config CMake phase.

if(USE_FIND_PACKAGE_MODULE)
  find_package(wxWidgets ${WX_lib_VERSION}
    COMPONENTS ${WX_lib_COMPONENTS} QUIET
  )
endif()

set(lib_WX_EXPORT_FILE "${BUILD_DIR}/export-wxWidgets.cmake")

if(NOT wxWidgets_FOUND AND NOT EXISTS ${lib_WX_EXPORT_FILE})
  #cmr_print_message("wxWidgets is not built, build it.")

  if(USE_FIND_PACKAGE_MODULE)
    set(lib_BUILD_MODE "INSTALL")
  else()
    set(lib_BUILD_MODE "BUILD")
  endif()
  
  # Build specified library version.
  include(${LIBCMAKER_WX_SRC_DIR}/lib_cmaker_wxwidgets.cmake)
  lib_cmaker_wxwidgets(
    VERSION ${lib_VERSION}
    DOWNLOAD_DIR ${DOWNLOAD_DIR}
    UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
    BUILD_DIR ${BUILD_DIR}
    ${lib_BUILD_MODE}
    COMPONENTS ${WX_lib_COMPONENTS}
  )

  if(USE_FIND_PACKAGE_MODULE)
    find_package(wxWidgets ${WX_lib_VERSION}
      COMPONENTS ${WX_lib_COMPONENTS} REQUIRED
    )
  endif()
  
#else()
#  cmr_print_message("wxWidgets is built, skip its building.")
endif()

if(USE_FIND_PACKAGE_MODULE)
  include(${wxWidgets_USE_FILE})
else()
  include(${lib_WX_EXPORT_FILE})
endif()


#-----------------------------------------------------------------------
# Use the newly got library. Link to the library.
#-----------------------------------------------------------------------

# Get an example sources from the wxWidgets sources.

# For cmr_wxwidgets_get_download_params() -> cmr_get_version_parts()
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_wxWidgets/cmake/modules/cmr_wxwidgets_get_download_params.cmake)
cmr_wxwidgets_get_download_params(${lib_VERSION}
  lib_URL lib_SHA lib_SRC_DIR_NAME lib_ARCH_FILE_NAME)
set(lib_SRC_DIR "${UNPACKED_SRC_DIR}/${lib_SRC_DIR_NAME}")

# Build test executables.

add_executable(${PROJECT_NAME} ${WIN32GUI}
  ${lib_SRC_DIR}/samples/vscroll/vstest.cpp
)

if(USE_FIND_PACKAGE_MODULE)
  target_include_directories(${PROJECT_NAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} ${wxWidgets_LIBRARIES})
else()
  target_link_libraries(${PROJECT_NAME} ${WX_lib_COMPONENTS})
endif()
