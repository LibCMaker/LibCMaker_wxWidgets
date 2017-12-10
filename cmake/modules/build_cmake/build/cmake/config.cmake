#############################################################################
# Name:        build/cmake/config.cmake
# Purpose:     Build wx-config script in build folder
# Author:      Tobias Taschner
# Created:     2016-10-13
# Copyright:   (c) 2016 wxWidgets development team
# Licence:     wxWindows licence
#############################################################################

set(wxCONFIG_DIR ${wxOUTPUT_DIR}/wx/config)
file(MAKE_DIRECTORY ${wxCONFIG_DIR})
set(TOOLCHAIN_FULLNAME ${wxBUILD_FILE_ID})

macro(wx_configure_script input output)
#    set(abs_top_srcdir ${CMAKE_CURRENT_SOURCE_DIR})
#    set(abs_top_builddir ${CMAKE_CURRENT_BINARY_DIR})
    set(abs_top_srcdir ${CMAKE_INSTALL_PREFIX})
    set(abs_top_builddir ${CMAKE_INSTALL_PREFIX})

    configure_file(
        ${input}
        ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${output}
        ESCAPE_QUOTES @ONLY NEWLINE_STYLE UNIX)
    file(COPY
        ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${output}
        DESTINATION ${wxCONFIG_DIR}
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ
            GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
endmacro()

function(wx_write_config_inplace)
    wx_configure_script(
        "${CMAKE_CURRENT_SOURCE_DIR}/wx-config-inplace.in"
        "inplace-${TOOLCHAIN_FULLNAME}"
        )
    execute_process(
        COMMAND
        ${CMAKE_COMMAND} -E create_symlink
        "lib/wx/config/inplace-${TOOLCHAIN_FULLNAME}"
#        "${CMAKE_CURRENT_BINARY_DIR}/wx-config"
        "${wxBINARY_DIR}/wx-config"
        )
endfunction()

function(wx_get_library_basename is_base out_WX_LIBRARY_BASENAME)
    
  # Set library name according to:
  # docs/contrib/about-platform-toolkit-and-library-names.md

  if(is_base)
    set(lib_toolkit base)
  else()
    set(lib_toolkit ${wxBUILD_TOOLKIT}${wxBUILD_WIDGETSET})
  endif()

  if(wxUSE_UNICODE)
    set(lib_unicode u)
  else()
    set(lib_unicode)
  endif()

  set(lib_debug "")
  if(CMAKE_CFG_INTDIR STREQUAL "." AND CMAKE_BUILD_TYPE STREQUAL "Debug"
      OR CMAKE_CFG_INTDIR STREQUAL "Debug")
    set(lib_debug "d")
  endif()
  
  set(${out_WX_LIBRARY_BASENAME}
    wx_${lib_toolkit}${lib_unicode}${lib_debug}
    PARENT_SCOPE
  )

endfunction()

function(wx_write_config)

    set(prefix ${CMAKE_INSTALL_PREFIX})
    set(exec_prefix "")
    wx_string_append(exec_prefix "${prefix}")

    # TODO: set variables
    set(includedir "")
    wx_string_append(includedir "${prefix}/include")
    set(libdir "")
    wx_string_append(libdir "${exec_prefix}/lib")
    set(bindir "")
    wx_string_append(bindir "${exec_prefix}/bin")

    if(CMAKE_CROSSCOMPILING)
        set(cross_compiling yes)
    else()
        set(cross_compiling no)
    endif()

    set(BUILT_WX_LIBS)
    foreach(lib IN LISTS wxLIB_TARGETS)
        wx_string_append(BUILT_WX_LIBS " ${lib}")
    endforeach()

    set(CC ${CMAKE_C_COMPILER})
    set(CXX ${CMAKE_CXX_COMPILER})
    set(DMALLOC_LIBS)
    find_program(EGREP egrep)
    set(EXTRALIBS_GUI)
    set(EXTRALIBS_HTML)
    set(EXTRALIBS_SDL)
    set(EXTRALIBS_STC)
    set(EXTRALIBS_WEBVIEW)
    set(EXTRALIBS_XML)
    set(LDFLAGS_GL)
    if(wxBUILD_MONOLITHIC)
        set(MONOLITHIC 1)
    else()
        set(MONOLITHIC 0)
    endif()
    set(OPENGL_LIBS)
    set(RESCOMP)
    if(wxBUILD_SHARED)
        set(SHARED 1)
    else()
        set(SHARED 0)
    endif()
    set(STD_BASE_LIBS)
    set(STD_GUI_LIBS)
    #TODO: setting TOOLCHAIN_NAME produces change results in config folder

#    set(TOOLCHAIN_NAME)
#    set(TOOLCHAIN_NAME "gtk2-unicode-static-3.1")
#    set(TOOLCHAIN_NAME "gtk2u-static-3.1")

    set(TOOLKIT_DIR ${wxBUILD_TOOLKIT})
    set(TOOLKIT_VERSION ${wxTOOLKIT_VERSION})
    set(WIDGET_SET ${wxBUILD_WIDGETSET})
    if(wxUSE_UNICODE)
        set(WX_CHARTYPE unicode)
    else()
        set(WX_CHARTYPE ansi)
    endif()

    set(WX_FLAVOUR "")
    
#    set(WX_LIBRARY_BASENAME_GUI)
#    set(WX_LIBRARY_BASENAME_NOGUI)
    wx_get_library_basename(true WX_LIBRARY_BASENAME_NOGUI)
    wx_get_library_basename(false WX_LIBRARY_BASENAME_GUI)

    set(WX_RELEASE ${wxMAJOR_VERSION}.${wxMINOR_VERSION})
    set(WX_SUBVERSION ${wxVERSION}.0)
    set(WX_VERSION ${wxVERSION})
    set(WXCONFIG_CFLAGS)
    set(WXCONFIG_CPPFLAGS)
    set(WXCONFIG_CXXFLAGS)
    set(WXCONFIG_LDFLAGS)
    set(WXCONFIG_LDFLAGS_GUI)
    set(WXCONFIG_LIBS)
    set(WXCONFIG_RESFLAGS)
    set(WXCONFIG_RPATH)

    wx_configure_script(
        "${CMAKE_CURRENT_SOURCE_DIR}/wx-config.in"
        "${TOOLCHAIN_FULLNAME}"
        )
endfunction()

wx_write_config_inplace()
wx_write_config()
