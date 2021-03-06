#   Copyright 2011-2015 Quickstep Technologies LLC.
#   Copyright 2015 Pivotal Software, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

QS_PROTOBUF_GENERATE_CPP(types_containers_Tuple_proto_srcs types_containers_Tuple_proto_hdrs
                         Tuple.proto)

# Declare micro-libs:
add_library(quickstep_types_containers_ColumnVector ColumnVector.cpp ColumnVector.hpp)
add_library(quickstep_types_containers_ColumnVectorUtil ../../empty_src.cpp ColumnVectorUtil.hpp)
add_library(quickstep_types_containers_ColumnVectorsValueAccessor ../../empty_src.cpp ColumnVectorsValueAccessor.hpp)
add_library(quickstep_types_containers_Tuple ../../empty_src.cpp Tuple.hpp)
add_library(quickstep_types_containers_Tuple_proto ${types_containers_Tuple_proto_srcs})

# Link dependencies:
target_link_libraries(quickstep_types_containers_ColumnVector
                      glog
                      quickstep_types_Type
                      quickstep_types_TypedValue
                      quickstep_utility_BitVector
                      quickstep_utility_Macros)
target_link_libraries(quickstep_types_containers_ColumnVectorUtil
                      quickstep_types_containers_ColumnVector)
target_link_libraries(quickstep_types_containers_ColumnVectorsValueAccessor
                      glog
                      quickstep_catalog_CatalogTypedefs
                      quickstep_storage_StorageBlockInfo
                      quickstep_storage_ValueAccessor
                      quickstep_types_TypedValue
                      quickstep_types_containers_ColumnVector
                      quickstep_types_containers_Tuple
                      quickstep_utility_Macros
                      quickstep_utility_ScopedDeleter)
target_link_libraries(quickstep_types_containers_Tuple
                      glog
                      quickstep_catalog_CatalogTypedefs
                      quickstep_types_TypedValue
                      quickstep_types_containers_Tuple_proto
                      quickstep_utility_Macros)
target_link_libraries(quickstep_types_containers_Tuple_proto
                      quickstep_types_TypedValue_proto
                      ${PROTOBUF_LIBRARY})

# Module all-in-one library:
add_library(quickstep_types_containers ../../empty_src.cpp)
target_link_libraries(quickstep_types_containers
                      quickstep_types_containers_ColumnVector
                      quickstep_types_containers_ColumnVectorUtil
                      quickstep_types_containers_ColumnVectorsValueAccessor
                      quickstep_types_containers_Tuple
                      quickstep_types_containers_Tuple_proto)

# Tests:
add_executable(ColumnVector_unittest "${CMAKE_CURRENT_SOURCE_DIR}/tests/ColumnVector_unittest.cpp")
target_link_libraries(ColumnVector_unittest
                      gtest
                      gtest_main
                      quickstep_types_Type
                      quickstep_types_TypeFactory
                      quickstep_types_TypeID
                      quickstep_types_TypedValue
                      quickstep_types_containers_ColumnVector
                      ${LIBS})
add_test(ColumnVector_unittest ColumnVector_unittest)
