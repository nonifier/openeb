# Copyright (c) Prophesee S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

target_sources(metavision_sdk_driver PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/antiflicker_module.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/biases.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/camera_exception.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/camera_generation.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/camera.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/cd.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/em.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/ext_trigger.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/geometry.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/illuminance.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/illuminance_module.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imu.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/imu_module.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/noise_filter_module.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/raw_data.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/roi.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/temperature.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/temperature_module.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trigger_out.cpp
)