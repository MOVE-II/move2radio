FILE(MAKE_DIRECTORY ${BUILD_PATH}/boost)
ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/boost/b2
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${BOOST_SOURCE} ${BUILD_PATH}/boost
  COMMAND ./bootstrap.sh
    --prefix="${PREFIX_PATH}/usr"
    --with-libraries=atomic,chrono,date_time,filesystem,program_options,regex,system,thread,serialization
  WORKING_DIRECTORY ${BUILD_PATH}/boost
  DEPENDS boost
  )

ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/boost_installed
  COMMAND ./b2 --with-test install
  COMMAND ./b2 install
  COMMAND ${CMAKE_COMMAND} -E touch ${PREFIX_PATH}/boost_installed
  COMMAND cp -r ${BOOST_SOURCE}/boost ${PREFIX_PATH}/usr/include/
  WORKING_DIRECTORY ${BUILD_PATH}/boost
  DEPENDS ${BUILD_PATH}/boost/b2
  )

ADD_CUSTOM_TARGET(build_boost
  DEPENDS ${PREFIX_PATH}/boost_installed)
  
ADD_DEPENDENCIES(build_boost prefix)
