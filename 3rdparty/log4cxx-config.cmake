find_library(LOG4CXX_LIBRARIES log4cxx)

if(MINGW)
  set(LOG4CXX_INCLUDE_DIRS /opt/mingw/usr/i686-pc-mingw32/include)
  set(LOG4CXX_LIBRARIES log4cxx aprutil-1 expat iconv apr-1 rpcrt4 shell32 ws2_32 advapi32 kernel32 msvcrt)
elif(MSVC)
  set(LOG4CXX_INCLUDE_DIRS C:/opt/3rdparty/include)
  set(LOG4CXX_LIBRARIES C:/opt/3rdparty/log4cxx.lib)
else()
  set(LOG4CXX_INCLUDE_DIRS /usr/include)
endif()

set(LOG4CXX_FOUND TRUE)
