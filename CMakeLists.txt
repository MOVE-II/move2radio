CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(move2radio
  LANGUAGES NONE
  DESCRIPTION "Portable Version of the MOVE-II groundstation")

INCLUDE(ExternalProject)

IF(UNIX AND NOT APPLE)
  SET(LINUX TRUE)
ENDIF()

INCLUDE(cmake/options.cmake)
INCLUDE(cmake/system_deps.cmake)

INCLUDE(cmake/build_autotools.cmake)
INCLUDE(cmake/build_cmake.cmake)
INCLUDE(cmake/build_meson.cmake)

SET(DEPS_PATH "${CMAKE_CURRENT_BINARY_DIR}/deps")
SET(BUILD_PATH "${CMAKE_CURRENT_BINARY_DIR}/build")
SET(PREFIX_PATH "${CMAKE_CURRENT_BINARY_DIR}/prefix")
FILE(MAKE_DIRECTORY ${DEPS_PATH}/src)

SET(ENV{PKG_CONFIG_PATH} ${PREFIX_PATH}/usr/lib/pkgconfig)
SET(PKG_CONFIG_PATH ENV{PKG_CONFIG_PATH})
## Custom target deps makes sure all sources are there
ADD_CUSTOM_TARGET(deps)
IF(NOT ${NO_DOWNLOAD})
  ADD_CUSTOM_TARGET(download)
  ADD_DEPENDENCIES(deps download)
ENDIF()

## move2deps.cmake contains all sources
INCLUDE(cmake/dependency.cmake)
INCLUDE(cmake/move2deps.cmake)

ADD_CUSTOM_TARGET(delete_prefix
  ${CMAKE_COMMAND} -E remove_directory ${PREFIX_PATH})
ADD_CUSTOM_TARGET(prefix
  ${CMAKE_COMMAND} -E make_directory ${PREFIX_PATH})

### Anaconda deploys a portable python + pygtk,numpy,pyqt ###
INCLUDE(cmake/anaconda.cmake)

INCLUDE(ProcessorCount)
PROCESSORCOUNT(N)
FIND_PROGRAM(MAKE make)
FIND_PROGRAM(MESON meson)
FIND_PROGRAM(NINJA ninja)

### Build all sources ###

# Boost and ldpc Build is more complicated. Moved to own file
INCLUDE(cmake/boost.cmake)
INCLUDE(cmake/ldpc.cmake)

MOVEII_BUILD_AUTOTOOLS(fftw EXTRA_OPTIONS --enable-threads --enable-float)
MOVEII_BUILD_AUTOTOOLS(gsl)
MOVEII_BUILD_AUTOTOOLS(libiconv)
MOVEII_BUILD_AUTOTOOLS(rtl-sdr)
MOVEII_BUILD_AUTOTOOLS(gmp)
MOVEII_BUILD_AUTOTOOLS(ntl NO_DEFAULT ON SOURCE_SUFFIX "/src" COPY_SOURCE ON
  EXTRA_OPTIONS NTL_GMP_LIP=on SHARED=on NATIVE=off DEF_PREFIX=${PREFIX_PATH}/usr)
MOVEII_BUILD_AUTOTOOLS(ncurses)
MOVEII_BUILD_CMAKE(airspy)
MOVEII_BUILD_CMAKE(gr-osmosdr)
MOVEII_BUILD_CMAKE(curl)
MOVEII_BUILD_CMAKE(curlpp)
MOVEII_BUILD_CMAKE(gr-ccsds)
MOVEII_BUILD_CMAKE(gr-iqbal)
MOVEII_BUILD_CMAKE(libosmosdr)
MOVEII_BUILD_CMAKE(bladerf EXTRA_OPTIONS -DINSTALL_UDEV_RULES=OFF)
MOVEII_BUILD_CMAKE(libmirisdr)
MOVEII_BUILD_CMAKE(soapysdr)
MOVEII_BUILD_CMAKE(hackrf SOURCE_SUFFIX "/host/")
MOVEII_BUILD_CMAKE(gr-fcdproplus)
MOVEII_BUILD_CMAKE(freersp)
MOVEII_BUILD_CMAKE(libuhd EXTRA_OPTIONS -DENABLE_E100=ON -DENABLE_E300=ON -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF -DENABLE_UTILS=OFF SOURCE_SUFFIX "/host")

MOVEII_BUILD_CMAKE(gnuradio EXTRA_OPTIONS
  -DENABLE_INTERNAL_VOLK=ON
  -DENABLE_DEFAULT=OFF
  -DENABLE_VOLK=ON
  -DENABLE_GNURADIO_RUNTIME=ON
  -DENABLE_PYTHON=ON
  -DENABLE_GR_AUDIO=ON
  -DENABLE_GR_BLOCKS=ON
  -DENABLE_GR_FILTER=ON
  -DENABLE_GR_FFT=ON
  -DENABLE_GR_UHD=ON
  -DENABLE_GR_FCD=ON
  -DENABLE_GR_ANALOG=ON
  -DENABLE_GR_WAVELET=ON
  -DENABLE_GRC=ON
  -DENABLE_GR_QTGUI=ON
  -DENABLE_GR_DIGITAL=ON)
ADD_DEPENDENCIES(build_gnuradio build_boost build_gsl build_fftw build_libiconv build_libuhd)

MOVEII_BUILD_AUTOTOOLS(fec NO_AUTORECONF ON NO_INSTALL ON)
## fec is to dumb to properly install:
ADD_CUSTOM_COMMAND(OUTPUT ${PREFIX_PATH}/usr/lib/libfec.so
  COMMAND ${CMAKE_COMMAND} -E copy ${FEC_SOURCE}/fec.h ${PREFIX_PATH}/usr/include/fec.h
  COMMAND ${CMAKE_COMMAND} -E copy ${BUILD_PATH}/fec/libfec.a ${PREFIX_PATH}/usr/lib/libfec.a
  COMMAND ${CMAKE_COMMAND} -E copy ${BUILD_PATH}/fec/libfec.so ${PREFIX_PATH}/usr/lib/libfec.so
  DEPENDS build_fec
  )
ADD_CUSTOM_TARGET(install_fec
  DEPENDS ${PREFIX_PATH}/usr/lib/libfec.so)

## Get the dependencies between the sources right:
ADD_DEPENDENCIES(build_gr_osmosdr build_rtl_sdr build_gnuradio build_libuhd build_airspy build_gr_fcdproplus build_hackrf build_gr_iqbal build_libosmosdr build_libmirisdr build_bladerf build_soapysdr build_freersp)
ADD_DEPENDENCIES(build_ntl build_gmp)
ADD_DEPENDENCIES(build_curlpp build_curl)
ADD_DEPENDENCIES(install_fec prefix)
ADD_DEPENDENCIES(build_gr_ccsds install_fec build_gnuradio build_ldpc build_curlpp)
ADD_DEPENDENCIES(build_gr_fcdproplus build_gnuradio)

ADD_CUSTOM_TARGET(move2radio)

ADD_DEPENDENCIES(move2radio build_gr_ccsds build_gr_fcdproplus build_gr_osmosdr)
ADD_DEPENDENCIES(build_libuhd build_boost build_ncurses)

ADD_DEPENDENCIES(build_hackrf build_fftw)
ADD_DEPENDENCIES(build_freersp build_boost)
