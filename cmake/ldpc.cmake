ADD_CUSTOM_COMMAND(OUTPUT ${BUILD_PATH}/ldpc/libldpc.so
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${LDPC_SOURCE} ${BUILD_PATH}/ldpc
  COMMAND ${MAKE} all
  WORKING_DIRECTORY ${BUILD_PATH}/ldpc
  DEPENDS ldpc ${LDPC_SOURCE}/ldpc.cpp
  )

ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/usr/lib/libldpc.so
  COMMAND ${CMAKE_COMMAND} -E copy ${BUILD_PATH}/ldpc/libldpc.so ${PREFIX_PATH}/usr/lib/libldpc.so
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${LDPC_SOURCE}/include/ldpc ${PREFIX_PATH}/usr/include/ldpc
  DEPENDS ${BUILD_PATH}/ldpc/libldpc.so
  )

ADD_CUSTOM_TARGET(build_ldpc
  DEPENDS ${PREFIX_PATH}/usr/lib/libldpc.so)
