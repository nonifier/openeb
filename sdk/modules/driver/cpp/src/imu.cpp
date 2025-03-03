/**********************************************************************************************************************
 * Copyright (c) Prophesee S.A.                                                                                       *
 *                                                                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");                                                    *
 * you may not use this file except in compliance with the License.                                                   *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0                                 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed   *
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.                      *
 * See the License for the specific language governing permissions and limitations under the License.                 *
 **********************************************************************************************************************/

#include "metavision/sdk/driver/imu.h"
#include "metavision/sdk/driver/camera_exception.h"

namespace Metavision {

Imu::~Imu() {}

CallbackId Imu::add_callback(const EventsImuCallback &cb) {
    throw CameraException(CameraErrorCode::DeprecatedFeature, "Imu not available.");
}

bool Imu::remove_callback(CallbackId callback_id) {
    throw CameraException(CameraErrorCode::DeprecatedFeature, "Imu not available.");
}

} // namespace Metavision
