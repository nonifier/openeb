# Copyright (c) Prophesee S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

############################
# metavision-sdk-{modules} #
############################
include("${CMAKE_CURRENT_LIST_DIR}/MetavisionOpenCPackConfig.cmake")
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/MetavisionEssentialsCPackConfig.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/MetavisionEssentialsCPackConfig.cmake")
endif(EXISTS "${CMAKE_CURRENT_LIST_DIR}/MetavisionEssentialsCPackConfig.cmake")
foreach(available_module IN LISTS METAVISION_SDK_MODULES_AVAILABLE)
    get_filename_component(module_cpack_config "${CMAKE_CURRENT_LIST_DIR}/../modules/${available_module}/cmake/MetavisionSDK_${available_module}CPackConfig.cmake" REALPATH)
    if(EXISTS "${module_cpack_config}")
        include("${module_cpack_config}")
    endif(EXISTS "${module_cpack_config}")
endforeach(available_module)