#
# Copyright (C) 2018 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl

#Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service \
    android.hardware.camera.provider@2.4-impl \
    camera.device@1.0-impl \
    camera.device@3.2-impl \
    camera.device@3.3-impl \
    vendor.qti.hardware.camera.device@1.0 \
    vendor.qti.hardware.camera.device@1.0_vendor \
    android.frameworks.displayservice@1.0

#Graphics
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.memtrack@1.0-impl \
    android.hardware.graphics.mapper@2.0-impl \
    android.hardware.renderscript@1.0-impl

#Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@2.0-impl \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.broadcastradio@1.0-impl \
    android.hardware.soundtrigger@2.0-impl

#Keymaster
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-service \
    android.hardware.keymaster@3.0-impl

#Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service \
    android.hardware.gatekeeper@1.0-impl

# Vibrator
PRODUCT_PACKAGES += \
    android.hardware.vibrator@1.0-service \
    android.hardware.vibrator@1.0-impl

# Power HAL
PRODUCT_PACKAGES += \
    android.hardware.power@1.1-service-qti

# Thermal HAL
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-service \
    android.hardware.thermal@1.0-impl

#GNSS HAL
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl-qti

#USB HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#CAS
PRODUCT_PACKAGES += \
    android.hardware.cas@1.0-service

#Configstore
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.0-service

#Health
PRODUCT_PACKAGES += \
    android.hardware.health@1.0-service \
    android.hardware.health@1.0-impl

#IR
PRODUCT_PACKAGES += \
    android.hardware.ir@1.0-service \
    android.hardware.ir@1.0-impl

#Media
PRODUCT_PACKAGES += \
    android.hardware.media.omx@1.0-service \
    android.hardware.media.omx@1.0-impl

#Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl-qti

#Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    vendor.qti.hardware.wifi.supplicant@1.0 \
    vendor.qti.hardware.wifi.supplicant@1.0_vendor

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.0-impl

#Tether
PRODUCT_PACKAGES += \
    android.hardware.tetheroffload.control@1.0

#Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1-service.xiaomi_sdm660

#Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.xiaomi_sdm660
