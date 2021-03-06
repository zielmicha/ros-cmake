message(STATUS "--- main.cmake ---")

# see Modules/CMakeGenericSystem.cmake
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT EQUAL 1)
  if (CMAKE_HOST_UNIX)
    set(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT 0)
    set(CMAKE_INSTALL_PREFIX "/opt/ros/unknown"
      CACHE PATH "Installation directory" FORCE)
  endif()
endif()

add_custom_target(test)

configure_file(cmake/generate.py 
  ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/generate.stamp
  @ONLY)

configure_file(cmake/package.cmake.em
  ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/package.cmake.stamp
  @ONLY)

configure_file(cmake/toplevel.cmake.em
  ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/toplevel.cmake.stamp
  @ONLY)

set(ROS_BUILD_LIBRARY_TYPE SHARED 
  CACHE STRING 
  "type of libraries to build, either SHARED or STATIC")

if(NOT "$ENV{ROS_PACKAGE_PATH}" STREQUAL "")
  message(STATUS "ROS_PACKAGE_PATH is set in environment")
  if(MSVC)
      if(NOT "$ENV{ROS_PACKAGE_PATH};$ENV{ROS_ROOT}" STREQUAL "${ROS_PACKAGE_PATH}")
          message(STATUS "ROS_PACKAGE_PATH has changed.")
          set(ROS_PACKAGE_PATH "$ENV{ROS_PACKAGE_PATH};$ENV{ROS_ROOT}")
      endif()
  else()
      if(NOT "$ENV{ROS_PACKAGE_PATH};$ENV{ROS_ROOT}" STREQUAL "${ROS_PACKAGE_PATH}")
    message(STATUS "ROS_PACKAGE_PATH has changed.")
    set(ROS_PACKAGE_PATH "$ENV{ROS_PACKAGE_PATH}:$ENV{ROS_ROOT}")
  endif()
endif()
endif()

if (ROS_PACKAGE_PATH)
  set(ROS_PACKAGE_PATH ${ROS_PACKAGE_PATH} CACHE STRING "ros pkg path")
else()
  if(MSVC)
    set(ROS_PACKAGE_PATH "$ENV{ROS_PACKAGE_PATH};$ENV{ROS_ROOT}"
      CACHE STRING "Directories to search for packages to build"
      )
  else()
  set(ROS_PACKAGE_PATH "$ENV{ROS_PACKAGE_PATH}:$ENV{ROS_ROOT}"
    CACHE STRING "Directories to search for packages to build"
    )
  endif()
endif()

if(ROS_PACKAGE_PATH STREQUAL "")
  message(FATAL_ERROR "ROS_PACKAGE_PATH is unset...  we won't be able to find any projects to build this way.")
endif()

if(NOT CMAKE_CROSSCOMPILING)
  try_run(CLANG CLANG_COMPRESULT
    ${CMAKE_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/cmake/platform/clang.c
    )
  if(CLANG)
    message("You're using clang")
  endif()
endif()

if (ROS_3RDPARTY_PATH)
  message("ROS_3RDPARTY_PATH=${ROS_3RDPARTY_PATH}")
endif()

find_package(PythonInterp)
if (NOT PYTHONINTERP_FOUND)
  message(FATAL_ERROR "could not find python interpreter")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/3rdparty/FindLog4cxx.cmake)
include_directories(${LOG4CXX_INCLUDE_DIR})

#
# this shouldn't really be here
#
if (CLANG)
  add_definitions(-DGTEST_USE_OWN_TR1_TUPLE)
endif()

execute_process(COMMAND
  ${PYTHON_EXECUTABLE}
  ${CMAKE_SOURCE_DIR}/cmake/generate.py "${ROS_PACKAGE_PATH}"
  ${CMAKE_SOURCE_DIR}/cmake
  ${CMAKE_BINARY_DIR}
  RESULT_VARIABLE GENERATE_RESULT
  OUTPUT_VARIABLE GENERATE_OUTPUT
  ERROR_VARIABLE GENERATE_ERROR
  )
if (GENERATE_RESULT)
  message(STATUS "********** Output ***********\n ${GENERATE_OUTPUT}")
  message(STATUS "*********** Error ***********\n ${GENERATE_ERROR}")
  message(FATAL_ERROR "Something was bad while generating")
endif()

if (CMAKE_CROSSCOMPILING)
  message("********* cross-compiling for ${CMAKE_SYSTEM_NAME} **********")
endif()
set(ROSBUILD TRUE CACHE INTERNAL "Flag for building under rosbuild2.")

include(cmake/FindPkgConfig.cmake)

option(BUILD_SHARED "build dynamically-linked binaries" ON)
option(BUILD_STATIC "build statically-linked binaries" OFF)

if (BUILD_SHARED)
  add_definitions(-DROS_BUILD_SHARED_LIBS=1)
endif()

if(NOT (BUILD_SHARED OR BUILD_STATIC))
  message(FATAL_ERROR "Neither BUILD_SHARED nor BUILD_STATIC are ON")
endif()

project(ROS)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CPACK_GENERATOR DEB)
set(CPACK_PACKAGE_CONTACT "Your friends at Willow Garage")
set(CPACK_PACKAGE_NAME "ros-unknown-cpacked")
set(CPACK_PACKAGE_VENDOR "Willow Garage")
set(CPACK_PACKAGE_VERSION "1.5.0")
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 5)
set(CPACK_PACKAGE_VERSION_PATCH 0)
set(CPACK_DEBIAN_PACKAGE_SECTION unstable)
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Somebody Smart <smartguy@willowgarage.com>")
set(CPACK_PACKAGE_INSTALL_DIRECTORY /opt/ros/dbag)
set(CPACK_SET_DESTDIR ON)
set(CPACK_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})


execute_process(COMMAND dpkg --print-architecture
  OUTPUT_VARIABLE 
  CPACK_DEBIAN_PACKAGE_ARCHITECTURE
  OUTPUT_STRIP_TRAILING_WHITESPACE)

include(CPack)


set(ROS_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/ros)
set(ROS_SETUP ${CMAKE_CURRENT_BINARY_DIR}/setup)
if(MSVC)
  set(ROSBUILD_SUBSHELL ${CMAKE_CURRENT_BINARY_DIR}/env.bat)
else()
set(ROSBUILD_SUBSHELL ${CMAKE_CURRENT_BINARY_DIR}/env.sh)
endif()
if (NOT ROS_MASTER_URI)
  set(ROS_MASTER_URI http://localhost:11311)
endif()

set(ROSBUILD_GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/gen)
file(MAKE_DIRECTORY ${ROSBUILD_GEN_DIR})
include_directories(${ROSBUILD_GEN_DIR}/cpp)

#
#  apply MACRO to args ARGN
#
macro(apply MACRO)
  set(APPLY_MACRO ${MACRO})
  set(APPLY_ARGS ${ARGN})
  set(_APPLY ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/_apply.cmake)
  configure_file(_apply.cmake.in
    ${_APPLY}
    @ONLY)
  include(${_APPLY})
endmacro()

#set_property(GLOBAL 
#  PROPERTY
#  GLOBAL_DEPENDS_DEBUG_MODE TRUE)
#
# Globally unique targets.  Wtf. 
#
cmake_policy(SET CMP0002 OLD)

include(cmake/FindPkgConfig.cmake)
# avoid automatic linking with windows
if(MSVC)
	add_definitions(-D"BOOST_ALL_NO_LIB")
endif()

#set(Boost_DETAILED_FAILURE_MSG TRUE)
#set(Boost_DEBUG TRUE)

set(Boost_ADDITIONAL_VERSIONS 1.46.1)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)

add_definitions(-DBOOST_CHRONO_INLINED=1)
if(BUILD_STATIC)
  set(Boost_USE_STATIC_LIBS ON)
else()
  add_definitions(-DBOOST_ALL_DYN_LINK=1)
  set(Boost_USE_STATIC_LIBS OFF)
endif()


find_package(Boost 
  COMPONENTS
  chrono 
  date_time 
  filesystem 
  graph 
  iostreams 
  math_c99 
  math_tr1 
  prg_exec_monitor
  program_options
  regex
  serialization 
  signals 
  system 
  thread
  unit_test_framework 
  wave 
  wserialization)

include_directories(${Boost_INCLUDE_DIR})

set(CMAKE_THREAD_PREFER_PTHREAD TRUE CACHE BOOL "prefer pthread")

find_package(Threads)

macro(rosbuild_3rdparty PKGNAME DEPFILE)

  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${DEPFILE})
    configure_file(install.sh.in ${CMAKE_CURRENT_BINARY_DIR}/3rdparty/install.sh
      @ONLY)
  
    execute_process(COMMAND ${CMAKE_CURRENT_BINARY_DIR}/3rdparty/install.sh
      RESULT_VARIABLE _3rdparty_result)
    if (NOT ${_3rdparty_result} EQUAL "0")
      message(FATAL_ERROR 
	"FAIL: 3rdparty ${PKGNAME} returned ${_3rdparty_result}, not 0 as we'd hoped.")
    else()
      message(STATUS 
	"3rdparty ${PKGNAME} bootstrap returned ${_3rdparty_result}.  Good.")
    endif()
  endif()

endmacro()

add_custom_target(test-results-run)
add_custom_target(tests)
add_custom_target(test-results
  COMMAND echo ${rostest_path}/bin/rostest-results --nodeps ${PROJECT_NAME}
  COMMENT FIXME test-results)
add_custom_target(clean-test-results)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/private.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/public.cmake)

rosbuild_check_for_sse()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/toplevel.static.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/toplevel.static.cmake)

message(STATUS "Traversing generated cmake files")

include(${CMAKE_CURRENT_BINARY_DIR}/toplevel.cmake)


foreach(setupfile
    setup.sh
    setup.csh
    setup.bat
    env.sh
    env.bat
    )
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${setupfile}.buildspace.in
    ${CMAKE_CURRENT_BINARY_DIR}/${setupfile}
    @ONLY)
endforeach()

foreach(installfile
    setup.sh
    env.sh
    )
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/${installfile}.install.in
    ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${installfile}.install
    @ONLY)

  install(PROGRAMS 
    ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${installfile}.install
    DESTINATION ${CMAKE_INSTALL_PREFIX}/env
    RENAME ${installfile})
endforeach()
  

#
# fixme:  this doesn't belong here
# 
message("*** fixme, install of ros/bin/")
install(DIRECTORY ${CMAKE_SOURCE_DIR}/ros/bin/
  DESTINATION bin/
  FILE_PERMISSIONS 
  WORLD_EXECUTE WORLD_READ GROUP_EXECUTE GROUP_READ OWNER_EXECUTE OWNER_READ
  )

install(DIRECTORY ros/config/
  DESTINATION config/
  )


