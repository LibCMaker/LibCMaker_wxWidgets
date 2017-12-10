# ****************************************************************************
#  Project:  LibCMaker_wxWidgets
#  Purpose:  A CMake build script for wxWidgets library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
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

set(LIBCMAKER_WX_SRC_DIR "${EXTERNAL_SRC_DIR}/LibCMaker_wxWidgets")
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

set(lib_VERSION "3.1.0")
set(WX_lib_COMPONENTS core base)

set(DOWNLOAD_DIR "${PROJECT_BINARY_DIR}")
set(UNPACKED_SRC_DIR "${PROJECT_BINARY_DIR}")
set(BUILD_DIR "${PROJECT_BINARY_DIR}/build_wxwidgets")

set(COPY_WX_CMAKE_BUILD_SCRIPTS ON)

# Library specific vars and options.

# Add a option. Parameter STRINGS represents a valid values.
# wx_option(<name> <desc> [default] [STRINGS strings])
function(wx_option name desc)
#  cmake_parse_arguments(OPTION "" "" "STRINGS" ${ARGN})
#  set(default ${OPTION_UNPARSED_ARGUMENTS})
#  set(${name} "${default}" PARENT_SCOPE)

  cmake_parse_arguments(OPTION "" "" "STRINGS" ${ARGN})
  if(ARGC EQUAL 2)
    set(default ON)
  else()
    set(default ${OPTION_UNPARSED_ARGUMENTS})
  endif()
          
  if(OPTION_STRINGS)
    set(cache_type STRING)
  else()
    set(cache_type BOOL)
  endif()

  set(${name} "${default}" CACHE ${cache_type} "${desc}")

  string(SUBSTRING ${name} 0 6 prefix)
  if(prefix STREQUAL "wxUSE_")
    mark_as_advanced(${name})
  endif()

  if(OPTION_STRINGS)
    set_property(CACHE ${name} PROPERTY STRINGS ${OPTION_STRINGS})
  endif()
endfunction()


# Global build options
#wx_option(wxBUILD_SHARED "Build wx libraries as shared libs"
#  ${BUILD_SHARED_LIBS}
#)
wx_option(wxBUILD_MONOLITHIC "Build wxWidgets as single library" OFF)
wx_option(wxBUILD_SAMPLES "Build only important samples (SOME) or ALL" OFF
  STRINGS SOME ALL OFF
)
wx_option(wxBUILD_TESTS "Build console tests (CONSOLE_ONLY) or ALL" OFF
  STRINGS CONSOLE_ONLY ALL OFF
)
wx_option(wxBUILD_DEMOS "Build demos" OFF)
wx_option(wxBUILD_PRECOMP "Use precompiled headers" ON)
wx_option(wxBUILD_INSTALL "Create install/uninstall target for wxWidgets" ON)
wx_option(wxBUILD_COMPATIBILITY "Enable compatibilty with earlier wxWidgets versions"
  3.0
  STRINGS 2.8 3.0 3.1
)

if(MSVC)
  wx_option(wxBUILD_USE_STATIC_RUNTIME "Link using the static runtime library"
    OFF
  )
else()
  # It set in WX by CMAKE_CXX_STANDARD
  #wx_option(wxBUILD_CXX_STANDARD "C++ standard used to build wxWidgets targets"
  #  ${CXX_STANDARD_DEFAULT}
  #  STRINGS COMPILER_DEFAULT 98 11 14
  #)
endif()

# TODO: wx_option(wxUSE_*)

# Exclude STC for version 3.1.0. TODO: remove it for 3.1.1.
wx_option(wxUSE_STC "use wxStyledTextCtrl library" OFF)


#-----------------------------------------------------------------------
# Build and install the wxWidgets.
#-----------------------------------------------------------------------

include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_wxWidgets/lib_cmaker_wxwidgets.cmake)

# Make compile, build and install the library at a config CMake phase,
# generate the CMake config files.

set(USING_WX_SUB_DIR ON)

set(ONLY_CONFIGURE "")
if(USING_WX_SUB_DIR)
  set(ONLY_CONFIGURE "ONLY_CONFIGURE")
endif()

# Install specified library version.
lib_cmaker_wxwidgets(
  VERSION ${lib_VERSION}
  DOWNLOAD_DIR ${DOWNLOAD_DIR}
  UNPACKED_SRC_DIR ${UNPACKED_SRC_DIR}
  BUILD_DIR ${BUILD_DIR}
  ${ONLY_CONFIGURE}
)


#-----------------------------------------------------------------------
# Configure for find_package.
#-----------------------------------------------------------------------

# Set CMake's search path for find_package(), find_program(), find_library(),
# find_file(), and find_path() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# find_package
#-----------------------------------------------------------------------

# Use newly got library.
if(NOT USING_WX_SUB_DIR)
  find_package(wxWidgets 3.1 COMPONENTS ${WX_lib_COMPONENTS} REQUIRED)
  include(${wxWidgets_USE_FILE})
endif()


#-----------------------------------------------------------------------
# Link to the library.
#-----------------------------------------------------------------------

# Get an example sources from the wxWidgets sources.
include(
  ${PROJECT_SOURCE_DIR}/cmake/LibCMaker_wxWidgets/cmake/modules/cmr_wxwidgets_get_download_params.cmake)
cmr_wxwidgets_get_download_params(${lib_VERSION}
  lib_URL lib_SHA lib_SRC_DIR_NAME lib_ARCH_FILE_NAME)
set(lib_SRC_DIR "${UNPACKED_SRC_DIR}/${lib_SRC_DIR_NAME}")

if(USING_WX_SUB_DIR)
  add_subdirectory(${lib_SRC_DIR})
endif()

# Build test executables.
add_executable(${PROJECT_NAME} ${WIN32GUI}
  ${lib_SRC_DIR}/samples/vscroll/vstest.cpp
)

if(USING_WX_SUB_DIR)
  target_link_libraries(${PROJECT_NAME} ${WX_lib_COMPONENTS})
else()
  target_include_directories(${PROJECT_NAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} ${wxWidgets_LIBRARIES})
endif()
