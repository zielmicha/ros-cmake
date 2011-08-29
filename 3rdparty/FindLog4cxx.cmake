# - Try to find log4cxx
# 
# Once done, this will define:
# LOG4CXX_FOUND - system has found log4cxx
# LOG4CXX_INCLUDE_DIRS - The include directories.
# LOG4CXX_LIBRARIES - the libs
#
# Variables that can be used as a hint for locating the library:
#
# LOG4CXX_ROOT_DIR - setdirectory under which lib and include folders are located.

set(LOG4CXX_ROOT_DIR 
  "${CMAKE_INSTALL_PREFIX}" CACHE STRING 
  "Specify root directory if internal guesses fail (e.g. /opt/).")


if(MINGW)
  # Until I implement a pkg-config check, just hard code them into mingw_cross.
  set(LOG4CXX_INCLUDE_DIRS /opt/mingw/usr/i686-pc-mingw32/include)
  set(LOG4CXX_LIBRARIES log4cxx aprutil-1 expat iconv apr-1 rpcrt4 shell32 ws2_32 advapi32 kernel32 msvcrt)
else()
  # These are cache variables, but we're not using them - simply use ROOT_DIR instead.
  find_library(LOG4CXX_LIBRARY log4cxx PATHS 
    ${LOG4CXX_ROOT_DIR} C:/opt/3rdparty
    PATH_SUFFIXES "/lib")

  find_path(LOG4CXX_INCLUDE_DIR log4cxx/log4cxx.h 
    PATHS ${LOG4CXX_ROOT_DIR} C:/opt/3rdparty
    PATH_SUFFIXES "/include" DOC "LOG4CXX include directory.")

  # Non cache variables

  set(LOG4CXX_LIBRARIES ${LOG4CXX_LIBRARY})
  set(LOG4CXX_INCLUDE_DIRS ${LOG4CXX_INCLUDE_DIR})
endif()


# handle the QUIETLY and REQUIRED arguments and set LOG4CXX_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LOG4CXX DEFAULT_MSG LOG4CXX_LIBRARIES LOG4CXX_INCLUDE_DIRS)
