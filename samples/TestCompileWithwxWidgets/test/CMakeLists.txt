# ****************************************************************************
#  Project:  LibCMaker_wxWidgets
#  Purpose:  A CMake build script for wxWidgets library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

# Testing with Google Test.
if(BUILD_TESTING)
  find_package(GTest REQUIRED)

  set(test_NAME "Examle_test")
  add_executable(${test_NAME} "")
  target_sources(${test_NAME}
    PRIVATE
      ${test_src_DIR}/example_test.cpp
  )
  set_target_properties(${test_NAME} PROPERTIES
    CXX_STANDARD 11
    C_STANDARD 11
  )

  # wxWidgets
  if(WX_USE_FIND_PACKAGE_MODULE)
    #include(${wxWidgets_USE_FILE})
    #target_link_libraries(${test_NAME} ${wxWidgets_LIBRARIES})

    target_compile_definitions(${test_NAME} PRIVATE ${wxWidgets_DEFINITIONS})
    target_compile_definitions(${test_NAME} PRIVATE
        $<$<CONFIG:Debug>:${wxWidgets_DEFINITIONS_DEBUG}>
    )
    target_compile_options(${test_NAME} PRIVATE ${wxWidgets_CXX_FLAGS})
    target_include_directories(${test_NAME} PRIVATE ${wxWidgets_INCLUDE_DIRS})
    target_link_libraries(${test_NAME} PRIVATE ${wxWidgets_LIBRARIES})

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

      find_library(ole32_LIB ole32)
      if(ole32_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${ole32_LIB})
      endif()

      find_library(oleacc_LIB oleacc)
      if(oleacc_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${oleacc_LIB})
      endif()

      find_library(oleaut32_LIB oleaut32)
      if(oleaut32_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${oleaut32_LIB})
      endif()

      find_library(uuid_LIB uuid)
      if(uuid_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${uuid_LIB})
      endif()

      find_library(uxtheme_LIB uxtheme)
      if(uxtheme_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${uxtheme_LIB})
      endif()

      find_library(winspool_LIB winspool)
      if(winspool_LIB)
        target_link_libraries(${test_NAME} PRIVATE ${winspool_LIB})
      endif()
    endif()

  else()
    target_link_libraries(${test_NAME} ${WX_lib_COMPONENTS})
  endif()

  target_link_libraries(${test_NAME} PRIVATE
    GTest::GTest GTest::Main
  )

  add_test(NAME ${test_NAME} COMMAND ${test_NAME})
endif()


# For running test, 1st build all:
#   cmake .. -DBUILD_TESTING=ON
#   cmake --build .
# Then run test with this command:
#   cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target test
# Or with this command:
#   ctest --verbose
# Env var CTEST_OUTPUT_ON_FAILURE or key --verbose are for show test outputs,
# see
# https://stackoverflow.com/a/37123943
# https://stackoverflow.com/a/38386596

# For Visual Studio:
# https://stackoverflow.com/a/31124523
# https://stackoverflow.com/a/37123943
# cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target RUN_TESTS
