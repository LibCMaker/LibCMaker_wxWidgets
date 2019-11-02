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

# Part of "LibCMaker/cmake/cmr_get_download_params.cmake".

  include(cmr_get_version_parts)
  cmr_get_version_parts(${version} major minor patch tweak)

  if(version VERSION_EQUAL "3.1.1")
    set(arch_file_sha
      "f999c3cf1887c0a60e519214c14b15cb9bb5ea6e")
  endif()
  if(version VERSION_EQUAL "3.1.2.20190118")
    set(arch_file_sha
      "88e92f63821073ef03999263cae5b1816e79b78f")
    set(unofficial_src true)
  endif()
  if(version VERSION_EQUAL "3.1.2.20190503")
    set(arch_file_sha
      "647123731611f605e769d3f9a3203195322fd674")
    set(unofficial_src true)
  endif()
  if(version VERSION_EQUAL "3.1.2.20190804")
    set(arch_file_sha
      "6598c477eba4462fbb67f32523a8ca6c9406fb91")
    set(unofficial_src true)
  endif()
  if(version VERSION_EQUAL "3.1.3")
    set(arch_file_sha
      "18be15d7a9e5b733e647677d3e9bc476df727f73")
  endif()

  set(base_url "https://github.com/wxWidgets/wxWidgets/releases/download")
  set(src_dir_name    "wxWidgets-${version}")
  set(arch_file_name  "${src_dir_name}.tar.bz2")
  set(unpack_to_dir   "${unpacked_dir}/${src_dir_name}")

  if(unofficial_src)
    # We get the source tar file from an unofficial place.
    # https://github.com/LibCMaker/LibCMaker_wxWidgets_Sources/archive/v3.1.2.20190118.tar.gz
    set(base_url "https://github.com/LibCMaker/LibCMaker_wxWidgets_Sources/archive")
    set(arch_file_name  "${src_dir_name}.tar.gz")
  endif()

  set(${out_ARCH_SRC_URL}
    "${base_url}/v${major}.${minor}.${patch}/wxwidgets-${version}.tar.bz2"
    PARENT_SCOPE
  )
  set(${out_ARCH_DST_FILE}  "${download_dir}/${arch_file_name}" PARENT_SCOPE)
  set(${out_ARCH_FILE_SHA}  "${arch_file_sha}" PARENT_SCOPE)
  set(${out_SHA_ALG}        "SHA1" PARENT_SCOPE)
  set(${out_UNPACK_TO_DIR}  "${unpack_to_dir}" PARENT_SCOPE)
  set(${out_UNPACKED_SOURCES_DIR}
    "${unpack_to_dir}/${src_dir_name}" PARENT_SCOPE
  )
  set(${out_VERSION_BUILD_DIR} "${build_dir}/${src_dir_name}" PARENT_SCOPE)

  if(unofficial_src)
    set(${out_ARCH_SRC_URL}   "${base_url}/v${version}.tar.gz" PARENT_SCOPE)
    set(${out_UNPACKED_SOURCES_DIR}
      "${unpack_to_dir}/LibCMaker_wxWidgets_Sources-${version}" PARENT_SCOPE
    )
  endif()
