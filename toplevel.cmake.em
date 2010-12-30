#
#  toplevel cmakelists generated by Grob
#  resistance is futile
#  prepare to be decoupled
#
@{
def aslist(x):
    return ';'.join(x)
def asitems(x):
    return '\n  '.join(x)

}
@[for (pkgname, version), d in packages.iteritems()]
set(@(pkgname)_PACKAGE_PATH @(d['srcdir']))
@[end for]

@[for lang, path in langs.iteritems()]
message(STATUS " * @lang")
include(@path)
@[end for]

set(ROSBUILD_LANGS @aslist(langs) CACHE STRING "List of enabled languages")
message("  ROSBUILD_LANGS = ${ROSBUILD_LANGS}")

include(${CMAKE_CURRENT_BINARY_DIR}/toplevel.static.cmake)

set(ROSBUILD_PYTHONPATH
  @(':'.join(src_pythonpath))
  )

macro(rosbuild_msgs)
@[for l in langs]
  genmsg_@(l[3:])(${ARGV})
@[end for]
endmacro()

macro(rosbuild_srvs)
@[for l in langs]
  gensrv_@(l[3:])(${ARGV})
@[end for]
endmacro()

macro(rosbuild_gentargets)
@[for l in langs]
  gentargets_@(l[3:])(${ARGV})
@[end for]
endmacro()

@[for pkg in topologically_sorted_packages]
if(EXISTS @(packages[(pkg, None)]['srcdir'])/CMakeLists.txt)
  add_subdirectory(@(packages[(pkg, None)]['srcdir']) @(pkg))
endif()
@[end for]