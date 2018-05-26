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

include(GNUInstallDirs)

include(cmr_lib_cmaker_post)
include(cmr_print_debug_message)
include(cmr_print_fatal_error)
include(cmr_print_message)
include(cmr_print_var_value)

include(cmr_wxwidgets_get_download_params)

# TODO: make docs
function(cmr_wxwidgets_cmaker)
  cmake_minimum_required(VERSION 3.2)

  cmr_lib_cmaker_post()
  
  # Required vars
  if(NOT lib_VERSION)
    cmr_print_fatal_error("Variable lib_VERSION is not defined.")
  endif()
  if(NOT lib_COMPONENTS)
    cmr_print_fatal_error("Variable lib_COMPONENTS is not defined.")
  endif()
  if(NOT lib_BUILD_DIR)
    cmr_print_fatal_error("Variable lib_BUILD_DIR is not defined.")
  endif()

  # Optional vars
  if(NOT lib_DOWNLOAD_DIR)
    set(lib_DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  if(NOT lib_UNPACKED_SRC_DIR)
    set(lib_UNPACKED_SRC_DIR "${lib_DOWNLOAD_DIR}/sources")
  endif()
  
  cmr_wxwidgets_get_download_params(${lib_VERSION}
    lib_URL lib_SHA lib_SRC_DIR_NAME lib_ARCH_FILE_NAME)

  set(lib_ARCH_FILE "${lib_DOWNLOAD_DIR}/${lib_ARCH_FILE_NAME}")
  set(lib_SRC_DIR "${lib_UNPACKED_SRC_DIR}/${lib_SRC_DIR_NAME}")
  set(lib_BUILD_SRC_DIR "${lib_BUILD_DIR}/${lib_SRC_DIR_NAME}")

  # Library specific vars.


  #-----------------------------------------------------------------------
  # Build library.
  #-----------------------------------------------------------------------

  #-----------------------------------------------------------------------
  # Download tar file.
  #
  if(NOT EXISTS "${lib_ARCH_FILE}")
    cmr_print_message("Download ${lib_URL}")
    file(
      DOWNLOAD "${lib_URL}" "${lib_ARCH_FILE}"
      EXPECTED_HASH SHA1=${lib_SHA}
      SHOW_PROGRESS
    )
  endif()
  
  #-----------------------------------------------------------------------
  # Extract tar file.
  #
  if(NOT EXISTS "${lib_SRC_DIR}")
    cmr_print_message("Extract ${lib_ARCH_FILE}")
    file(MAKE_DIRECTORY ${lib_UNPACKED_SRC_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xjf ${lib_ARCH_FILE}
      WORKING_DIRECTORY ${lib_UNPACKED_SRC_DIR}
    )
  endif()


  #-----------------------------------------------------------------------
  # Configure library.
  #
  add_subdirectory(${lib_SRC_DIR} ${lib_BUILD_SRC_DIR})

  
  #-----------------------------------------------------------------------
  # Export library targets.
  #
  if(NOT lib_INSTALL)
    macro(add_wx_deps wx_COMPONENTS wx_component)
      list(FIND ${wx_COMPONENTS} ${wx_component} is_contained)
      if(is_contained GREATER -1)
        list(APPEND ${wx_COMPONENTS} ${ARGN})
      endif()
    endmacro()
    
    cmr_print_debug_message("lib_COMPONENTS before add_wx_deps()")
    cmr_print_var_value(lib_COMPONENTS)
    
    # TODO: add deps for all wx components.
    add_wx_deps(lib_COMPONENTS base wxzlib wxregex)
    
    if(wxUSE_LIBTIFF STREQUAL "builtin")
      add_wx_deps(lib_COMPONENTS core wxjpeg wxpng wxtiff)
    else()
      add_wx_deps(lib_COMPONENTS core wxjpeg wxpng)
    endif()
    
    cmr_print_debug_message("lib_COMPONENTS after add_wx_deps()")
    cmr_print_var_value(lib_COMPONENTS)
    
    export(
      TARGETS ${lib_COMPONENTS}
      FILE "export-wxWidgets.cmake"
      EXPORT_LINK_INTERFACE_LIBRARIES
    )
  endif()

endfunction()
