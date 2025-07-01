include(ExternalProject)
message(STATUS "Configuring protobuf...")

set(PROTOBUF_INSTALL_DIR ${CMAKE_BINARY_DIR}/protobuf-install)
set(PROTOBUF_HEADERS_DIR ${PROTOBUF_INSTALL_DIR}/include)
set(PROTOBUF_LIBRARY_DIR ${PROTOBUF_INSTALL_DIR}/lib)
set(PROTOBUF_LIBRARY_FILE ${PROTOBUF_LIBRARY_DIR}/libprotobuf.a)
set(PROTOBUF_PROTOC_PATH ${PROTOBUF_INSTALL_DIR}/bin)

if (NOT TARGET protobuf::static)
    add_library(protobuf::static STATIC IMPORTED GLOBAL)
    set_target_properties(protobuf::static
        PROPERTIES
        IMPORTED_LOCATION ${PROTOBUF_LIBRARY_FILE}
        INTERFACE_INCLUDE_DIRECTORIES ${PROTOBUF_HEADERS_DIR}
        INTERFACE_LINK_LIBRARIES zlib::static
        CONSUMER_CFLAGS "-I${PROTOBUF_HEADERS_DIR}"
        CONSUMER_LDFLAGS "-L${PROTOBUF_LIBRARY_DIR} -lprotobuf"
        CONSUMER_PROTOC_PATH ${PROTOBUF_PROTOC_PATH}
        CONSUMER_DESCRIPTOR_PROTO_FILE "${PROTOBUF_HEADERS_DIR}/google/protobuf/descriptor.proto"
    )
    message(STATUS "protobuf::static target created. Install dir: ${PROTOBUF_INSTALL_DIR}")
endif()

register_dependency(
    protobuf
    "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v21.9.tar.gz"
    "0aa7df8289c957a4c54cbe694fbabe99b180e64ca0f8fdb5e2f76dcf56ff2422"
    "LICENSE"
)

ExternalProject_Add(protobuf
    URL ${DEP_protobuf_URL}
    URL_HASH SHA256=${DEP_protobuf_SHA256}
    UPDATE_DISCONNECTED 1
    DOWNLOAD_DIR ${SOURCE_DOWNLOADS_DIR}
    DOWNLOAD_NAME ${DEP_protobuf_FILENAME}
    UPDATE_COMMAND sh -c "test -f <SOURCE_DIR>/configure || <SOURCE_DIR>/autogen.sh"
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --prefix=${PROTOBUF_INSTALL_DIR}
        --enable-static
        --disable-shared
        --with-zlib-include=$<TARGET_PROPERTY:zlib::static,INTERFACE_INCLUDE_DIRECTORIES>
        --with-zlib-lib=$<TARGET_PROPERTY:zlib::static,IMPORTED_LOCATION>
    BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install
    DEPENDS zlib::static
    BUILD_IN_SOURCE 1
)

add_dependencies(protobuf::static protobuf)
message(STATUS "protobuf configuration completed")
