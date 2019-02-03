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

    # Try to find already installed lib.
    if(WX_USE_FIND_PACKAGE_MODULE)
      find_package(${module_NAME} ${module_version} QUIET ${find_args})
    endif()

    set(WX_lib_EXPORT_FILE "${lib_BUILD_DIR}/export-wxWidgets.cmake")

    if(NOT wxWidgets_FOUND AND NOT EXISTS ${WX_lib_EXPORT_FILE})
      cmr_print_status("${find_NAME} is not built, build it.")

      include(cmr_find_package_${lib_NAME_LOWER})

      if(WX_USE_FIND_PACKAGE_MODULE)
        if(find_REQUIRED)
          list(APPEND find_args REQUIRED)
        endif()
        find_package(${module_NAME} ${module_version} ${find_args})
      endif()

    else()
      cmr_print_status("${find_NAME} is built, skip its building.")
    endif()

    if(WX_USE_FIND_PACKAGE_MODULE)
      set(wxWidgets_FOUND ${wxWidgets_FOUND} PARENT_SCOPE)
      set(wxWidgets_INCLUDE_DIRS ${wxWidgets_INCLUDE_DIRS} PARENT_SCOPE)
      set(wxWidgets_LIBRARIES ${wxWidgets_LIBRARIES} PARENT_SCOPE)
      set(wxWidgets_LIBRARY_DIRS ${wxWidgets_LIBRARY_DIRS} PARENT_SCOPE)
      set(wxWidgets_DEFINITIONS ${wxWidgets_DEFINITIONS} PARENT_SCOPE)
      set(wxWidgets_DEFINITIONS_DEBUG
        ${wxWidgets_DEFINITIONS_DEBUG} PARENT_SCOPE
      )
      set(wxWidgets_CXX_FLAGS ${wxWidgets_CXX_FLAGS} PARENT_SCOPE)
      set(wxWidgets_USE_FILE ${wxWidgets_USE_FILE} PARENT_SCOPE)
    else()
      set(WX_lib_EXPORT_FILE ${WX_lib_EXPORT_FILE} PARENT_SCOPE)
    endif()
