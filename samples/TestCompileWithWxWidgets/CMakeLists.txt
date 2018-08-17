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

cmake_minimum_required(VERSION 3.3)

project(LibCMaker_wxWidgets_Compile_Test CXX)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)

set(WX_USE_FIND_PACKAGE_MODULE OFF)


#-----------------------------------------------------------------------
# Compiler flags
#-----------------------------------------------------------------------

if(MSVC AND NOT BUILD_SHARED_LIBS)
  set(cmr_USE_MSVC_STATIC_RUNTIME ON)

  # Set MSVC runtime flags for all configurations
  # See:
  # https://stackoverflow.com/a/20804336
  # https://stackoverflow.com/a/14172871
  foreach(cfg "" ${CMAKE_CONFIGURATION_TYPES})
    set(c_flag_var   CMAKE_C_FLAGS)
    set(cxx_flag_var CMAKE_CXX_FLAGS)
    if(cfg)
      string(TOUPPER ${cfg} cfg_upper)
      set(c_flag_var   "${c_flag_var}_${cfg_upper}")
      set(cxx_flag_var "${cxx_flag_var}_${cfg_upper}")
    endif()
    if(${c_flag_var} MATCHES "/MD")
      string(REPLACE "/MD" "/MT" ${c_flag_var} "${${c_flag_var}}")
      set(${c_flag_var} ${${c_flag_var}} CACHE STRING
        "Flags used by the C compiler during ${cfg_upper} builds." FORCE
      )
    endif()
    if(${cxx_flag_var} MATCHES "/MD")
      string(REPLACE "/MD" "/MT" ${cxx_flag_var} "${${cxx_flag_var}}")
      set(${cxx_flag_var} ${${cxx_flag_var}} CACHE STRING
        "Flags used by the CXX compiler during ${cfg_upper} builds." FORCE
      )
    endif()
  endforeach()
endif()


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")


#-----------------------------------------------------------------------
# Set vars to LibCMaker_wxWidgets
#-----------------------------------------------------------------------

set(WX_lib_NAME         "wxWidgets")
set(WX_lib_VERSION      "3.1.1")
set(WX_lib_COMPONENTS   core base)
set(WX_lib_DIR          "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_wxWidgets")

# To use below for sample sources.
set(cmr_UNPACKED_DIR ${CMAKE_CURRENT_BINARY_DIR}/download/unpacked)

# To use our FindwxWidgets.cmake and UsewxWidgets.cmake.
list(APPEND CMAKE_MODULE_PATH "${WX_lib_DIR}/cmake/modules")

# We must set this variable explicitly to the static lib building.
set(BUILD_SHARED_LIBS OFF)


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

if(MSVC)
  # LibCMaker set /MD or /MT flags by cmr_USE_MSVC_STATIC_RUNTIME.
  #cmr_wx_option(wxBUILD_USE_STATIC_RUNTIME
  #  "Link using the static runtime library"
  #  OFF
  #)
  cmr_wx_option(wxBUILD_MSVC_MULTIPROC
    "Enable multi-processor compilation for MSVC"
    ON
  )
else()
  # It set in WX by CMAKE_CXX_STANDARD
  #cmr_wx_option(wxBUILD_CXX_STANDARD
  #  "C++ standard used to build wxWidgets targets"
  #  ${CXX_STANDARD_DEFAULT}
  #  STRINGS COMPILER_DEFAULT 98 11 14
  #)
endif()

# TODO: cmr_wx_option(wxUSE_*)

# Exclude STC for version 3.1.1. TODO: check it for newer version.
cmr_wx_option(wxUSE_STC "use wxStyledTextCtrl library" OFF)


#-----------------------------------------------------------------------
# Build, install and find the wxWidgets
#-----------------------------------------------------------------------

# Make build and install the library at a config CMake phase.
include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${WX_lib_NAME}
  VERSION         ${WX_lib_VERSION}
  COMPONENTS      ${WX_lib_COMPONENTS}
  LIB_DIR         ${WX_lib_DIR}
  REQUIRED
  CUSTOM_LOGIC_FILE ${WX_lib_DIR}/cmake/cmr_find_package_wxwidgets_custom.cmake
)

# wxWidgets_USE_FILE set in cmr_find_package_icu_host_tools_custom.cmake.
# lib_WX_EXPORT_FILE set in cmr_find_package_icu_host_tools_custom.cmake.

if(WX_USE_FIND_PACKAGE_MODULE)
  include(${wxWidgets_USE_FILE})
else()
  include(${lib_WX_EXPORT_FILE})
endif()


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables.

# To run it on Linux with the shared libs
# which are built with non standard path in CMAKE_INSTALL_PREFIX use:
# LD_LIBRARY_PATH="<${CMAKE_INSTALL_PREFIX}>/lib:.:$LD_LIBRARY_PATH" ./LibCMaker_wxWidgets_Compile_Test
# where <${CMAKE_INSTALL_PREFIX}> is path which is used
# as value for CMAKE_INSTALL_PREFIX.

# Get an example sources from the lib sources.
set(lib_SRC_DIR
  "${cmr_UNPACKED_DIR}/wxWidgets-${WX_lib_VERSION}/wxWidgets-${WX_lib_VERSION}"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR}/samples)

if(WIN32)
  # See docs for add_executable().
  set(WIN32GUI WIN32)
else()
  set(WIN32GUI "")
endif()

# Example
add_executable(${PROJECT_NAME} ${WIN32GUI}
  ${lib_EXAMPLES_SRC_DIR}/vscroll/vstest.cpp
)

# wxWidgets
if(WX_USE_FIND_PACKAGE_MODULE)
  target_include_directories(${PROJECT_NAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} ${wxWidgets_LIBRARIES})
else()
  target_link_libraries(${PROJECT_NAME} ${WX_lib_COMPONENTS})
endif()
