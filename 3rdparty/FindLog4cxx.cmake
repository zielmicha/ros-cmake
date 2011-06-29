# - Try to find log4cxx
# 
# Once done, this will define:
# Log4cxx_FOUND - system has found log4cxx
# Log4cxx_INCLUDE_DIRS - The include directories.
# Log4cxx_LIBRARIES - the libs
#
# Variables that can be used as a hint for locating the library:
#
# Log4cxx_ROOT_DIR - setdirectory under which lib and include folders are located.

set(Log4cxx_ROOT_DIR 
  "${CMAKE_INSTALL_PREFIX}" CACHE STRING 
  "Specify root directory if internal guesses fail (e.g. /opt/).")


if(MINGW)
  # Until I implement a pkg-config check, just hard code them into mingw_cross.
  set(Log4cxx_INCLUDE_DIRS /opt/mingw/usr/i686-pc-mingw32/include)
  set(Log4cxx_LIBRARIES log4cxx aprutil-1 expat iconv apr-1 rpcrt4 shell32 ws2_32 advapi32 kernel32 msvcrt)
else()
  # These are cache variables, but we're not using them - simply use ROOT_DIR instead.
  find_library(Log4cxx_LIBRARY log4cxx PATHS 
    ${Log4cxx_ROOT_DIR} C:/opt/3rdparty
    PATH_SUFFIXES "/lib")

  find_path(Log4cxx_INCLUDE_DIR log4cxx/log4cxx.h 
    PATHS ${Log4cxx_ROOT_DIR} C:/opt/3rdparty
    PATH_SUFFIXES "/include" DOC "Log4cxx include directory.")

  # Non cache variables

  set(Log4cxx_LIBRARIES ${Log4cxx_LIBRARY})
  set(Log4cxx_INCLUDE_DIRS ${Log4cxx_INCLUDE_DIR})
endif()


# handle the QUIETLY and REQUIRED arguments and set Log4cxx_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Log4cxx DEFAULT_MSG Log4cxx_LIBRARIES Log4cxx_INCLUDE_DIRS)


mark_as_advanced(Log4cx_INCLUDE_DIR Log4cx_LIBRARY)