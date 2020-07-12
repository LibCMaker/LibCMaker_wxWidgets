# ****************************************************************************
#  Project:  LibCMaker_wxWidgets
#  Purpose:  A CMake build script for wxWidgets library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2020 NikitaFeodonit
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

set(LibCMaker_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/libs")
set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")

include(${LibCMaker_DIR}/samples/cmr_get_cmake_min_ver.cmake NO_POLICY_SCOPE)
cmr_get_cmake_min_ver()
cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})

project(LibCMaker_wxWidgets_Compile_Test CXX)

set(WX_USE_FIND_PACKAGE_MODULE ON)

include(${LibCMaker_DIR}/samples/cmr_samples_common_macros.cmake)


#-----------------------------------------------------------------------
# Common sample 1st part
#-----------------------------------------------------------------------

cmr_common_sample_1st_part()


#-----------------------------------------------------------------------
# Compiler flags
#-----------------------------------------------------------------------

if(NOT BUILD_SHARED_LIBS)
  set(cmr_USE_STATIC_RUNTIME ON)
endif()

# Set compile flags.
if(MSVC)
  # Determine MSVC runtime library flag
  set(MSVC_LIB_USE "/MD")
  set(MSVC_LIB_REPLACE "/MT")
  if(cmr_USE_STATIC_RUNTIME AND NOT BUILD_SHARED_LIBS)
    set(MSVC_LIB_USE "/MT")
    set(MSVC_LIB_REPLACE "/MD")
  endif()
  # Set MSVC runtime flags for all configurations
  # See:
  # https://stackoverflow.com/a/20804336
  # https://stackoverflow.com/a/14172871
  foreach(cfg "" ${CMAKE_CONFIGURATION_TYPES})
    set(c_flag_var CMAKE_C_FLAGS)
    set(cxx_flag_var CMAKE_CXX_FLAGS)
    if(cfg)
      string(TOUPPER ${cfg} cfg_upper)
      set(c_flag_var   "${c_flag_var}_${cfg_upper}")
      set(cxx_flag_var "${cxx_flag_var}_${cfg_upper}")
    endif()
    if(${c_flag_var} MATCHES ${MSVC_LIB_REPLACE})
      string(REPLACE
        ${MSVC_LIB_REPLACE} ${MSVC_LIB_USE} ${c_flag_var} "${${c_flag_var}}"
      )
      set(${c_flag_var} ${${c_flag_var}} CACHE STRING
        "Flags used by the C compiler during ${cfg_upper} builds." FORCE
      )
    endif()
    if(${cxx_flag_var} MATCHES ${MSVC_LIB_REPLACE})
      string(REPLACE
        ${MSVC_LIB_REPLACE} ${MSVC_LIB_USE} ${cxx_flag_var} "${${cxx_flag_var}}"
      )
      set(${cxx_flag_var} ${${cxx_flag_var}} CACHE STRING
        "Flags used by the CXX compiler during ${cfg_upper} builds." FORCE
      )
    endif()
  endforeach()

elseif(("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    OR ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang"))
  if(cmr_USE_STATIC_RUNTIME AND NOT BUILD_SHARED_LIBS)
    if(MINGW)
      set(STATIC_LINKER_FLAGS "-static")
    elseif(NOT ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND APPLE))
      set(STATIC_LINKER_FLAGS "-static-libgcc -static-libstdc++")
    endif()
    set(CMAKE_EXE_LINKER_FLAGS
      "${CMAKE_EXE_LINKER_FLAGS} ${STATIC_LINKER_FLAGS}"
    )
    set(CMAKE_SHARED_LINKER_FLAGS
      "${CMAKE_SHARED_LINKER_FLAGS} ${STATIC_LINKER_FLAGS}"
    )
  endif()
endif()


#-----------------------------------------------------------------------
# Download, configure, build, install and find the required libraries
#-----------------------------------------------------------------------

include(${LibCMaker_LIB_DIR}/LibCMaker_wxWidgets/cmr_build_wxwidgets.cmake)


#-----------------------------------------------------------------------
# Build the executable of the example
#-----------------------------------------------------------------------

# Get an example sources from the lib sources.
set(lib_SRC_DIR
  "${cmr_UNPACKED_DIR}/wxWidgets-${WX_lib_VERSION}/wxWidgets-${WX_lib_VERSION}"
#  "${cmr_UNPACKED_DIR}/wxWidgets-${WX_lib_VERSION}/LibCMaker_wxWidgets_Sources-${WX_lib_VERSION}"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR}/samples)

target_sources(${PROJECT_NAME}
  PRIVATE
    ${lib_EXAMPLES_SRC_DIR}/vscroll/vstest.cpp
)
set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 11
  C_STANDARD 11
)

if(WIN32)
  # See docs for add_executable() and WIN32_EXECUTABLE.
  set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE ON)
endif()

# wxWidgets
if(WX_USE_FIND_PACKAGE_MODULE)
  #include(${wxWidgets_USE_FILE})
  #target_link_libraries(${PROJECT_NAME} ${wxWidgets_LIBRARIES})

  target_compile_definitions(${PROJECT_NAME} PRIVATE ${wxWidgets_DEFINITIONS})
  target_compile_definitions(${PROJECT_NAME} PRIVATE
      $<$<CONFIG:Debug>:${wxWidgets_DEFINITIONS_DEBUG}>
  )
  target_compile_options(${PROJECT_NAME} PRIVATE ${wxWidgets_CXX_FLAGS})
  target_include_directories(${PROJECT_NAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} PRIVATE ${wxWidgets_LIBRARIES})

  if(MINGW AND NOT BUILD_SHARED_LIBS)
    if(NOT MINGW_HOME)
      message(FATAL_ERROR "Please set MINGW_HOME to MinGW home path.")
    endif()

    set(mingw_ARCH "x86_64")
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(mingw_ARCH "i686")
    endif()
    set(mingw_PREFIX "${mingw_ARCH}-w64-mingw32")
    list(APPEND CMAKE_PREFIX_PATH "${MINGW_HOME}/${mingw_PREFIX}")

    find_library(comdlg32_LIB comdlg32)
    if(comdlg32_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${comdlg32_LIB})
    endif()

    find_library(gdi32_LIB gdi32)
    if(gdi32_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${gdi32_LIB})
    endif()

    find_library(ole32_LIB ole32)
    if(ole32_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${ole32_LIB})
    endif()

    find_library(oleacc_LIB oleacc)
    if(oleacc_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${oleacc_LIB})
    endif()

    find_library(oleaut32_LIB oleaut32)
    if(oleaut32_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${oleaut32_LIB})
    endif()

    find_library(uuid_LIB uuid)
    if(uuid_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${uuid_LIB})
    endif()

    find_library(uxtheme_LIB uxtheme)
    if(uxtheme_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${uxtheme_LIB})
    endif()

    find_library(winspool_LIB winspool)
    if(winspool_LIB)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${winspool_LIB})
    endif()
  endif()
else()
  target_link_libraries(${PROJECT_NAME} PRIVATE ${WX_lib_COMPONENTS})
endif()


#-----------------------------------------------------------------------
# Common sample 2nd part
#-----------------------------------------------------------------------

cmr_common_sample_2nd_part()


#-----------------------------------------------------------------------
# Testing
#-----------------------------------------------------------------------

set(test_src_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
add_subdirectory(test)
