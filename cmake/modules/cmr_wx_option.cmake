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

include(CMakeParseArguments) # cmake_parse_arguments

# Add a option. Parameter STRINGS represents a valid values.
# cmr_wx_option(<name> <desc> [default] [STRINGS strings])
function(cmr_wx_option name desc)
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
