find_library(LOG4CXX_LIBRARIES log4cxx)

# Don't need to hard code it now as package.em.in now does a find_package for 3rd party libs.
if ( NOT LOG4CXX_LIBRARIES )
  if(MINGW)
    set(LOG4CXX_INCLUDE_DIRS /opt/mingw/usr/i686-pc-mingw32/include)
    set(LOG4CXX_LIBRARIES log4cxx aprutil-1 expat iconv apr-1 rpcrt4 shell32 ws2_32 advapi32 kernel32 msvcrt)
  elseif(MSVC)
    set(LOG4CXX_INCLUDE_DIRS C:/opt/3rdparty/include)
    set(LOG4CXX_LIBRARIES C:/opt/3rdparty/lib/log4cxx.lib)
  else()
    set(LOG4CXX_INCLUDE_DIRS /usr/include)
  endif()
endif()

set(LOG4CXX_FOUND TRUE)
