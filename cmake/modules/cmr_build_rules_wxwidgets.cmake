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

# Part of "LibCMaker/cmake/modules/cmr_build_rules.cmake".

  # Configure library.
  add_subdirectory(${lib_SRC_DIR} ${lib_VERSION_BUILD_DIR})

  # Export library targets.
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
