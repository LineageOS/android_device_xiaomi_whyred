#
# vendor prop for whyred
#

# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    af.fast_track_multiplier=1 \
    audio.adm.buffering.ms=6 \
    audio.offload.min.duration.secs=30 \
    audio.offload.video=true \
    audio.deep_buffer.media=true \
    persist.vendor.audio.fluence.voicecall=true \
    persist.vendor.audio.fluence.voicerec=false  \
    persist.vendor.audio.fluence.speaker=true \
    persist.vendor.audio.hifi.int_codec=true \
    persist.vendor.audio.ras.enabled=false \
    persist.vendor.bt.a2dp_offload_cap=sbc-aac \
    persist.dirac.acs.controller=qem \
    persist.dirac.acs.storeSettings=1 \
    persist.dirac.acs.ignore_error=1 \
    ro.vendor.audio.sdk.fluencetype=fluence \
    ro.vendor.audio.sdk.ssr=false \
    ro.audio.flinger_standbytime_ms=300 \
    ro.audio.soundfx.dirac=true \
    vendor.audio.tunnel.encode=false \
    vendor.audio.offload.buffer.size.kb=64 \
    vendor.audio.offload.track.enable=false \
    vendor.voice.path.for.pcm.voip=true \
    vendor.audio.offload.multiaac.enable=true \
    vendor.audio.dolby.ds2.enabled=false \
    vendor.audio.dolby.ds2.hardbypass=false \
    vendor.audio.offload.multiple.enabled=false \
    vendor.audio.offload.passthrough=false \
    vendor.audio.offload.gapless.enabled=true \
    vendor.audio.safx.pbe.enabled=true \
    vendor.audio.parser.ip.buffer.size=262144 \
    vendor.audio.flac.sw.decoder.24bit=true \
    vendor.audio.use.sw.alac.decoder=true \
    vendor.audio.use.sw.ape.decoder=true \
    vendor.audio.hw.aac.encoder=true \
    vendor.fm.a2dp.conc.disabled=true \
    vendor.audio.noisy.broadcast.delay=600 \
    vendor.audio.offload.pstimeout.secs=3 \
    vendor.audio_hal.period_size=192

# Battery
PRODUCT_PROPERTY_OVERRIDES += \
    persist.chg.max_volt_mv=9000

# Bluetooth
PRODUCT_PROPERTY_OVERRIDES += \
    qcom.bluetooth.soc=cherokee \
    ro.bluetooth.hfp.ver=1.6 \
    bt.max.hfpclient.connections=1 \
    persist.bt.a2dp.aac_disable=true

# Camera
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.camera.aux.packagelist=org.codeaurora.snapcam,com.android.camera,com.qualcomm.qti.qmmi,org.cyanogenmod.snap \
    persist.camera.preview.ubwc=0 \
    persist.camera.stats.test=0 \
    persist.camera.depth.focus.cb=0 \
    persist.camera.isp.clock.optmz=0 \
    persist.camera.hist.high=20 \
    persist.camera.hist.drc=1.2 \
    persist.camera.linkpreview=0 \
    persist.camera.isp.turbo=1 \
    persist.camera.eis.enable=1 \
    persist.flash.low.lux=390 \
    persist.flash.light.lux=340 \
    persist.imx376_ofilm.low.lux=310 \
    persist.imx376_ofilm.light.lux=280 \
    persist.imx376_sunny.low.lux=310 \
    persist.imx376_sunny.light.lux=280 \
    persist.ov13855_sunny.low.lux=385 \
    persist.ov13855_sunny.light.lux=370 \
    persist.s5k3l8_ofilm.low.lux=379 \
    persist.s5k3l8_ofilm.light.lux=367 \
    persist.vendor.qti.telephony.vt_cam_interface=1 \
    persist.dbg.vt_avail_ovr=1 \
    vidc.enc.dcvs.extra-buff-count=2 \
    vendor.vidc.enc.disable_bframes=1 \
    vendor.vidc.dec.enable.downscalar=1 \
    vendor.vidc.enc.disable.pq=false

# CNE
PRODUCT_PROPERTY_OVERRIDES += \
    persist.cne.feature=1

# Dalvik
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

# Device Specific
PRODUCT_PROPERTY_OVERRIDES += \
    sys.autobrightness_optimize=true \
    persist.sys.ssr.restart_level=ALL_ENABLE \
    qemu.hw.mainkeys=0 \
    persist.device.type=omt \
    persist.activate_mbn.enabled=false \
    ro.regionalization.support=true

# Dirac (Xiaomi Headset Effect)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.audio.soundfx.dirac=true \
    persist.dirac.acs.controller=qem \
    persist.dirac.acs.storeSettings=1 \
    persist.dirac.acs.ignore_error=1

# Display
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.latch_unsignaled=1 \
    debug.gralloc.enable_fb_ubwc=1 \
    debug.sf.recomputecrop=0 \
    debug.sf.hw=1 \
    persist.hwc.enable_vds=1 \
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0 \
    ro.opengles.version=196610 \
    ro.sf.lcd_density=480 \
    sdm.debug.disable_skip_validate=1 \
    vendor.display.enable_default_color_mode=0

# DPM
PRODUCT_PROPERTY_OVERRIDES += \
    persist.dpm.feature=1 \
    persist.vendor.dpm.nsrm.bkg.evt=3955

# DRM
PRODUCT_PROPERTY_OVERRIDES += \
   drm.service.enabled=true

# Factory reset partition
PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/bootdevice/by-name/frp

# GPS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.overlay.izat.optin=rro

# HWUI
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hwui.texture_cache_size=88 \
    ro.hwui.layer_cache_size=58 \
    ro.hwui.path_cache_size=32 \
    ro.hwui.gradient_cache_size=1 \
    ro.hwui.drop_shadow_cache_size=6 \
    ro.hwui.r_buffer_cache_size=8 \
    ro.hwui.texture_cache_flushrate=0.4 \
    ro.hwui.text_small_cache_width=1024 \
    ro.hwui.text_small_cache_height=1024 \
    ro.hwui.text_large_cache_width=2048 \
    ro.hwui.text_large_cache_height=2048

# IMS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.dbg.volte_avail_ovr=1 \
    persist.dbg.ims_volte_enable=1 \
    persist.radio.videopause.mode=1 \
    persist.data.iwlan.enable=true \
    persist.radio.VT_HYBRID_ENABLE=1

# Media
PRODUCT_PROPERTY_OVERRIDES += \
    media.stagefright.enable-player=true \
    media.stagefright.enable-http=true \
    media.stagefright.enable-aac=true \
    media.stagefright.enable-qcp=true \
    media.stagefright.enable-scan=true \
    mmp.enable.3g2=true \
    media.aac_51_output_enabled=true \
    mm.enable.smoothstreaming=true \
    mm.enable.qcom_parser=13631471 \
    persist.mm.enable.prefetch=true \
    vidc.enc.target_support_bframe=1 \
    vendor.vidc.enc.disable_bframes=1 \
    vendor.vidc.dec.enable.downscalar=1 \
    vendor.vidc.enc.disable.pq=false \
    video.disable.ubwc=1

# Memory
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

# Netflix custom property
PRODUCT_PROPERTY_OVERRIDES += \
   ro.netflix.bsp_rev=Q660-13149-1

# NFC DT
PRODUCT_PROPERTY_OVERRIDES += \
    ro.nfc.port=I2C \
    ro.hardware.nfc_nci=nqx.default

# NTP Server
PRODUCT_PROPERTY_OVERRIDES += \
    persist.backup.ntpServer="0.pool.ntp.org" \

# Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so \
    ro.vendor.qti.sys.fw.bg_apps_limit=60 \
    sdm.debug.disable_skip_validate=1 \
    sdm.perf_hint_window=50 \
    persist.sys.perf.debug=false

# Radio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.data.netmgrd.qos.enable=true \
    persist.data.mode=concurrent \
    persist.data.wda.enable=true \
    persist.data.df.dl_mode=5 \
    persist.data.df.ul_mode=5 \
    persist.data.df.agg.dl_pkt=10 \
    persist.data.df.agg.dl_size=4096 \
    persist.data.df.mux_count=8 \
    persist.data.df.iwlan_mux=9 \
    persist.data.df.dev_name=rmnet_usb0 \
    persist.radio.multisim.config=dsds \
    persist.radio.apm_sim_not_pwdn=1 \
    persist.radio.schd.cache=3500 \
    persist.radio.atfwd.start=true \
    persist.radio.VT_CAM_INTERFACE=2 \
    persist.rmnet.data.enable=true \
    persist.data.netmgrd.qos.enable=true \
    persist.radio.multisim.config=dsds \
    persist.radio.apm_sim_not_pwdn=1 \
    persist.vendor.radio.sib16_support=1 \
    persist.vendor.radio.custom_ecc=1 \
    persist.vendor.radio.rat_on=combine \
    persist.radio.schd.cache=3500 \
    persist.sys.mcd_config_file=/system/etc/mcd_default.conf
    telephony.lteOnCdmaDevice=1 \
    ro.telephony.default_network=22,20 \
    ro.use_data_netmgrd=true \
    rild.libpath=/system/vendor/lib64/libril-qc-qmi-1.so \
    persist.rild.nitz_plmn= \
    persist.rild.nitz_long_ons_0= \
    persist.rild.nitz_long_ons_1= \
    persist.rild.nitz_long_ons_2= \
    persist.rild.nitz_long_ons_3= \
    persist.rild.nitz_short_ons_0= \
    persist.rild.nitz_short_ons_1= \
    persist.rild.nitz_short_ons_2= \
    persist.rild.nitz_short_ons_3= \
    ril.subscription.types=NV,RUIM \
    DEVICE_PROVISIONED=1 \
    persist.vendor.radio.snapshot_enabled=1 \
    persist.vendor.radio.snapshot_timer=5 \
    persist.radio.sw_mbn_update=0
    persist.radio.hw_mbn_update=0
    persist.radio.trigger.silence=true

# Security Patch Level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.security_patch=2018-05-01

# Sensors
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.sensors.facing=false \
    ro.vendor.sensors.cmc=false \
    ro.vendor.sdk.sensors.gestures=false \
    ro.vendor.sensors.dev_ori=false \
    ro.vendor.sensors.pmd=true \
    ro.vendor.sensors.sta_detect=true \
    ro.vendor.sensors.mot_detect=true

# Time daemon
PRODUCT_PROPERTY_OVERRIDES += \
    persist.timed.enable=true \
    persist.delta_time.enable=true

# USB
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config.extra=none \
    sys.usb.controller=a800000.dwc3 \
    sys.usb.rndis.func.name=rndis_bam \
    sys.usb.rmnet.func.name=rmnet_bam

# Voice assistant
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opa.eligible_device=true

# WFD
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.wfd.virtual=0
    persist.debug.wfd.enable=1

# Wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0
